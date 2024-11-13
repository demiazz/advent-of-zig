import { render } from "preact";

import { Application } from "@/components/Application";

import { initialize, solve } from "@/bridge";

initialize()
  .then((solutions) => {
    const container = document.getElementById("root");

    if (container == null) {
      throw new Error("Can't found root element");
    }

    render(<Application solutions={solutions} onSolve={solve} />, container);
  })
  .catch((error) => alert(error));
