// Lets a coach preview a client's own screens with that client's data,
// read-only, while still talking to Supabase as the coach (RLS's existing
// "coach select all" policies are what actually gate the reads — this file
// never signs in as the client and never grants write access).
const VIEW_AS_STORAGE_KEY = 'mova_view_as_client';

function getViewAsClient() {
  try {
    const raw = sessionStorage.getItem(VIEW_AS_STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
  }
}

function startViewAsClient(clientId, clientName) {
  sessionStorage.setItem(VIEW_AS_STORAGE_KEY, JSON.stringify({ id: clientId, name: clientName }));
  window.location.href = 'home.html';
}

function exitViewAsClient() {
  sessionStorage.removeItem(VIEW_AS_STORAGE_KEY);
  window.location.href = 'coach-clients.html';
}

// Client-facing screens call this right after requireSession() to find out
// whose data to load: the signed-in user's own, or — while a coach is
// previewing a client — that client's.
function resolveViewer(session) {
  const viewAs = getViewAsClient();
  return {
    userId: viewAs ? viewAs.id : session.user.id,
    isReadOnly: !!viewAs,
    viewAsName: viewAs ? viewAs.name : null,
  };
}

// Inserts the "Viewing as [Name] · read-only" banner as a sibling right
// before #card, so it survives every later `card.innerHTML = ...` re-render.
function renderViewAsBanner(viewAsName) {
  if (!viewAsName) return;
  const card = document.getElementById('card');
  if (!card || !card.parentNode) return;
  const banner = document.createElement('div');
  banner.style.cssText = 'display:flex; align-items:center; justify-content:space-between; gap:10px; background:var(--chai); border-radius:12px; padding:10px 14px; margin-bottom:0.9rem;';
  banner.innerHTML = `
    <span class="mwp-body" style="font-size:12px; color:var(--ink);">Viewing as ${viewAsName} · read-only</span>
    <button type="button" style="background:var(--ink); color:var(--creme); border:none; border-radius:7px; padding:6px 12px; font-size:11px; font-family:'Poppins',sans-serif; cursor:pointer; flex-shrink:0;">Exit</button>
  `;
  banner.querySelector('button').addEventListener('click', exitViewAsClient);
  card.parentNode.insertBefore(banner, card);
}

// Disables every control inside `container` that could log, save, submit, or
// upload client data — the read-only lockdown for a view-as screen. Anything
// that must stay usable (e.g. the coach's own logout button) opts out with a
// `data-keep-enabled` attribute.
function lockReadOnly(container) {
  if (!container) return;
  container.querySelectorAll('button, input, textarea, select, .scale-btn').forEach((el) => {
    if (el.hasAttribute('data-keep-enabled')) return;
    el.disabled = true;
    el.style.pointerEvents = 'none';
    el.style.opacity = '0.5';
  });
}
