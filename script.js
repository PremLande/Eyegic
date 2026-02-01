// Config
const WHATSAPP_NUMBER = "918600044322"; // E.164 format, no spaces (91 for India country code)

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

  // Enquiry form submission
  var enquiryForm = document.getElementById("enquiryForm");
  if (enquiryForm) {
    enquiryForm.addEventListener("submit", function (e) {
      e.preventDefault();
      
      var name = document.getElementById("name").value.trim();
      var phone = document.getElementById("phone").value.trim();
      var email = document.getElementById("email").value.trim();
      var message = document.getElementById("message").value.trim();
      var prescriptionFile = document.getElementById("prescription").files[0];
      
      // Build message
      var text = `*Enquiry from Eyegic Opticals Website*\n\n`;
      text += `*Name:* ${name || "(not provided)"}\n`;
      text += `*Phone:* ${phone || "(not provided)"}\n`;
      if (email) {
        text += `*Email:* ${email}\n`;
      }
      text += `\n*Message:*\n${message || "(no message)"}\n`;
      
      if (prescriptionFile) {
        text += `\n*Prescription:* File uploaded (${prescriptionFile.name})`;
        text += `\n\nNote: Please share the prescription file separately in this chat.`;
      }
      
      // Disable submit button
      var submitBtn = enquiryForm.querySelector('button[type="submit"]');
      if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.textContent = "Opening WhatsApp...";
      }
      
      // Open WhatsApp
      openWhatsApp(text);
      
      // Reset form after a delay
      setTimeout(function() {
        enquiryForm.reset();
        if (submitBtn) {
          submitBtn.disabled = false;
          submitBtn.textContent = "Submit Enquiry";
        }
        
        // Show success message
        var successMsg = document.createElement('div');
        successMsg.className = 'form-success';
        successMsg.textContent = '✓ Enquiry sent! Share your prescription in the WhatsApp chat if you uploaded one.';
        enquiryForm.appendChild(successMsg);
        
        setTimeout(function() {
          successMsg.remove();
        }, 5000);
      }, 1000);
    });
  }
});
