/* ═══════════════════════════════════════════════════════════════
   statAfrikR Foundation — i18n.js
   Système de traduction FR (défaut) / EN
   ═══════════════════════════════════════════════════════════════ */
'use strict';

const TRANSLATIONS = {
  fr: {
    /* Navigation */
    'nav.fondation':    'Fondation',
    'nav.gouvernance':  'Gouvernance',
    'nav.package':      'Package',
    'nav.formation':    'Formation',
    'nav.roadmap':      'Roadmap',
    'nav.communaute':   'Communauté',
    'nav.partenaire':   'Devenir partenaire',
    'nav.don':          'Faire un don',

    /* Hero index */
    'hero.badge':       'Package CRAN officiel · Avril 2026',
    'hero.sub':         'Foundation for African Statistical Innovation & Open Data',
    'hero.quote':       '« statAfrikR est conçu par et pour les statisticiens africains. »',
    'hero.btn1':        'Découvrir statAfrikR',
    'hero.btn2':        'Devenir partenaire INS',
    'hero.stat1':       'Téléchargements CRAN en 1 mois',
    'hero.stat2':       'Fonctions documentées v0.1.0',
    'hero.stat3':       'INS partenaires cibles (2028)',
    'hero.stat4':       'Statisticiens à certifier (2028)',

    /* Sections communes */
    'section.install':  'Installer statAfrikR en 30 secondes',
    'section.why':      'Pourquoi statAfrikR est stratégique pour les INS',
    'section.pipeline': 'Pipeline statistique complet — 5 modules intégrés',
    'section.news':     'Suivre l\'évolution de statAfrikR',
    'section.partner':  'Le siège de la Foundation dans votre INS',

    /* Don */
    'don.title':        'Soutenir la statAfrikR Foundation',
    'don.sub':          'Votre don finance le développement open source, les formations gratuites et les certifications pour les statisticiens africains.',
    'don.btn.10':       'Faire un don de 10 €',
    'don.btn.25':       'Faire un don de 25 €',
    'don.btn.50':       'Faire un don de 50 €',
    'don.btn.libre':    'Montant libre',
    'don.deductible':   'Don déductible des impôts · Fonds de dotation · Loi n°2008-776',
    'don.receipt':      'Reçu fiscal envoyé automatiquement',

    /* Footer */
    'footer.legal':     'Fonds de dotation en cours de constitution · Loi n°2008-776 du 4 août 2008.',
  },

  en: {
    /* Navigation */
    'nav.fondation':    'Foundation',
    'nav.gouvernance':  'Governance',
    'nav.package':      'Package',
    'nav.formation':    'Training',
    'nav.roadmap':      'Roadmap',
    'nav.communaute':   'Community',
    'nav.partenaire':   'Become a partner',
    'nav.don':          'Donate',

    /* Hero index */
    'hero.badge':       'Official CRAN package · April 2026',
    'hero.sub':         'Foundation for African Statistical Innovation & Open Data',
    'hero.quote':       '"statAfrikR is designed by and for African statisticians."',
    'hero.btn1':        'Discover statAfrikR',
    'hero.btn2':        'Become an NSO partner',
    'hero.stat1':       'CRAN downloads in 1 month',
    'hero.stat2':       'Documented functions v0.1.0',
    'hero.stat3':       'Target NSO partners (2028)',
    'hero.stat4':       'Statisticians to certify (2028)',

    /* Sections communes */
    'section.install':  'Install statAfrikR in 30 seconds',
    'section.why':      'Why statAfrikR is strategic for NSOs',
    'section.pipeline': 'Complete statistical pipeline — 5 integrated modules',
    'section.news':     'Follow statAfrikR\'s progress',
    'section.partner':  'Host the Foundation headquarters in your NSO',

    /* Don */
    'don.title':        'Support the statAfrikR Foundation',
    'don.sub':          'Your donation funds open source development, free training, and certifications for African statisticians.',
    'don.btn.10':       'Donate €10',
    'don.btn.25':       'Donate €25',
    'don.btn.50':       'Donate €50',
    'don.btn.libre':    'Custom amount',
    'don.deductible':   'Tax-deductible donation · Endowment Fund · Law n°2008-776',
    'don.receipt':      'Tax receipt sent automatically',

    /* Footer */
    'footer.legal':     'Endowment fund being established · Law n°2008-776 of 4 August 2008.',
  }
};

/* ── Appliquer les traductions ───────────────────────────────── */
function applyTranslations(lang) {
  const t = TRANSLATIONS[lang] || TRANSLATIONS.fr;
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.getAttribute('data-i18n');
    if (t[key] !== undefined) {
      if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
        el.placeholder = t[key];
      } else {
        el.innerHTML = t[key];
      }
    }
  });
  /* Attributs placeholder et title */
  document.querySelectorAll('[data-i18n-title]').forEach(el => {
    const key = el.getAttribute('data-i18n-title');
    if (t[key]) el.title = t[key];
  });
  /* Langue sur le html */
  document.documentElement.lang = lang;
  document.documentElement.setAttribute('data-lang', lang);
}

/* ── Init & toggle ───────────────────────────────────────────── */
function initI18n() {
  const stored = localStorage.getItem('saf-lang') || 'fr';
  applyTranslations(stored);

  /* Mettre le bon bouton actif */
  document.querySelectorAll('.lang-btn').forEach(btn => {
    btn.classList.toggle('active', btn.getAttribute('data-lang') === stored);
    btn.addEventListener('click', () => {
      const lang = btn.getAttribute('data-lang');
      localStorage.setItem('saf-lang', lang);
      applyTranslations(lang);
      document.querySelectorAll('.lang-btn').forEach(b =>
        b.classList.toggle('active', b.getAttribute('data-lang') === lang));
    });
  });
}

document.addEventListener('DOMContentLoaded', initI18n);
