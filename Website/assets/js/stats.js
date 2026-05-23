/* ═══════════════════════════════════════════════════════════════
   statAfrikR Foundation — stats.js
   CRAN downloads · GitHub stars · SVG chart
   ═══════════════════════════════════════════════════════════════ */
'use strict';

const FALLBACK = { total: 375, monthly: [8,11,6,11,20,7,9,2,15,22,8,10,22,5,6,15,10,11,4,14] };
const PKG = 'statAfrikR';
const GITHUB_REPO = 'damoko2004/statAfrikR';

/* ── Fetch CRAN total ────────────────────────────────────────── */
async function fetchCranTotal() {
  try {
    const r = await fetch(`https://cranlogs.r-pkg.org/downloads/total/2026-04-03:${today()}/${PKG}`);
    if (!r.ok) throw new Error('CRAN API error');
    const d = await r.json();
    return d[0]?.downloads ?? FALLBACK.total;
  } catch {
    return FALLBACK.total;
  }
}

/* ── Fetch CRAN daily downloads (last 30 days) ───────────────── */
async function fetchCranDaily() {
  try {
    const r = await fetch(`https://cranlogs.r-pkg.org/downloads/daily/last-month/${PKG}`);
    if (!r.ok) throw new Error();
    const d = await r.json();
    return d[0]?.downloads ?? FALLBACK.monthly;
  } catch {
    return FALLBACK.monthly;
  }
}

/* ── Fetch GitHub stars ──────────────────────────────────────── */
async function fetchGitHubStars() {
  try {
    const r = await fetch(`https://api.github.com/repos/${GITHUB_REPO}`);
    if (!r.ok) throw new Error();
    const d = await r.json();
    return { stars: d.stargazers_count ?? 0, forks: d.forks_count ?? 0, issues: d.open_issues_count ?? 0 };
  } catch {
    return { stars: 0, forks: 0, issues: 0 };
  }
}

function today() {
  return new Date().toISOString().split('T')[0];
}

/* ── Update hero counters ────────────────────────────────────── */
function updateCounters(total) {
  const el = document.getElementById('cran-total');
  if (el) el.setAttribute('data-count', total);
}

/* ── Draw SVG bar chart ──────────────────────────────────────── */
function drawBarChart(containerId, data) {
  const container = document.getElementById(containerId);
  if (!container) return;
  const arr = Array.isArray(data)
    ? data.map(d => typeof d === 'object' ? d.downloads : d)
    : Object.values(data);
  const max = Math.max(...arr) || 1;
  const W = 700, H = 200, pad = 40, barW = Math.floor((W - pad * 2) / arr.length) - 3;
  const cols = ['#1D4F3A','#2A6B50','#1D4F3A','#9C6A10','#1D4F3A','#2A6B50'];
  let rects = '', ticks = '', vals = '';
  arr.forEach((v, i) => {
    const bh = Math.max(4, ((v / max) * (H - 30)));
    const x = pad + i * (barW + 3);
    const y = H - 10 - bh;
    const c = v === Math.max(...arr) ? '#9C6A10' : cols[i % cols.length];
    rects += `<rect class="chart-bar" x="${x}" y="${y}" width="${barW}" height="${bh}" fill="${c}" rx="3">
      <title>${v} téléchargements</title></rect>`;
    if (v === Math.max(...arr)) {
      vals += `<text x="${x + barW / 2}" y="${y - 6}" text-anchor="middle" font-size="10" fill="#9C6A10" font-weight="bold">${v}</text>`;
    }
  });
  container.innerHTML = `<svg viewBox="0 0 ${W} ${H}" xmlns="http://www.w3.org/2000/svg" class="bar-chart-svg" aria-label="Téléchargements CRAN">
    <text x="${W/2}" y="14" text-anchor="middle" font-size="11" fill="#718096" font-family="Arial">Téléchargements quotidiens — source : cranlogs.r-pkg.org</text>
    ${rects}${vals}
    <text x="${pad}" y="${H}" font-size="10" fill="#718096" font-family="Arial">J-30</text>
    <text x="${W - pad}" y="${H}" text-anchor="end" font-size="10" fill="#718096" font-family="Arial">Aujourd'hui</text>
  </svg>`;
}

/* ── GitHub stats display ────────────────────────────────────── */
function updateGitHubStats(stats) {
  const map = { 'gh-stars': stats.stars, 'gh-forks': stats.forks, 'gh-issues': stats.issues };
  Object.entries(map).forEach(([id, val]) => {
    const el = document.getElementById(id);
    if (el) el.textContent = val;
  });
}

/* ── Init ────────────────────────────────────────────────────── */
async function init() {
  const [total, daily, gh] = await Promise.all([fetchCranTotal(), fetchCranDaily(), fetchGitHubStars()]);
  updateCounters(total);
  drawBarChart('cran-chart', daily);
  updateGitHubStats(gh);
  // Also update any static CRAN total elements
  document.querySelectorAll('.cran-total-val').forEach(el => { el.textContent = total.toLocaleString('fr-FR'); });
}

document.addEventListener('DOMContentLoaded', init);
