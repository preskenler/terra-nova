# Terra Nova — Team Report

Municipal platform for the city of Terra Nova, built with **Ruby on Rails 8.1**,
**Hotwire** (Turbo + Stimulus) and **ViewComponents**.

This document answers the jury's declaration form for every demand currently
broadcast by the Terra Nova API: what the team built, where to test it, and how to
verify it.

---

## How to run and where to test

Start the application:

```sh
docker compose up -d postgres
bin/rails db:prepare db:seed
bin/rails server
```

Then open <http://localhost:3000>.

Demo accounts (all passwords are `password123`):

| Role | Sign-in URL | Credentials |
| --- | --- | --- |
| Citizen | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` | `citoyen@novaterra.fr` |
| Agent | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/sign_in` | `agent@novaterra.fr` |
| Agent admin | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/sign_in` | `admin@novaterra.fr` |
| Citizen admin | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` | `admin@novaterra.fr` |

The external Terra Nova API key must be configured (`WEBCUP_API_KEY`) for the agent
demand feed (`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/demands`) to populate.

> The live application is deployed at
> <https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/>. The test links below
> are absolute URLs pointing to it.

---

# Implemented demands

## D01 · Easy · 250 XP — Create an account

**What we built.** A complete citizen sign-up flow with Devise
(`:database_authenticatable`, `:registerable`, `:validatable`): unique email,
password validation (minimum 8 characters), automatic `Profile` creation, then a
redirect to onboarding and finally to the personal space. Forms are labelled,
translated (FR/EN) and accessible, with clear error messages.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_up`

**How to verify.**

1. Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_up` and submit an email that already exists → a readable error is shown.
2. Create a valid account (email + password) → you are redirected to `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding`.
3. Complete onboarding (profile, language, accessibility) → you land on `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`.
4. Sign out, then sign back in with the same credentials → you return to your personal space.

---

## D03 · Easy · 250 XP — Sign in to a personal space

**What we built.** Devise login for citizens; the personal space `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` aggregates
the profile and activity (requests, appointments, unread notifications). The session
persists across visits.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`

**How to verify.** Sign in with `citoyen@novaterra.fr` / `password123` → you are
redirected to `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`, which shows your information and activity.

---

## D04 · Easy · 250 XP — Contact the administration

**What we built.** A public contact form for questions, complaints, suggestions or
data concerns. It works signed-in or anonymously (an email is required when anonymous),
generates a tracked reference (`MSG-…`) and confirms the submission. Agents handle the
messages in their workspace.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new` → agent side: `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks`

**How to verify.** 1) Submit a message → a confirmation with a reference is displayed.
2) Sign in as an agent → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks` lists the message. 3) Change its status →
the linked citizen is notified.

---

## D05 · Easy · 250 XP — Present municipal services

**What we built.** A services catalog with categories, descriptions, contacts and
priority highlighting; 12 services are seeded.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**How to verify.** Browse the list, search “civil”, open a service → description,
contact details and a map are shown.

---

## D06 · Easy · 250 XP — Find and read announcements

**What we built.** A public announcements index and detail pages; only published and
active announcements are visible.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/announcements`

**How to verify.** The seeded announcements are listed; open one to read the full body.

---

## D07 · Medium · 500 XP — Clear homepage

**What we built.** A homepage with a hero section, active alerts, emergency contacts,
priority services and the latest news, giving direct access to the main services.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`

**How to verify.** The priority services are surfaced first and a prominent link leads
to `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`.

---

## D08 · Medium · 500 XP — Distinguish citizen / agent / admin

**What we built.** Two Devise scopes (`User` and `Agent`) with `role` enums
(`citizen` / `agent` / `admin`) and a separate `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` workspace with its own
navigation and sign-in.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` versus `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`

**How to verify.** The agent workspace is visually and functionally distinct from the
citizen space and requires an agent account.

---

## D09 · Medium · 500 XP — Role-based access

**What we built.** Pundit policies plus route constraints; citizens cannot reach the
agent workspace or perform sensitive actions.

**Where to test.** Sign in as a citizen, then open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**How to verify.** You are redirected to the agent sign-in; agent-only pages are
inaccessible to citizens.

---

## D11 · Medium · 540 XP — Track request status and steps

**What we built.** A citizen request list with status, and a per-request event timeline
showing the steps already completed.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests` → open a request

**How to verify.** The status badge and the “Progress” timeline of events are displayed.

---

## D12 · Medium · 540 XP — First-login onboarding

**What we built.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding` guides the citizen through profile completion, language
selection and accessibility settings. First-time citizens are redirected there
automatically and land in `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` when finished.

**Where to test.** Create a new account → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding`

**How to verify.** Complete the guided steps → onboarding is marked complete and you
reach your personal space.

---

## D13 · Easy · 310 XP — Understand difficult words

**What we built.** A plain-language glossary explaining terms used across the platform.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/glossary`

