import "./toggle.css";
import type { Meta, StoryObj } from "@itemconsulting/xp-storybook-utils";
import id from "./toggle.ftlh";

export default {
  title: "Components/Toggle",
  parameters: {
    layout: "centered",
    server: {
      params: {
        template: `
          [#import "${id}" as Toggle /]
          [@Toggle.render id=id name=name checked=checked disabled=disabled /]
        `,
      },
    },
  },
} satisfies Meta;

export const toggle: StoryObj = {
  args: {
    id: "feature",
    name: "feature",
    label: "Feature 1",
    checked: false,
    disabled: false,
  },
};
