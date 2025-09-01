import { render } from "/lib/tineikt/freemarker";
import {
  getSpaces,
  getFeature,
  getFeatures,
  update as updateFeature,
  publish as publishFeature,
  PRINCIPAL_KEY_ADMIN,
  type Feature,
} from "/lib/feature-toggles";
import { ZonedDateTime, LanguageRange, ZoneId, Locale } from "/lib/time";
import { getToolUrl } from "/lib/xp/admin";
import { hasRole } from "/lib/xp/auth";
import { getSupportedLocales, localize } from "/lib/xp/i18n";
import type { Request, Response } from "@enonic-types/core";
import type { FreemarkerParams } from "./feature-toggles.freemarker";

const LOCALE_DEFAULT = "en";
const view = resolve("feature-toggles.ftlh");

type RequestParams = {
  params: {
    locale?: string;
    spaceKey?: string;
    formId?: string;
    id?: string;
    enabled?: "on";
  };
};

export function all(req: Request<RequestParams>): Response {
  const isAdmin = hasRole("system.admin") || hasRole(PRINCIPAL_KEY_ADMIN);
  const locale = req.params.locale ?? getLocale(req);
  const spaceKey = req.params.spaceKey;
  const spaces = getSpaces();
  const zoneId = ZoneId.systemDefault().getId();
  const noFeaturesMessage = localize({
    key: "feature-toggles.noFeatures",
    locale,
    values: [
      "https://github.com/ItemConsulting/lib-xp-feature-toggles?tab=readme-ov-file#gradle",
      "https://github.com/ItemConsulting/lib-xp-feature-toggles?tab=readme-ov-file#create",
    ],
  });

  // Handle toggle form
  if (req.params.formId === "toggle" && req.params.id) {
    updateFeature({
      id: req.params.id,
      enabled: req.params.enabled === "on",
    });
  }
  // Handle publish form
  else if (req.params.formId === "publish" && req.params.id) {
    publishFeature(req.params.id);
  }

  // If no spaces or features, render error message
  if (spaces.length === 0) {
    return {
      body: render<FreemarkerParams>(view, {
        locale,
        zoneId,
        userCanPublish: isAdmin,
        features: [],
        filters: [],
        spaceKey: "",
        noFeaturesMessage,
      }),
    };
  }
  // If no spaceKey provided, redirect to first space
  else if (!spaceKey) {
    return {
      redirect: getApplicationUrl({
        spaceKey: spaces[0]._name,
      }),
    };
  }

  const model: FreemarkerParams = {
    locale,
    zoneId,
    spaceKey,
    userCanPublish: isAdmin,
    features: getFeatures(spaceKey).map((feature) => {
      return {
        ...feature,
        createdDate: ZonedDateTime.parse(feature.createdTime),
        isDraftAndMasterSame: isSameOnOtherBranch(feature),
      };
    }),
    filters: spaces.map((space) => ({
      text: space._name,
      url: getApplicationUrl({ spaceKey: space._name }),
    })),
    noFeaturesMessage,
  };

  return {
    body: render<FreemarkerParams>(view, model),
  };
}

function getLocale(req: Request): string {
  const acceptLanguage = req.headers["Accept-Language"];

  if (acceptLanguage) {
    const languageRange = LanguageRange.parse(acceptLanguage);
    return Locale.filterTags(languageRange, getSupportedLocales(["i18n/phrases"]))[0] ?? LOCALE_DEFAULT;
  }

  return LOCALE_DEFAULT;
}

export function getApplicationUrl(params: Record<string, string>): string {
  const queryParams = Object.keys(params)
    .map((key) => `${key}=${encodeURIComponent(params[key])}`)
    .join("&");

  return `${getToolUrl("no.item.featuretoggles", "feature-toggles")}?${queryParams}`;
}

function isSameOnOtherBranch(feature: Feature): boolean {
  return feature.enabled === getFeature(feature.id, "master")?.enabled;
}