**How to verify.** Seeded terms (“Signalement”, “Démarche”, …) are explained simply.

---

## D14 · Medium · 540 XP — Choose another language

**What we built.** A French/English interface with a header switcher and a profile
setting; the choice is persisted to the account.

**Where to test.** Header language selector, or `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/edit`

**How to verify.** Switch to English → navigation and pages update; reload the page →
the choice persists.

---

## D15 · Easy · 270 XP — Know where you are

**What we built.** Accessible breadcrumb navigation (with an “aria-label”) on all key
pages, showing the path back to the previous levels.

**Where to test.** Any inner page, e.g. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**How to verify.** The breadcrumb shows Home / Services / page and links back.

---

## D16 · Easy · 270 XP — Confirmation after sending

**What we built.** Submitting a request shows a confirmation message with its reference,
opens the request page (which includes the reference and a timeline) and queues a
confirmation email.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new` → submit

**How to verify.** 1) You are redirected to the new request with a success message.
2) The request appears in `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`. 3) The email is queued (asserted by the test
suite; configure SMTP or a preview tool such as Letter Opener to read it).

---

## D17 · Easy · 270 XP — Count of pending requests

**What we built.** The agent dashboard and the request list display how many requests
still need action.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**How to verify.** “Pending requests” counters and per-status statistics are visible.

---

## D18 · Difficult · 840 XP — Broadcast a general message

**What we built.** Agents publish announcements (severity, audience, publication window);
published announcements appear on the homepage and the news page.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` → New

**How to verify.** Create an announcement → it appears at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/announcements`.

---

## D19 · Difficult · 750 XP — Agent workspace reading the Terra Nova API

**What we built.** A server-side client for the Webcup API (authenticated with the
`X-Webcup-Api-Key` header), idempotent synchronisation keyed on `request_code`, polling
roughly every 30 seconds via Solid Queue, and a live console with session status,
filters and a triage board (`unseen → reviewing → planned → in progress → done/ignored`).

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/demands`

**How to verify.** 1) The feed lists the current demands with XP and difficulty.
2) “Refresh now” updates it; it also auto-refreshes every 30 seconds. 3) Change a
demand’s triage status → it persists.

---

## D20 · Difficult · 930 XP — Usable by everyone (accessibility)

