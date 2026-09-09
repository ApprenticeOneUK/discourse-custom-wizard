# ApprenticeOne test cadence

This fork remains aligned with its upstream project. Pull requests and pushes
run the full plugin workflow once against the Discourse core commit used by the
current ApprenticeOne candidate. Documentation-only changes do not boot a
Discourse test environment.

Stable and main are early-warning targets and run weekly or manually. Upstream
source comparison is handled by the ApprenticeOne maintenance control
repository. The integrated ApprenticeOne stack is built once per candidate
fingerprint, not once per repository event.

The metadata version check ignores documentation and workflow-only pull
requests because those do not change the plugin release.

