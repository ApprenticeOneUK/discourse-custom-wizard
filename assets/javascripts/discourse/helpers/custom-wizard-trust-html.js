import { trustHTML } from "@ember/template";

export default function customWizardTrustHtml(value) {
  return trustHTML(value);
}
