import { test } from "node:test";
import assert from "node:assert/strict";
import { badgeFor, INVALID_BADGE } from "../badge.ts";

test("invalid jobset returns an orange error badge", () => {
  assert.equal(INVALID_BADGE.color, "orange");
  assert.equal(INVALID_BADGE.isError, true);
  assert.equal(INVALID_BADGE.label, "invalid");
  assert.equal(INVALID_BADGE.message, "jobset");
});

test("all builds passing returns a green badge", () => {
  const badge = badgeFor({
    name: "jobset",
    project: "proj",
    nrfailed: 0,
    nrtotal: 5,
  });
  assert.equal(badge.color, "green");
  assert.equal(badge.isError, false);
  assert.equal(badge.message, "5 / 5");
});

test("failed builds returns a red badge with passed / total", () => {
  const badge = badgeFor({
    name: "jobset",
    project: "proj",
    nrfailed: 2,
    nrtotal: 5,
  });
  assert.equal(badge.color, "red");
  assert.equal(badge.isError, true);
  assert.equal(badge.message, "3 / 5");
});

test("missing nrtotal yields a grey unknown badge, never NaN", () => {
  const badge = badgeFor({ name: "jobset", project: "proj", nrfailed: 0 });
  assert.equal(badge.color, "grey");
  assert.equal(badge.message, "unknown");
});

test("missing name and project fall back to unknown", () => {
  const badge = badgeFor({ nrfailed: 1, nrtotal: 4 });
  assert.equal(badge.label, "unknown: unknown");
});
