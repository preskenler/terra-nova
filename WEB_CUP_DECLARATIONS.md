# Terra Nova — Déclarations de fonctionnalités (Webcup)

Généré automatiquement depuis `REPORT.md`. À relire avant validation : une pré-déclaration ne vaut pas validation.

## D01 — Create an account

```text
Fonctionnalité D01 réalisée — Create an account.

Implémentation : A complete citizen sign-up flow with Devise
(:database_authenticatable, :registerable, :validatable): unique email,
password validation (minimum 8 characters), automatic Profile creation, then a
redirect to onboarding and finally to the personal space. Forms are labelled,
translated (FR/EN) and accessible, with clear error messages.
Preuve : /users/sign_up — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1. Open /users/sign_up and submit an email that already exists → a readable error is shown.
2. Create a valid account (email + password) → you are redirected to /onboarding.
3. Complete onboarding (profile, language, accessibility) → you land on /espace.
4. Sign out, then sign back in with the same credentials → you return to your personal space.
```

## D03 — Sign in to a personal space

```text
Fonctionnalité D03 réalisée — Sign in to a personal space.

Implémentation : Devise login for citizens; the personal space /espace aggregates
the profile and activity (requests, appointments, unread notifications). The session
persists across visits.
Preuve : /users/sign_in → /espace — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Sign in with citoyen@novaterra.fr / password123 → you are
redirected to /espace, which shows your information and activity.
```

## D04 — Contact the administration

```text
Fonctionnalité D04 réalisée — Contact the administration.

Implémentation : A public contact form for questions, complaints, suggestions or
data concerns. It works signed-in or anonymously (an email is required when anonymous),
generates a tracked reference (MSG-…) and confirms the submission. Agents handle the
messages in their workspace.
Preuve : /feedback/new → agent side: /agents/feedbacks — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Submit a message → a confirmation with a reference is displayed.
2) Sign in as an agent → /agents/feedbacks lists the message. 3) Change its status →
the linked citizen is notified.
```

## D05 — Present municipal services

```text
Fonctionnalité D05 réalisée — Present municipal services.

Implémentation : A services catalog with categories, descriptions, contacts and
priority highlighting; 12 services are seeded.
Preuve : /services — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Browse the list, search “civil”, open a service → description,
contact details and a map are shown.
```

## D06 — Find and read announcements

```text
Fonctionnalité D06 réalisée — Find and read announcements.

Implémentation : A public announcements index and detail pages; only published and
active announcements are visible.
Preuve : /announcements — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The seeded announcements are listed; open one to read the full body.
```

## D07 — Clear homepage

```text
Fonctionnalité D07 réalisée — Clear homepage.

Implémentation : A homepage with a hero section, active alerts, emergency contacts,
priority services and the latest news, giving direct access to the main services.
Preuve : / — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The priority services are surfaced first and a prominent link leads
to /services.
```

## D08 — Distinguish citizen / agent / admin

```text
Fonctionnalité D08 réalisée — Distinguish citizen / agent / admin.

Implémentation : Two Devise scopes (User and Agent) with role enums
(citizen / agent / admin) and a separate /agents workspace with its own
navigation and sign-in.
Preuve : /agents versus / — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The agent workspace is visually and functionally distinct from the
citizen space and requires an agent account.
```

## D09 — Role-based access

```text
Fonctionnalité D09 réalisée — Role-based access.

Implémentation : Pundit policies plus route constraints; citizens cannot reach the
agent workspace or perform sensitive actions.
Preuve : Sign in as a citizen, then open /agents/requests — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : You are redirected to the agent sign-in; agent-only pages are
inaccessible to citizens.
```

## D11 — Track request status and steps

```text
Fonctionnalité D11 réalisée — Track request status and steps.

Implémentation : A citizen request list with status, and a per-request event timeline
showing the steps already completed.
Preuve : /requests → open a request — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The status badge and the “Progress” timeline of events are displayed.
```

## D12 — First-login onboarding

```text
Fonctionnalité D12 réalisée — First-login onboarding.

Implémentation : /onboarding guides the citizen through profile completion, language
selection and accessibility settings. First-time citizens are redirected there
automatically and land in /espace when finished.
Preuve : Create a new account → /onboarding — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Complete the guided steps → onboarding is marked complete and you
reach your personal space.
```

## D13 — Understand difficult words

```text
Fonctionnalité D13 réalisée — Understand difficult words.

Implémentation : A plain-language glossary explaining terms used across the platform.
Preuve : /glossary — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Seeded terms (“Signalement”, “Démarche”, …) are explained simply.
```

## D14 — Choose another language

