// CSP対策のため、GA4をjsに切り分け
// GA_TRACKING_IDが未設定の環境（CI・開発環境など）ではmetaタグが出力されないため、何もしない
// （エラーになるとapplication.jsの後続処理（確認ダイアログの差し替え等）が実行されなくなる）
const trackingMeta = document.querySelector('meta[name="ga-tracking-id"]');
if (trackingMeta) {
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());
  gtag('config', trackingMeta.content);
}