**What we built.** A WCAG 2.2 AA accessibility program: semantic landmarks, skip-to-content
link, visible keyboard focus, labelled forms with error summaries, high-contrast and
large-text modes, reduced-motion support and live regions for alerts.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility` and the header “Accessibility” menu

**How to verify.** Toggle high contrast / large text; navigate with the keyboard only;
the accessibility statement lists every supported feature.

---

## F21 · Medium · 520 XP — Screen-reader usability

**What we built.** Semantic HTML, correct `lang` attribute, landmark roles, labelled
controls, `aria-current` breadcrumbs and `role="alert"` / live regions for alerts.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility` and any form (e.g. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new`)

**How to verify.** With VoiceOver/NVDA, headings, labels and errors are announced
correctly, and the skip link jumps to the main content.

---

## F22 · Easy · 250 XP — Agent request queue with states

**What we built.** An agent list of citizen requests with status badges, filters and
pending counts, so agents can quickly see what still needs action.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**How to verify.** Filter by status and open a request to see its state and details.

---

## F23 · Medium · 520 XP — Contrast / readability

**What we built.** A high-contrast mode (persisted) and colour choices that never rely
on colour alone to convey meaning.

**Where to test.** Header “Accessibility” menu

**How to verify.** Enable “High contrast” → the interface switches to high-contrast
colours and the choice persists.

---

## F24 · Easy · 260 XP — Larger text

**What we built.** A large-text mode that scales the root font size; layouts reflow
without breaking.

**Where to test.** Header “Accessibility” menu

**How to verify.** Enable “Large text” → text grows and the layout remains usable; the
choice persists.

---

## F25 · Medium · 540 XP — Report a broken streetlight with location

**What we built.** A report form with an optional service, a description, location text
and an interactive map picker to place the exact spot.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**How to verify.** Fill in the problem, click the map to place the marker (coordinates
fill the form), submit → the request is created and tracked.

---

## F26 · Easy · 270 XP — History of past requests

**What we built.** A personal history of requests with their status and dates.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**How to verify.** All previously created requests are listed and can be opened.

---

## F27 · Medium · 540 XP — Multilingual service content

**What we built.** Service names and descriptions are stored per locale and follow the
selected interface language.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` after switching the interface to English

**How to verify.** Service names/descriptions display in English; switch back to French.

---

## F28 · Easy · 270 XP — Highlight priority services

**What we built.** A `priority` flag on services, surfaced in a dedicated “Priority
services” section on the homepage and catalog.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**How to verify.** Priority services appear in a dedicated section with a “Priority” badge.

---

## F29 · Difficult · 840 XP — Neighbourhood flood alert

**What we built.** Alerts with a kind (flood / heatwave / security / other), a severity,
an area and a schedule; they are shown as prominent banners and announced to screen
readers.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**How to verify.** The seeded “flood — south district” alert is displayed prominently on
the homepage.

---

## F30 · Medium · 560 XP — Notify on important announcement

**What we built.** Publishing an announcement notifies every citizen in-app (and queues
an email), so nobody misses important information.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` → New; then `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications`

**How to verify.** After publishing, the notification appears in the citizen’s
notification list.

---

## F31 · Difficult · 840 XP — Heatwave guidance for vulnerable people

**What we built.** Alerts carry a target segment (e.g. “vulnerable people”) and
recommendations, and are displayed as a distinct warning banner.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**How to verify.** The seeded heatwave alert with its recommendations is visible.

---

## F32 · Easy · 280 XP — Find health services quickly

**What we built.** Search and category filters, a dedicated “Health” service and an
emergency panel so urgent needs are found immediately.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services?q=santé`

**How to verify.** The Health service is returned, and the emergency panel is displayed
alongside the results.

---

## F33 · Easy · 290 XP — Delete my account safely

**What we built.** Account deletion protected by password confirmation, so an
unauthorized person with an open session cannot delete the account.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account`

**How to verify.** 1) Enter a wrong password → an error is shown and the account is
kept. 2) Enter the correct password → the account is deleted and you are redirected
home. (Use a throwaway account.)

---

## F34 · Medium · 580 XP — Agents administer citizen accounts

**What we built.** Agent management of citizen accounts: list, search, view, edit
(language, onboarding), role change (administrators only) and account unlock.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users`

**How to verify.** Search a citizen and open the record; edit fields; an administrator
can change the role and unlock a locked account.

---

## F35 · Easy · 290 XP — Onboarding guidance

**What we built.** The onboarding page guides the new inhabitant step by step through
profile completion, language, accessibility and a short tour.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding` (with a new account)

**How to verify.** The four guided steps are presented clearly with short hints.

---

## F36 · Medium · 580 XP — Transport schedules and info

**What we built.** Transport lines with their mode, per-weekday schedules and active
disruptions, all in one screen.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/transports`

**How to verify.** Seeded lines show their timetables, and an active disruption is
flagged on one line.

---

## F37 · Difficult · 900 XP — Brute-force protection

**What we built.** `rack-attack` throttling on sign-in (per IP and per account),
password resets and sensitive endpoints; Devise `:lockable` for account lockout; agents
can unlock accounts.

**Where to test.** Repeated failed sign-ins at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in`

**How to verify.** After several rapid attempts you receive **HTTP 429 (Too Many
Requests)**; sustained failures lock the account, which an agent can unlock at
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users/:id`.

---

## F38 · Medium · 600 XP — Service under maintenance

**What we built.** Services have a status (`active` / `maintenance` / `inactive`).
A service under maintenance shows a banner with a message and expected return; inactive
services are hidden from the public catalog.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/eau-assainissement`

**How to verify.** A maintenance banner with the message and the expected return is
displayed.

---

## F39 · Medium · 600 XP — Book an appointment

**What we built.** Citizens choose an agent and a date, see computed available slots and
confirm; booking sends a confirmation and an in-app notification. Cancellation is
supported, and agents manage their schedule and availability.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/appointments/new`

**How to verify.** 1) Pick an agent and a date → available slots appear. 2) Choose a slot
→ confirm → the appointment page shows a success message. 3) The appointment appears in
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/appointments`.

---

## F40 · Easy · 300 XP — Reminder before an appointment

**What we built.** `Appointments::ReminderJob` emails confirmed appointments roughly 24
hours ahead; it is scheduled through Solid Queue recurring tasks.

**Where to test.** Create an appointment ~24 hours ahead, then run
`bin/rails runner 'Appointments::ReminderJob.new.perform'`

**How to verify.** A reminder is queued/sent exactly once (never twice); this is covered
by the test suite.

---

## F41 · Medium · 620 XP — Keyboard-only navigation

**What we built.** A skip-to-content link, logical focus order, a visible focus
indicator and no keyboard traps.

**Where to test.** Any page, using only Tab/Shift+Tab

**How to verify.** You can reach the header, navigation, forms and content, and the
focus indicator is always visible.

---

## F42 · Difficult · 930 XP — Accessible forms and errors

**What we built.** Programmatic labels, an error summary with links, and
`aria-describedby` / `aria-invalid` wiring. Authentication fields allow pasting and
password managers.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new` → submit the empty form

**How to verify.** An error summary appears; fields are marked invalid and associated
with their messages for assistive technologies.

---