```text
Fonctionnalité D14 réalisée — Choose another language.

Implémentation : A French/English interface with a header switcher and a profile
setting; the choice is persisted to the account.
Preuve : Header language selector, or /profile/edit — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Switch to English → navigation and pages update; reload the page →
the choice persists.
```

## D15 — Know where you are

```text
Fonctionnalité D15 réalisée — Know where you are.

Implémentation : Accessible breadcrumb navigation (with an “aria-label”) on all key
pages, showing the path back to the previous levels.
Preuve : Any inner page, e.g. /services/etat-civil — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The breadcrumb shows Home / Services / page and links back.
```

## D16 — Confirmation after sending

```text
Fonctionnalité D16 réalisée — Confirmation after sending.

Implémentation : Submitting a request shows a confirmation message with its reference,
opens the request page (which includes the reference and a timeline) and queues a
confirmation email.
Preuve : /requests/new → submit — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) You are redirected to the new request with a success message.
2) The request appears in /requests. 3) The email is queued (asserted by the test
suite; configure SMTP or a preview tool such as Letter Opener to read it).
```

## D17 — Count of pending requests

```text
Fonctionnalité D17 réalisée — Count of pending requests.

Implémentation : The agent dashboard and the request list display how many requests
still need action.
Preuve : /agents and /agents/requests — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : “Pending requests” counters and per-status statistics are visible.
```

## D18 — Broadcast a general message

```text
Fonctionnalité D18 réalisée — Broadcast a general message.

Implémentation : Agents publish announcements (severity, audience, publication window);
published announcements appear on the homepage and the news page.
Preuve : /agents/announcements → New — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Create an announcement → it appears at / and /announcements.
```

## D19 — Agent workspace reading the Terra Nova API

```text
Fonctionnalité D19 réalisée — Agent workspace reading the Terra Nova API.

Implémentation : A server-side client for the Webcup API (authenticated with the
X-Webcup-Api-Key header), idempotent synchronisation keyed on request_code, polling
roughly every 30 seconds via Solid Queue, and a live console with session status,
filters and a triage board (unseen → reviewing → planned → in progress → done/ignored).
Preuve : /agents/demands — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) The feed lists the current demands with XP and difficulty.
2) “Refresh now” updates it; it also auto-refreshes every 30 seconds. 3) Change a
demand’s triage status → it persists.
```

## D20 — Usable by everyone (accessibility)

```text
Fonctionnalité D20 réalisée — Usable by everyone (accessibility).

Implémentation : A WCAG 2.2 AA accessibility program: semantic landmarks, skip-to-content
link, visible keyboard focus, labelled forms with error summaries, high-contrast and
large-text modes, reduced-motion support and live regions for alerts.
Preuve : /accessibility and the header “Accessibility” menu — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Toggle high contrast / large text; navigate with the keyboard only;
the accessibility statement lists every supported feature.
```

## F21 — Screen-reader usability

```text
Fonctionnalité F21 réalisée — Screen-reader usability.

Implémentation : Semantic HTML, correct lang attribute, landmark roles, labelled
controls, aria-current breadcrumbs and role="alert" / live regions for alerts.
Preuve : /accessibility and any form (e.g. /feedback/new) — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : With VoiceOver/NVDA, headings, labels and errors are announced
correctly, and the skip link jumps to the main content.
```

## F22 — Agent request queue with states

```text
Fonctionnalité F22 réalisée — Agent request queue with states.

Implémentation : An agent list of citizen requests with status badges, filters and
pending counts, so agents can quickly see what still needs action.
Preuve : /agents/requests — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Filter by status and open a request to see its state and details.
```

## F23 — Contrast / readability

```text
Fonctionnalité F23 réalisée — Contrast / readability.

Implémentation : A high-contrast mode (persisted) and colour choices that never rely
on colour alone to convey meaning.
Preuve : Header “Accessibility” menu — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Enable “High contrast” → the interface switches to high-contrast
colours and the choice persists.
```

## F24 — Larger text

```text
Fonctionnalité F24 réalisée — Larger text.

Implémentation : A large-text mode that scales the root font size; layouts reflow
without breaking.
Preuve : Header “Accessibility” menu — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Enable “Large text” → text grows and the layout remains usable; the
choice persists.
```

## F25 — Report a broken streetlight with location

```text
Fonctionnalité F25 réalisée — Report a broken streetlight with location.

Implémentation : A report form with an optional service, a description, location text
and an interactive map picker to place the exact spot.
Preuve : /requests/new — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Fill in the problem, click the map to place the marker (coordinates
fill the form), submit → the request is created and tracked.
```

## F26 — History of past requests

```text
Fonctionnalité F26 réalisée — History of past requests.

Implémentation : A personal history of requests with their status and dates.
Preuve : /requests — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : All previously created requests are listed and can be opened.
```

