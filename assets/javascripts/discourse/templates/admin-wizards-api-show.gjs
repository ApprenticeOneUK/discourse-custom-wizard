import { Input } from "@ember/component";
import { fn, hash } from "@ember/helper";
import ComboBox from "discourse/select-kit/components/combo-box";
import MultiSelect from "discourse/select-kit/components/multi-select";
import DButton from "discourse/ui-kit/d-button";
import dAvatar from "discourse/ui-kit/helpers/d-avatar";
import dIcon from "discourse/ui-kit/helpers/d-icon";
import dLoadingSpinner from "discourse/ui-kit/helpers/d-loading-spinner";
import { i18n } from "discourse-i18n";

export default <template>
  <div class="wizard-api-header page">
    <div class="buttons">
      {{#if @controller.updating}}
        {{dLoadingSpinner size="small"}}
      {{else}}
        {{#if @controller.responseIcon}}
          {{dIcon @controller.responseIcon}}
        {{/if}}
      {{/if}}

      <DButton
        @label="admin.wizard.api.save"
        @action={{@controller.save}}
        class="btn-primary"
        @disabled={{@controller.saveDisabled}}
      />

      {{#if @controller.showRemove}}
        <DButton
          @action={{@controller.remove}}
          @label="admin.wizard.api.remove"
        />
      {{/if}}

      {{#if @controller.error}}
        <div class="error">
          {{@controller.error}}
        </div>
      {{/if}}
    </div>

    <div class="wizard-header large">
      {{#if @controller.api.isNew}}
        {{i18n "admin.wizard.api.new"}}
      {{else}}
        <span>{{@controller.api.title}}</span>
      {{/if}}
    </div>

    <div class="metadata">
      <div class="title">
        <label>{{i18n "admin.wizard.api.title"}}</label>
        <Input
          @value={{@controller.api.title}}
          placeholder={{i18n "admin.wizard.api.title_placeholder"}}
        />
      </div>

      <div class="name {{@controller.nameClass}}">
        <label>{{i18n "admin.wizard.api.name"}}</label>
        {{#if @controller.api.isNew}}
          <Input
            @value={{@controller.api.name}}
            placeholder={{i18n "admin.wizard.api.name_placeholder"}}
          />
        {{else}}
          <span>{{@controller.api.name}}</span>
        {{/if}}
      </div>
    </div>
  </div>

  <div class="wizard-api-header">
    <div class="buttons">
      {{#if @controller.isOauth}}
        {{#if @controller.authorizing}}
          {{dLoadingSpinner size="small"}}
        {{else}}
          {{#if @controller.authErrorMessage}}
            <span>{{@controller.authErrorMessage}}</span>
          {{/if}}
        {{/if}}
        <DButton
          @label="admin.wizard.api.auth.btn"
          @action={{@controller.authorize}}
          @disabled={{@controller.authDisabled}}
          class="btn-primary"
        />
      {{/if}}
    </div>

    <div class="wizard-header medium">
      {{i18n "admin.wizard.api.auth.label"}}
    </div>
  </div>

  <div class="wizard-api-authentication">
    <div class="settings">

      <div class="wizard-header small">
        {{i18n "admin.wizard.api.auth.settings"}}
      </div>

      {{#if @controller.showRedirectUri}}
        <div class="control-group redirect-uri">
          <div class="control-label">
            <label>{{i18n "admin.wizard.api.auth.redirect_uri"}}</label>
            <div class="controls">
              {{@controller.api.redirectUri}}
            </div>
          </div>
        </div>
      {{/if}}

      <div class="control-group auth-type">
        <label>{{i18n "admin.wizard.api.auth.type"}}</label>
        <div class="controls">
          <ComboBox
            @value={{@controller.api.authType}}
            @content={{@controller.authorizationTypes}}
            @onChange={{fn @controller.updateApiProperty "authType"}}
            @options={{hash none="admin.wizard.api.auth.type_none"}}
          />
        </div>
      </div>

      {{#if @controller.isOauth}}
        {{#if @controller.threeLeggedOauth}}
          <div class="control-group">
            <label>{{i18n "admin.wizard.api.auth.url"}}</label>
            <div class="controls">
              <Input @value={{@controller.api.authUrl}} />
            </div>
          </div>
        {{/if}}

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.token_url"}}</label>
          <div class="controls">
            <Input @value={{@controller.api.tokenUrl}} />
          </div>
        </div>

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.client_id"}}</label>
          <div class="controls">
            <Input @value={{@controller.api.clientId}} />
          </div>
        </div>

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.client_secret"}}</label>
          <div class="controls">
            <Input @value={{@controller.api.clientSecret}} />
          </div>
        </div>

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.params.label"}}</label>
          <div class="controls">
            {{#each @controller.api.authParams as |param|}}
              <div class="param">
                <Input
                  @value={{param.key}}
                  placeholder={{i18n "admin.wizard.key"}}
                />
                <Input
                  @value={{param.value}}
                  placeholder={{i18n "admin.wizard.value"}}
                />
                <DButton
                  @action={{@controller.removeParam}}
                  @actionParam={{param}}
                  @icon="xmark"
                />
              </div>
            {{/each}}
            <DButton
              @label="admin.wizard.api.auth.params.new"
              @icon="plus"
              @action={{@controller.addParam}}
            />
          </div>
        </div>
      {{/if}}

      {{#if @controller.isBasicAuth}}
        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.username"}}</label>
          <div class="controls">
            <Input @value={{@controller.api.username}} />
          </div>
        </div>

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.auth.password"}}</label>
          <div class="controls">
            <Input @value={{@controller.api.password}} />
          </div>
        </div>
      {{/if}}
    </div>

    {{#if @controller.isOauth}}
      <div class="status">
        <div class="authorization">
          {{#if @controller.api.authorized}}
            <span class="authorization-indicator authorized"></span>
            <span>{{i18n "admin.wizard.api.status.authorized"}}</span>
          {{else}}
            <span class="authorization-indicator not-authorized"></span>
            <span>{{i18n "admin.wizard.api.status.not_authorized"}}</span>
          {{/if}}
        </div>

        <div class="wizard-header small">
          {{i18n "admin.wizard.api.status.label"}}
        </div>

        {{#if @controller.threeLeggedOauth}}
          <div class="control-group">
            <label>{{i18n "admin.wizard.api.status.code"}}</label>
            <div class="controls">
              {{@controller.api.code}}
            </div>
          </div>
        {{/if}}

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.status.access_token"}}</label>
          <div class="controls">
            {{@controller.api.accessToken}}
          </div>
        </div>

        {{#if @controller.threeLeggedOauth}}
          <div class="control-group">
            <label>{{i18n "admin.wizard.api.status.refresh_token"}}</label>
            <div class="controls">
              {{@controller.api.refreshToken}}
            </div>
          </div>
        {{/if}}

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.status.expires_at"}}</label>
          <div class="controls">
            {{@controller.api.tokenExpiresAt}}
          </div>
        </div>

        <div class="control-group">
          <label>{{i18n "admin.wizard.api.status.refresh_at"}}</label>
          <div class="controls">
            {{@controller.api.tokenRefreshAt}}
          </div>
        </div>
      </div>
    {{/if}}
  </div>

  <div class="wizard-header medium">
    {{i18n "admin.wizard.api.endpoint.label"}}
  </div>

  <div class="wizard-api-endpoints">
    <DButton
      @action={{@controller.addEndpoint}}
      @label="admin.wizard.api.endpoint.add"
      @icon="plus"
    />

    {{#if @controller.api.endpoints}}
      <div class="endpoint-list">
        <ul>
          {{#each @controller.api.endpoints as |endpoint|}}
            <li>
              <div class="endpoint">
                <div class="endpoint-">
                  <div class="top">
                    <Input
                      @value={{endpoint.name}}
                      placeholder={{i18n "admin.wizard.api.endpoint.name"}}
                    />
                    <Input
                      @value={{endpoint.url}}
                      placeholder={{i18n "admin.wizard.api.endpoint.url"}}
                      class="endpoint-url"
                    />
                    <DButton
                      @action={{@controller.removeEndpoint}}
                      @actionParam={{endpoint}}
                      @icon="xmark"
                      class="remove-endpoint"
                    />
                  </div>
                  <div class="bottom">
                    <ComboBox
                      @content={{@controller.endpointMethods}}
                      @value={{endpoint.method}}
                      @onChange={{fn
                        @controller.updateEndpointProperty
                        endpoint
                        "method"
                      }}
                      @options={{hash none="admin.wizard.api.endpoint.method"}}
                    />
                    <ComboBox
                      @content={{@controller.contentTypes}}
                      @value={{endpoint.content_type}}
                      @onChange={{fn
                        @controller.updateEndpointProperty
                        endpoint
                        "content_type"
                      }}
                      @options={{hash
                        none="admin.wizard.api.endpoint.content_type"
                      }}
                    />
                    <MultiSelect
                      @value={{endpoint.success_codes}}
                      @content={{@controller.successCodes}}
                      @onChange={{fn
                        @controller.updateEndpointProperty
                        endpoint
                        "success_codes"
                      }}
                      @options={{hash
                        none="admin.wizard.api.endpoint.success_codes"
                      }}
                    />
                  </div>
                </div>
              </div>
            </li>
          {{/each}}
        </ul>
      </div>
    {{/if}}
  </div>

  <div class="wizard-header medium">
    {{i18n "admin.wizard.api.log.label"}}

    <div class="controls">
      <DButton
        @action={{@controller.clearLogs}}
        class="clear-logs"
        @label="admin.wizard.api.log.clear"
      />
    </div>
  </div>

  <div class="wizard-api-log">
    <div class="log-list">
      <table class="wizard-api-log-table">
        <thead>
          <th>Datetime</th>
          <th>User</th>
          <th>Status</th>
          <th>URL</th>
          <th>Error</th>
        </thead>
        <tbody>
          {{#each @controller.api.log as |logentry|}}
            <tr>
              <td>{{logentry.time}}</td>
              <td class="user-image">
                <div class="user-image-inner">
                  <a
                    href={{logentry.userpath}}
                    data-user-card={{logentry.username}}
                  >{{dAvatar logentry imageSize="medium"}}</a>
                </div>
              </td>
              <td>{{logentry.status}}</td>
              <td>{{logentry.url}}</td>
              <td>{{logentry.error}}</td>
            </tr>
          {{/each}}
        </tbody>
      </table>
    </div>
  </div>
</template>
