[#-- @ftlvariable name="locale" type="String" --]
[#-- @ftlvariable name="zoneId" type="String" --]
[#-- @ftlvariable name="spaceKey" type="String" --]
[#-- @ftlvariable name="userCanPublish" type="Boolean" --]
[#-- @ftlvariable name="title" type="String" --]
[#-- @ftlvariable name="features" type="java.util.ArrayList" --]
[#-- @ftlvariable name="feature.id" type="String" --]
[#-- @ftlvariable name="feature.name" type="String" --]
[#-- @ftlvariable name="feature.description" type="String" --]
[#-- @ftlvariable name="feature.enabled" type="Boolean" --]
[#-- @ftlvariable name="feature.createdDate" type="java.time.ZonedDateTime" --]
[#-- @ftlvariable name="feature.isDraftAndMasterSame" type="Boolean" --]
[#-- @ftlvariable name="noFeaturesMessage" type="String" --]
[#import "../../views/toggle/toggle.ftlh" as Toggle]

[#setting locale=locale]

<!DOCTYPE html>
<html lang="${locale}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="view-transition" content="same-origin" />

  <link rel="icon" href="[@assetUrl path='images/icon.svg'/]">
  <link rel="mask-icon" href=”[@assetUrl path='images/icon.svg'/]” color=”#000000">
  <link rel="stylesheet" href="[@assetUrl path='styles/main.min.css'/]" />

  <script type="module" src="[@assetUrl path='hotwired__turbo/8.0.12/dist/turbo.es2017-esm.js'/]"></script>
  <script type="module" src="[@assetUrl path='scripts/form-submit-on-change.mjs'/]"></script>

  <title>[@localize key="feature-toggles.displayName" locale=locale /]</title>
</head>
<body>
<div class="feature-toggles">
  <div class="layout--header theme-brand1">
    [#include "../../views/header/header.ftlh"]
  </div>
  <div class="layout--content">
    [#list features as feature]
      [#assign toggleId="toggle-${feature.id}" /]

      <label class="feature--label" for="${toggleId}">
        <span class="feature--name">${feature.name} </span>
        <span class="feature--description">
          [#if feature.createdDate?has_content]
            [@localize key="feature-toggles.created" locale=locale /]
            <time datetime="${feature.createdDate.format()}">${feature.createdDate.format("MEDIUM_DATE", zoneId)} ${feature.createdDate.format("SHORT_TIME", zoneId)}</time>
          [/#if]

          [#if feature.description?has_content]
            &mdash; ${feature.description}
          [/#if]
        </span>
      </label>

      <turbo-frame
        id="turbo-frame-toggle-${feature.id}"
        refresh="morph"
        class="feature-toggles--buttons">

        <submit-form-on-change>
          <form
            method="get"
            class="feature-toggles--form-toggle">

            <input
              type="hidden"
              name="formId"
              value="toggle">

            <input
              type="hidden"
              name="spaceKey"
              value="${spaceKey}">

            <input
              type="hidden"
              name="id"
              value="${feature.id}">

            [@Toggle.render
              id=toggleId
              name="enabled"
              checked=feature.enabled
              disabled=!(userCanPublish!false) /]

            <button type="submit" class="button theme-accent">
              [@localize key="feature-toggles.save" locale=locale /]
            </button>
          </form>
        </submit-form-on-change>

        <form
          method="get"
          class="feature-toggles--form-publish">

          <input
            type="hidden"
            name="id"
            value="${feature.id}">

          <input
            type="hidden"
            name="spaceKey"
            value="${spaceKey}">

          <input
            type="hidden"
            name="formId"
            value="publish">

          [#if userCanPublish!false]
            <button
              class="button theme-accent [#if feature.isDraftAndMasterSame]visibility-hidden[/#if]"
              type="submit">

              [@localize key="feature-toggles.publish" locale=locale /]
            </button>
          [/#if]
        </form>
      </turbo-frame>
    [#else]
      <p class="feature-toggles--no-toggles">${noFeaturesMessage?no_esc!}</p>
    [/#list]
  </div>
</div>
</body>
</html>
