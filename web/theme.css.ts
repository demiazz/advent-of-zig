import { createGlobalTheme, globalStyle } from "@vanilla-extract/css";

export const vars = createGlobalTheme(":root", {
  lineHeight: "1.4em",

  background: {
    primary: "#0f0f23",
    input: "#10101a",
  },

  text: {
    primary: "#ffffff",
    secondary: "#cccccc",
  },

  interactive: {
    primary: "#009900",
    highlight: "#00cc00",
    inactive: "#284c2a",
    focus: "#99ff99",
  },

  accent: "#ffff66",
  error: "#ff6666",
});

globalStyle("*, *::before, *::after", {
  boxSizing: "border-box",
});

globalStyle("html, body", {
  width: "100vw",
  height: "100vh",

  fontFamily: '"Source Code Pro", monospace',
  fontSize: "14pt",
  fontWeight: "300",
  lineHeight: vars.lineHeight,
});

globalStyle("body", {
  minWidth: "60em",

  backgroundColor: vars.background.primary,
});

globalStyle("body::after", {
  content: "",
  position: "fixed",
  top: "0",
  left: "0",
  width: "100vw",
  height: "100vh",
  background: `repeating-linear-gradient(0deg, rgba(0, 0, 0, 0.15), rgba(0, 0, 0, 0.15) 2px, transparent 2px, transparent 4px)`,
  pointerEvents: "none",
});

globalStyle("#root", {
  width: "100%",
  height: "100%",
});

globalStyle("h1, h2", {
  margin: 0,

  fontSize: "inherit",
  fontWeight: "inherit",
});
