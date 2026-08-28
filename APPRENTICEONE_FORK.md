# ApprenticeOne Custom Wizard fork

This branch is based on Custom Wizard 2.18.3 (`2d15be38`) and adds accessible,
configurable feedback for unanswered required fields.

## Site settings

The following settings appear under **Admin > Plugins > Custom Wizard >
Settings**:

- `wizard_required_field_error_message` — default: “Complete this field to
  continue.”
- `wizard_required_dropdown_error_message` — default: “Select an option to
  continue.”
- `wizard_required_checkbox_error_message` — default: “Tick this box to
  continue.”

The dropdown and checkbox settings override the general message for those field
types. Changes are global across Custom Wizard flows and may require users to
refresh an already-open wizard.

## Behaviour

- Every unanswered required field on the current step is validated.
- Error text appears below the relevant field while retaining the existing red
  outline.
- Errors are announced to assistive technology.
- A required-field error clears when the field receives a valid value.
- Errors from answer validation or the server are not cleared by the
  required-field logic.

These behaviours are intentionally not site settings because disabling them
would recreate the accessibility and usability problem this fork fixes. Visual
styling can still be overridden by the site theme.
