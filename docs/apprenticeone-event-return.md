# Event Sign-in return after Welcome

This opt-in change is based on ApprenticeOne's deployed branch,
`apprenticeone/configurable-required-field-errors` at `c7cc158a98491e81cc0d80469df09e3ef92e7869`.
It preserves the fork's existing required-field messages, mapper corrections and accessible dropdown labels.
No Discourse core patch is required.

## Why the homepage appeared

On the deployed Discourse revision `a6ade3e9915f427d115f082a2ddbc6c208c5f3c1`,
`UsersController#perform_account_activation` deletes `destination_url` before choosing
the required wizard. The wizard can subsequently remember the homepage/referrer instead.
Event Sign-in's return banner is a deliberate fallback when a new tab cannot attribute
completion to its originating tab.

There is also a second handoff hazard: core redirects `/t/-/<id>` to the current topic
slug and strips unrecognised query parameters. The server now resolves the current slug
before returning, so the `event_sign_in` marker reaches the component.

## Behavior

- Disabled by default: `wizard_event_return_enabled` must be enabled by an administrator.
- Recognises only the component's exact `/t/-/<positive-id>?event_sign_in=<32 lowercase hex>` cookie/path.
- Captures after successful authenticated activation, at account-created handoff, or when a marked event request is intercepted by a required signup wizard.
- Stores the destination privately in PluginStore, bound to user and wizard, independently of `save_submissions`.
- A homepage visit or refresh does not replace the destination or extend its 24-hour lifetime.
- Successful final-step handling runs existing completion actions and cleanup first, then consumes the return once under a user row lock.
- Explicit `route_to`, action `redirect_on_complete`, and final-step `redirect_on_next` keep their existing priority. Only the ordinary entry/referrer destination is replaced.
- Rechecks topic existence, deletion, ordinary (non-PM) topic type and the user's current access after completion actions. A group membership granted by Welcome therefore takes effect before this check.
- Expired/inaccessible returns and unsuccessful completion actions use the homepage, unless an explicit action redirect applies. This change does not alter the plugin's existing completion-action error handling.
- Abandoned expired records are removed daily. Ordinary signups, optional wizards and other users/wizards retain their existing behavior.

The component's existing marked-arrival handling clears local storage, its owned cookie,
the marker in the address bar and the return banner. Other tabs receive storage cleanup.
No background tab is forcibly navigated. Cross-device activation without the cookie is
outside this change's scope; interrupted flows can still use the component's fallback.

## Validation

Tests use the matching Discourse revision above, Ruby 3.4.6, Node 24.14.0 and a dedicated
local PostgreSQL database. The new request suite reproduces the old homepage return and
covers real signup with its queued activation token in another session, refresh/resume,
validation errors, disabled submission history, expiry, private/deleted events,
completion group membership, explicit redirects, failed actions, ordinary signup,
optional wizards, one-time consumption, isolation and untrusted destinations.

Final local result on 11 October 2026: **406 server tests passed** (entire plugin suite
plus core activation request tests) in a fresh `discourse_event_return_verify_test` database.
Ruby lint and Syntax Tree checks passed. The companion passed 31 Node tests and 17
Discourse QUnit tests with no logged deprecations. The interactive five-step local Welcome
returned automatically to the selected event, with profile and group actions confirmed.
SMTP delivery and the exact live Age Check/Guest Gate/theme configuration were not tested.

Run from the isolated Discourse checkout with this plugin checked out in
`plugins/discourse-custom-wizard`:

```sh
RAILS_ENV=test LOAD_PLUGINS=1 bundle exec rspec plugins/discourse-custom-wizard/spec
RAILS_ENV=test LOAD_PLUGINS=1 bundle exec rspec spec/requests/users_controller_spec.rb:59
```

Use an isolated test database. The companion repository contains the guarded
`scripts/seed-onboarding-test.rb` fixture for a fictional five-step Welcome with profile
and group actions. It requires `discourse_event_signin_test` and test-only mail delivery.
It is a representative integration fixture, not a copy of the live wizard or live users.

## Approval and deployment

**This PR must remain unmerged until the owner approves it.** Its base is the deployed
ApprenticeOne branch, not the upstream `main` branch. Merging into that branch and updating
the plugin on the live host are separate actions; neither has been performed by this work.

After approval: merge this PR into `apprenticeone/configurable-required-field-errors`,
update/rebuild the plugin using the site's normal deployment process, then enable
`wizard_event_return_enabled`. Check that Welcome has Signup and Required enabled and
no explicit action redirect that should take precedence. Test signup from an event the
new member is allowed to view. Do not make private categories public merely to test this.

Turning the setting off stops new captures and automatic wizard event returns. Existing
pending records expire and are pruned. Event Sign-in's manual fallback remains available.
