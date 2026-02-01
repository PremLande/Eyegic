// API Configuration - Use environment variable or default to relative path
const API_BASE_URL = window.API_BASE_URL || '/api';

// WhatsApp Configuration
const WHATSAPP_NUMBER = "+919309979538";

// Build WhatsApp URL
function buildWhatsAppUrl(message) {
    const encoded = encodeURIComponent(message);
    return `https://wa.me/${WHATSAPP_NUMBER}?text=${encoded}`;
}

// Open WhatsApp with message
function openWhatsApp(message) {
    const url = buildWhatsAppUrl(message);
    window.open(url, "_blank");
}

// API Functions
async function fetchEnquiries() {
    try {
        const response = await fetch(`${API_BASE_URL}/api/enquiries`);
        if (!response.ok) throw new Error('Failed to fetch enquiries');
        return await response.json();
    } catch (error) {
        console.error('Error fetching enquiries:', error);
        return [];
    }
}

async function createEnquiry(enquiryData) {
    try {
        const response = await fetch(`${API_BASE_URL}/api/enquiries`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(enquiryData)
        });
        if (!response.ok) throw new Error('Failed to create enquiry');
        return await response.json();
    } catch (error) {
        console.error('Error creating enquiry:', error);
        throw error;
    }
}

function displayEnquiries(enquiries) {
    const container = document.getElementById('enquiriesContainer');
    if (!container) return;

    if (enquiries.length === 0) {
        container.innerHTML = '<p class="no-enquiries">No enquiries yet. Be the first to enquire!</p>';
        return;
    }

    container.innerHTML = enquiries.map(enquiry => `
        <div class="enquiry-card">
            <div class="enquiry-header">
                <h3>${enquiry.name || 'Anonymous'}</h3>
                <span class="enquiry-date">${new Date(enquiry.created_at).toLocaleDateString()}</span>
            </div>
            ${enquiry.email ? `<p class="enquiry-email"><strong>Email:</strong> ${enquiry.email}</p>` : ''}
            ${enquiry.phone ? `<p class="enquiry-phone"><strong>Phone:</strong> ${enquiry.phone}</p>` : ''}
            ${enquiry.product ? `<p class="enquiry-product"><strong>Product:</strong> ${enquiry.product}</p>` : ''}
            ${enquiry.message ? `<p class="enquiry-message">${enquiry.message}</p>` : ''}
        </div>
    `).join('');
}

// Initialize when DOM is ready
document.addEventListener("DOMContentLoaded", function() {
    // Set current year in footer
    const yearEl = document.getElementById("year");
    if (yearEl) {
        yearEl.textContent = new Date().getFullYear();
    }

    // Generic WhatsApp buttons
    const genericButtons = document.querySelectorAll('[data-whatsapp-intent="generic"]');
    genericButtons.forEach(function(btn) {
        btn.addEventListener("click", function(e) {
            e.preventDefault();
            openWhatsApp("Hello Eyegic Opticals! I would like to enquire about your products and services.");
        });
    });

    // Product enquiry buttons
    const productButtons = document.querySelectorAll('.btn[data-product]');
    productButtons.forEach(function(btn) {
        btn.addEventListener("click", async function(e) {
            e.preventDefault();
            const product = btn.getAttribute("data-product") || "Product";
            
            // Show prompt for quick enquiry
            const name = prompt("Enter your name for the enquiry:");
            if (!name) return;
            
            const message = prompt("Enter your message (optional):");
            
            try {
                await createEnquiry({
                    name,
                    product,
                    message: message || null
                });
                
                alert('Thank you! Your enquiry has been submitted.');
                loadEnquiries();
            } catch (error) {
                // Fallback to WhatsApp if API fails
                openWhatsApp(`Hi! I'm interested in: ${product}. Could you please share more details and availability?`);
            }
        });
    });

    // Contact form submission
    const contactForm = document.getElementById("contactForm");
    if (contactForm) {
        contactForm.addEventListener("submit", async function(e) {
            e.preventDefault();
            const name = document.getElementById("name").value.trim();
            const email = document.getElementById("email").value.trim();
            const phone = document.getElementById("phone").value.trim();
            const message = document.getElementById("message").value.trim();
            
            if (!name || !message) {
                alert("Please fill in name and message fields.");
                return;
            }

            const submitButton = contactForm.querySelector('button[type="submit"]');
            const originalText = submitButton.textContent;
            submitButton.disabled = true;
            submitButton.textContent = 'Submitting...';

            try {
                await createEnquiry({
                    name,
                    email: email || null,
                    phone: phone || null,
                    message
                });
                
                alert('Thank you! Your enquiry has been submitted successfully.');
                contactForm.reset();
                
                // Refresh enquiries list
                loadEnquiries();
            } catch (error) {
                alert('Failed to submit enquiry. Please try again or contact us via WhatsApp.');
                console.error('Error:', error);
            } finally {
                submitButton.disabled = false;
                submitButton.textContent = originalText;
            }
        });
    }

    // Load and display enquiries
    async function loadEnquiries() {
        const enquiries = await fetchEnquiries();
        displayEnquiries(enquiries);
    }

    // Load enquiries on page load
    loadEnquiries();
    
    // Refresh enquiries every 30 seconds
    setInterval(loadEnquiries, 30000);

    // Smooth scroll for navigation links
    const navLinks = document.querySelectorAll('a[href^="#"]');
    navLinks.forEach(function(link) {
        link.addEventListener("click", function(e) {
            const href = this.getAttribute("href");
            if (href !== "#" && href.length > 1) {
                const target = document.querySelector(href);
                if (target) {
                    e.preventDefault();
                    target.scrollIntoView({
                        behavior: "smooth",
                        block: "start"
                    });
                }
            }
        });
    });
});
