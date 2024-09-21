import { DefaultApi, JobsetOverviewInner } from "./hydra-client";

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

  jobsetShield = (jobset?: JobsetOverviewInner) => {
    if (jobset === undefined) {
      return {
        cacheSeconds: 3000,
        color: "orange",
        label: "invalid",
        labelColor: "black",
        link: [],
        logo: "nixos",
        logoColor: "blue",
        message: "jobset",
      };
    }

    // Overly simplified, but we'll suggest passing
    // if all builds are green
    const isPassing = jobset?.nrfailed === 0;

    return {
      cacheSeconds: 300,
      color: isPassing ? "green" : "red",
      label: `${jobset?.project}: ${jobset?.name}`,
      labelColor: "black",
      link: [
        `${this.instance}/jobset/${jobset?.project}/${jobset?.name}/latest-eval`,
      ],
      logo: "nixos",
      logoColor: "blue",
      message: isPassing
        ? "passing"
        : `${jobset.nrtotal - jobset.nrfailed} / ${jobset.nrtotal}`,
    };
  };
}
