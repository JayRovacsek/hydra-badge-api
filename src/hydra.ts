import { DefaultApi, JobsetOverviewInner } from "./hydra-client";

interface shieldBadge {
  color: string;
  isError: boolean;
  label: string;
  labelColor: string;
  logoColor: string;
  message: string;
  namedLogo: string;
  schemaVersion: number;
}

export class Hydra {
  instance: string;
  client: DefaultApi;

  constructor(instance: string) {
    const configuration = {
      basePath: instance,
    };

    this.instance = instance;

    this.client = new DefaultApi(configuration);
  }

  jobsetShield = (jobset?: JobsetOverviewInner): shieldBadge => {
    if (jobset === undefined) {
      return {
        color: "orange",
        isError: true,
        label: "invalid",
        labelColor: "black",
        logoColor: "blue",
        message: "jobset",
        namedLogo: "nixos",
        schemaVersion: 1,
      };
    }

    // Overly simplified, but we'll suggest passing
    // if all builds are green
    const isPassing = jobset?.nrfailed === 0;

    return {
      color: isPassing ? "green" : "red",
      isError: isPassing,
      label: `${jobset?.project}: ${jobset?.name}`,
      labelColor: "black",
      logoColor: "blue",
      namedLogo: "nixos",
      message: isPassing
        ? "passing"
        : `${jobset.nrtotal - jobset.nrfailed} / ${jobset.nrtotal}`,
      schemaVersion: 1,
    };
  };
}
