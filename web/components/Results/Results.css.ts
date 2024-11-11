import { style } from "@vanilla-extract/css";

import { vars } from "../../theme.css";

export const label = style({
  color: vars.text.primary,

  textShadow: `0 0 5px ${vars.text.primary}`,
});

export const ok = style({});

export const fail = style({});

export const answer = style({
  selectors: {
    [`${ok} &`]: {
      color: vars.accent,

      textShadow: `0 0 5px ${vars.accent}`,
    },

    [`${fail} &`]: {
      color: vars.error,

      textShadow: `0 0 5px ${vars.error}`,
    },
  },
});
