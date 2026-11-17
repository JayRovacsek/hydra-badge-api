import { DefaultApi } from "./hydra-client";

export const createHydraClient = (instance: string) =>
  Object.freeze({
    client: new DefaultApi({
      basePath: instance,
      baseOptions: { timeout: 10_000 },
    }),
  });

export { badgeFor, INVALID_BADGE } from "./badge";
export type { ShieldBadge } from "./badge";
