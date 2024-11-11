import { style } from "@vanilla-extract/css";

import { vars } from "../../theme.css";

export const root = style({
  display: "flex",
  flexDirection: "row",
  flexWrap: "wrap",
  columnGap: "1ch",
});

export const input = style({
  display: "none",
});

export const item = style({
  color: vars.interactive.primary,

  textDecoration: "none",

  cursor: "pointer",

  selectors: {
    "&:hover, &:focus": {
      color: vars.interactive.focus,
    },

    [`&:has(${input}:checked)`]: {
      color: vars.interactive.focus,

      textShadow: `
        0 0 2px ${vars.interactive.focus},
        0 0 5px ${vars.interactive.focus}
      `,
    },

    [`&:has(${input}:disabled)`]: {
      color: vars.interactive.inactive,
      cursor: "default",
    },
  },
});
