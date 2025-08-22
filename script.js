// Config
const WHATSAPP_NUMBER = "+919309979538"; // E.164 format, no spaces

// Helpers
function buildWhatsAppUrl(message) {
  const encoded = encodeURIComponent(message);
  return `https://wa.me/${WHATSAPP_NUMBER}?text=${encoded}`;
}

function openWhatsApp(message) {
  const url = buildWhatsAppUrl(message);
  window.open(url, "_blank");
}

// Bind dynamic year
document.addEventListener("DOMContentLoaded", function () {
  var yearEl = document.getElementById("year");
  if (yearEl) {
    yearEl.textContent = new Date().getFullYear();
  }

  // Generic intent buttons
  var genericButtons = document.querySelectorAll('[data-whatsapp-intent="generic"]');
  genericButtons.forEach(function (btn) {
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      openWhatsApp("Hello Eyegic Opticals! I would like to enquire about your products.");
    });
  });

  // Product Buy/Enquire buttons
  var productButtons = document.querySelectorAll('.btn-buy[data-product]');
  productButtons.forEach(function (btn) {
    btn.addEventListener("click", function (e) {
      e.preventDefault();
      var product = btn.getAttribute("data-product") || "Product";
      openWhatsApp(`Hi! I'm interested in: ${product}. Could you share details and availability?`);
    });
  });

  // Contact form → WhatsApp
  var form = document.getElementById("contactForm");
  if (form) {
    form.addEventListener("submit", function (e) {
      e.preventDefault();
      var name = document.getElementById("name").value.trim();
      var message = document.getElementById("message").value.trim();
      var text = `Hello! My name is ${name || "(not provided)"}.\n${message || "(no message)"}`;
      openWhatsApp(text);
    });
  }

  // Simple carousel
  var slides = Array.from(document.querySelectorAll('.hero-carousel .slide'));
  var dots = Array.from(document.querySelectorAll('.hero-carousel .dot'));
  var current = 0;
  function goTo(index) {
    if (!slides.length) return;
    slides[current].classList.remove('active');
    if (dots[current]) dots[current].classList.remove('active');
    current = (index + slides.length) % slides.length;
    slides[current].classList.add('active');
    if (dots[current]) dots[current].classList.add('active');
  }
  dots.forEach(function (d) {
    d.addEventListener('click', function () { goTo(parseInt(d.getAttribute('data-index'), 10)); });
  });
  if (slides.length) {
    setInterval(function () { goTo(current + 1); }, 4000);
  }

  // Filters
  var filterButtons = document.querySelectorAll('.filter-btn');
  var productCards = document.querySelectorAll('.product-grid .card');
  function applyFilter(category) {
    productCards.forEach(function (card) {
      var cats = (card.getAttribute('data-category') || '').split(/\s+/);
      var show = category === 'All' || cats.includes(category);
      card.style.display = show ? '' : 'none';
    });
  }
  filterButtons.forEach(function (btn) {
    btn.addEventListener('click', function () {
      filterButtons.forEach(function (b) { b.classList.remove('active'); });
      btn.classList.add('active');
      applyFilter(btn.getAttribute('data-filter'));
    });
  });

  // Category cards link → set filter on arrival
  var categoryCards = document.querySelectorAll('.category-card');
  categoryCards.forEach(function (card) {
    card.addEventListener('click', function () {
      var target = card.getAttribute('data-filter');
      setTimeout(function () {
        var btn = document.querySelector('.filter-btn[data-filter="' + target + '"]');
        if (btn) btn.click();
      }, 0);
    });
  });

  // Search
  var searchInput = document.getElementById('globalSearch');
  var searchBtn = document.getElementById('searchBtn');
  function runSearch() {
    var q = (searchInput && searchInput.value || '').toLowerCase();
    if (!q) { productCards.forEach(function (c) { c.style.display = ''; }); return; }
    productCards.forEach(function (card) {
      var text = card.textContent.toLowerCase();
      card.style.display = text.indexOf(q) > -1 ? '' : 'none';
    });
    // Jump to products
    var products = document.getElementById('products');
    if (products) products.scrollIntoView({ behavior: 'smooth' });
  }
  if (searchBtn) searchBtn.addEventListener('click', runSearch);
  if (searchInput) searchInput.addEventListener('keydown', function (e) { if (e.key === 'Enter') { e.preventDefault(); runSearch(); } });
});


