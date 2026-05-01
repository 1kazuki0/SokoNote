// CSP対策のため、GA4をjsに切り分け
const trackingId = document.querySelector('meta[name="ga-tracking-id"]').content;
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());
gtag('config', trackingId);
