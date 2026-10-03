# Nova Terra — Implementation Plan

Municipal platform for the city of **Nova Terra** (Rails app `TerraNova`).
This document is the single source of truth for scope, architecture, milestones, and
requirement traceability. It complements `README.md` (which is for setup/usage).

> **Status:** milestones **M0–M8 implemented**. The external Webcup "Terra Nova" API is
> integrated (live demand feed + triage console). 137 automated tests pass; RuboCop,
> Brakeman, bundler-audit and importmap audit are clean. See `README.md` to run it.

---

## 1. Context

We are building the digital heart of **Terra Nova**: a production-ready, accessible,
multi-language municipal platform serving citizens, municipal agents, and administrators.

The platform must also **consume the external Webcup "Terra Nova" API**, which streams the
functional demands (`D…` / `F…` codes) issued by the Haut Conseil during a 24-hour event.
The API is the *living requirements feed*; the agent workspace is where it is surfaced and
triaged. This means the architecture must be **data-driven and able to absorb new demands
without rebuilding**.

### Two concepts that must not be confused

| Concept | Model | Meaning |
|---|---|---|
| **Demand** | `Demand` | A demand broadcast by the external Webcup API (a requirement, e.g. `F52`). Identified by `request_code`. |
| **Request** | `Request` | A citizen *signalement* created inside the app (e.g. a broken streetlight). |

> French uses "demande" for both. Keep the models and UI vocabulary clearly separated.

---

## 2. Current state (verified)

- Fresh **Rails 8.1.4**, Ruby **3.3.12**, **MySQL 8.4**.
- Asset pipeline: **Propshaft + Tailwind CSS + vendored daisyUI** (no Node toolchain).
- **importmap-rails + Hotwire (Turbo + Stimulus)** already wired.
- **Minitest** with `test:system` (Capybara + Selenium); CI runs tests + Brakeman +
  RuboCop + bundler-audit.
- **Solid Cache / Solid Queue / Solid Cable** gems present (production).
- **Kamal** deploy scaffolding present.
- Empty schema (`version: 0`), only `/up` route, no domain models yet.

---

## 3. Decisions

| Topic | Decision |
|---|---|
| Test framework | **Minitest** (fixtures + system tests), keep CI as-is |
| UI composition | **ViewComponents** design system over daisyUI |
| Maps / location | **Leaflet + OpenStreetMap**, JS vendored locally, graceful degradation to plain lat/lng |
| Locale | Session + cookie + persisted user/agent profile preference (no URL prefix) |
| Build cadence | End-to-end, milestone by milestone, each ending green |
| Default locale | `fr` (fallback `en`), configurable |
| API auth | Server-side only, `X-Webcup-Api-Key` header, key in env/credentials |

### Open questions

- `D02`, `D10`, `F01–F20` were not provided. If they exist later, they simply appear in the
  API feed; the app must not assume fixed counts.
- Confirm interpretation: API `requests` are shown in the **agent workspace as a live
  monitoring/triage console**, not converted into citizen-facing content automatically.

---

## 4. Stack additions

- `devise` — authentication for `User` and `Agent`
- `pundit` — authorization
- `paper_trail` — change tracking
- `view_component` — component-driven UI
- `rack-attack` — rate limiting / brute-force protection
- `devise-i18n` — translated auth UI
- `mobility` (optional) — translatable Service/Announcement/Alert content
- `faker` (dev/test) — seed data
- HTTP client for the Webcup API: standard library `Net::HTTP` or `faraday` (decided at build)

---

## 5. Domain model

### Authentication / identity

- **`User`** (citizen account)
  - Devise: `:database_authenticatable, :registerable, :recoverable, :rememberable,
    :validatable, :trackable, :lockable, :timeoutable`
  - Fields: `role` enum (`citizen`, `admin`), `locale`, `onboarding_completed`,
    `high_contrast`, `large_text`.
  - `has_one :profile`, `has_many :requests`, `:appointments`, `:notifications`,
    `:request_supports`, `:feedbacks`.
  - **paper_trail caveat:** track updates but ignore Devise columns
    (`sign_in_count`, `current_sign_in_at`, `last_sign_in_at`, `current_sign_in_ip`,
    `last_sign_in_ip`, `failed_attempts`, `locked_at`) so logins don't spam versions.
