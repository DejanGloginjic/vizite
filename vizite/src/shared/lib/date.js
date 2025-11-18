// Robustna util funkcija – radi sa Date, "YYYY-MM-DD", ISO stringovima.
export function toISODate(d = new Date()) {
  const date = d instanceof Date ? d : new Date(d);
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${y}-${m}-${day}`;
}

export function parseToDate(input) {
  if (input instanceof Date) return input;
  if (!input) return null;
  // već "YYYY-MM-DD"
  if (typeof input === "string" && /^\d{4}-\d{2}-\d{2}$/.test(input)) {
    const [y, m, d] = input.split("-").map((x) => parseInt(x, 10));
    return new Date(y, m - 1, d);
  }
  // pokušaj nativnog parsera (ISO itd.)
  const t = new Date(input);
  return isNaN(t.getTime()) ? null : t;
}

// dd.mm.yyyy
export function formatDateHuman(input) {
  const d = parseToDate(input);
  if (!d) return "—";
  const day = String(d.getDate()).padStart(2, "0");
  const m = String(d.getMonth() + 1).padStart(2, "0");
  const y = d.getFullYear();
  return `${day}.${m}.${y}`;
}

// Tačno računanje godina (bez zaokruživanja unaprijed).
export function calcAge(dob, ref = new Date()) {
  const birth = parseToDate(dob);
  const refDate = parseToDate(ref);
  if (!birth || !refDate) return null;

  let age = refDate.getFullYear() - birth.getFullYear();
  const refMonth = refDate.getMonth();
  const birthMonth = birth.getMonth();

  if (
    refMonth < birthMonth ||
    (refMonth === birthMonth && refDate.getDate() < birth.getDate())
  ) {
    age -= 1;
  }
  return age;
}

// --- ADD BELOW YOUR EXISTING EXPORTS ---

// Parsira samo YYYY-MM-DD u lokalni Date (bez vremenske zone)
export function parseISODateOnly(s) {
  const m = String(s || "").match(/^(\d{4})-(\d{2})-(\d{2})$/);
  if (!m) return null;
  const [, y, mo, d] = m;
  return new Date(Number(y), Number(mo) - 1, Number(d));
}

function startOfDay(d) {
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
}

export function formatVisitHeading(dateStr, now = new Date()) {
  const d = parseISODateOnly(dateStr) || new Date(dateStr);
  if (isNaN(d)) return String(dateStr || "");

  const today = startOfDay(now);
  const that = startOfDay(d);
  const diffDays = Math.round((that - today) / 86400000);

  if (diffDays === 0) return "danas";
  if (diffDays === -1) return "juče";
  if (diffDays === 1) return "sutra";

  // npr. "čet, 27. feb 2025"
  const fmt = new Intl.DateTimeFormat("sr-Latn-RS", {
    weekday: "short",
    day: "2-digit",
    month: "short",
    year: "numeric",
  });
  // većina sr skraćenica ima tačke; to je ok, ali možemo ih očistiti ako želiš:
  return fmt.format(that); // npr. "čet, 27. feb 2025"
}