## F43 · Easy · 310 XP — Colour blindness

**What we built.** Status is never conveyed by colour alone — every coloured badge
carries a readable label — and a high-contrast mode is available.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**How to verify.** Every coloured badge displays a text label.

---

## F44 · Medium · 620 XP — Enlarge without breaking layout

**What we built.** Responsive layouts that reflow, plus a large-text mode; content stays
usable at narrow widths and high zoom.

**Where to test.** Browser zoom at 200–400% on `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**How to verify.** Content reflows into a single column without overlap or loss of
information.

---

## F45 · Difficult · 960 XP — Locate physical services

**What we built.** A Leaflet/OpenStreetMap map on service pages with the address and an
“Open in OpenStreetMap” link, plus a text alternative for assistive technologies.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**How to verify.** A map with a marker and the address is displayed; the OpenStreetMap
link opens the location.

---

## F46 · Easy · 320 XP — Hospitals and emergency services

**What we built.** Emergency services (call 112) are surfaced in a dedicated panel on
the homepage and the catalog, with telephone number and address.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` (emergency panel) and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/urgences`

**How to verify.** The emergency panel and the “Emergency services” detail page display
the number and the location.

---

## F47 · Difficult · 960 XP — Justify and trace actions

**What we built.** PaperTrail records changes on the key models with the acting user and
a timestamp, and an agent-facing audit log page makes it consultable over time.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs`

**How to verify.** Past changes are listed with who did them and when.

---

## F48 · Medium · 640 XP — Who modified what

**What we built.** Each audit entry shows the actor (`Agent:` / `User:`) and an
attribute-level before/after diff of the change.

**Where to test.** As an agent, change a request status → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs` → open the
entry

**How to verify.** The diff shows the changed field with its before and after values.

---

## F49 · Easy · 330 XP — Notify when my request changes state

**What we built.** When an agent changes the status of a request, an in-app notification
is created (and a status email is queued).

**Where to test.** As an agent, update a request at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference`; then
visit `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications`

**How to verify.** The citizen receives a notification describing the new status.

---

## F50 · Difficult · 990 XP — Activity dashboard

**What we built.** An agent dashboard showing platform activity (citizens, requests,
pending requests, upcoming appointments) alongside the Terra Nova API feed statistics
and recent items.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents`

**How to verify.** The statistics cards and the recent-activity lists are displayed.

---

## F51 · Difficult · 990 XP — Data-usage concerns, traceable

**What we built.** A transparency page explaining how data is used and citizens’ rights,
a dedicated “data concern” contact kind, and a tracked reference so the citizen knows
the contribution was received. Agents handle these messages in their workspace.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/transparency` → “Report a data concern”

**How to verify.** Submit a concern → a confirmation with a reference is displayed; the
message appears in `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks`.

---

## F52 · Medium · 660 XP — Support an existing request

**What we built.** Citizens can co-sign another citizen’s request; the support count is
tracked, displayed, and can be withdrawn.

**Where to test.** Open a request (e.g. from `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`) → “Support this request”

**How to verify.** Clicking records your support and the counter increases; you can
withdraw your support.

---

# Additional demands (later API waves) — implemented

These demands appeared in later API waves. They are now implemented as well.

## D02 · Difficult · 1020 XP — Sign in without a classic password

**What we built.** Passwordless sign-in with email magic links. The link is signed,
single-use and valid for 15 minutes; consuming it rotates a per-user nonce so it cannot
be replayed. The request response is deliberately generic to avoid revealing whether an
email exists, and the endpoint is rate-limited. The second factor still applies when
enabled.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/magic_link` (link “Sign in without a password” in the header)

**How to verify.** 1) Enter `citoyen@novaterra.fr` → a generic “link sent” message.
2) Open the emailed link (configure SMTP or a mail preview to read it) → you are signed
in. 3) Open the same link again → it is rejected (single use). 4) Enter an unknown email
→ the same generic message. Covered by automated tests.

---

## F53 · Difficult · 1020 XP — Additional verification (two-factor authentication)

**What we built.** TOTP two-factor authentication via an authenticator app. Citizens
enrol from their profile (QR code + manual secret), confirm with a 6-digit code, and the
account is then gated by a verification challenge after every password or magic-link
sign-in. It can be disabled from the same page.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/two_factor`

