// import { BaseAPI as api } from './client';
import * as express from "express";
import * as dotenv from "dotenv";

dotenv.config();

const app = express.default();
const port = process.env.PORT ?? 8080;

app.get("/", (req, res) => {
  res.send("Express + TypeScript Server");
});

app.listen(port, () => {
  console.log("a");
});
