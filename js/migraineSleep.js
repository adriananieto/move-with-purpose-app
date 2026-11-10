// recommended_foods rows in the "Migraine & Sleep" category are not part of
// the nutrition plan: nutrition screens filter them out, and they're shown on
// their own screen (migraine-sleep.html), linked from Profile.
const MIGRAINE_SLEEP_CATEGORY = 'Migraine & Sleep';

function isMigraineSleepFood(row) {
  return String(row?.category || '').trim().toLowerCase() === MIGRAINE_SLEEP_CATEGORY.toLowerCase();
}

function withoutMigraineSleep(rows) {
  return (rows || []).filter((r) => !isMigraineSleepFood(r));
}

function escapeMigraineSleepText(s) {
  return String(s ?? '').replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// All Migraine & Sleep rows for a user, in coach-defined order.
async function fetchMigraineSleepItems(userId) {
  const { data } = await sb.from('recommended_foods')
    .select('id, category, name, portion, order_index')
    .eq('user_id', userId)
    .ilike('category', '%migraine%sleep%')
    .order('order_index');
  return (data || []).filter(isMigraineSleepFood);
}