- **`Agent`** (municipal agent / admin)
  - Devise modules as above.
  - Fields: `role` enum (`agent`, `admin`), `locale`.
  - `has_many :appointments`, `:demands` (assignee), polymorphic authorship via `RequestEvent`.

### Citizen space

- **`Profile`** — `user_id` (unique), `address`, `phone`, `postal_code`, `city`,
  preferences (json).
- **`Request`** — `user_id`, `service_id` (nullable), `subject`, `description`,
  `location_text`, `latitude`, `longitude`, `status` enum
  (`submitted, acknowledged, in_progress, resolved, closed, rejected`),
  human-readable `reference` (e.g. `NOVA-2026-0001`). **paper_trail**.
- **`RequestEvent`** — `request_id`, `from_status`, `to_status`, `comment`,
  `visible_to_citizen` bool, polymorphic `created_by`.
- **`RequestSupport`** — `request_id`, `user_id` (unique pair) — co-sign / support a request.
- **`RequestAttachment`** (optional, ActiveStorage) — photos for signalements.
- **`Appointment`** — `user_id`, `agent_id`, `service_id` (nullable), `starts_at`,
  `ends_at`, `notes`, `status` enum (`requested, confirmed, cancelled, completed, no_show`),
  `cancellation_reason`. **paper_trail**.
- **`AgentAvailability`** — `agent_id`, `wday`, `start_time`, `end_time`, `slot_minutes`, `active`.
- **`AgentTimeOff`** — blocked dates for availability.
- **`Notification`** — `user_id`, polymorphic `notifiable`, `kind`, title/body (i18n keys),
  `read_at`.
- **`Feedback`** — `user_id` (nullable), `kind` enum
  (`question, complaint, suggestion, data_concern`), `subject`, `message`, `status`
  (`new, in_review, resolved`), `reference`. **paper_trail**.
- **`GlossaryTerm`** — `term`, definition translations, optional service/context link.

### Content / city information

- **`Service`** — `name`, `description`, `category`, `priority` bool, `status` enum
  (`active, maintenance, inactive`), `address`, `latitude`, `longitude`,
  `contact_email`, `contact_phone`, `slug`, maintenance/incident message + expected return.
  Translatable name/description. **paper_trail**.
- **`Announcement`** — `title`, `body`, `severity` enum (`info, alert, critical`),
  `published_at`, `starts_at`, `ends_at`, `target_audience` enum (`all, citizens, agents`),
  `active`. Translatable. **paper_trail**.
- **`Alert`** — `title`, `body`, `kind` enum (`flood, heatwave, security, other`),
  `severity`, `starts_at`, `ends_at`, `active`, geographic targeting
  (`latitude`, `longitude`, `radius_km`, `locality`) and **target segments**
  (e.g. vulnerable residents). Translatable. **paper_trail**.
- **`TransportLine`** — `name`, `mode` (`bus, tram, metro`), `color`, description.
- **`TransportSchedule`** — `transport_line_id`, `wday`, `first_departure`, `last_departure`,
  `frequency_minutes`.
- **`TransportDisruption`** — `transport_line_id`, `message`, `severity`, `starts_at`, `ends_at`.

### Audit / security

- **`AuditLog`** — security and administrative events: polymorphic `actor`,
  polymorphic `auditable`, `action`, `metadata` json, `ip`, `user_agent`. Distinct from
  paper_trail versions.
- **PaperTrail `versions`** — content changes for `Request`, `User`, `Service`,
  `Announcement`, `Alert`, `Appointment`, `Feedback`, `Demand`.

### External Webcup API

- **`Demand`** — external demand feed, unique `request_code`.
  - Fields: `request_code`, `external_id`, `requester_name`, `requester_type`,
    `message_public`, `difficulty`, `difficulty_level`, `xp_base`, `xp_time_bonus`,
    `xp_total`, `xp_available`, `is_initial`, `visible_since_wave`, `arrival_type`,
    `wave_number`, `arrival_time`, `is_ai_related`, `is_ai_request`, `group_name`,
    `sort_order`, `first_seen_at`, `last_seen_at`, `raw_payload` json.
  - Triage: `triage_status` enum (`unseen, reviewing, planned, in_progress, done, ignored`),
    `notes`, `assignee_agent_id`.
  - **paper_trail** on triage changes.
