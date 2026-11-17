import type { JobsetOverviewInner } from "./hydra-client";

export type ShieldBadge = {
  readonly color: "green" | "red" | "orange" | "grey";
  readonly isError: boolean;
  readonly label: string;
  readonly labelColor: string;
  readonly logoColor: string;
  readonly message: string;
  readonly namedLogo: string;
  readonly schemaVersion: number;
};

const BASE_BADGE = {
  labelColor: "black",
  logoColor: "blue",
  namedLogo: "nixos",
  schemaVersion: 1,
} as const;

export const INVALID_BADGE: ShieldBadge = {
  ...BASE_BADGE,
  color: "orange",
  isError: true,
  label: "invalid",
  message: "jobset",
};

// A jobset with no builds recorded is neither passing nor failing.
const UNKNOWN_BADGE = (label: string): ShieldBadge => ({
  ...BASE_BADGE,
  color: "grey",
  isError: false,
  label,
  message: "unknown",
});

export const badgeFor = (jobset: JobsetOverviewInner): ShieldBadge => {
  const failed = jobset.nrfailed ?? 0;
  const total = jobset.nrtotal ?? 0;
  const label = `${jobset.project ?? "unknown"}: ${jobset.name ?? "unknown"}`;

  if (total === 0) {
    return UNKNOWN_BADGE(label);
  }

  const isPassing = failed === 0;
  return {
    ...BASE_BADGE,
    color: isPassing ? "green" : "red",
    isError: !isPassing,
    label,
    message: `${total - failed} / ${total}`,
  };
};
