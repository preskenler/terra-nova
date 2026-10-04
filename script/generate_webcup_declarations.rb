# frozen_string_literal: true

# Generates standardised, *French* "feature declaration" texts for the Webcup
# dashboard from REPORT.fr.md, which documents every demand.
#
#   ruby script/generate_webcup_declarations.rb
#
# Outputs:
#   tmp/webcup_declarations.json   (id, title, implemented, test_url,
#                                    jury_instructions, text — FR)
#   WEB_CUP_DECLARATIONS.md        (human-readable, copy/paste or review)
require "json"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
REPORT = File.join(ROOT, "REPORT.fr.md")
APP_URL = "https://preskenlair.lareunion.webcup.hodi.cloud"

report = File.read(REPORT)

def clean(text)
  text.to_s
      .gsub(/\*\*/, "")
      .gsub(/`/, "")
      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
      .strip
end

# First URL found in a "Où tester" value.
def first_url(text)
  text.to_s[/https?:\/\/[^\s`]+/]
end

sections = report.scan(/^## ((?:D|F)\d+)[^\n]*?—\s*([^\n]+)\n(.*?)(?=^## |\z)/m)

declarations = sections.map do |id, title, body|
  implemented = clean(body[/\*\*Ce que nous avons réalisé\.\*\*\s*(.*?)(?=\n\*\*|\z)/m, 1])
  where       = clean(body[/\*\*Où tester\.\*\*\s*(.*?)(?=\n\*\*|\z)/m, 1])
  how         = clean(body[/\*\*Comment vérifier\.\*\*\s*(.*?)(?=\n---|\z)/m, 1])
  test_url    = first_url(where) || APP_URL

  text = <<~TEXT.strip
    Fonctionnalité #{id} réalisée — #{title.strip}.

    Implémentation : #{implemented}
    Preuve : #{where} — application en ligne : #{APP_URL}/
    Notes (vérification) : #{how}
  TEXT

  {
    "id" => id.strip,
    "title" => title.strip,
    "implemented" => implemented,
    "test_url" => test_url,
    "jury_instructions" => how,
    "text" => text
  }
end

FileUtils.mkdir_p(File.join(ROOT, "tmp"))
File.write(File.join(ROOT, "tmp/webcup_declarations.json"), JSON.pretty_generate(declarations))

# JS map for pasting into the browser console (tmp/webcup_declarations.js).
js_map = declarations.to_h { |d| [ d["id"], d["text"] ] }
File.write(
  File.join(ROOT, "tmp/webcup_declarations.js"),
  "window.WEBCUP_DECLARATIONS = #{JSON.generate(js_map)};\n"
)

md = +"# Terra Nova — Déclarations de fonctionnalités (Webcup)\n\n"
md << "Généré automatiquement depuis `REPORT.fr.md`. À relire avant validation : " \
      "une pré-déclaration ne vaut pas validation.\n\n"
declarations.each do |d|
  md << "## #{d['id']} — #{d['title']}\n\n```text\n#{d['text']}\n```\n\n"
end
File.write(File.join(ROOT, "WEB_CUP_DECLARATIONS.md"), md)

puts "Generated #{declarations.size} declarations (FR)."
puts "  tmp/webcup_declarations.json"
puts "  WEB_CUP_DECLARATIONS.md"