- **`DemandSync`** — one row per poll: `fetched_at`, `success`, `http_status`, `error`,
  `status`, `is_running`, `current_wave`, `elapsed_minutes`, `visible_requests_count`,
  `initial_requests_count`, `wave_requests_count`, `next_wave_number`,
  `minutes_until_next_wave`, `raw_session` json.

---

## 6. External API integration (D19)

### Client

`TerraNova::Webcup::Client` (namespaced service object):

- `GET {WEBCUP_API_BASE_URL}/requests` (default base `https://24h.webcup.fr/wp-json/webcup/v1`).
- Auth via `X-Webcup-Api-Key` header (never query string, never browser-exposed).
- Timeouts, JSON parsing, structured result object (`success?`, `http_status`, `data`, `error`).
- Distinguishes **403 (auth)** from **network/timeout/5xx** errors; never raises into the
  request cycle.

### Configuration

- `WEBCUP_API_BASE_URL`
- `WEBCUP_API_KEY` (dev/test env; **Rails encrypted credentials in production**)
- `WEBCUP_POLL_INTERVAL` (default 30s)

The key is **server-side only**. It must never appear in HTML/JS or the repo.

### Sync

- `Demands::SyncJob`:
  - Fetch session + requests.
  - Idempotent upsert of `Demand` by `request_code`; preserve `first_seen_at`, bump
    `last_seen_at`.
  - Record a `DemandSync` row for every poll (success or failure).
  - On newly seen `request_code`s: create agent `Notification` and **broadcast a Turbo
    Stream** so the agent console updates live.
  - Safe to run repeatedly; handles 403 / network errors; failed polls keep last-good data.
- Scheduling: **Solid Queue recurring** (`config/recurring.yml`, ~30s) with a manual
  refresh endpoint and a self-rescheduling fallback.
- **No hardcoded counts or waves.** Use API-provided values only. `request_code` is the
  stable business key.

### Agent console (D19)

- `/agents/demands`: live "N new demands" banner, filters (wave, difficulty, XP, requester
  type, triage status), search, session-status widget (current wave, minutes until next
  wave, visible counts), and a **triage board** (unseen → reviewing → planned → in progress
  → done/ignored) that doubles as the competition backlog.
- Demand detail: `message_public`, XP breakdown, arrival metadata, internal notes,
  assignee.
- Live updates via Turbo Streams; manual refresh button; admin-visible banner on repeated
  API failures.

---

## 7. Authorization

- **Pundit** for policy enforcement.
- Because there are two Devise scopes, `pundit_user` is resolved per controller:
  `current_user` in the citizen space, `current_agent` under `/agents`.
- Admin capability = `user.admin? || agent&.admin?`.
- Citizens own their `Request`/`Appointment`/`Profile`; agents manage demands, requests,
  citizen accounts, announcements, alerts; admins manage global settings.

---

## 8. Routes

```ruby
root "home#index"

# Public
resources :services, only: [:index, :show]
resources :announcements, only: [:index, :show]
resources :alerts, only: [:index]
resources :transports, only: [:index]
resources :glossary, only: [:index]
resource  :feedback, only: [:new, :create]

# Citizen space
authenticate :user do
  resources :requests do
    resources :supports, only: [:create, :destroy], module: :requests
  end
  resources :appointments, only: [:index, :new, :create, :show] do
    member { patch :cancel }
  end
  resources :notifications, only: [:index, :update]
  resource  :profile,    only: [:show, :edit, :update]
  resource  :onboarding, only: [:show, :update]
  resource  :account,    only: [:show, :destroy]   # account deletion
end

# Agent workspace
namespace :agents do
  root "dashboard#index"
  resources :demands, only: [:index, :show, :update] do
    collection { post :refresh }
  end
  resources :requests, only: [:index, :show, :update]
  resources :users, only: [:index, :show, :edit, :update]
  resources :appointments do
    member { patch :cancel; patch :reschedule }
  end
  resources :availabilities
  resources :announcements
  resources :alerts
  resources :services
  resources :audit_logs, only: [:index, :show]
  resource  :settings, only: [:show, :update]
end

# Devise
devise_for :users, controllers: {
  registrations: "users/registrations",
  sessions: "users/sessions"
}
devise_for :agents, path: "agents", controllers: {
  sessions: "agents/sessions"
}
```

