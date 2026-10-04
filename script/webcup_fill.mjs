// Optional Playwright pre-fill for the Webcup "fonctionnalités" dashboard.
//
// It NEVER sees your password: it opens a browser, you log in manually the first
// time (the session is stored in tmp/webcup-browser, git-ignored), then it fills
// each declaration. Nothing is submitted unless you pass --submit.
//
// Setup (do NOT add a package.json at the repo root — the Ruby build step
// would then try to install Node):
//   mkdir -p /tmp/webcup-automation && cd /tmp/webcup-automation
//   npm i playwright && npx playwright install chromium
//   NODE_PATH=/tmp/webcup-automation/node_modules node \
//     /Users/clement/preskenler/terra-nova/script/webcup_fill.mjs
//
// Flags:
//   --only=D01,F22   fill just these ids
//   --submit         click the save button too (review first!)
//   --no-pause       close the browser at the end
import { chromium } from "playwright";
import { readFileSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join } from "node:path";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const DASHBOARD = "https://24h.webcup.fr/dashboard/fonctionnalites/";
const args = new Set(process.argv.slice(2));
const submit = args.has("--submit");
const only = (args.has("--only") ? process.argv.find((a) => a.startsWith("--only")) : null)
  ?.split("=")[1]?.split(",");

// Adapt these if the dashboard markup differs.
const SELECTORS = {
  field: 'textarea:not([hidden]), [contenteditable="true"]',
  save: 'button:has-text("Enregistrer"), button:has-text("Valider"), button:has-text("Soumettre")'
};

const declarations = JSON.parse(
  readFileSync(join(ROOT, "tmp/webcup_declarations.json"), "utf8")
).filter((d) => !only || only.includes(d.id));

console.log(`${declarations.length} déclaration(s) à pré-remplir.`);

const context = await chromium.launchPersistentContext(join(ROOT, "tmp/webcup-browser"), {
  headless: false,
  viewport: { width: 1400, height: 900 }
});
const page = context.pages()[0] || (await context.newPage());

await page.goto(DASHBOARD, { waitUntil: "domcontentloaded" });
if (!page.url().includes("/dashboard/")) {
  console.log("→ Connecte-toi dans la fenêtre ouverte (ton mot de passe reste privé).");
  await page.waitForURL(/\/dashboard\//, { timeout: 0 });
}

for (const { id, text } of declarations) {
  try {
    const cell = page.getByText(id, { exact: true }).first();
    await cell.scrollIntoViewIfNeeded();
    await cell.click();
    await page.waitForTimeout(600);

    const field = page.locator(SELECTORS.field).first();
    await field.waitFor({ state: "visible", timeout: 5000 });
    await field.fill(text);

    if (submit) {
      const save = page.locator(SELECTORS.save).first();
      if (await save.count()) {
        await save.click();
        await page.waitForTimeout(600);
      }
    }
    console.log(`  ✓ ${id}`);
  } catch (e) {
    console.warn(`  ! ${id}: ${String(e.message).split("\n")[0]}`);
  }
}

console.log(submit ? "Terminé (soumis)." : "Pré-remplissage terminé — relis puis enregistre manuellement.");
if (args.has("--no-pause")) await context.close();
else await page.pause();
