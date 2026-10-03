# Seed data for Nova Terra.
#
# Idempotent: safe to run repeatedly. Creates the demo accounts documented in
# the README, the municipal catalog (services, transport, glossary) and, when
# the Webcup API is configured, an initial demand sync.

puts "Seeding Nova Terra…"

# --- Municipal agents (agent workspace) -------------------------------------
agent = Agent.find_or_initialize_by(email: "agent@novaterra.fr")
agent.assign_attributes(password: "password123", role: "agent", locale: "fr")
agent.save!
puts "  Agent:        agent@novaterra.fr / password123"

admin_agent = Agent.find_or_initialize_by(email: "admin@novaterra.fr")
admin_agent.assign_attributes(password: "password123", role: "admin", locale: "fr")
admin_agent.save!
puts "  Agent admin:  admin@novaterra.fr / password123"

# --- Citizens ---------------------------------------------------------------
citizen = User.find_or_initialize_by(email: "citoyen@novaterra.fr")
citizen.assign_attributes(password: "password123", role: "citizen", locale: "fr",
                          onboarding_completed: true)
citizen.save!
citizen.create_profile if citizen.profile.nil?
puts "  Citizen:      citoyen@novaterra.fr / password123"

admin_user = User.find_or_initialize_by(email: "admin@novaterra.fr")
admin_user.assign_attributes(password: "password123", role: "admin", locale: "fr",
                             onboarding_completed: true)
admin_user.save!
admin_user.create_profile if admin_user.profile.nil?
puts "  Citizen admin: admin@novaterra.fr / password123"

