# frozen_string_literal: true

# The production host (Hodifly/cPanel, glibc 2.28) forces Bundler's "ruby"
# platform for native gems, so the pure-ruby `tailwindcss-ruby` gem is installed
# and no `tailwindcss` executable exists. `assets:precompile` would abort.
#
# When the executable is unavailable, skip the CSS build and serve the
# precompiled stylesheet committed at app/assets/builds/tailwind.css.
# Run `bin/rails tailwindcss:build` locally after changing styles and commit
# the regenerated file.
if Rake::Task.task_defined?("tailwindcss:build")
  executable_available =
    begin
      require "tailwindcss/ruby"
      Tailwindcss::Ruby.executable
      true
    rescue StandardError
      false
    end

  unless executable_available
    warn "[tailwindcss] no standalone executable on this host — skipping the " \
         "build and serving the committed app/assets/builds/tailwind.css"
    Rake::Task["tailwindcss:build"].clear
  end
end
