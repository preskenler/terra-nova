// Helper to paste in the browser's DevTools console on the Webcup
// "/dashboard/fonctionnalites/" page.
//
// 1. Paste the content of tmp/webcup_declarations.js  (defines window.WEBCUP_DECLARATIONS)
// 2. Paste this file.
// 3. Open a "Déclaration" cell, then in the console run:  w('D01')
//
// It fills the currently-visible declaration field, handling React/Next-style
// controlled inputs. Nothing is submitted — review, then save manually.
window.w = function (id) {
  const all = window.WEBCUP_DECLARATIONS || {};
  const text = all[id];
  if (!text) {
    console.warn('Unknown id "' + id + '". Known ids: ' + Object.keys(all).join(', '));
    return;
  }

  const field =
    document.querySelector('textarea:not([hidden])') ||
    document.querySelector('[contenteditable="true"]');
  if (!field) {
    console.warn('No declaration field found — open a "Déclaration" first.');
    return;
  }

  if (field.tagName === 'TEXTAREA') {
    const setter = Object.getOwnPropertyDescriptor(
      window.HTMLTextAreaElement.prototype,
      'value'
    ).set;
    setter.call(field, text);
    field.dispatchEvent(new Event('input', { bubbles: true }));
    field.dispatchEvent(new Event('change', { bubbles: true }));
  } else {
    field.innerText = text;
    field.dispatchEvent(new InputEvent('input', { bubbles: true }));
  }

  console.log('✅ Filled ' + id + ' — review, then save.');
};

console.log(
  'Helper ready. Open a declaration and run w("D01") ' +
    '(ids: D01…F84). Nothing is submitted automatically.'
);