# --- Municipal services (D05/D07/F27/F28/F32/F38/F46) -----------------------
SERVICES = [
  {
    slug: "etat-civil", category: "etat_civil", priority: true,
    address: "Hôtel de Ville, 1 place de la République", contact_phone: "01 23 45 67 89",
    latitude: 48.8566, longitude: 2.3522,
    name_fr: "État civil", name_en: "Civil registry",
    description_fr: "Actes de naissance, mariage, décès, livret de famille et recensement citoyen.",
    description_en: "Birth, marriage and death certificates, family records and citizen registration."
  },
  {
    slug: "urbanisme", category: "urbanisme", priority: false,
    address: "Service urbanisme, 4 rue des Bâtisseurs", contact_phone: "01 23 45 67 90",
    latitude: 48.8580, longitude: 2.3500,
    name_fr: "Urbanisme", name_en: "Urban planning",
    description_fr: "Permis de construire, déclarations préalables et informations sur le plan local d'urbanisme.",
    description_en: "Building permits, prior declarations and local planning information."
  },
  {
    slug: "sante", category: "sante", priority: true,
    address: "Centre municipal de santé, 10 avenue Pasteur", contact_phone: "01 23 45 67 91",
    latitude: 48.8540, longitude: 2.3480,
    name_fr: "Santé", name_en: "Health",
    description_fr: "Centre de santé municipal, vaccins, campagne de prévention et accès aux soins.",
    description_en: "Municipal health centre, vaccinations, prevention campaigns and access to care."
  },
  {
    slug: "urgences", category: "urgence", priority: true, emergency: true,
    address: "Hôpital de Nova Terra, 100 boulevard de la Résilience", contact_phone: "112",
    latitude: 48.8500, longitude: 2.3600,
    name_fr: "Urgences", name_en: "Emergency services",
    description_fr: "Numéros d'urgence et services d'urgence de la ville. En cas de danger immédiat, appelez le 112.",
    description_en: "Emergency numbers and city emergency services. In immediate danger, call 112."
  },
  {
    slug: "collecte-dechets", category: "dechets", priority: true,
    address: "Centre technique municipal, 2 rue du Recyclage", contact_phone: "01 23 45 67 92",
    latitude: 48.8620, longitude: 2.3550,
    name_fr: "Collecte des déchets", name_en: "Waste collection",
    description_fr: "Calendrier de collecte, encombrants, compostage et propreté de la ville.",
    description_en: "Collection calendar, bulky items, composting and city cleanliness."
  },
  {
    slug: "transports", category: "transports", priority: false,
    address: "Maison des mobilités, 7 place des Voyageurs", contact_phone: "01 23 45 67 93",
    latitude: 48.8570, longitude: 2.3580,
    name_fr: "Transports municipaux", name_en: "Public transport",
    description_fr: "Lignes de bus, tram et navettes, horaires et abonnements.",
    description_en: "Bus, tram and shuttle lines, timetables and passes."
  },
  {
    slug: "action-sociale", category: "social", priority: false,
    address: "Centre communal d'action sociale, 5 rue de la Fraternité", contact_phone: "01 23 45 67 94",
    latitude: 48.8590, longitude: 2.3460,
    name_fr: "Action sociale", name_en: "Social services",
    description_fr: "Aide aux familles, personnes âgées et personnes en situation de précarité.",
    description_en: "Support for families, elderly people and those in precarious situations."
  },
  {
    slug: "eclairage-public", category: "environnement", priority: false,
    address: "Services techniques, 22 rue de l'Aube", contact_phone: "01 23 45 67 95",
    latitude: 48.8550, longitude: 2.3620,
    name_fr: "Éclairage public", name_en: "Street lighting",
    description_fr: "Signalez un lampadaire cassé, éteint ou un problème d'éclairage dans votre rue.",
    description_en: "Report a broken, unlit or faulty streetlight in your street."
  },
  {
    slug: "voirie", category: "environnement", priority: false,
    address: "Services techniques, 22 rue de l'Aube", contact_phone: "01 23 45 67 96",
    latitude: 48.8555, longitude: 2.3615,
    name_fr: "Voirie et espaces publics", name_en: "Roads and public spaces",
    description_fr: "Trous dans la chaussée, trottoirs abîmés, signalisation et mobilier urbain.",
    description_en: "Potholes, damaged pavements, signage and street furniture."
  },
  {
    slug: "eau-assainissement", category: "environnement", priority: false,
    address: "Régie des eaux, 15 quai de la Rivière", contact_phone: "01 23 45 67 97",
    latitude: 48.8530, longitude: 2.3520,
    status: "maintenance",
    maintenance_message_fr: "Le portail de gestion des abonnements est en maintenance. Les relevés reprendront normalement.",
    maintenance_message_en: "The subscription management portal is under maintenance. Readings will resume normally.",
    expected_return: "Demain à 9h",
    name_fr: "Eau et assainissement", name_en: "Water and sanitation",
    description_fr: "Abonnements, relevés de compteur, fuites et qualité de l'eau.",
    description_en: "Subscriptions, meter readings, leaks and water quality."
  },
  {
    slug: "culture-loisirs", category: "loisirs", priority: false,
    address: "Médiathèque, 3 place des Arts", contact_phone: "01 23 45 67 98",
    latitude: 48.8600, longitude: 2.3540,
    name_fr: "Culture et loisirs", name_en: "Culture and leisure",
    description_fr: "Médiathèque, salles municipales, événements culturels et inscriptions aux activités.",
    description_en: "Library, municipal halls, cultural events and activity registrations."
  },
  {
    slug: "espaces-verts", category: "environnement", priority: false,
    address: "Parc municipal, entrée nord", contact_phone: "01 23 45 67 99",
    latitude: 48.8640, longitude: 2.3500,
    name_fr: "Espaces verts", name_en: "Green spaces",
    description_fr: "Parcs, jardins partagés et entretien des espaces végétalisés.",
    description_en: "Parks, shared gardens and upkeep of green spaces."
  }
].freeze

SERVICES.each do |attrs|
  service = Service.find_or_initialize_by(slug: attrs[:slug])
  service.assign_attributes(attrs)
  service.save!
end
puts "  Services:     #{Service.count}"

# --- Transport lines, schedules and disruptions (F36) ----------------------
transport_lines = [
  { slug: "tram-t1", mode: "tram", color: "#0055a4",
    name_fr: "Tram T1", name_en: "Tram T1",
    description_fr: "Gare centrale ↔ Université, toutes les 8 minutes en semaine.",
    description_en: "Central station ↔ University, every 8 minutes on weekdays." },
  { slug: "bus-b2", mode: "bus", color: "#00a651",
    name_fr: "Bus B2", name_en: "Bus B2",
    description_fr: "Centre-ville ↔ Quartier sud, desserte des équipements publics.",
    description_en: "City centre ↔ South district, serving public facilities." },
  { slug: "navette-c3", mode: "navette", color: "#f2a900",
    name_fr: "Navette Centre", name_en: "City shuttle",
    description_fr: "Navette gratuite du centre historique, toutes les 15 minutes.",
    description_en: "Free shuttle of the historic centre, every 15 minutes." }
]

