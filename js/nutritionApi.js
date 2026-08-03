const USDA_API_KEY = 'DEMO_KEY';

const USDA_NUTRIENT_IDS = { calories: 1008, protein: 1003, fat: 1004, carbs: 1005 };

async function searchFoods(query) {
  if (!query || query.trim().length < 2) return [];
  const url = `https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${USDA_API_KEY}&query=${encodeURIComponent(query)}&pageSize=6`;
  const res = await fetch(url);
  if (!res.ok) throw new Error('Food search failed');
  const data = await res.json();
  return (data.foods || []).map((f) => ({
    fdcId: f.fdcId,
    description: f.description,
    brandName: f.brandName || null,
    per100g: extractMacrosPer100g(f.foodNutrients || []),
  }));
}

function extractMacrosPer100g(foodNutrients) {
  const macros = { calories: 0, protein: 0, fat: 0, carbs: 0 };
  foodNutrients.forEach((n) => {
    if (n.nutrientId === USDA_NUTRIENT_IDS.calories) macros.calories = n.value || 0;
    if (n.nutrientId === USDA_NUTRIENT_IDS.protein) macros.protein = n.value || 0;
    if (n.nutrientId === USDA_NUTRIENT_IDS.fat) macros.fat = n.value || 0;
    if (n.nutrientId === USDA_NUTRIENT_IDS.carbs) macros.carbs = n.value || 0;
  });
  return macros;
}

function scaleMacros(per100g, amountGrams) {
  const factor = amountGrams / 100;
  return {
    calories: Math.round(per100g.calories * factor),
    protein: Math.round(per100g.protein * factor * 10) / 10,
    carbs: Math.round(per100g.carbs * factor * 10) / 10,
    fat: Math.round(per100g.fat * factor * 10) / 10,
  };
}
