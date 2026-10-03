# Deploying Terra Nova on cPanel (Hodifly / Passenger)

The production host for this project is a cPanel account running the app through
**Phusion Passenger** (Hodifly, glibc 2.28). This is *not* Kamal: the
`config/deploy.yml` and `.kamal/` files are generator scaffolding and are unused
in production.

- Ruby: **3.3.12** (must match `.ruby-version`)
- Database: **MySQL 8.0+**
- Web server: Apache + Passenger, document root = the app's `public/`

---

## 1. Create the database(s)

In **cPanel → MySQL® Databases**:

1. Create the database (e.g. `preskenlair_terra_nova_production`). cPanel prefixes
   names with the account name.
2. Create a MySQL user and grant it **ALL PRIVILEGES** on the database.

A single database is enough: the `cache`, `queue` and `cable` connections fall
back to the primary database (`config/database.yml`). If you prefer to split
them, create three more databases and set `MYSQL_CACHE_DATABASE`,
`MYSQL_QUEUE_DATABASE` and `MYSQL_CABLE_DATABASE` accordingly.

---

## 2. Configure the application environment

In **cPanel → Setup Ruby App**, open the app and add these environment variables
(they must be visible to Passenger, not just your shell):

| Variable | Value | Required |
|---|---|---|
| `RAILS_ENV` | `production` | yes |
| `RAILS_MASTER_KEY` | contents of `config/master.key` (`cat config/master.key`) | yes * |
| `SECRET_KEY_BASE` | any long random string (`bin/rails secret`) | yes * |
| `MYSQL_HOST` | `127.0.0.1` | yes |
| `MYSQL_DATABASE` | `preskenlair_terra_nova_production` | yes |
| `MYSQL_USER` | the cPanel MySQL user | yes |
| `MYSQL_PASSWORD` | that user's password | yes |
| `MYSQL_CACHE_DATABASE` / `MYSQL_QUEUE_DATABASE` / `MYSQL_CABLE_DATABASE` | defaults to `MYSQL_DATABASE` | no |
| `WEBCUP_API_KEY` | Terra Nova API key | no (feature degrades) |
| `WEBCUP_API_BASE_URL` | `https://24h.webcup.fr/wp-json/webcup/v1` | no |
| `RAILS_SERVE_STATIC_FILES` | `true` | no ** |

\* At least one of `RAILS_MASTER_KEY` / `SECRET_KEY_BASE` is required. If you set
`SECRET_KEY_BASE`, the app boots even without the master key; the encrypted
credentials then simply cannot be read and the Webcup API is disabled. Prefer
setting `RAILS_MASTER_KEY` so encrypted credentials (SMTP, API key) work.

\** Passenger serves `public/` directly, so this is normally unnecessary.

---

## 3. Install gems, migrate and precompile

Open **cPanel → Terminal** (or SSH) and run from the application root:

```sh
cd ~/apps/terra_nova            # adjust to your app root

# Make sure the host Bundler is at least the version in Gemfile.lock
bundler -v
gem install bundler -v 4.0.22   # only if `bundler -v` is older

bundle install

RAILS_ENV=production bundle exec rails db:prepare
RAILS_ENV=production bundle exec rails assets:precompile

# Tell Passenger to restart the app
mkdir -p tmp && touch tmp/restart.txt
```

> On glibc 2.28 hosts Bundler resolves native gems as plain `ruby`, and no
> standalone `tailwindcss` binary exists. `lib/tasks/tailwindcss_deploy.rake`
> detects this and serves the committed `app/assets/builds/tailwind.css` instead
> of aborting the precompile. After changing styles, run
> `bin/rails tailwindcss:build` locally and commit the regenerated file.

---

## 4. Troubleshooting a 500

Apache's default **"Internal Server Error … Additionally, a 500 … while trying to
use an ErrorDocument"** page means the Rails app **failed to boot**; the real
error is hidden. Reproduce it by hand:

```sh
cd ~/apps/terra_nova
RAILS_ENV=production bundle exec ruby -e 'require "./config/environment"; puts "BOOT OK"'
```

That prints the exception Apache swallowed. Then check the Passenger log:

```sh
tail -50 ~/logs/*.log
tail -50 ~/apps/terra_nova/stderr.log
```

Common causes and fixes:

| Symptom in the boot output | Fix |
|---|---|
| `ActiveSupport::MessageEncryptor::InvalidMessage` / `Missing encryption key` | `RAILS_MASTER_KEY` is missing or wrong. Set it (or `SECRET_KEY_BASE`). The `webcup.rb` initializer is hardened against this, but Devise/session still need a key. |
| `Bundler::GemNotFound` / `Could not find …` | Gems not installed for this host — run `bundle install`. Match `BUNDLED WITH` from `Gemfile.lock`. |
| `Mysql2::Error::ConnectionError` / access denied | Wrong `MYSQL_*` variables, or the DB user lacks privileges. |
| `ActiveRecord::NoDatabaseError` | Database not created, or `MYSQL_DATABASE` name doesn't include the cPanel prefix. |
| `ActiveRecord::StatementInvalid … doesn't exist` (at runtime) | Migrations not run — `RAILS_ENV=production bundle exec rails db:prepare`. |
| Assets return 404 | Run `RAILS_ENV=production bundle exec rails assets:precompile`. |

After any change, restart Passenger:

```sh
touch tmp/restart.txt
```