**How to verify.** 1) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/two_factor` and scan the QR code with an
authenticator app. 2) Enter the current 6-digit code → enabling is confirmed.
3) Sign out and sign in with your password → you are redirected to `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/two_factor`.
4) Enter the code → access is granted. 5) Disable it from the same page.

---

## F54 · Medium · 680 XP — Alert on sign-in from a new device

**What we built.** Each sign-in is recorded with its IP address and a device fingerprint.
A sign-in from a device never seen before creates an in-app notification and a security
email. Recent sign-ins are listed in the personal data page.

**Where to test.** New-device notification at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications`; history at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data`

**How to verify.** 1) Sign in normally, then sign in again from a different browser
(different user agent). 2) A “New sign-in detected” notification appears, and a security
email is queued. 3) Signing in twice from the same device does not alert again.

---

## F55 · Difficult · 1020 XP — Retrieve my personal data

**What we built.** A personal data page giving a clear, structured summary (account
settings, two-factor status, registration date, activity counts and recent sign-ins),
plus a portable JSON export covering the account, profile, requests with their steps,
appointments, notifications, messages and supports.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data` → “Download my data (JSON)”

**How to verify.** 1) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data` → a readable summary is displayed.
2) Click the download button → a structured JSON file is returned. 3) Check it reflects
your real requests and appointments.

---

## F56 · Medium · 680 XP — Download a recap of my requests

**What we built.** A CSV export of the citizen’s request history: reference, submission
date, subject, status, service, location, number of steps, supporters and last update —
ready to open in a spreadsheet.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests` → “Download (CSV)”, or directly `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests.csv`

**How to verify.** 1) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`. 2) Click “Download (CSV)” → a data file is
downloaded. 3) Check the rows match your requests and their statuses.

---

## F57 · Medium · 700 XP — Environmental performance diagnosis

**What we built.** An `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` page reporting the measured size of the application’s own
stylesheets and JavaScript against explicit budgets, together with the design choices
that reduce the footprint. The Leaflet map library is now imported dynamically, so its
weight is only paid on pages that actually display a map.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`

**How to verify.** Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` → measured weights and budgets are shown. Then open a
page without a map and check the browser Network tab: `leaflet.js` is not downloaded.

---

## F58 · Difficult · 1050 XP — Durable reduction of the digital impact

**What we built.** Systematic lightweight choices across the key journeys: no SPA
framework (server-rendered Hotwire), no external web fonts or trackers, dynamic import of
the map library, and an **automated asset-size budget** enforced by the test suite so the
weight cannot regress unnoticed.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`; test `test/performance/asset_budget_test.rb`

**How to verify.** 1) Run `bin/rails test test/performance/asset_budget_test.rb` → it
passes and fails if the CSS/JS budgets are exceeded. 2) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` documents the policy and
current numbers.

---

## F59 · Medium · 700 XP — Works on slow connections

**What we built.** A **low-data mode** preference, persisted to the profile and session,
that disables maps (no tile requests) and other heavy optional resources. Pages are
server-rendered, so content remains available and readable without JavaScript.

**Where to test.** Header “Accessibility” menu → “Low data mode”

**How to verify.** 1) Enable “Low data mode”. 2) Open a service with a location → the map
is not loaded and a note is displayed instead. 3) In the Network tab, confirm no tile
requests are made.

---

## F60 · Easy · 350 XP — Lightweight images and media

**What we built.** No external fonts or heavy media; the 2FA QR code is an inline data
URI; map tiles are only requested when a map is actually shown (and never in low-data
mode). The media choices and budgets are documented at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` and any page’s Network tab

**How to verify.** 1) Browse the main pages → no large media are loaded.
2) Enable low-data mode → no tile requests. 3) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` describes the media choices.

---

## F61 · Difficult · 1080 XP — Fast even on low-powered devices

**What we built.** Pages stay light by default: the Leaflet JavaScript library is no
longer module-preloaded on every page (it is imported dynamically and fetched only where
a map is actually rendered), and the Leaflet stylesheet was moved out of the global
bundle so it is loaded only on map pages. Pages are server-rendered with no SPA
framework, `prefers-reduced-motion` is respected, and an automated asset-budget test
protects the weight from regressions.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` (no map library), a map page `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`, and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`

**How to verify.** 1) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` and check the browser Network tab → `leaflet.js` is not
preloaded. 2) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil` → the map library loads only there.
3) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` → measured weights are within budget; run
`bin/rails test test/performance/asset_budget_test.rb` → passes.

---

## F62 · Medium · 720 XP — A simpler, faster version of pages

**What we built.** A persisted **“Simple mode”** preference that renders lighter, faster
versions of the key pages: the homepage drops decorative blocks, the services catalog
drops the priority highlight, and maps are not loaded — while all essential information
and actions remain available.

**Where to test.** Accessibility menu → “Simple mode”; then `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**How to verify.** 1) Enable “Simple mode” from the header Accessibility menu.
2) The homepage no longer shows the “What you can do” and news blocks.
3) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` no longer shows the priority section and loads no map, but search and the
full list remain.

---

## F63 · Difficult · 1080 XP — Quickly disable a faulty service

