const express = require("express");

const app = express();
const port = process.env.PORT || 8080;

app.get("/", (_req, res) => res.send("Hello from Node.js\n"));
app.get("/health", (_req, res) => res.json({ status: "ok" }));

const server = app.listen(port, "0.0.0.0", () => console.log(`listening on ${port}`));

// Node runs as PID 1 in a container and ignores SIGTERM unless it is handled.
for (const signal of ["SIGTERM", "SIGINT"]) {
  process.on(signal, () => server.close(() => process.exit(0)));
}
