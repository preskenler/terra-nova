# terra_nova

Rails 8 application backed by MySQL 8.4.

## Requirements

* Ruby 3.3.12
* MySQL 8.0+ (or Docker)

## Setup

```sh
bin/setup
bin/rails db:prepare
```

## Running with Docker (development)

`docker-compose.yml` starts MySQL 8.4.11 and the Rails app with your source
directory mounted for live reloading:

```sh
docker compose up --build
```

Then open <http://localhost:3000>.

Useful commands:

```sh
# Rails console / runner inside the container
docker compose exec web bin/rails console
docker compose exec web bin/rails db:migrate

# Run the test suite
docker compose exec web bin/rails test

# Stop the stack (keeps the MySQL volume)
docker compose down

# Stop and delete the MySQL volume (fresh database next start)
docker compose down -v
```

Configuration is read from the `MYSQL_*` environment variables. Copy
`.env.example` to `.env` to override the defaults (for example if port 3306 is
already in use, set `MYSQL_HOST_PORT=3307`).

### Troubleshooting

If the app cannot authenticate against MySQL 8.4 (`caching_sha2_password`), add
the following to the `db` service and recreate it:

```yaml
    command: --mysql-native-password=ON
```

## Tests

```sh
bin/rails db:test:prepare test
```

## Deployment

Deployment is handled with [Kamal](https://kamal-deploy.org); see
`config/deploy.yml` and `.kamal/`.
