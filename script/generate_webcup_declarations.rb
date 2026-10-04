# frozen_string_literal: true

# Generates standardised "feature declaration" texts for the Webcup dashboard
# from REPORT.md, which already documents every demand.
#
#   ruby script/generate_webcup_declarations.rb
#
# Outputs:
#   tmp/webcup_declarations.json   (id + text, for the Playwright pre-fill script)
#   WEB_CUP_DECLARATIONS.md        (human-readable, copy/paste or review)
require "json"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
REPORT = File.join(ROOT, "REPORT.md")
APP_URL = "https://preskenler-terra-nova-f55b36d739c2.herokuapp.com"

report = File.read(REPORT)

def clean(text)
  text.to_s
      .gsub(/\*\*/, "")
      .gsub(/`/, "")
      .gsub(/\[([^\]]+)\]\([^)]+\)/, '\1')
      .strip
end

sections = report.scan(/^## ((?:D|F)\d+)[^\n]*?—\s*([^\n]+)\n(.*?)(?=^## |\z)/m)

declarations = sections.map do |id, title, body|
  what  = clean(body[/\*\*What we built\.\*\*\s*(.*?)(?=\n\*\*|\z)/m, 1])
  where = clean(body[/\*\*Where to test\.\*\*\s*(.*?)(?=\n\*\*|\z)/m, 1])
  how   = clean(body[/\*\*How to verify\.\*\*\s*(.*?)(?=\n---|\z)/m, 1])

  text = <<~TEXT.strip
    Fonctionnalité #{id} réalisée — #{title.strip}.

    Implémentation : #{what}
    Preuve : #{where} — application en ligne : #{APP_URL}/
    Notes (vérification) : #{how}
  TEXT

  { "id" => id.strip, "title" => title.strip, "text" => text }
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
md << "Généré automatiquement depuis `REPORT.md`. À relire avant validation : " \
      "une pré-déclaration ne vaut pas validation.\n\n"
declarations.each do |d|
  md << "## #{d['id']} — #{d['title']}\n\n```text\n#{d['text']}\n```\n\n"
end
File.write(File.join(ROOT, "WEB_CUP_DECLARATIONS.md"), md)

puts "Generated #{declarations.size} declarations."
puts "  tmp/webcup_declarations.json"
puts "  WEB_CUP_DECLARATIONS.md"
