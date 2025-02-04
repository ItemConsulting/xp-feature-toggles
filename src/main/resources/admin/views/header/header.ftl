[#-- @ftlvariable name="locale" type="String" --]
[#-- @ftlvariable name="spaceKey" type="String" --]
[#-- @ftlvariable name="filters" type="java.util.ArrayList" --]

<header class="header">
  <h1>
    [@localize key="feature-toggles.displayName" locale=locale /]
  </h1>

  [#if filters?size > 1]
    <div class="header--toolbar">
      <div class="header--nav-label" id="header-nav-label">
        [@localize key="feature-toggles.selectSpace" locale=locale /]
      </div>

      <nav class="header--filters" aria-labelledby="header-nav-label">
        [#list filters as filter]
          <a
            class="pill"
            href="${filter.url}"
            [#if filter.text == spaceKey]aria-current="true"[/#if]>

            ${filter.text}
          </a>
        [/#list]
      </nav>
    </div>
  [/#if]
</header>