**What we built.** A service management area in the agent workspace (`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`)
with a **one-click “Disable”** that immediately puts a service under maintenance, a
one-click “Enable” to restore it, and an edit form for the maintenance message (FR/EN),
expected return and contacts. Changes are recorded in the audit trail.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`

**How to verify.** 1) Sign in as an agent and open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`.
2) Click “Disable” on a service → it becomes “Under maintenance”, and the citizen side
(`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`) immediately shows the maintenance banner.
3) Click “Enable” to restore it.

---

## F64 · Easy · 360 XP — See a service’s status before starting

**What we built.** Every service card now carries a status badge (Open / Under
maintenance / Closed), the service page shows the status prominently with the maintenance
banner, and the request form displays a live warning when an unavailable service is
selected — so citizens know before starting and know what to do next.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`, a service page (e.g. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/eau-assainissement`), and
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**How to verify.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` shows an Open / Under maintenance / Closed badge on each
card. 2) Open a maintenance service → a banner with the message and expected return is
shown. 3) In `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`, select a maintenance service → a warning appears before you
submit.

---

## F65 · Difficult · 1110 XP — Put decisions to residents' opinion

**What we built.** Consultations (attached to a project, with a kind: opinion, poll or
decision) that citizens can answer. Each answer is recorded with a **traceable reference**
and a confirmation notification, and agents can view the aggregated results — so the city
can justify the participation and the citizen knows the contribution was received.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/consultations/:id` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/consultations`

**How to verify.** 1) Open a consultation from a project page. 2) Submit your opinion →
the confirmation shows a reference. 3) As an agent, open the consultation → the results
and the list of responses are displayed.

---

## F66 · Medium · 740 XP — Give an opinion without a formal vote

**What we built.** A simple answer form on each consultation (Favourable / Unfavourable /
No opinion + optional comment). One answer per citizen, recorded instantly, with a
reference and a confirmation so nothing is ambiguous.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/consultations/:id`

**How to verify.** 1) Sign in and open a consultation → choose an option and submit.
2) A confirmation with a reference is displayed. 3) Re-open the consultation → your
recorded answer and reference are shown.

---

## F67 · Medium · 740 XP — Consult the city's ongoing projects

**What we built.** A public projects area: an index that highlights **ongoing** projects
and a detail page per project, listing its consultations, timeline and category.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects/:slug`

**How to verify.** 1) Open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects` → ongoing projects appear in a dedicated section.
2) Open a project → its description, dates, category and related consultations are shown.

---

## F68 · Easy · 370 XP — Propose ideas for the colony

**What we built.** Citizens can propose an idea (category, title, description) — recorded
with a reference and a confirmation notification — support others' ideas (co-sign), and
agents can **moderate** ideas (submitted → under review → accepted/declined) with the
author notified.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas/:reference` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/ideas`

**How to verify.** 1) Propose an idea → confirmation with a reference. 2) Open another
citizen's idea → support it (the counter increases). 3) As an agent, open `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/ideas`,
change the status → the author is notified.

---

## F69 · Expert · 1520 XP — Protect sensitive data; perceptible protection

**What we built.** A `SecurityEvent` log records authentication and account-security
activity (sign-in, failed sign-in, two-factor enabled/disabled, account unlocked), surfaced
in an **administrator-only** monitoring page. This complements the existing protections
(2FA, passwordless links, account lockout, rack-attack throttling, CSP/HSTS, filtered
parameters).

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events` (administrator account)

**How to verify.** 1) Sign in and make a failed sign-in → events appear in the list.
2) A regular agent cannot open the page (redirected). 3) An administrator can.

---

## F70 · Difficult · 1140 XP — Administrative data strictly restricted

**What we built.** The audit trail and the security events are now **administrator-only**
(enforced by Pundit), and role changes remain administrator-only. Operational data stays
available to regular agents.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**How to verify.** 1) Sign in as a regular agent → access is denied (redirect + message).
2) Sign in as an administrator → access is granted.

---

## F71 · Difficult · 1140 XP — Newcomers without email, in several languages

**What we built.** Sign-in by **email or citizen identifier** (`TN-XXXXXX`). Agents can
create an account **without an email address**: the system generates a placeholder email,
a citizen identifier and a temporary password, shown once for handover. A third locale
(Spanish) was added to demonstrate easy language extension.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users/new`, then `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in`, and the language switcher

**How to verify.** 1) As an agent, create an account leaving the email blank → credentials
are displayed. 2) Sign in with the **identifier** and the temporary password.
3) Switch the interface to Español.

---

## F72 · Easy · 380 XP — A starting point without redoing registration

**What we built.** A “Where to start?” helper on the personal space: pick a situation
(moving in, waste, streetlight, health, transport, permits, water) → suggested services and
a one-click pre-filled request. No new registration step.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` (guidance section)

**How to verify.** 1) Choose “Health and emergencies” → suggested services appear.
2) Choose “A broken streetlight” → “Start a request” opens a pre-filled form.

---

## F73 · Medium · 780 XP — Official message visible by everyone, immediately

**What we built.** Announcements can be **pinned**, which renders them as a **site-wide
banner on every page** (citizen and agent layouts), in addition to the news page.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` (pin) → any page