## F27 — Multilingual service content

```text
Fonctionnalité F27 réalisée — Multilingual service content.

Implémentation : Service names and descriptions are stored per locale and follow the
selected interface language.
Preuve : /services after switching the interface to English — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Service names/descriptions display in English; switch back to French.
```

## F28 — Highlight priority services

```text
Fonctionnalité F28 réalisée — Highlight priority services.

Implémentation : A priority flag on services, surfaced in a dedicated “Priority
services” section on the homepage and catalog.
Preuve : / and /services — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Priority services appear in a dedicated section with a “Priority” badge.
```

## F29 — Neighbourhood flood alert

```text
Fonctionnalité F29 réalisée — Neighbourhood flood alert.

Implémentation : Alerts with a kind (flood / heatwave / security / other), a severity,
an area and a schedule; they are shown as prominent banners and announced to screen
readers.
Preuve : / and /alerts — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The seeded “flood — south district” alert is displayed prominently on
the homepage.
```

## F30 — Notify on important announcement

```text
Fonctionnalité F30 réalisée — Notify on important announcement.

Implémentation : Publishing an announcement notifies every citizen in-app (and queues
an email), so nobody misses important information.
Preuve : /agents/announcements → New; then /notifications — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : After publishing, the notification appears in the citizen’s
notification list.
```

## F31 — Heatwave guidance for vulnerable people

```text
Fonctionnalité F31 réalisée — Heatwave guidance for vulnerable people.

Implémentation : Alerts carry a target segment (e.g. “vulnerable people”) and
recommendations, and are displayed as a distinct warning banner.
Preuve : /alerts — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The seeded heatwave alert with its recommendations is visible.
```

## F32 — Find health services quickly

```text
Fonctionnalité F32 réalisée — Find health services quickly.

Implémentation : Search and category filters, a dedicated “Health” service and an
emergency panel so urgent needs are found immediately.
Preuve : /services?q=santé — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The Health service is returned, and the emergency panel is displayed
alongside the results.
```

## F33 — Delete my account safely

```text
Fonctionnalité F33 réalisée — Delete my account safely.

Implémentation : Account deletion protected by password confirmation, so an
unauthorized person with an open session cannot delete the account.
Preuve : /account — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Enter a wrong password → an error is shown and the account is
kept. 2) Enter the correct password → the account is deleted and you are redirected
home. (Use a throwaway account.)
```

## F34 — Agents administer citizen accounts

```text
Fonctionnalité F34 réalisée — Agents administer citizen accounts.

Implémentation : Agent management of citizen accounts: list, search, view, edit
(language, onboarding), role change (administrators only) and account unlock.
Preuve : /agents/users — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Search a citizen and open the record; edit fields; an administrator
can change the role and unlock a locked account.
```

## F35 — Onboarding guidance

```text
Fonctionnalité F35 réalisée — Onboarding guidance.

Implémentation : The onboarding page guides the new inhabitant step by step through
profile completion, language, accessibility and a short tour.
Preuve : /onboarding (with a new account) — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The four guided steps are presented clearly with short hints.
```

## F36 — Transport schedules and info

```text
Fonctionnalité F36 réalisée — Transport schedules and info.

Implémentation : Transport lines with their mode, per-weekday schedules and active
disruptions, all in one screen.
Preuve : /transports — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Seeded lines show their timetables, and an active disruption is
flagged on one line.
```

## F37 — Brute-force protection

```text
Fonctionnalité F37 réalisée — Brute-force protection.

Implémentation : rack-attack throttling on sign-in (per IP and per account),
password resets and sensitive endpoints; Devise :lockable for account lockout; agents
can unlock accounts.
Preuve : Repeated failed sign-ins at /users/sign_in — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : After several rapid attempts you receive HTTP 429 (Too Many
Requests); sustained failures lock the account, which an agent can unlock at
/agents/users/:id.
```

## F38 — Service under maintenance

```text
Fonctionnalité F38 réalisée — Service under maintenance.

Implémentation : Services have a status (active / maintenance / inactive).
A service under maintenance shows a banner with a message and expected return; inactive
services are hidden from the public catalog.
Preuve : /services/eau-assainissement — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : A maintenance banner with the message and the expected return is
displayed.
```

## F39 — Book an appointment

```text
Fonctionnalité F39 réalisée — Book an appointment.

Implémentation : Citizens choose an agent and a date, see computed available slots and
confirm; booking sends a confirmation and an in-app notification. Cancellation is
supported, and agents manage their schedule and availability.
Preuve : /appointments/new — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Pick an agent and a date → available slots appear. 2) Choose a slot
→ confirm → the appointment page shows a success message. 3) The appointment appears in
/appointments.
```

