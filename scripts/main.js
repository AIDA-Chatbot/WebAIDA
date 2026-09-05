/* ============================================================
   AIDA — Main JavaScript
   ============================================================ */

(function () {
  'use strict';

  // --- Scroll: nav sticky -----------------------------------
  const nav = document.getElementById('nav');
  function onScroll() {
    nav.classList.toggle('is-scrolled', window.scrollY > 48);
  }
  window.addEventListener('scroll', onScroll, { passive: true });
  onScroll();

  // --- Mobile menu -----------------------------------------
  const hamburger = document.getElementById('hamburger');
  const mobileMenu = document.getElementById('mobile-menu');

  hamburger.addEventListener('click', function () {
    const isOpen = hamburger.classList.toggle('is-open');
    mobileMenu.classList.toggle('is-open', isOpen);
    hamburger.setAttribute('aria-expanded', String(isOpen));
  });

  // Close mobile menu on link click
  mobileMenu.querySelectorAll('a').forEach(function (link) {
    link.addEventListener('click', function () {
      hamburger.classList.remove('is-open');
      mobileMenu.classList.remove('is-open');
      hamburger.setAttribute('aria-expanded', 'false');
    });
  });

  // --- Scroll reveal ----------------------------------------
  const revealObserver = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          revealObserver.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.12, rootMargin: '0px 0px -40px 0px' }
  );

  document.querySelectorAll('.reveal, .stagger').forEach(function (el) {
    revealObserver.observe(el);
  });

  // Steps highlight on scroll
  const stepObserver = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        entry.target.classList.toggle('is-visible', entry.isIntersecting);
      });
    },
    { threshold: 0.5 }
  );

  document.querySelectorAll('.step').forEach(function (el) {
    stepObserver.observe(el);
  });

  // --- Waitlist form ----------------------------------------
  const form      = document.getElementById('waitlist-form');
  const input     = document.getElementById('waitlist-email');
  const btn       = document.getElementById('waitlist-btn');
  const successEl = document.getElementById('waitlist-success');
  const errorEl   = document.getElementById('waitlist-error');

  if (form) {
    form.addEventListener('submit', function (e) {
      e.preventDefault();

      const email = input.value.trim();

      // Clear previous state
      errorEl.textContent = '';
      errorEl.hidden = true;

      // Basic validation
      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        errorEl.textContent = 'Ingresá un correo electrónico válido.';
        errorEl.hidden = false;
        input.focus();
        return;
      }

      // Loading state
      btn.dataset.loading = '';
      btn.textContent = 'Enviando...';

      // Submit to Formspree (endpoint placeholder — replace YOUR_ID)
      fetch('https://formspree.io/f/YOUR_FORMSPREE_ID', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ email: email }),
      })
        .then(function (res) {
          if (res.ok) {
            form.hidden = true;
            successEl.classList.add('is-visible');
          } else {
            return res.json().then(function (data) {
              throw new Error(data.error || 'Error desconocido');
            });
          }
        })
        .catch(function (err) {
          errorEl.textContent = 'Hubo un problema al registrar tu correo. Intentá de nuevo o escribinos a aidaassistantbot@gmail.com';
          errorEl.hidden = false;
        })
        .finally(function () {
          delete btn.dataset.loading;
          btn.textContent = 'Anotarme';
        });
    });
  }

  // --- Smooth active nav link on scroll --------------------
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav__link[href^="#"]');

  const sectionObserver = new IntersectionObserver(
    function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          const id = entry.target.id;
          navLinks.forEach(function (link) {
            link.classList.toggle('nav__link--active', link.getAttribute('href') === '#' + id);
          });
        }
      });
    },
    { threshold: 0.35 }
  );

  sections.forEach(function (s) { sectionObserver.observe(s); });

})();