**How to verify.** 1) Create or edit an announcement and tick “Pin as a site-wide banner”.
2) Open any page (e.g. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/glossary`) → the message appears at the top.

---

## F74 · Easy · 390 XP — Partner opening hours and location

**What we built.** A **partner directory** with a detail page showing the address, a
Leaflet map and the seven-day opening hours, plus agent management (including a bulk
hours editor).

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners/:slug` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/partners`

**How to verify.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners` lists the partner. 2) Open it → hours table and location
map. 3) As an agent, edit the hours and see them update.

---

## F75 · Difficult · 1170 XP — Spotting duplicate requests

**What we built.** A similarity heuristic (`Requests::Similarity`: keyword overlap plus
same-service/location boost) surfaces **“possible duplicates”** on the agent request page,
with a one-click action to link the request to the one it duplicates.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference`

**How to verify.** 1) Open a request → possible duplicates are listed. 2) Click “Link as
duplicate” → the link is recorded.

---

## F76 · Medium · 780 XP — Comment after using a service

**What we built.** Citizens can leave a **rating and comment** on a service (one per
citizen), recorded with a reference and a confirmation notification. Reviews are displayed
on the service page and agents can **publish/hide** them.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/:slug` (review form) and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/service_reviews`

**How to verify.** 1) Sign in, open a service → leave a comment. 2) It appears on the
service page with the reference confirmation. 3) As an agent, hide/publish it.

---

## F77 · Difficult · 1200 XP — Stay pleasant under overload

**What we built.** Large lists are now **paginated** (25/page) — agent requests, citizen
requests, citizen accounts and the audit log — so pages stay bounded. Hot homepage,
catalog and pinned-message queries are **cached** briefly, and the most-filtered columns
are **indexed**. A public **`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status`** page reports component health, and the existing
low-data/simple modes and dynamically-imported map already keep pages lightweight.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status`, and the pagination controls on `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`,
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs`

**How to verify.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` shows database/cache state and counts. 2) Lists show
“Page X of Y” with previous/next. 3) Filters keep working across pages.

---

## F78 · Expert · 1600 XP — Stable with many simultaneous connections

**What we built.** Bounded page sizes and offsets (no unbounded result sets), cached hot
reads, composite indexes for the queue/lists, and lightweight server-rendered pages with
no SPA. Combined with the existing connection pooling, this keeps the platform responsive
under concurrent access.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` and the request lists

**How to verify.** 1) Lists never load unbounded rows (25/page). 2) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` reports the
database operational and cache writable. 3) Filtering/sorting stay fast.

> Note: a full load-testing harness was out of scope for this pass; the safeguards above
> (pagination, caching, indexes, bounded queries) are the concrete, verifiable measures.

---

## F79 · Easy · 400 XP — Sort and filter my requests

**What we built.** Citizens can **search** their own requests by subject/description,
**filter by status**, and **sort** by most recent or oldest. The CSV export follows the
applied filters.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**How to verify.** 1) Enter “lampadaire” → only matching requests remain. 2) Filter by
“Submitted”. 3) Sort by “Oldest”.

---

## F80 · Medium · 800 XP — Rank priority requests

**What we built.** Requests carry a **priority** (`normal`<https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`urgent`>). Agents can set it on
the request page; the queue shows a priority badge, an **urgent** counter, a priority
filter and a “priority first” sort.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference`

**How to verify.** 1) Open a request and set it to **Urgent** (Save priority).
2) Back in the list, filter by “Urgent” or sort “Priority first” → it comes first with an
“Urgent” badge.

---

## F81 · Difficult · 1230 XP — Perceptible protection against automated submissions

**What we built.** Public forms carry a signed render-time token and an off-screen
honeypot field, so blind scripted POSTs and bots that fill hidden fields are rejected with
a clear “Envoi bloqué” page. `rack-attack` throttles the request, contact and sign-up
endpoints, and every block is recorded as a `SecurityEvent`, so the protection is
perceptible from the admin security console without complicating normal use.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**How to verify.** 1) The forms show “Formulaire protégé contre les envois automatiques.”
2) POST without the token (or with the honeypot filled) → “Envoi bloqué”. 3) The blocked
attempt appears in `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events` as `form_protection_blocked`.

---

## F82 · Medium · 820 XP — No uncontrolled repeat submissions

**What we built.** Before creating a request, the app checks whether the signed-in citizen
submitted an identical request (same subject and description) in the last 10 minutes. If so
it keeps the first one and redirects the citizen to it with an explicit notice, instead of
creating a duplicate.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**How to verify.** Submit the same request twice in a row → the second submission lands on
the existing request and shows “Vous avez déjà envoyé cette demande (…)”.

---

## F83 · Easy · 410 XP — Acknowledgement with an identifiable reference

**What we built.** Every request has a stable reference (`NOVA-YYYY-XXXXX`), shown in an
“Accusé de réception” card on the request page (with received date and a print action) and
repeated in the confirmation email, so the citizen can find or quote it later.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/:reference` and the confirmation email.

