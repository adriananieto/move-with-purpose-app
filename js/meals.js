// Shared meal naming/ordering. Logs always use meal_type; meal_targets.label and
// meal_targets.sort_order let a coach rename and reorder meals per client.
const MEAL_DEFAULT_LABELS = { breakfast: 'Breakfast', snack_am: 'Snack AM', lunch: 'Lunch', snack_pm: 'Snack PM', dinner: 'Dinner' };
const MEAL_DEFAULT_ORDER = ['breakfast', 'snack_am', 'lunch', 'snack_pm', 'dinner'];

function escapeMealText(s) {
  return String(s).replace(/[&<>"']/g, (c) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
}

// targetsByType: { [meal_type]: meal_targets row }
function mealLabel(type, targetsByType) {
  const custom = targetsByType?.[type]?.label;
  return escapeMealText(custom && String(custom).trim() ? custom.trim() : (MEAL_DEFAULT_LABELS[type] || type));
}

// A meal_targets row may exist only to carry label/sort_order (macros left at
// their 0 default); only show a macro target when it actually has numbers.
function hasMealMacros(t) {
  return !!t && ['calories', 'protein_g', 'carbs_g', 'fat_g'].some((k) => Number(t[k]) > 0);
}

function orderedMealTypes(targetsByType, types = MEAL_DEFAULT_ORDER) {
  const key = (type) => {
    const so = targetsByType?.[type]?.sort_order;
    return so != null ? Number(so) : MEAL_DEFAULT_ORDER.indexOf(type);
  };
  return [...types].sort((a, b) => (key(a) - key(b)) || (MEAL_DEFAULT_ORDER.indexOf(a) - MEAL_DEFAULT_ORDER.indexOf(b)));
}
