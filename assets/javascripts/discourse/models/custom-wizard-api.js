/* eslint-disable ember/no-classic-classes */
import EmberObject, { computed } from "@ember/object";
import { trackedArray } from "@ember/reactive/collections";
import { dasherize } from "@ember/string";
import { ajax } from "discourse/lib/ajax";

const CustomWizardApi = EmberObject.extend({
  redirectUri: computed("name", function () {
    const nameParam = dasherize(this.name);
    const baseUrl =
      location.protocol +
      "//" +
      location.hostname +
      (location.port ? ":" + location.port : "");
    return baseUrl + `/admin/wizards/api/${nameParam}/redirect`;
  }),
});

CustomWizardApi.reopenClass({
  create(params = {}) {
    const api = this._super.apply(this);
    const authorization = params.authorization || {};
    const endpoints = params.endpoints;

    api.setProperties({
      name: params.name,
      title: params.title,
      originalTitle: params.title,
      authType: authorization.auth_type,
      authUrl: authorization.auth_url,
      tokenUrl: authorization.token_url,
      clientId: authorization.client_id,
      clientSecret: authorization.client_secret,
      username: authorization.username,
      password: authorization.password,
      authParams: trackedArray(authorization.auth_params || []),
      authorized: authorization.authorized,
      accessToken: authorization.access_token,
      refreshToken: authorization.refresh_token,
      code: authorization.code,
      tokenExpiresAt: authorization.token_expires_at,
      tokenRefreshAt: authorization.token_refresh_at,
      endpoints: trackedArray(endpoints || []),
      isNew: params.isNew,
      log: params.log,
    });

    return api;
  },

  find(name) {
    return ajax(`/admin/wizards/api/${name}`, {
      type: "GET",
    }).then((result) => {
      return CustomWizardApi.create(result);
    });
  },

  list() {
    return ajax("/admin/wizards/api", {
      type: "GET",
    }).then((result) => {
      return result;
    });
  },
});

export default CustomWizardApi;
