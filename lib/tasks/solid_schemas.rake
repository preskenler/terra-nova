# frozen_string_literal: true

# Solid Cache, Solid Queue and Solid Cable ship their tables in dedicated
# schema files (db/cache_schema.rb, db/queue_schema.rb, db/cable_schema.rb).
#
# On a single-database platform such as Heroku, all four connections point at
# the same PostgreSQL database. `bin/rails db:prepare` therefore sees the
# database already exists and skips loading the Solid schemas, leaving
# solid_cache_entries / solid_queue_* / solid_cable_messages missing.
#
# This task loads any missing Solid schema idempotently so it can run from the
# release phase on every deploy. It never touches the primary tables.
namespace :db do
  desc "Load the Solid Cache/Queue/Cable schemas if their tables are missing"
  task load_solid_schemas: :environment do
    {
      "cache" => "solid_cache_entries",
      "queue" => "solid_queue_jobs",
      "cable" => "solid_cable_messages"
    }.each do |name, table|
      config = ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: name)
      next if config.nil? || ActiveRecord::Base.connection.table_exists?(table)

      ActiveRecord::Tasks::DatabaseTasks.load_schema(
        config, :ruby, Rails.root.join("db/#{name}_schema.rb")
      )
      puts "Loaded #{name} schema (#{table})."
    end
  end
end