## F40 — Reminder before an appointment

```text
Fonctionnalité F40 réalisée — Reminder before an appointment.

Implémentation : Appointments::ReminderJob emails confirmed appointments roughly 24
hours ahead; it is scheduled through Solid Queue recurring tasks.
Preuve : Create an appointment ~24 hours ahead, then run
bin/rails runner 'Appointments::ReminderJob.new.perform' — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : A reminder is queued/sent exactly once (never twice); this is covered
by the test suite.
```

## F41 — Keyboard-only navigation

```text
Fonctionnalité F41 réalisée — Keyboard-only navigation.

Implémentation : A skip-to-content link, logical focus order, a visible focus
indicator and no keyboard traps.
Preuve : Any page, using only Tab/Shift+Tab — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : You can reach the header, navigation, forms and content, and the
focus indicator is always visible.
```

## F42 — Accessible forms and errors

```text
Fonctionnalité F42 réalisée — Accessible forms and errors.

Implémentation : Programmatic labels, an error summary with links, and
aria-describedby / aria-invalid wiring. Authentication fields allow pasting and
password managers.
Preuve : /requests/new → submit the empty form — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : An error summary appears; fields are marked invalid and associated
with their messages for assistive technologies.
```

## F43 — Colour blindness

```text
Fonctionnalité F43 réalisée — Colour blindness.

Implémentation : Status is never conveyed by colour alone — every coloured badge
carries a readable label — and a high-contrast mode is available.
Preuve : /services, /requests, /alerts — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Every coloured badge displays a text label.
```

## F44 — Enlarge without breaking layout

```text
Fonctionnalité F44 réalisée — Enlarge without breaking layout.

Implémentation : Responsive layouts that reflow, plus a large-text mode; content stays
usable at narrow widths and high zoom.
Preuve : Browser zoom at 200–400% on /services — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Content reflows into a single column without overlap or loss of
information.
```

## F45 — Locate physical services

```text
Fonctionnalité F45 réalisée — Locate physical services.

Implémentation : A Leaflet/OpenStreetMap map on service pages with the address and an
“Open in OpenStreetMap” link, plus a text alternative for assistive technologies.
Preuve : /services/etat-civil — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : A map with a marker and the address is displayed; the OpenStreetMap
link opens the location.
```

## F46 — Hospitals and emergency services

```text
Fonctionnalité F46 réalisée — Hospitals and emergency services.

Implémentation : Emergency services (call 112) are surfaced in a dedicated panel on
the homepage and the catalog, with telephone number and address.
Preuve : /services (emergency panel) and /services/urgences — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The emergency panel and the “Emergency services” detail page display
the number and the location.
```

## F47 — Justify and trace actions

```text
Fonctionnalité F47 réalisée — Justify and trace actions.

Implémentation : PaperTrail records changes on the key models with the acting user and
a timestamp, and an agent-facing audit log page makes it consultable over time.
Preuve : /agents/audit_logs — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Past changes are listed with who did them and when.
```

## F48 — Who modified what

```text
Fonctionnalité F48 réalisée — Who modified what.

Implémentation : Each audit entry shows the actor (Agent: / User:) and an
attribute-level before/after diff of the change.
Preuve : As an agent, change a request status → /agents/audit_logs → open the
entry — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The diff shows the changed field with its before and after values.
```

## F49 — Notify when my request changes state

```text
Fonctionnalité F49 réalisée — Notify when my request changes state.

Implémentation : When an agent changes the status of a request, an in-app notification
is created (and a status email is queued).
Preuve : As an agent, update a request at /agents/requests/:reference; then
visit /notifications — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The citizen receives a notification describing the new status.
```

## F50 — Activity dashboard

```text
Fonctionnalité F50 réalisée — Activity dashboard.

Implémentation : An agent dashboard showing platform activity (citizens, requests,
pending requests, upcoming appointments) alongside the Terra Nova API feed statistics
and recent items.
Preuve : /agents — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : The statistics cards and the recent-activity lists are displayed.
```

## F51 — Data-usage concerns, traceable

```text
Fonctionnalité F51 réalisée — Data-usage concerns, traceable.

Implémentation : A transparency page explaining how data is used and citizens’ rights,
a dedicated “data concern” contact kind, and a tracked reference so the citizen knows
the contribution was received. Agents handle these messages in their workspace.
Preuve : /transparency → “Report a data concern” — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Submit a concern → a confirmation with a reference is displayed; the
message appears in /agents/feedbacks.
```

## F52 — Support an existing request

```text
Fonctionnalité F52 réalisée — Support an existing request.

Implémentation : Citizens can co-sign another citizen’s request; the support count is
tracked, displayed, and can be withdrawn.
Preuve : Open a request (e.g. from /requests) → “Support this request” — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Clicking records your support and the counter increases; you can
withdraw your support.
```

