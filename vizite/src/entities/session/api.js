import { cfcGet } from "../../shared/api/cfc";
import { ENV } from "../../shared/config/env";
import { sessionTestData } from "../../shared/mocks/session";

export async function getSession() {
  if (ENV.USE_MOCK_SESSION) {
    return sessionTestData; // instant, bez mreže
  }
  return await cfcGet("get_session");
}
