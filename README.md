# Terra Nova

The digital heart of **Terra Nova**: a production-ready, accessible, multilingual
municipal platform built with **Ruby on Rails 8.1**, **Hotwire** and **ViewComponents**.

It serves three audiences:

- **Citizens** — create an account, complete onboarding, browse municipal services,
  submit requests/*signalements*, follow their progress, book appointments and contact
  the administration.
- **Municipal agents** — a dedicated `/agents` workspace to triage requests and
  appointments, manage citizen accounts, publish announcements/alerts and consult an
  audit trail.
- **Administrators** — agents with the `admin` role can perform sensitive actions such
  as granting administrator rights.

The platform also **consumes the external Webcup "Terra Nova" API**, which streams the
functional demands issued during the event, and surfaces them live in the agent
workspace where they can be triaged.

---

## Requirements

- Ruby **3.3.12**
- PostgreSQL **18.6** (or Docker)
- No Node.js toolchain required (Tailwind + daisyUI are compiled by `tailwindcss-rails`
  and JavaScript is served through importmaps)

---

## Setup

### Option A — full Docker stack (recommended)

```sh
cp .env.example .env
docker compose up --build
```

Then open <http://localhost:3000>.

### Option B — local Ruby + Dockerised PostgreSQL

```sh
docker compose up -d postgres   # starts PostgreSQL 18.6 on localhost:5432
bin/setup                       # or: bundle install && bin/rails db:prepare
bin/rails db:seed
bin/rails tailwindcss:build
bin/rails server
```

> The `pg` gem needs PostgreSQL client libraries to build locally. On macOS:
> `brew install libpq` then
> `bundle config build.pg --with-pg-config="$(brew --prefix libpq)/bin/pg_config"`.

---

## Environment variables

Copy `.env.example` to `.env` (gitignored). Every variable is optional; defaults match
`docker-compose.yml`.

| Variable | Purpose | Default |
|---|---|---|
| `POSTGRES_HOST`, `POSTGRES_PORT`, `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`, `POSTGRES_TEST_DATABASE` | Database connection | see `.env.example` |
| `WEBCUP_API_BASE_URL` | External Terra Nova API base URL | `https://24h.webcup.fr/wp-json/webcup/v1` |
| `WEBCUP_API_KEY` | API key (falls back to Rails credentials `webcup.api_key`) | — |
| `WEBCUP_POLL_INTERVAL` | Poll interval in seconds | `30` |

> The API key is **server-side only**: it is never rendered into HTML/JS. In production,
> prefer encrypted credentials (`bin/rails credentials:edit`, key `webcup.api_key`).

---

## Deploying to Heroku

The app is Heroku-ready: the `Procfile` runs `db:prepare` and `db:load_solid_schemas`
in the release phase, and `config/database.yml` production uses the platform
`DATABASE_URL` for the primary database **and** the Solid Cache/Queue/Cable components
(they share the single Heroku Postgres instance).

```sh
heroku create <app-name>
heroku addons:create heroku-postgresql:essential-0
heroku addons:create mailtrap:unpaid          # or any SMTP provider
heroku config:set RAILS_MASTER_KEY="$(cat config/master.key)" \
  WEBCUP_API_KEY=<key> \
  SOLID_QUEUE_IN_PUMA=true \
  APP_HOST=<app-name>.herokuapp.com \
  MAILER_FROM=no-reply@example.com \
  SMTP_ADDRESS=... SMTP_PORT=587 SMTP_USER_NAME=... SMTP_PASSWORD=...
git push heroku main                          # release phase migrates + loads schemas
heroku run bin/rails db:seed                  # demo data (idempotent)
```

- `SOLID_QUEUE_IN_PUMA=true` runs the job supervisor (demand sync, appointment
  reminders, mailers) inside the web dyno — no separate worker dyno required.
- Mail goes out through the `SMTP_*` variables, so any provider works (Mailtrap,
  SendGrid, Mailgun, …). `APP_HOST` is used for mailer links and host authorization.

---

## Demo accounts

Seeded by `bin/rails db:seed`:

| Role | URL | Credentials |
|---|---|---|
| Agent | `/agents/sign_in` | `agent@novaterra.fr` / `password123` |
| Agent admin | `/agents/sign_in` | `admin@novaterra.fr` / `password123` |
| Citizen | `/users/sign_in` | `citoyen@novaterra.fr` / `password123` |
| Citizen admin | `/users/sign_in` | `admin@novaterra.fr` / `password123` |

---

## External Terra Nova API integration

The API is poll-based and authenticated with the `X-Webcup-Api-Key` header.

- `TerraNova::Webcup::Client` performs the HTTP call and returns a structured result
  (distinguishing `403` from network/timeout errors).
- `Demands::Sync` upserts demands by their stable **`request_code`** (idempotent),
  records a `DemandSync` snapshot of the `session` block, and returns newly seen codes.
- `Demands::SyncJob` is scheduled ~every 30 seconds via **Solid Queue recurring tasks**
  (`config/recurring.yml`) and can also be triggered from the console.
- The agent console (`/agents/demands`) shows a live feed with filters, a session-status
  widget (current wave, next wave) and a **triage board**
  (`unseen → reviewing → planned → in progress → done/ignored`).
- New demands update the console live over Turbo Streams, and a Stimulus poller refreshes
  the panel every 30 seconds without reloading the page.

No counts or waves are hard-coded: future `D…`/`F…` demands simply appear in the feed.

---

## Features

- **Authentication & roles** — Devise (`User` + `Agent`), role separation, Pundit
  authorization, account lockout.
- **Onboarding** — profile, language and accessibility steps on first login.
- **Services catalog** — search, categories, priority highlighting, status
  (open/maintenance/closed) with alternatives, Leaflet/OpenStreetMap location, emergency
  services panel with phone numbers.
- **Requests/*signalements*** — create with optional service, location text and an
  interactive map, confirmation page + email, history, timeline and citizen co-signing.
- **Appointments** — slot browsing, booking, cancellation, agent schedule management,
  weekly availability and blocked periods, confirmation and reminder emails.
- **Announcements & alerts** — translated content, severities, audiences, geographic
  targeting, publication notifications and accessible banners.
- **Notifications** — in-app list with mark-as-read, plus emails on request status change.
- **Audit trail** — PaperTrail versions with actor (`Agent:`/`User:`) and attribute-level
  diffs, filterable from `/agents/audit_logs`.
- **Contact & transparency** — public contact form (including data-usage concerns),
  transparency and accessibility statement pages.
- **Passwordless sign-in & 2FA** — email magic-link login and TOTP two-factor
  authentication.
- **Personal data** — a clear personal-data page and a portable JSON export.
- **Security alerts** — a notification and email when a sign-in comes from a new device.
- **Requests recap** — CSV download of a citizen's request history.
- **Environmental impact** — measured weight report at `/eco` enforced by an automated
  asset budget test, plus low-data and simple modes and a dynamically imported map library.
- **Service administration** — agents manage the catalog and can disable a faulty service
  in one click (`/agents/services`).
- **Participatory democracy** — consult city projects, answer consultations with a
  traceable opinion, and propose/support citizen ideas.
- **Partner directory** — partners with opening hours, address and map (`/partners`).
- **Service reviews** — citizens rate and comment on services; agents moderate.
- **Duplicate detection** — agents see likely duplicate requests and can link them.
- **Guided start** — a “Where to start?” helper on the personal space.
- **Security monitoring** — an admin-only security-event log; sign-in by email **or**
  citizen identifier (accounts can be created without an email); Spanish locale added. Recent
  activity is summarised and unusual volumes are flagged, so protection is perceptible.
- **Resilience** — paginated lists, cached hot queries, indexed filters and a public
  `/status` page.
- **Request management** — citizens filter/sort their requests; agents rank priority
  requests in the queue. Urgent requests are surfaced first with a prominent callout, agents
  can export the exact filtered selection as CSV, and administrators can download a clear,
  verifiable backup of all requests.

---

## Internationalization

French (`fr`) is the default; English (`en`) is the fallback. The active locale is
resolved from, in order: explicit `?locale=`, the signed-in user/agent preference, the
session, then the cookie. It can be changed from the header switcher or from the profile.

**Adding a locale**

1. Add it to `config.i18n.available_locales` in `config/application.rb`.
2. Add `config/locales/<locale>.yml` (navigation, pages, mailers, models…).
3. Translate the per-locale content accessors (e.g. `name_<locale>`, `title_<locale>`) —
   the `Translatable` concern generates them automatically for every available locale.

---

## Accessibility (WCAG 2.2 AA)

- Semantic landmarks, correct `<html lang>`, skip-to-content link and a focusable `<main>`.
- Consistent, visible keyboard focus indicator and layouts that reflow down to 320px and
  high zoom.
- Forms with programmatic labels, an error summary and `aria-describedby`/`aria-invalid`.
- **High-contrast** and **large-text** modes, persisted to the profile and session and
  available from every page. Critical alerts use `role="alert"` and never rely on colour
  alone.
- Live regions for asynchronous updates, `prefers-reduced-motion` and `prefers-contrast`
  respected.

See `/accessibility` for the published statement.

---

## Running the tests

```sh
bin/rails db:test:prepare test      # unit, model, policy, service, mailer and controller tests
bin/rails test:system               # system tests (requires Chrome/chromedriver)
```

The suite covers models, Pundit policies, service objects, mailers, background jobs,
ViewComponents and critical flows (registration → onboarding, request creation and agent
handling, booking, service disable → citizen banner). System tests use the RackTest driver
so they run in CI without a browser; an asset-budget test guards the platform's weight.

Quality gates used by CI: `bin/rubocop`, `bin/brakeman`, `bin/bundler-audit` and
`bin/importmap audit`.

---

## Security

- `force_ssl` + HSTS + secure cookies in production.
- Content Security Policy with nonces (Leaflet needs OpenStreetMap tile images and
  `style-src-attr 'unsafe-inline'` for runtime positioning).
- `rack-attack` throttles sign-in (per IP and per account), password resets, request
  creation and API refreshes.
- Devise `:lockable` + `:timeoutable`, filtered parameters, Pundit scoping and
  password-confirmed account deletion.

---

## Project structure

```
app/
  components/            ViewComponents (UI design system)
  controllers/
    agents/              municipal agent workspace
    concerns/            CitizenSpace
  javascript/controllers/ Stimulus controllers (map, locale, demand poller)
  jobs/                  Demands::SyncJob, Appointments::ReminderJob
  models/                User, Agent, Demand, Service, Request, Appointment, ...
  policies/              Pundit policies
  services/              TerraNova::Webcup::Client, Demands::Sync, Appointments::AvailableSlots
  views/                 ERB + ViewComponents
config/
  locales/               fr.yml, en.yml, devise.en.yml
  recurring.yml          Solid Queue recurring tasks
```

---

## Known limitations / future improvements

- OpenStreetMap's default tiles are for development/demo; production should use a proper
  tile provider per OSM's usage policy.
- Maps are a progressive enhancement: coordinates remain usable without JavaScript.
- Reminders require the Solid Queue recurring tasks to be running.
- When the external API is unavailable, the agent console degrades to last-good data and
  displays an error banner.
- Future `D…`/`F…` demands are intentionally unknown in advance; the data-driven design
  absorbs them without a rebuild.
