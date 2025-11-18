import { http } from "./http";

/** Pretvori payload u URLSearchParams (array -> "1,2,3"; boolean -> "1"/"0") */
function toForm(payload = {}) {
  const form = new URLSearchParams();
  Object.entries(payload).forEach(([k, v]) => {
    if (v === undefined || v === null) return;
    if (Array.isArray(v)) {
      form.append(k, v.join(","));
    } else if (typeof v === "boolean") {
      form.append(k, v ? "1" : "0");
    } else {
      form.append(k, String(v));
    }
  });
  return form;
}

/** GET ?method=...&returnformat=json&... */
export async function cfcGet(method, params = {}) {
  const { data } = await http.get("", {
    params: { method, returnformat: "json", ...params },
  });
  return data;
}

/** POST form-url-encoded na ?method=...&returnformat=json */
export async function cfcPost(method, body = {}) {
  const form = toForm(body);
  const { data } = await http.post("", form, {
    params: { method, returnformat: "json" },
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
  });
  return data;
}

/** PUT form-url-encoded (ako zatreba) */
export async function cfcPut(method, body = {}) {
  const form = toForm(body);
  const { data } = await http.put("", form, {
    params: { method, returnformat: "json" },
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
  });
  return data;
}
