async function requireSession() {
  const { data: { session } } = await sb.auth.getSession();
  if (!session) {
    window.location.href = 'index.html';
    return null;
  }
  return session;
}

async function logout() {
  await sb.auth.signOut();
  window.location.href = 'index.html';
}