## D02 — Sign in without a classic password

```text
Fonctionnalité D02 réalisée — Sign in without a classic password.

Implémentation : Passwordless sign-in with email magic links. The link is signed,
single-use and valid for 15 minutes; consuming it rotates a per-user nonce so it cannot
be replayed. The request response is deliberately generic to avoid revealing whether an
email exists, and the endpoint is rate-limited. The second factor still applies when
enabled.
Preuve : /users/magic_link (link “Sign in without a password” in the header) — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Enter citoyen@novaterra.fr → a generic “link sent” message.
2) Open the emailed link (configure SMTP or a mail preview to read it) → you are signed
in. 3) Open the same link again → it is rejected (single use). 4) Enter an unknown email
→ the same generic message. Covered by automated tests.
```

## F53 — Additional verification (two-factor authentication)

```text
Fonctionnalité F53 réalisée — Additional verification (two-factor authentication).

Implémentation : TOTP two-factor authentication via an authenticator app. Citizens
enrol from their profile (QR code + manual secret), confirm with a 6-digit code, and the
account is then gated by a verification challenge after every password or magic-link
sign-in. It can be disabled from the same page.
Preuve : /profile/two_factor — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open /profile/two_factor and scan the QR code with an
authenticator app. 2) Enter the current 6-digit code → enabling is confirmed.
3) Sign out and sign in with your password → you are redirected to /users/two_factor.
4) Enter the code → access is granted. 5) Disable it from the same page.
```

## F54 — Alert on sign-in from a new device

```text
Fonctionnalité F54 réalisée — Alert on sign-in from a new device.

Implémentation : Each sign-in is recorded with its IP address and a device fingerprint.
A sign-in from a device never seen before creates an in-app notification and a security
email. Recent sign-ins are listed in the personal data page.
Preuve : New-device notification at /notifications; history at /account/data — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in normally, then sign in again from a different browser
(different user agent). 2) A “New sign-in detected” notification appears, and a security
email is queued. 3) Signing in twice from the same device does not alert again.
```

## F55 — Retrieve my personal data

```text
Fonctionnalité F55 réalisée — Retrieve my personal data.

Implémentation : A personal data page giving a clear, structured summary (account
settings, two-factor status, registration date, activity counts and recent sign-ins),
plus a portable JSON export covering the account, profile, requests with their steps,
appointments, notifications, messages and supports.
Preuve : /account/data → “Download my data (JSON)” — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open /account/data → a readable summary is displayed.
2) Click the download button → a structured JSON file is returned. 3) Check it reflects
your real requests and appointments.
```

## F56 — Download a recap of my requests

```text
Fonctionnalité F56 réalisée — Download a recap of my requests.

Implémentation : A CSV export of the citizen’s request history: reference, submission
date, subject, status, service, location, number of steps, supporters and last update —
ready to open in a spreadsheet.
Preuve : /requests → “Download (CSV)”, or directly /requests.csv — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open /requests. 2) Click “Download (CSV)” → a data file is
downloaded. 3) Check the rows match your requests and their statuses.
```

## F57 — Environmental performance diagnosis

```text
Fonctionnalité F57 réalisée — Environmental performance diagnosis.

Implémentation : An /eco page reporting the measured size of the application’s own
stylesheets and JavaScript against explicit budgets, together with the design choices
that reduce the footprint. The Leaflet map library is now imported dynamically, so its
weight is only paid on pages that actually display a map.
Preuve : /eco — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Open /eco → measured weights and budgets are shown. Then open a
page without a map and check the browser Network tab: leaflet.js is not downloaded.
```

## F58 — Durable reduction of the digital impact

```text
Fonctionnalité F58 réalisée — Durable reduction of the digital impact.

Implémentation : Systematic lightweight choices across the key journeys: no SPA
framework (server-rendered Hotwire), no external web fonts or trackers, dynamic import of
the map library, and an automated asset-size budget enforced by the test suite so the
weight cannot regress unnoticed.
Preuve : /eco; test test/performance/asset_budget_test.rb — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Run bin/rails test test/performance/asset_budget_test.rb → it
passes and fails if the CSS/JS budgets are exceeded. 2) /eco documents the policy and
current numbers.
```

## F59 — Works on slow connections

```text
Fonctionnalité F59 réalisée — Works on slow connections.

Implémentation : A low-data mode preference, persisted to the profile and session,
that disables maps (no tile requests) and other heavy optional resources. Pages are
server-rendered, so content remains available and readable without JavaScript.
Preuve : Header “Accessibility” menu → “Low data mode” — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Enable “Low data mode”. 2) Open a service with a location → the map
is not loaded and a note is displayed instead. 3) In the Network tab, confirm no tile
requests are made.
```

