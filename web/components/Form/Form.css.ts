import { style } from "@vanilla-extract/css";

import { vars } from "../../theme.css";

export const root = style({
  width: "45em",
});

export const input = style({
  width: "100%",

  background: vars.background.input,

  fontSize: "inherit",
  color: vars.text.primary,

  resize: "none",
});

export const actions = style({
  display: "flex",
  flexDirection: "row",
  justifyContent: "flex-end",
  gap: "1ch",

  marginTop: "1.2em",
});

export const action = style({
  padding: "0",

  border: "none",
  background: "transparent",

  fontSize: "inherit",
  color: vars.interactive.primary,

  cursor: "pointer",

  selectors: {
    "&:hover": {
      color: vars.interactive.focus,
    },

    "&:disabled": {
      color: vars.interactive.inactive,
      cursor: "default",
    },
  },
});
