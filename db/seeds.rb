# Seed data for Nova Terra.
#
# Idempotent: safe to run repeatedly. Creates the demo accounts documented in
# the README and, when the Webcup API is configured, an initial demand sync.

puts "Seeding Nova Terra…"

# --- Municipal agents (agent workspace) -------------------------------------
agent = Agent.find_or_initialize_by(email: "agent@novaterra.fr")
agent.assign_attributes(password: "password123", role: "agent", locale: "fr")
agent.save!
puts "  Agent:  agent@novaterra.fr / password123"

admin_agent = Agent.find_or_initialize_by(email: "admin@novaterra.fr")
admin_agent.assign_attributes(password: "password123", role: "admin", locale: "fr")
admin_agent.save!
puts "  Agent admin:  admin@novaterra.fr / password123"

# --- Citizens ---------------------------------------------------------------
citizen = User.find_or_initialize_by(email: "citoyen@novaterra.fr")
citizen.assign_attributes(password: "password123", role: "citizen", locale: "fr",
                          onboarding_completed: true)
citizen.save!
puts "  Citizen: citoyen@novaterra.fr / password123"

admin_user = User.find_or_initialize_by(email: "admin@novaterra.fr")
admin_user.assign_attributes(password: "password123", role: "admin", locale: "fr",
                             onboarding_completed: true)
admin_user.save!
puts "  Citizen admin: admin@novaterra.fr / password123"

# --- Initial demand sync (optional) -----------------------------------------
if TerraNova::Webcup.configured?
  result = Demands::Sync.call
  status = result.sync.success? ? "ok" : "failed (#{result.sync.error})"
  puts "  Demand sync: #{status} — #{Demand.count} demands, #{result.new_codes.size} new"
else
  puts "  Demand sync skipped (WEBCUP_API_KEY not set)"
end

puts "Done."
