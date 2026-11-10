// Program-phase math in one place: "Day X · Week Y", the renewal date, and
// pauses. Every date here is a LOCAL calendar date ('YYYY-MM-DD'), never UTC,
// so day counts don't jump at night.
//
//   paused_elapsed   = paused_days + (paused_since ? today - paused_since : 0)
//   effective_day    = (today - phase_start_date) - paused_elapsed + 1
//   effective_renew  = (renewal_date || phase_start_date + 28) + paused_elapsed
//
// While paused_since is set, day/week stay frozen and the renewal reminder
// never fires.

const PHASE_PROFILE_COLUMNS = 'phase_start_date, renewal_date, paused_since, paused_days';
const PHASE_LENGTH_DAYS = 28;

function localDateStr(d = new Date()) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function parseLocalDate(str) {
  const [y, m, d] = String(str).slice(0, 10).split('-').map(Number);
  return new Date(y, m - 1, d);
}

// Whole calendar days from `fromStr` to `toStr` (round() absorbs DST shifts).
function daysBetween(fromStr, toStr) {
  return Math.round((parseLocalDate(toStr) - parseLocalDate(fromStr)) / (24 * 60 * 60 * 1000));
}

function addDays(str, n) {
  const d = parseLocalDate(str);
  d.setDate(d.getDate() + n);
  return localDateStr(d);
}

function pausedElapsedDays(profile, todayStr = localDateStr()) {
  const base = Number(profile?.paused_days) || 0;
  const since = profile?.paused_since;
  return base + (since ? Math.max(0, daysBetween(since, todayStr)) : 0);
}

function computePhase(profile, todayStr = localDateStr()) {
  const isPaused = !!profile?.paused_since;
  const pausedElapsed = pausedElapsedDays(profile, todayStr);
  const start = profile?.phase_start_date || null;

  let effectiveDay = null;
  let day = null;
  let week = null;
  if (start) {
    effectiveDay = Math.max(1, daysBetween(start, todayStr) - pausedElapsed + 1);
    const daysSince = effectiveDay - 1;
    day = (daysSince % 7) + 1;
    week = Math.min(4, Math.floor(daysSince / 7) + 1);
  }

  const baseRenewal = profile?.renewal_date || (start ? addDays(start, PHASE_LENGTH_DAYS) : null);
  const renewalDate = baseRenewal ? addDays(baseRenewal, pausedElapsed) : null;
  const daysUntilRenewal = renewalDate ? daysBetween(todayStr, renewalDate) : null;
  const renewalDue = !isPaused && daysUntilRenewal !== null && daysUntilRenewal <= 3;

  return { isPaused, pausedElapsed, effectiveDay, day, week, renewalDate, daysUntilRenewal, renewalDue };
}

async function fetchPhaseProfile(userId) {
  const { data } = await sb.from('profiles').select(PHASE_PROFILE_COLUMNS).eq('id', userId).single();
  return data || null;
}

function pausedBannerHtml() {
  return `
    <div style="display:flex; align-items:center; gap:10px; background:var(--chai); border-radius:12px; padding:10px 14px; margin-bottom:0.9rem;">
      <i class="ti ti-player-pause" style="font-size:16px; color:var(--ink); flex-shrink:0;" aria-hidden="true"></i>
      <p class="mwp-body" style="font-size:12px; color:var(--ink); margin:0;">Program paused. We'll pick up where you left off.</p>
    </div>`;
}
