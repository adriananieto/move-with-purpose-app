function renderBottomNav(active) {
  const items = [
    { key: 'home', href: 'home.html', icon: 'ti-home' },
    { key: 'workout', href: 'workout.html', icon: 'ti-barbell' },
    { key: 'nutrition', href: 'nutrition.html', icon: 'ti-apple' },
    { key: 'profile', href: 'profile.html', icon: 'ti-chart-line' },
  ];
  const html = items.map((item) => {
    const color = item.key === active ? '#8F867E' : '#C4BEB4';
    return `<a href="${item.href}" style="color:${color}; text-decoration:none; line-height:0;"><i class="ti ${item.icon}" style="font-size:19px;" aria-hidden="true"></i></a>`;
  }).join('');

  document.querySelectorAll('[data-bottom-nav]').forEach((el) => {
    el.innerHTML = html;
    el.style.cssText = 'display:flex; justify-content:space-around; border-top:0.5px solid rgba(0,0,0,0.1); padding-top:12px; margin-top:1.2rem;';
  });
}