transport_lines.each do |attrs|
  line = TransportLine.find_or_initialize_by(slug: attrs[:slug])
  line.assign_attributes(attrs)
  line.save!
end

if TransportSchedule.none?
  tram = TransportLine.find_by(slug: "tram-t1")
  [ 1, 2, 3, 4, 5 ].each do |wday|
    tram.transport_schedules.create!(wday: wday, first_departure: "05:30", last_departure: "23:00", frequency_minutes: 8)
  end
  tram.transport_schedules.create!(wday: 6, first_departure: "06:00", last_departure: "23:30", frequency_minutes: 12)
  tram.transport_schedules.create!(wday: 0, first_departure: "07:00", last_departure: "22:00", frequency_minutes: 15)

  bus = TransportLine.find_by(slug: "bus-b2")
  [ 1, 2, 3, 4, 5, 6 ].each do |wday|
    bus.transport_schedules.create!(wday: wday, first_departure: "05:45", last_departure: "22:30", frequency_minutes: 10)
  end
end

if TransportDisruption.none?
  bus = TransportLine.find_by(slug: "bus-b2")
  disruption = bus.transport_disruptions.new(
    severity: "warning", starts_at: Time.current, ends_at: 3.days.from_now
  )
  disruption.message_fr = "Arrêt « Place des Arts » non desservi en raison de travaux, jusqu'à vendredi."
  disruption.message_en = "Stop “Place des Arts” not served due to works, until Friday."
  disruption.save!
end
puts "  Transports:   #{TransportLine.count} lines, #{TransportDisruption.count} disruptions"

# --- Glossary (D13) ---------------------------------------------------------
GLOSSARY = [
  { slug: "signalement",
    term_fr: "Signalement", term_en: "Report",
    definition_fr: "Action de prévenir la ville d'un problème constaté (voirie, éclairage, propreté…).",
    definition_en: "Reporting a problem you have noticed to the city (roads, lighting, cleanliness…)." },
  { slug: "demarche",
    term_fr: "Démarche", term_en: "Procedure",
    definition_fr: "Ensemble des étapes nécessaires pour obtenir une prestation municipale.",
    definition_en: "The set of steps required to obtain a municipal service." },
  { slug: "justificatif",
    term_fr: "Justificatif", term_en: "Supporting document",
    definition_fr: "Document qui prouve une information (identité, domicile, revenus…).",
    definition_en: "A document proving information (identity, address, income…)." },
  { slug: "attestation",
    term_fr: "Attestation", term_en: "Certificate",
    definition_fr: "Document officiel délivré par la mairie confirmant un fait ou un droit.",
    definition_en: "An official document issued by the town hall confirming a fact or a right." }
].freeze

GLOSSARY.each do |attrs|
  term = GlossaryTerm.find_or_initialize_by(slug: attrs[:slug])
  term.assign_attributes(attrs)
  term.save!
end
puts "  Glossary:     #{GlossaryTerm.count} terms"

# --- Agent availability (F39) ----------------------------------------------
Agent.find_each do |agent_record|
  next if agent_record.agent_availabilities.exists?

  [ 1, 2, 3, 4, 5 ].each do |wday|
    agent_record.agent_availabilities.create!(wday: wday, start_time: "09:00", end_time: "12:00", slot_minutes: 30)
    agent_record.agent_availabilities.create!(wday: wday, start_time: "14:00", end_time: "17:00", slot_minutes: 30)
  end
end
puts "  Availability: #{AgentAvailability.count} ranges"

# --- Initial demand sync (optional) -----------------------------------------
if TerraNova::Webcup.configured?
  result = Demands::Sync.call
  status = result.sync.success? ? "ok" : "failed (#{result.sync.error})"
  puts "  Demand sync:  #{status} — #{Demand.count} demands, #{result.new_codes.size} new"
else
  puts "  Demand sync:  skipped (WEBCUP_API_KEY not set)"
end

puts "Done."