All `/agents` routes are protected by `authenticate :agent`.

---

## 9. UI / components (ViewComponents)

Layout & wayfinding: `AppLayout`, `HeaderNav`, `Footer`, `SkipLink`, `Breadcrumbs`,
`PageHeader`, `LocaleSwitcher`, `AccessibilityControls`.

Content: `Button`, `Card`, `AlertBanner`, `Flash`, `StatusBadge`, `EmptyState`,
`Pagination`, `FilterBar`, `DataTable`, `StatCard`.

Domain: `RequestTimeline`, `RequestStatus`, `ServiceCard`, `DemandCard`, `XpBreakdown`,
`SessionStatus`, `MapPicker` (Stimulus: `map_picker`), `DefinitionTooltip` (glossary).

Forms: `FormField`, `ErrorSummary`, `Fieldset` — with correct `label`/`aria-describedby`/
`aria-invalid` wiring.

---

## 10. Accessibility (WCAG 2.2 AA)

- Semantic landmarks (`header`/`nav`/`main`/`footer`), correct `<html lang>` and `dir`.
- Skip-to-content link; `<main id="main-content" tabindex="-1">`; focus management after
  Turbo navigation.
- Visible focus states (`focus-visible`), ≥24px targets, no keyboard traps.
- Forms: programmatic labels, error summary with links, `aria-describedby`/`aria-invalid`,
  accessible authentication (allow paste/password managers — no paste blocking).
- Live regions for async updates; critical alerts announced (`role="alert"`/`aria-live`)
  and visually distinct without relying on colour alone.
- **High-contrast mode** (`data-theme`, persisted to profile + cookie, respects
  `prefers-contrast`).
- **Large-text mode** (root font scaling; reflow validated at 320px / 400% zoom).
- Respect `prefers-reduced-motion`.
- Testing: automated axe-core pass through Selenium in system tests + manual VoiceOver
  checklist for critical flows (registration, request creation, agent demand handling).

---

## 11. Internationalization

- `available_locales = %i[fr en]`, default `fr`, fallback `en`.
- Locale files split by domain: `fr.yml`/`en.yml`, plus `devise`, `mailers`,
  `activerecord` (models/attributes), enum labels, date/time formats.
- Resolution order: request param → signed-in user/agent `locale` → session → cookie →
  default. Switcher persists to session and, when signed in, to the profile.
- Translatable content for `Service`, `Announcement`, `Alert` (mobility or JSON-backed
  translation with fallback).
- Emails and Devise messages translated (`devise-i18n`).

---

## 12. Security

