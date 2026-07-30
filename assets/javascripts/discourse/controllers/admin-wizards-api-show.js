import Controller from "@ember/controller";
import { action, computed, set } from "@ember/object";
import { service } from "@ember/service";
import { underscore } from "@ember/string";
import { ajax } from "discourse/lib/ajax";
import { popupAjaxError } from "discourse/lib/ajax-error";
import { i18n } from "discourse-i18n";
import { selectKitContent } from "../lib/wizard";
import CustomWizardApi from "../models/custom-wizard-api";

export default class AdminWizardsApiShowController extends Controller {
  @service router;

  queryParams = ["refresh_list"];
  loadingSubscriptions = false;
  endpointMethods = selectKitContent(["PUT", "POST", "PATCH", "DELETE"]);
  responseIcon = null;
  contentTypes = selectKitContent([
    "application/json",
    "application/x-www-form-urlencoded",
  ]);
  successCodes = selectKitContent([
    100, 101, 102, 200, 201, 202, 203, 204, 205, 206, 207, 208, 226, 300, 301,
    302, 303, 303, 304, 305, 306, 307, 308,
  ]);
  authorizationTypes = selectKitContent([
    "none",
    "basic",
    "oauth_2",
    "oauth_3",
  ]);

  @computed("api.authorized")
  get notAuthorized() {
    return !this.api.authorized;
  }

  @computed("api.isNew")
  get showRemove() {
    return !this.api.isNew;
  }

  @computed("threeLeggedOauth", "api.name")
  get showRedirectUri() {
    return this.threeLeggedOauth && Boolean(this.api.name);
  }

  @computed(
    "saveDisabled",
    "api.authType",
    "api.authUrl",
    "api.tokenUrl",
    "api.clientId",
    "api.clientSecret",
    "threeLeggedOauth"
  )
  get authDisabled() {
    if (
      this.saveDisabled ||
      !this.api.authType ||
      !this.api.tokenUrl ||
      !this.api.clientId ||
      !this.api.clientSecret
    ) {
      return true;
    }
    if (this.threeLeggedOauth) {
      return !this.api.authUrl;
    }
    return false;
  }

  @computed("api.name", "api.authType")
  get saveDisabled() {
    return !this.api.name || !this.api.authType;
  }

  @computed("api.authType")
  get isBasicAuth() {
    return this.api.authType === "basic";
  }

  @computed("api.authType")
  get isOauth() {
    return this.api.authType?.includes("oauth");
  }

  @computed("api.authType")
  get twoLeggedOauth() {
    return this.api.authType === "oauth_2";
  }

  @computed("api.authType")
  get threeLeggedOauth() {
    return this.api.authType === "oauth_3";
  }

  @computed("api.isNew")
  get nameClass() {
    return this.api.isNew ? "new" : "saved";
  }

  @action
  updateApiProperty(property, value) {
    this.set(`api.${property}`, value);
  }

  @action
  updateEndpointProperty(endpoint, property, value) {
    set(endpoint, property, value);
  }

  @action
  addParam() {
    this.api.authParams.push({});
  }

  @action
  removeParam(param) {
    const index = this.api.authParams.indexOf(param);
    if (index !== -1) {
      this.api.authParams.splice(index, 1);
    }
  }

  @action
  addEndpoint() {
    this.api.endpoints.push({});
  }

  @action
  removeEndpoint(endpoint) {
    const index = this.api.endpoints.indexOf(endpoint);
    if (index !== -1) {
      this.api.endpoints.splice(index, 1);
    }
  }

  @action
  authorize() {
    const api = this.get("api");
    const { name, authType, authUrl, authParams } = api;

    this.set("authErrorMessage", "");

    if (authType === "oauth_2") {
      this.set("authorizing", true);
      ajax(`/admin/wizards/api/${underscore(name)}/authorize`)
        .catch(popupAjaxError)
        .then((result) => {
          if (result.success) {
            this.set("api", CustomWizardApi.create(result.api));
          } else if (result.failed && result.message) {
            this.set("authErrorMessage", result.message);
          } else {
            this.set("authErrorMessage", "Authorization Failed");
          }
          setTimeout(() => {
            this.set("authErrorMessage", "");
          }, 6000);
        })
        .finally(() => this.set("authorizing", false));
    } else if (authType === "oauth_3") {
      let query = "?";

      query += `client_id=${api.clientId}`;
      query += `&redirect_uri=${encodeURIComponent(api.redirectUri)}`;
      query += `&response_type=code`;

      if (authParams) {
        authParams.forEach((param) => {
          query += `&${param.key}=${encodeURIComponent(param.value)}`;
        });
      }

      window.location.href = authUrl + query;
    }
  }

  @action
  save() {
    const api = this.get("api");
    const name = api.name;
    const authType = api.authType;
    let error;

    if (!name || !authType) {
      return;
    }

    const data = {
      auth_type: authType,
    };

    if (api.title) {
      data.title = api.title;
    }

    if (api.get("isNew")) {
      data.new = true;
    }

    let requiredParams;

    if (authType === "basic") {
      requiredParams = ["username", "password"];
    } else if (authType === "oauth_2") {
      requiredParams = ["tokenUrl", "clientId", "clientSecret"];
    } else if (authType === "oauth_3") {
      requiredParams = ["authUrl", "tokenUrl", "clientId", "clientSecret"];
    }

    if (requiredParams) {
      for (const requiredParam of requiredParams) {
        if (!api[requiredParam]) {
          const key = requiredParam.replace("auth", "");
          error = `${i18n(
            `admin.wizard.api.auth.${underscore(key)}`
          )} is required for ${authType}`;
          break;
        }
        data[underscore(requiredParam)] = api[requiredParam];
      }
    }

    const params = api.authParams;
    if (params.length) {
      data.auth_params = JSON.stringify(params);
    }

    const endpoints = api.endpoints;
    if (endpoints.length) {
      for (const endpoint of endpoints) {
        if (!endpoint.name) {
          error = "Every endpoint must have a name";
          break;
        }
      }
      data.endpoints = JSON.stringify(endpoints);
    }

    if (error) {
      this.set("error", error);
      setTimeout(() => {
        this.set("error", "");
      }, 6000);
      return;
    }

    this.set("updating", true);

    ajax(`/admin/wizards/api/${underscore(name)}`, {
      type: "PUT",
      data,
    })
      .catch(popupAjaxError)
      .then((result) => {
        if (result.success) {
          this.send("afterSave", result.api.name);
        } else {
          this.set("responseIcon", "xmark");
        }
      })
      .finally(() => this.set("updating", false));
  }

  @action
  remove() {
    const name = this.get("api.name");
    if (!name) {
      return;
    }

    this.set("updating", true);

    ajax(`/admin/wizards/api/${underscore(name)}`, {
      type: "DELETE",
    })
      .catch(popupAjaxError)
      .then((result) => {
        if (result.success) {
          this.send("afterDestroy");
        }
      })
      .finally(() => this.set("updating", false));
  }

  @action
  clearLogs() {
    const name = this.get("api.name");
    if (!name) {
      return;
    }

    ajax(`/admin/wizards/api/${underscore(name)}/logs`, {
      type: "DELETE",
    })
      .catch(popupAjaxError)
      .then((result) => {
        if (result.success) {
          this.router.transitionTo("adminWizardsApis").then(() => {
            this.send("refreshModel");
          });
        }
      })
      .finally(() => this.set("updating", false));
  }
}
