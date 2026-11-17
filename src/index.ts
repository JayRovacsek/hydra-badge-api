import express from "express";
import * as dotenv from "dotenv";
import { createHydraClient, badgeFor, INVALID_BADGE } from "./hydra";

dotenv.config();

const app = express();
const port = Number(process.env.PORT) || 8080;
const instance = process.env.INSTANCE ?? "https://hydra.nixos.org";

const hydra = createHydraClient(instance);

const PARAM_PATTERN = /^[A-Za-z0-9._-]+$/;

app.get("/badge/:project/:jobset", async (req, res) => {
  const { jobset, project } = req.params;

  if (!PARAM_PATTERN.test(project) || !PARAM_PATTERN.test(jobset)) {
    res.status(400).json({ error: "invalid project or jobset name" });
    return;
  }

  try {
    const jobsets = await hydra.client.apiJobsetsGet(project);
    const found = jobsets.data.find((j) => j.name === jobset);
    res.json(found ? badgeFor(found) : INVALID_BADGE);
  } catch (error) {
    console.error("hydra fetch failed", error);
    res.status(502).json(INVALID_BADGE);
  }
});

app.listen(port);