## F60 — Lightweight images and media

```text
Fonctionnalité F60 réalisée — Lightweight images and media.

Implémentation : No external fonts or heavy media; the 2FA QR code is an inline data
URI; map tiles are only requested when a map is actually shown (and never in low-data
mode). The media choices and budgets are documented at /eco.
Preuve : /eco and any page’s Network tab — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Browse the main pages → no large media are loaded.
2) Enable low-data mode → no tile requests. 3) /eco describes the media choices.
```

## F61 — Fast even on low-powered devices

```text
Fonctionnalité F61 réalisée — Fast even on low-powered devices.

Implémentation : Pages stay light by default: the Leaflet JavaScript library is no
longer module-preloaded on every page (it is imported dynamically and fetched only where
a map is actually rendered), and the Leaflet stylesheet was moved out of the global
bundle so it is loaded only on map pages. Pages are server-rendered with no SPA
framework, prefers-reduced-motion is respected, and an automated asset-budget test
protects the weight from regressions.
Preuve : / (no map library), a map page /services/etat-civil, and /eco — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open / and check the browser Network tab → leaflet.js is not
preloaded. 2) Open /services/etat-civil → the map library loads only there.
3) Open /eco → measured weights are within budget; run
bin/rails test test/performance/asset_budget_test.rb → passes.
```

## F62 — A simpler, faster version of pages

```text
Fonctionnalité F62 réalisée — A simpler, faster version of pages.

Implémentation : A persisted “Simple mode” preference that renders lighter, faster
versions of the key pages: the homepage drops decorative blocks, the services catalog
drops the priority highlight, and maps are not loaded — while all essential information
and actions remain available.
Preuve : Accessibility menu → “Simple mode”; then / and /services — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Enable “Simple mode” from the header Accessibility menu.
2) The homepage no longer shows the “What you can do” and news blocks.
3) /services no longer shows the priority section and loads no map, but search and the
full list remain.
```

## F63 — Quickly disable a faulty service

```text
Fonctionnalité F63 réalisée — Quickly disable a faulty service.

Implémentation : A service management area in the agent workspace (/agents/services)
with a one-click “Disable” that immediately puts a service under maintenance, a
one-click “Enable” to restore it, and an edit form for the maintenance message (FR/EN),
expected return and contacts. Changes are recorded in the audit trail.
Preuve : /agents/services — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in as an agent and open /agents/services.
2) Click “Disable” on a service → it becomes “Under maintenance”, and the citizen side
(/services) immediately shows the maintenance banner.
3) Click “Enable” to restore it.
```

## F64 — See a service’s status before starting

```text
Fonctionnalité F64 réalisée — See a service’s status before starting.

Implémentation : Every service card now carries a status badge (Open / Under
maintenance / Closed), the service page shows the status prominently with the maintenance
banner, and the request form displays a live warning when an unavailable service is
selected — so citizens know before starting and know what to do next.
Preuve : /services, a service page (e.g. /services/eau-assainissement), and
/requests/new — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) /services shows an Open / Under maintenance / Closed badge on each
card. 2) Open a maintenance service → a banner with the message and expected return is
shown. 3) In /requests/new, select a maintenance service → a warning appears before you
submit.
```

## F65 — Put decisions to residents' opinion

```text
Fonctionnalité F65 réalisée — Put decisions to residents' opinion.

Implémentation : Consultations (attached to a project, with a kind: opinion, poll or
decision) that citizens can answer. Each answer is recorded with a traceable reference
and a confirmation notification, and agents can view the aggregated results — so the city
can justify the participation and the citizen knows the contribution was received.
Preuve : /projects, /consultations/:id and /agents/consultations — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open a consultation from a project page. 2) Submit your opinion →
the confirmation shows a reference. 3) As an agent, open the consultation → the results
and the list of responses are displayed.
```

## F66 — Give an opinion without a formal vote

```text
Fonctionnalité F66 réalisée — Give an opinion without a formal vote.

Implémentation : A simple answer form on each consultation (Favourable / Unfavourable /
No opinion + optional comment). One answer per citizen, recorded instantly, with a
reference and a confirmation so nothing is ambiguous.
Preuve : /consultations/:id — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in and open a consultation → choose an option and submit.
2) A confirmation with a reference is displayed. 3) Re-open the consultation → your
recorded answer and reference are shown.
```

## F67 — Consult the city's ongoing projects

