/* ═══════════════════════════════════════════════════════════════
   statAfrikR Foundation — main.js
   Navigation · Tabs · Accordion · Stepper · Compteurs · i18n
   ═══════════════════════════════════════════════════════════════ */
'use strict';

/* ── Navigation ──────────────────────────────────────────────── */
(function initNav() {
  const nav = document.querySelector('.nav');
  const toggle = document.querySelector('.nav-toggle');
  const links = document.querySelector('.nav-links');
  if (toggle && links) {
    toggle.addEventListener('click', () => {
      links.classList.toggle('open');
      toggle.setAttribute('aria-expanded', links.classList.contains('open'));
    });
    // Close on outside click
    document.addEventListener('click', (e) => {
      if (!nav.contains(e.target)) links.classList.remove('open');
    });
  }
  // Active link
  const path = window.location.pathname.split('/').pop() || 'index.html';
  document.querySelectorAll('.nav-links a').forEach(a => {
    const href = a.getAttribute('href');
    if (href === path || (path === '' && href === 'index.html')) {
      a.classList.add('active');
    }
  });
})();

/* ── Language Toggle ─────────────────────────────────────────── */
(function initLang() {
  const stored = localStorage.getItem('saf-lang') || 'fr';
  document.documentElement.setAttribute('data-lang', stored);
  document.querySelectorAll('.lang-btn').forEach(btn => {
    const lang = btn.getAttribute('data-lang');
    if (lang === stored) btn.classList.add('active');
    btn.addEventListener('click', () => {
      const newLang = btn.getAttribute('data-lang');
      document.documentElement.setAttribute('data-lang', newLang);
      localStorage.setItem('saf-lang', newLang);
      document.querySelectorAll('.lang-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      // Toggle FR/EN content
      document.querySelectorAll('[data-fr]').forEach(el => {
        el.textContent = newLang === 'en' ? el.getAttribute('data-en') || el.textContent : el.getAttribute('data-fr') || el.textContent;
      });
    });
  });
})();

/* ── Animated Counters ───────────────────────────────────────── */
function animateCounter(el, target, duration = 1800) {
  const start = performance.now();
  const isDecimal = target % 1 !== 0;
  const step = (timestamp) => {
    const elapsed = timestamp - start;
    const progress = Math.min(elapsed / duration, 1);
    const eased = 1 - Math.pow(1 - progress, 3);
    const current = Math.round(eased * target * (isDecimal ? 100 : 1)) / (isDecimal ? 100 : 1);
    el.textContent = isDecimal ? current.toFixed(1) : current.toLocaleString('fr-FR');
    if (progress < 1) requestAnimationFrame(step);
    else el.textContent = typeof el.dataset.suffix === 'string' ? target + el.dataset.suffix : target.toLocaleString('fr-FR');
  };
  requestAnimationFrame(step);
}

/* ── Intersection Observer for fade-in & counters ────────────── */
(function initObserver() {
  const io = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      el.classList.add('visible');
      if (el.dataset.count !== undefined) {
        const target = parseFloat(el.dataset.count);
        animateCounter(el, target);
        io.unobserve(el);
      }
    });
  }, { threshold: 0.15 });
  document.querySelectorAll('.fade-in, [data-count]').forEach(el => io.observe(el));
})();

/* ── Copy Code Buttons ───────────────────────────────────────── */
(function initCopyBtns() {
  document.querySelectorAll('.copy-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const block = btn.closest('.code-block');
      const code = block ? block.querySelector('pre').innerText : '';
      navigator.clipboard.writeText(code).then(() => {
        btn.textContent = '✓ Copié';
        btn.classList.add('copied');
        setTimeout(() => { btn.textContent = 'Copier'; btn.classList.remove('copied'); }, 2000);
      }).catch(() => {
        // Fallback for non-HTTPS
        const ta = document.createElement('textarea');
        ta.value = code; ta.style.position = 'fixed'; ta.style.opacity = '0';
        document.body.appendChild(ta); ta.select();
        document.execCommand('copy'); document.body.removeChild(ta);
        btn.textContent = '✓ Copié'; btn.classList.add('copied');
        setTimeout(() => { btn.textContent = 'Copier'; btn.classList.remove('copied'); }, 2000);
      });
    });
  });
})();

/* ── Tabs ────────────────────────────────────────────────────── */
(function initTabs() {
  document.querySelectorAll('.tabs').forEach(tabsEl => {
    const btns = tabsEl.querySelectorAll('.tab-btn');
    const panels = tabsEl.querySelectorAll('.tab-panel');
    btns.forEach((btn, i) => {
      btn.addEventListener('click', () => {
        btns.forEach(b => b.classList.remove('active'));
        panels.forEach(p => p.classList.remove('active'));
        btn.classList.add('active');
        if (panels[i]) panels[i].classList.add('active');
      });
    });
    // Activate first
    if (btns[0]) btns[0].click();
  });
})();

/* ── Accordion ───────────────────────────────────────────────── */
(function initAccordion() {
  document.querySelectorAll('.accordion-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const body = btn.nextElementSibling;
      const isOpen = btn.classList.contains('active');
      // Close all
      document.querySelectorAll('.accordion-btn.active').forEach(b => {
        b.classList.remove('active');
        const bd = b.nextElementSibling;
        if (bd) { bd.style.display = 'none'; }
      });
      if (!isOpen && body) {
        btn.classList.add('active');
        body.style.display = 'block';
      }
    });
  });
})();

/* ── Organigramme SVG Tooltip ────────────────────────────────── */
(function initOrgTooltip() {
  const tooltip = document.querySelector('.org-tooltip');
  if (!tooltip) return;
  document.querySelectorAll('.org-node').forEach(node => {
    const desc = node.getAttribute('data-desc');
    if (!desc) return;
    node.addEventListener('mouseenter', (e) => {
      tooltip.textContent = desc;
      tooltip.classList.add('visible');
    });
    node.addEventListener('mousemove', (e) => {
      tooltip.style.left = (e.pageX + 12) + 'px';
      tooltip.style.top  = (e.pageY - 40) + 'px';
    });
    node.addEventListener('mouseleave', () => tooltip.classList.remove('visible'));
  });
})();

/* ── Searchable Table ────────────────────────────────────────── */
function initSearchTable(inputId, tableId) {
  const input = document.getElementById(inputId);
  const table = document.getElementById(tableId);
  if (!input || !table) return;
  input.addEventListener('input', () => {
    const q = input.value.toLowerCase();
    table.querySelectorAll('tbody tr').forEach(row => {
      row.style.display = row.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  });
}
initSearchTable('fn-search', 'fn-table');

/* ── Smooth scroll for anchor links ─────────────────────────── */
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', (e) => {
    const target = document.querySelector(a.getAttribute('href'));
    if (target) {
      e.preventDefault();
      const top = target.getBoundingClientRect().top + window.scrollY - 80;
      window.scrollTo({ top, behavior: 'smooth' });
    }
  });
});

/* ── Contact Form Validation ─────────────────────────────────── */
(function initForm() {
  const form = document.getElementById('contact-form');
  if (!form) return;
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    let valid = true;
    form.querySelectorAll('[required]').forEach(field => {
      if (!field.value.trim()) {
        valid = false;
        field.style.borderColor = '#DC2626';
        field.style.boxShadow = '0 0 0 3px rgba(220,38,38,0.1)';
      } else {
        field.style.borderColor = '';
        field.style.boxShadow = '';
      }
    });
    const email = form.querySelector('[type="email"]');
    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value)) {
      valid = false;
      email.style.borderColor = '#DC2626';
    }
    if (valid) {
      form.submit();
    }
  });
})();
