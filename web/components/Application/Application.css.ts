import { style } from "@vanilla-extract/css";

import { vars } from "../../theme.css";

export const root = style({
  display: "grid",

  gridTemplateColumns: "auto 1fr",
  gridTemplateRows: "repeat(4, auto)",
  gridTemplateAreas: `
    "title years"
    "subtitle days"
    "form form"
    "results results"
  `,

  columnGap: "2ch",
});

export const title = style({
  gridArea: "title",

  color: vars.interactive.highlight,

  textShadow: `0 0 5px ${vars.interactive.highlight}`,
});

export const years = style({
  gridArea: "years",
});

export const subTitle = style({
  gridArea: "subtitle",

  color: vars.interactive.highlight,

  textAlign: "right",
  textShadow: `0 0 5px ${vars.interactive.highlight}`,
});

export const subTitleDelimiter = style({
  color: vars.interactive.inactive,

  textAlign: "right",
  textShadow: `0 0 5px ${vars.interactive.inactive}`,
});

export const days = style({
  gridArea: "days",
});

export const form = style({
  gridArea: "form",

  marginTop: vars.lineHeight,
});

export const results = style({
  gridArea: "results",

  marginTop: vars.lineHeight,

  color: vars.text.primary,
});

export const result = style({});

export const ok = style({
  color: vars.accent,
});

export const fail = style({
  color: vars.error,
});