```text
Fonctionnalité F67 réalisée — Consult the city's ongoing projects.

Implémentation : A public projects area: an index that highlights ongoing projects
and a detail page per project, listing its consultations, timeline and category.
Preuve : /projects and /projects/:slug — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open /projects → ongoing projects appear in a dedicated section.
2) Open a project → its description, dates, category and related consultations are shown.
```

## F68 — Propose ideas for the colony

```text
Fonctionnalité F68 réalisée — Propose ideas for the colony.

Implémentation : Citizens can propose an idea (category, title, description) — recorded
with a reference and a confirmation notification — support others' ideas (co-sign), and
agents can moderate ideas (submitted → under review → accepted/declined) with the
author notified.
Preuve : /ideas, /ideas/new, /ideas/:reference and /agents/ideas — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Propose an idea → confirmation with a reference. 2) Open another
citizen's idea → support it (the counter increases). 3) As an agent, open /agents/ideas,
change the status → the author is notified.
```

## F69 — Protect sensitive data; perceptible protection

```text
Fonctionnalité F69 réalisée — Protect sensitive data; perceptible protection.

Implémentation : A SecurityEvent log records authentication and account-security
activity (sign-in, failed sign-in, two-factor enabled/disabled, account unlocked), surfaced
in an administrator-only monitoring page. This complements the existing protections
(2FA, passwordless links, account lockout, rack-attack throttling, CSP/HSTS, filtered
parameters).
Preuve : /agents/security_events (administrator account) — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in and make a failed sign-in → events appear in the list.
2) A regular agent cannot open the page (redirected). 3) An administrator can.
```

## F70 — Administrative data strictly restricted

```text
Fonctionnalité F70 réalisée — Administrative data strictly restricted.

Implémentation : The audit trail and the security events are now administrator-only
(enforced by Pundit), and role changes remain administrator-only. Operational data stays
available to regular agents.
Preuve : /agents/audit_logs and /agents/security_events — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in as a regular agent → access is denied (redirect + message).
2) Sign in as an administrator → access is granted.
```

## F71 — Newcomers without email, in several languages

```text
Fonctionnalité F71 réalisée — Newcomers without email, in several languages.

Implémentation : Sign-in by email or citizen identifier (TN-XXXXXX). Agents can
create an account without an email address: the system generates a placeholder email,
a citizen identifier and a temporary password, shown once for handover. A third locale
(Spanish) was added to demonstrate easy language extension.
Preuve : /agents/users/new, then /users/sign_in, and the language switcher — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) As an agent, create an account leaving the email blank → credentials
are displayed. 2) Sign in with the identifier and the temporary password.
3) Switch the interface to Español.
```

## F72 — A starting point without redoing registration

```text
Fonctionnalité F72 réalisée — A starting point without redoing registration.

Implémentation : A “Where to start?” helper on the personal space: pick a situation
(moving in, waste, streetlight, health, transport, permits, water) → suggested services and
a one-click pre-filled request. No new registration step.
Preuve : /espace (guidance section) — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Choose “Health and emergencies” → suggested services appear.
2) Choose “A broken streetlight” → “Start a request” opens a pre-filled form.
```

## F73 — Official message visible by everyone, immediately

```text
Fonctionnalité F73 réalisée — Official message visible by everyone, immediately.

Implémentation : Announcements can be pinned, which renders them as a site-wide
banner on every page (citizen and agent layouts), in addition to the news page.
Preuve : /agents/announcements (pin) → any page — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Create or edit an announcement and tick “Pin as a site-wide banner”.
2) Open any page (e.g. /glossary) → the message appears at the top.
```

## F74 — Partner opening hours and location

```text
Fonctionnalité F74 réalisée — Partner opening hours and location.

Implémentation : A partner directory with a detail page showing the address, a
Leaflet map and the seven-day opening hours, plus agent management (including a bulk
hours editor).
Preuve : /partners, /partners/:slug and /agents/partners — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) /partners lists the partner. 2) Open it → hours table and location
map. 3) As an agent, edit the hours and see them update.
```

## F75 — Spotting duplicate requests

```text
Fonctionnalité F75 réalisée — Spotting duplicate requests.

Implémentation : A similarity heuristic (Requests::Similarity: keyword overlap plus
same-service/location boost) surfaces “possible duplicates” on the agent request page,
with a one-click action to link the request to the one it duplicates.
Preuve : /agents/requests/:reference — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open a request → possible duplicates are listed. 2) Click “Link as
duplicate” → the link is recorded.
```

## F76 — Comment after using a service

```text
Fonctionnalité F76 réalisée — Comment after using a service.

Implémentation : Citizens can leave a rating and comment on a service (one per
citizen), recorded with a reference and a confirmation notification. Reviews are displayed
on the service page and agents can publish/hide them.
Preuve : /services/:slug (review form) and /agents/service_reviews — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Sign in, open a service → leave a comment. 2) It appears on the
service page with the reference confirmation. 3) As an agent, hide/publish it.
```

