import { createRoot } from "react-dom/client";

import { Application } from "@/components/Application";

import { initialize, solve } from "@/bridge";

initialize()
  .then((solutions) => {
    const container = document.getElementById("root");

    if (container == null) {
      throw new Error("Can't found root element");
    }

    const root = createRoot(container);

    root.render(<Application solutions={solutions} onSolve={solve} />);
  })
  .catch((error) => alert(error));
