/* ============================================================
   AIDA — Interacción del sitio
   ------------------------------------------------------------
   Sin dependencias. Todo degrada bien: si el JS no carga,
   la página sigue siendo legible y navegable.
   ============================================================ */
(function () {
  'use strict';

  /* --- Configuración -------------------------------------- */
  // Reemplazá por el ID real del formulario de Formspree (ej: 'xabcdefg').
  // Mientras diga 'YOUR_FORMSPREE_ID', el formulario invita a escribir por correo
  // en lugar de fingir que guardó el dato.
  var FORMSPREE_ID = 'YOUR_FORMSPREE_ID';
  var CONTACT_EMAIL = 'aidaassistantbot@gmail.com';

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  var $  = function (sel, ctx) { return (ctx || document).querySelector(sel); };
  var $$ = function (sel, ctx) { return Array.prototype.slice.call((ctx || document).querySelectorAll(sel)); };

  /* --- Año en el footer ----------------------------------- */
  var year = $('#year');
  if (year) year.textContent = new Date().getFullYear();

  /* --- Sombra de la barra al hacer scroll ----------------- */
  var nav = $('#nav');
  if (nav) {
    var onScroll = function () { nav.classList.toggle('is-scrolled', window.scrollY > 16); };
    window.addEventListener('scroll', onScroll, { passive: true });
    onScroll();
  }

  /* --- Menú móvil ----------------------------------------- */
  var burger = $('#burger');
  var drawer = $('#drawer');
  if (burger && drawer) {
    var closeDrawer = function () {
      burger.classList.remove('is-open');
      drawer.classList.remove('is-open');
      burger.setAttribute('aria-expanded', 'false');
    };

    burger.addEventListener('click', function () {
      var open = !drawer.classList.contains('is-open');
      burger.classList.toggle('is-open', open);
      drawer.classList.toggle('is-open', open);
      burger.setAttribute('aria-expanded', String(open));
    });

    $$('a', drawer).forEach(function (a) { a.addEventListener('click', closeDrawer); });

    document.addEventListener('keydown', function (e) {
      if (e.key === 'Escape' && drawer.classList.contains('is-open')) {
        closeDrawer();
        burger.focus();
      }
    });
  }

  /* --- Modo texto grande ---------------------------------- */
  var sizeBtn = $('#text-size');
  if (sizeBtn) {
    var KEY = 'aida:text-size';
    var apply = function (on) {
      document.documentElement.classList.toggle('is-large', on);
      sizeBtn.setAttribute('aria-pressed', String(on));
    };

    var saved = null;
    try { saved = localStorage.getItem(KEY); } catch (e) { /* modo privado */ }
    apply(saved === 'large');

    sizeBtn.addEventListener('click', function () {
      var on = sizeBtn.getAttribute('aria-pressed') !== 'true';
      apply(on);
      try { localStorage.setItem(KEY, on ? 'large' : 'normal'); } catch (e) { /* ignorar */ }
    });
  }

  /* --- Aparición al hacer scroll -------------------------- */
  var revealables = $$('.reveal, .stagger');
  if (reduceMotion || !('IntersectionObserver' in window)) {
    revealables.forEach(function (el) { el.classList.add('is-visible'); });
    $$('.step').forEach(function (el) { el.classList.add('is-visible', 'is-lit'); });
  } else {
    var revealObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        revealObserver.unobserve(entry.target);
      });
    }, { threshold: 0.12, rootMargin: '0px 0px -60px 0px' });

    revealables.forEach(function (el) { revealObserver.observe(el); });

    // Los números de los pasos se encienden mientras están en pantalla.
    // Usa una clase propia: 'is-visible' pertenece al reveal y no debe volver atrás.
    var stepObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        entry.target.classList.toggle('is-lit', entry.isIntersecting);
      });
    }, { threshold: 0.45 });
    $$('.step').forEach(function (el) { stepObserver.observe(el); });
  }

  /* --- Enlace activo en la navegación --------------------- */
  var navLinks = $$('.nav__links .nav__link');
  var sections = $$('main section[id]');
  if (navLinks.length && sections.length && 'IntersectionObserver' in window) {
    var setActive = function (id) {
      navLinks.forEach(function (link) {
        link.classList.toggle('is-active', link.getAttribute('href') === '#' + id);
      });
    };
    var sectionObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) { if (entry.isIntersecting) setActive(entry.target.id); });
    }, { rootMargin: '-45% 0px -50% 0px' });
    sections.forEach(function (s) { sectionObserver.observe(s); });
  }

  /* --- Animación del chat de ejemplo ---------------------- */
  var chat = $('#chat');
  var chatBody = $('#chat-body');
  var typing = $('#typing');
  var replay = $('#chat-replay');

  if (chat && chatBody) {
    var messages = $$('[data-msg]', chatBody);
    var timers = [];
    var run = 0;

    var clearTimers = function () {
      timers.forEach(clearTimeout);
      timers = [];
    };

    var later = function (fn, ms) {
      var id = run;
      timers.push(setTimeout(function () { if (id === run) fn(); }, ms));
    };

    var showAll = function () {
      messages.forEach(function (m) { m.classList.add('is-in'); });
      if (typing) typing.classList.remove('is-in');
      if (replay) replay.classList.remove('is-visible');
    };

    var play = function () {
      run += 1;
      clearTimers();
      messages.forEach(function (m) { m.classList.remove('is-in'); });
      if (typing) typing.classList.remove('is-in');
      if (replay) replay.classList.remove('is-visible');
      chatBody.scrollTop = 0;

      var t = 350;
      messages.forEach(function (msg, i) {
        var incoming = msg.classList.contains('msg--in');
        var thinking = incoming ? 850 : 0;

        if (incoming && typing) {
          later(function () {
            typing.classList.add('is-in');
            chatBody.scrollTop = chatBody.scrollHeight;
          }, t);
        }
        t += thinking;

        later(function () {
          if (typing) typing.classList.remove('is-in');
          msg.classList.add('is-in');
          chatBody.scrollTop = chatBody.scrollHeight;
          if (i === messages.length - 1 && replay) {
            later(function () { replay.classList.add('is-visible'); }, 900);
          }
        }, t);

        t += 1150;
      });
    };

    if (reduceMotion) {
      showAll();
      chatBody.scrollTop = chatBody.scrollHeight;
    } else if ('IntersectionObserver' in window) {
      var chatObserver = new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
          if (!entry.isIntersecting) return;
          chatObserver.disconnect();
          play();
        });
      }, { threshold: 0.35 });
      chatObserver.observe(chat);
    } else {
      showAll();
    }

    if (replay) replay.addEventListener('click', play);
  }

  /* --- Video: se carga recién al hacer clic --------------- */
  var facade = $('#video-facade');
  var videoWrap = $('#video-wrap');
  if (facade && videoWrap) {
    var videoId = videoWrap.getAttribute('data-video');

    // YouTube devuelve un gris de 120x90 cuando el video no tiene versión
    // maxres, y con estado 200: por eso no alcanza con 'onerror'.
    var thumb = $('#video-thumb');
    if (thumb) {
      var checkThumb = function () {
        if (thumb.naturalWidth && thumb.naturalWidth < 200) {
          thumb.src = 'https://i.ytimg.com/vi/' + videoId + '/hqdefault.jpg';
        }
      };
      if (thumb.complete) checkThumb();
      else thumb.addEventListener('load', checkThumb, { once: true });
    }

    facade.addEventListener('click', function () {
      var id = videoId;
      var iframe = document.createElement('iframe');
      iframe.src = 'https://www.youtube-nocookie.com/embed/' + id + '?autoplay=1&rel=0&hl=es';
      iframe.title = 'Video de presentación de AIDA — Samsung Innovation Campus 2025';
      iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
      iframe.allowFullscreen = true;
      iframe.loading = 'lazy';
      videoWrap.appendChild(iframe);
      facade.remove();
    });
  }

  /* --- Lista de espera ------------------------------------ */
  var form = $('#waitlist-form');
  if (form) {
    var input   = $('#waitlist-email');
    var btn     = $('#waitlist-btn');
    var errorEl = $('#waitlist-error');
    var okEl    = $('#waitlist-success');

    var fail = function (html) {
      errorEl.innerHTML = html;
      errorEl.hidden = false;
    };

    form.addEventListener('submit', function (e) {
      e.preventDefault();

      var email = input.value.trim();
      errorEl.hidden = true;
      errorEl.textContent = '';

      if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        fail('Revisá el correo: parece que le falta algo.');
        input.focus();
        return;
      }

      if (FORMSPREE_ID === 'YOUR_FORMSPREE_ID') {
        fail('Todavía estamos activando el formulario. Escribinos a ' +
             '<a href="mailto:' + CONTACT_EMAIL + '?subject=Lista%20de%20espera%20de%20AIDA" ' +
             'style="color:inherit;text-decoration:underline">' + CONTACT_EMAIL + '</a> ' +
             'y te anotamos a mano.');
        return;
      }

      btn.dataset.loading = '';
      var label = btn.textContent;
      btn.textContent = 'Enviando';

      fetch('https://formspree.io/f/' + FORMSPREE_ID, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
        body: JSON.stringify({ email: email, origen: 'WebAIDA — lista de espera' })
      })
        .then(function (res) {
          if (!res.ok) throw new Error('respuesta ' + res.status);
          form.hidden = true;
          okEl.classList.add('is-visible');
        })
        .catch(function () {
          fail('No pudimos registrar tu correo. Probá de nuevo o escribinos a ' +
               '<a href="mailto:' + CONTACT_EMAIL + '" style="color:inherit;text-decoration:underline">' +
               CONTACT_EMAIL + '</a>.');
        })
        .finally(function () {
          delete btn.dataset.loading;
          btn.textContent = label;
        });
    });
  }
})();