## F77 — Stay pleasant under overload

```text
Fonctionnalité F77 réalisée — Stay pleasant under overload.

Implémentation : Large lists are now paginated (25/page) — agent requests, citizen
requests, citizen accounts and the audit log — so pages stay bounded. Hot homepage,
catalog and pinned-message queries are cached briefly, and the most-filtered columns
are indexed. A public /status page reports component health, and the existing
low-data/simple modes and dynamically-imported map already keep pages lightweight.
Preuve : /status, and the pagination controls on /agents/requests,
/requests, /agents/users, /agents/audit_logs — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) /status shows database/cache state and counts. 2) Lists show
“Page X of Y” with previous/next. 3) Filters keep working across pages.
```

## F78 — Stable with many simultaneous connections

```text
Fonctionnalité F78 réalisée — Stable with many simultaneous connections.

Implémentation : Bounded page sizes and offsets (no unbounded result sets), cached hot
reads, composite indexes for the queue/lists, and lightweight server-rendered pages with
no SPA. Combined with the existing connection pooling, this keeps the platform responsive
under concurrent access.
Preuve : /status and the request lists — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Lists never load unbounded rows (25/page). 2) /status reports the
database operational and cache writable. 3) Filtering/sorting stay fast.

> Note: a full load-testing harness was out of scope for this pass; the safeguards above
> (pagination, caching, indexes, bounded queries) are the concrete, verifiable measures.
```

## F79 — Sort and filter my requests

```text
Fonctionnalité F79 réalisée — Sort and filter my requests.

Implémentation : Citizens can search their own requests by subject/description,
Preuve : /requests — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Enter “lampadaire” → only matching requests remain. 2) Filter by
“Submitted”. 3) Sort by “Oldest”.
```

## F80 — Rank priority requests

```text
Fonctionnalité F80 réalisée — Rank priority requests.

Implémentation : Requests carry a priority (normal/urgent). Agents can set it on
the request page; the queue shows a priority badge, an urgent counter, a priority
filter and a “priority first” sort.
Preuve : /agents/requests and /agents/requests/:reference — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) Open a request and set it to Urgent (Save priority).
2) Back in the list, filter by “Urgent” or sort “Priority first” → it comes first with an
“Urgent” badge.
```

## F81 — Perceptible protection against automated submissions

```text
Fonctionnalité F81 réalisée — Perceptible protection against automated submissions.

Implémentation : Public forms carry a signed render-time token and an off-screen
honeypot field, so blind scripted POSTs and bots that fill hidden fields are rejected with
a clear “Envoi bloqué” page. rack-attack throttles the request, contact and sign-up
endpoints, and every block is recorded as a SecurityEvent, so the protection is
perceptible from the admin security console without complicating normal use.
Preuve : /feedback/new, /requests/new, /agents/security_events — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : 1) The forms show “Formulaire protégé contre les envois automatiques.”
2) POST without the token (or with the honeypot filled) → “Envoi bloqué”. 3) The blocked
attempt appears in /agents/security_events as form_protection_blocked.
```

## F82 — No uncontrolled repeat submissions

```text
Fonctionnalité F82 réalisée — No uncontrolled repeat submissions.

Implémentation : Before creating a request, the app checks whether the signed-in citizen
submitted an identical request (same subject and description) in the last 10 minutes. If so
it keeps the first one and redirects the citizen to it with an explicit notice, instead of
creating a duplicate.
Preuve : /requests/new — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Submit the same request twice in a row → the second submission lands on
the existing request and shows “Vous avez déjà envoyé cette demande (…)”.
```

## F83 — Acknowledgement with an identifiable reference

```text
Fonctionnalité F83 réalisée — Acknowledgement with an identifiable reference.

Implémentation : Every request has a stable reference (NOVA-YYYY-XXXXX), shown in an
“Accusé de réception” card on the request page (with received date and a print action) and
repeated in the confirmation email, so the citizen can find or quote it later.
Preuve : /requests/:reference and the confirmation email. — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Submit a request → the acknowledgement card shows the reference; the
email subject and body repeat it.
```

## F84 — Agents reply directly to a request

```text
Fonctionnalité F84 réalisée — Agents reply directly to a request.

Implémentation : Agents post threaded replies from the request page — public (notifies the
citizen in-app and by email) or internal (agent-only note). Public replies appear on the
citizen’s request page.
Preuve : /agents/requests/:reference (reply form) and /requests/:reference. — application en ligne : https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/
Notes (vérification) : Post a public reply as an agent → the citizen sees it and receives a
notification/email; post an internal note → the citizen does not.
```