**How to verify.** Submit a request → the acknowledgement card shows the reference; the
email subject and body repeat it.

---

## F84 · Medium · 820 XP — Agents reply directly to a request

**What we built.** Agents post threaded replies from the request page — public (notifies the
citizen in-app and by email) or internal (agent-only note). Public replies appear on the
citizen’s request page.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference` (reply form) and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/:reference`.

**How to verify.** Post a public reply as an agent → the citizen sees it and receives a
notification/email; post an internal note → the citizen does not.

---

## F85 · Expert · 1680 XP — Unusual activity detected; perceptible protection

**What we built.** The administrator security console aggregates the events already recorded
(blocked automated submissions, failed sign-ins, …) over the last hour and flags an unusual
volume as a clear signal, with a list of the events involved and the most active address. No
new monitoring subsystem is added: suspicious activity becomes perceptible from the existing
trail, while normal use is untouched.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**How to verify.** Open the security console: the “Recent activity” panel shows the volume of
events over the last hour and marks the activity “Normal” or “Unusual”. After several blocked
submissions, an “Unusual activity detected” alert lists the offending event counts.

---

## F86 · Expert · 1680 XP — Urgent situations are never treated as ordinary

**What we built.** Requests already carry a priority (F80). The agent queue now defaults to
**“priority first”** (also when the urgent filter is selected), a prominent callout appears
whenever urgent requests are pending, and the dashboard counts urgent requests — so what needs
attention is immediately visible as the daily volume grows, rather than being buried in the
list.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents`

**How to verify.** Set a request to **Urgent**, then open the agent request list: an “urgent
requests to treat” callout is shown and the queue lists urgent requests first; the dashboard
shows the urgent-request counter.

---

## F87 · Difficult · 1260 XP — Important data can be verified and backed up

**What we built.** Administrators can download a **clear, reusable backup** of all citizen
requests (`/agents/exports/requests`). The file is not a raw dump: it opens with a readable
summary (generation date and author, total count, urgent count, period covered, breakdown by
status) followed by the request records with priority and citizen — so the teams can confirm
important data can be saved and reused.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/exports/requests` (administrators only, linked from the agent navigation as “Backup”).

**How to verify.** As an administrator, click **Backup** in the agent navigation → a CSV is
downloaded whose header summarises the export before the records. A non-administrator agent
cannot reach the page.

---

## F88 · Medium · 840 XP — Select useful data and export it in a simple format

**What we built.** The agent request list has an **“Export selection (CSV)”** action that
honours the active filters (search, status, priority, service): the agents select exactly the
information they need and download it in a simple, reusable CSV (priority and citizen
included). Citizens can still download their own request history.

**Where to test.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` and `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**How to verify.** Filter the queue (e.g. status *Submitted*) then click **Export selection
(CSV)** → the downloaded file contains only the matching requests. Repeat from the citizen
space with **Download (CSV)**.

---

# Global implementation notes

- **Stack:** Rails 8.1, PostgreSQL 18.6, Hotwire (Turbo + Stimulus), ViewComponents,
  Tailwind + daisyUI (no Node toolchain).
- **Security:** Devise (two scopes) with passwordless magic links, sign-in by citizen
  identifier, and TOTP two-factor authentication, Pundit, PaperTrail, `rack-attack`,
  new-device sign-in alerts, a security-event log (admin-only), CSP with nonces, HSTS and
  secure cookies in production, filtered parameters, password-confirmed account deletion.
- **Internationalisation:** French default with English fallback and Spanish; translatable
  service, announcement, alert and partner content; locale resolved from parameter →
  profile → session → cookie.
- **Accessibility:** WCAG 2.2 AA-oriented statement at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility`.
- **Environmental:** measured weight and budgets at `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`, enforced by an automated
  asset-size test; low-data and simple modes, and a dynamically imported map library.
- **Participatory democracy:** projects, consultations with recorded opinions (F65/F66),
  citizen ideas with support and moderation (F68).
- **Partners & feedback:** partner directory with hours and location (F74); service
  reviews (F76); duplicate detection for agents (F75).
- **Performance:** the map library is not preloaded on non-map pages and its stylesheet
  loads only where a map renders.
- **Quality:** 294 automated tests pass (287 unit/controller/integration + 7 browser-style
  system tests), including a page-render smoke test; RuboCop, Brakeman, bundler-audit and
  importmap audit are all clean.