- `assume_ssl` + `force_ssl` (HSTS) + secure cookies in production.
- **CSP** with nonces for importmap/JS; account for **Leaflet** (`img-src` OSM tiles
  `https://*.tile.openstreetmap.org data:`, and `style-src-attr 'unsafe-inline'` for
  Leaflet's runtime positioning), scoped narrowly and documented.
- **rack-attack**: throttle login, password reset, request creation, and API refresh.
- Devise `:lockable` + paranoid mode + `:timeoutable`.
- Strong params, Pundit scoping to prevent IDOR, filtered sensitive params.
- Password-confirmed account deletion with cascade handling.
- **Protect the Webcup API key**; log auth/security events to `AuditLog`; user-facing
  lockout / 429 notices that are clear without making normal use painful.
- Brakeman + bundler-audit + importmap audit stay clean (already in CI).

---

## 13. Testing (Minitest)

- Model tests: validations, associations, enums, scopes.
- Policy tests: citizen vs agent vs admin.
- Integration tests with Devise helpers: registration → onboarding, request creation →
  agent handling, appointment booking, demand sync idempotency.
- Mailer tests: request status change, appointment confirmation/reminder.
- System tests: critical flows + accessibility assertions (labels/roles) + axe-core pass.
- API client/job tests using a stubbed HTTP response (no live calls in CI).

---

## 14. Milestones

Each milestone ends green on `bin/rails test` and `bin/rails test:system`, with
Brakeman/RuboCop/bundler-audit clean.

- **M0 — Foundation + API ingestion**
  Gems + config (Devise/Pundit/ViewComponent/paper_trail/rack-attack, CSP/HSTS, i18n
  scaffold), base layout (skip link, breadcrumbs, locale switcher, a11y controls),
  User/Agent migrations, **Webcup client + `Demand`/`DemandSync` + `SyncJob` + agent
  demands console with live updates (D19)**.
- **M1 — Auth & accounts**
  Devise User + Agent, role separation, onboarding (D12/F35), profile, account deletion
  (F33), agents administer citizen accounts (F34), demand triage assignment.
- **M2 — City information**
  Homepage hierarchy (D07), services catalog with search/priority/status
  (D05/F28/F32/F38), emergency/health panel (F46), Leaflet maps + directions (F45),
  transports schedules/disruptions (F36), glossary (D13), translatable content (F27).
- **M3 — Requests & signalements**
  Create/list/detail + history (F25/F26), confirmation (D16), request support/co-sign
  (F52), agent queue + pending counts (F22/D17/F50-lite), event timeline (D11), status
  notifications (F49).
- **M4 — Appointments**
  Availability + booking (F39), agent schedule management, confirmation and reminder
  emails (F40) via Solid Queue recurring.
- **M5 — Announcements & alerts**
  Announcements (D06/D18/F30), alerts with geo targeting, target segments, and timing
  (F29/F31).
- **M6 — Audit & security**
  paper_trail versions + audit log views (F47/F48), security observability and protection
  (F37), activity dashboard (F50).
- **M7 — Accessibility, i18n & participation**
  Accessibility program completion (D20/F21/F41/F42/F43/F44), i18n completion (D14),
  contact/feedback + transparency + data concerns (D04/F51).
- **M8 — Hardening & deliverables**
  Seeds, README rewrite, test hardening, security/performance review, final QA.

---

## 15. Requirement traceability

Status: ✅ planned · ➕ added from the requirements list

| ID | Need | Type | Coverage | Milestone |
|---|---|---|---|---|
| D01 | Simple registration | Institution | ✅ Devise `User` | M1 |
| D03 | Login → personal space | Institution | ✅ Devise scopes, dashboard | M1 |
| D04 | Contact administration + confirmation | Institution | ✅ `Feedback` + reference/email | M7 |
| D05 | Clear services presentation | Institution | ✅ Services catalog | M2 |
| D06 | Find/read announcements | Institution | ✅ Announcements | M5 |
| D07 | Homepage hierarchy | Institution | ✅ Homepage with priority services | M2 |
| D08 | Distinguish citizen/agent/admin | Institution | ✅ Role enums | M0–M1 |
| D09 | Role-based access | Institution | ✅ Pundit + namespaces | M1 |
| D19 | Separate agent workspace reading **Nova Terra API** | Institution | ➕ API client + sync + live console | M0 |
| F22 | Agent request queue + state | Institution | ✅ Agent requests index | M3 |
| F21 | Screen-reader usability | Citoyen | ✅ A11y program | M7 |
| F23 | Contrast / important info visible | Citoyen | ✅ High-contrast mode | M7 |
| F24 | Larger text without breakage | Citoyen | ✅ Large-text mode | M7 |
| D11 | Where are my requests / steps | Citoyen | ✅ Request list + timeline | M3 |
| D12 | First-login onboarding | Institution | ✅ `/onboarding` | M1 |
| D14 | Choose another language | Citoyen | ✅ i18n + switcher | M0/M7 |
| D15 | Know where I am / go back | Citoyen | ✅ Breadcrumbs | M0 |
| D16 | Clear post-submission confirmation | Citoyen | ✅ Confirmation page + email | M3 |
| D17 | Count of pending requests | Institution | ✅ Agent dashboard counters | M3 |
| F25 | Report broken streetlight + location | Citoyen | ✅ Requests + map | M3 |
| F26 | History of past requests | Citoyen | ✅ Request history | M3 |
| F27 | Multilingual service content | Institution | ✅ Translatable content | M2 |
| F28 | Highlight priority services | Institution | ✅ `Service.priority` | M2 |
| D18 | Broadcast a general message | Institution | ✅ Announcements | M5 |
| F29 | Neighbourhood flood alert | Alerte | ✅ Alert + geo + timing | M5 |
| F30 | Notify on important announcement | Institution | ✅ Notifications + email | M5 |
| F31 | Heatwave guidance for vulnerable people | Alerte | ➕ Alert target segments | M5 |
| F32 | Find health services fast | Citoyen | ➕ Search/filter + health category | M2 |
| F33 | Delete my account safely | Institution | ✅ Password-confirmed deletion | M1 |
| F34 | Agents administer citizen accounts | Institution | ✅ `agents/users` CRUD | M1 |
| F35 | Timely onboarding hints | Citoyen | ✅ Onboarding | M1 |
| F36 | Transport schedules/info | Institution | ➕ `TransportLine` + schedules + disruptions | M2 |
| F37 | Brute-force protection, perceptible | Sécurité | ➕ Lockable + rate limit + notices + log | M6 |
| F38 | Know a service is down before starting | Citoyen | ➕ Status/maintenance banner + alternatives | M2 |
| F39 | Book an appointment unambiguously | Institution | ✅ Appointments | M4 |
| F40 | Reminder before appointment | Citoyen | ✅ Reminder mailers | M4 |
| D13 | Hard-to-understand words | Citoyen | ➕ Glossary + plain language | M2/M7 |
| D20 | Usable by all, incl. disabled | Institution | ✅ Accessibility program | M7 |
| F41 | Keyboard-only navigation | Citoyen | ✅ Keyboard a11y | M7 |
| F42 | Verify forms/errors accessible with AT | Institution | ✅ A11y audit + axe tests | M7 |
| F43 | Difficulty distinguishing colours | Citoyen | ✅ Don't rely on colour alone + contrast | M7 |
| F44 | Enlarge without breaking layout | Citoyen | ✅ Reflow/zoom validation | M7 |
| F45 | Locate physical services | Institution | ➕ Leaflet map + address + directions | M2 |
| F46 | Where are hospitals/emergency services | Citoyen | ➕ Emergency panel + map | M2 |
| F47 | Justify/trace actions over time | Institution | ✅ paper_trail | M6 |
| F48 | Who changed what | Institution | ✅ Audit log view | M6 |
| F49 | Notify when my request changes state | Citoyen | ✅ Notifications + email | M3 |
| F50 | Simple activity dashboard | Institution | ✅ Agent dashboard | M3/M6 |
| F51 | Data-usage concerns + traceable participation | Citoyen | ➕ Feedback category + transparency page | M7 |
| F52 | Support an existing request | Citoyen | ➕ `RequestSupport` | M3 |

**48/48** of the listed IDs are covered; **10** required additions (all included above).
`D02`, `D10`, and `F01–F20` were not provided; the data-driven API design absorbs them
when/if they appear.

---

## 16. Deliverables

- Complete Rails structure: models, migrations, validations, associations, controllers,
  Pundit policies, ViewComponent views, routes, seeds.
- `README.md` rewrite: setup, server start, demo citizen/agent credentials, tests, how to
  add locales, env vars (DB, mailer, Webcup API), accessibility notes, limitations.
- Notes on: how accessibility was addressed, how to extend languages, known limitations and
  future improvements.

---

## 17. Known limitations / future improvements

- OSM default tiles are for dev/demo; production needs a proper tile provider per OSM usage
  policy.
- Maps require JS; coordinate fields remain usable without it.
- Reminders depend on Solid Queue recurring jobs being run.
- The external API may be unavailable; the console degrades to last-good data with a
  visible error.
- Future `D…`/`F…` demands are not known in advance by design.
