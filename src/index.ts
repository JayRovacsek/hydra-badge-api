// import { BaseAPI as api } from './client';
import * as express from "express";
import * as dotenv from "dotenv";
import { Hydra } from "./hydra";

dotenv.config();

const app = express.default();
const port = process.env.PORT ?? 8080;
const instance = process.env.INSTANCE ?? "https://hydra.nixos.org";

const hydra = new Hydra(instance);

app.get("/badge/:project/:jobset", async (req, res) => {
  const { jobset, project } = req.params;
  try {
    const jobsets = await hydra.client.apiJobsetsGet(project);

    const shieldData = hydra.jobsetShield(
      jobsets.data.find((j) => j.name === jobset),
    );

    res.send(shieldData);
  } catch (error) {}
});

app.listen(port, async () => {});
