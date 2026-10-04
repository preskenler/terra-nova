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

# Plain-language summaries of the essential information (F89): short, simple
# sentences that keep the meaning without the administrative jargon.
PLAIN_LANGUAGE = {
  "etat-civil" => {
    fr: "Vous avez besoin d'un acte de naissance, de mariage ou de décès ? Ce service les délivre. Pensez à vous munir d'une pièce d'identité.",
    en: "Need a birth, marriage or death certificate? This service issues them. Please bring an ID document."
  },
  "urbanisme" => {
    fr: "Vous voulez construire, agrandir ou clôturer ? Ce service instruit les demandes d'autorisation et explique les règles locales.",
    en: "Want to build, extend or fence? This service handles permit applications and explains the local rules."
  },
  "sante" => {
    fr: "Besoin de soins, d'un vaccin ou d'un conseil santé ? Le centre municipal vous accueille.",
    en: "Need care, a vaccine or health advice? The municipal centre welcomes you."
  },
  "urgences" => {
    fr: "Danger immédiat ? Appelez le 112. Ce service regroupe les numéros d'urgence de la ville.",
    en: "Immediate danger? Call 112. This service lists the city's emergency numbers."
  },
  "collecte-dechets" => {
    fr: "Vous cherchez les jours de collecte ou un service pour vos encombrants ? C'est ici.",
    en: "Looking for collection days or a way to dispose of bulky items? This is the place."
  },
  "transports" => {
    fr: "Bus, tram ou navette : horaires, itinéraires et abonnements sont réunis ici.",
    en: "Bus, tram or shuttle: timetables, routes and passes are gathered here."
  },
  "action-sociale" => {
    fr: "Vous ou un proche avez besoin d'aide ? Ce service accompagne les familles, les personnes âgées et les personnes en difficulté.",
    en: "Do you or a loved one need help? This service supports families, elderly people and those in difficulty."
  },
  "eclairage-public" => {
    fr: "Un lampadaire ne fonctionne pas ? Signalez-le ici : indiquez la rue et le problème.",
    en: "A streetlight is out? Report it here: give the street and the problem."
  },
  "voirie" => {
    fr: "Un trottoir abîmé ou un trou dans la chaussée ? Signalez-le ici avec le lieu précis.",
    en: "Damaged pavement or a pothole? Report it here with the exact location."
  },
  "eau-assainissement" => {
    fr: "Une fuite, une facture d'eau ou une question sur la qualité ? Ce service s'en occupe.",
    en: "A leak, a water bill or a quality question? This service handles it."
  },
  "culture-loisirs" => {
    fr: "Médiathèque, salles et activités culturelles : retrouvez ici toutes les inscriptions.",
    en: "Library, halls and cultural activities: find all registrations here."
  },
  "espaces-verts" => {
    fr: "Un parc, un jardin partagé ou un souci sur un espace vert ? Ce service en assure l'entretien.",
    en: "A park, a shared garden or an issue in a green space? This service maintains them."
  }
}.freeze

SERVICES.each do |attrs|
  service = Service.find_or_initialize_by(slug: attrs[:slug])
  plain = PLAIN_LANGUAGE[attrs[:slug]]
  service.assign_attributes(attrs)
  service.assign_attributes(plain_language_fr: plain[:fr], plain_language_en: plain[:en]) if plain
  service.save!
end
puts "  Services:     #{Service.count}"

# --- Transport lines, schedules and disruptions (F36) ----------------------
transport_lines = [
  { slug: "tram-t1", mode: "tram", color: "#176b3a",
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

# --- Announcements and alerts (D18/F29/F30/F31) ----------------------------
if Announcement.none?
  announcement = Announcement.new(severity: "info", target_audience: "all", published_at: Time.current, active: true)
  announcement.title_fr = "Travaux de rénovation de la place centrale"
  announcement.title_en = "Central square renovation works"
  announcement.body_fr = "Les travaux de rénovation de la place centrale débutent lundi. Des déviations sont mises en place."
  announcement.body_en = "Renovation works on the central square start on Monday. Diversions are in place."
  announcement.save!

  waste = Announcement.new(severity: "alert", target_audience: "citizens", published_at: 1.day.ago, active: true)
  waste.title_fr = "Nouveaux horaires de collecte des déchets"
  waste.title_en = "New waste collection times"
  waste.body_fr = "À partir du 1er novembre, la collecte des ordures ménagères aura lieu le matin au lieu du soir."
  waste.body_en = "From 1 November, household waste collection will take place in the morning instead of the evening."
  waste.save!
end

if Alert.none?
  flood = Alert.new(kind: "flood", severity: "critical", target_segment: "residents", locality: "Quartier sud",
                    latitude: 48.850, longitude: 2.360, radius_km: 2, starts_at: Time.current, active: true)
  flood.title_fr = "Montée inhabituelle du niveau de l'eau — quartier sud"
  flood.title_en = "Unusual water level rise — south district"
  flood.body_fr = "Le niveau de l'eau monte rapidement dans le quartier sud. Évitez les abords de la rivière et suivez les consignes des secours."
  flood.body_en = "Water levels are rising quickly in the south district. Avoid the riverbanks and follow emergency instructions."
  flood.save!

  heat = Alert.new(kind: "heatwave", severity: "alert", target_segment: "vulnerable", starts_at: Time.current, active: true)
  heat.title_fr = "Vague de chaleur : recommandations"
  heat.title_en = "Heatwave: recommendations"
  heat.body_fr = "Une vague de chaleur touche la ville. Buvez régulièrement, restez au frais et prenez des nouvelles de vos proches vulnérables."
  heat.body_en = "A heatwave is affecting the city. Drink regularly, stay cool and check on vulnerable relatives."
  heat.save!
end
puts "  Alerts:       #{Alert.count} alerts, #{Announcement.count} announcements"

# --- Participatory democracy (F65-F68) -------------------------------------
if Project.none?
  park = Project.new(status: "ongoing", category: "environnement", published: true,
                     starts_on: Date.current - 20, ends_on: Date.current + 120)
  park.name_fr = "Réaménagement du parc central"
  park.name_en = "Central park redevelopment"
  park.description_fr = "Création d'îlots de fraîcheur, aire de jeux et pistes cyclables au parc central."
  park.description_en = "Creation of cool islands, a playground and cycle paths in the central park."
  park.save!

  tram = Project.new(status: "planned", category: "mobilite", published: true, starts_on: Date.current + 30)
  tram.name_fr = "Nouvelle ligne de tram"
  tram.name_en = "New tram line"
  tram.description_fr = "Étude d'une nouvelle ligne de tram reliant le centre à l'université."
  tram.description_en = "Study of a new tram line linking the centre to the university."
  tram.save!
end

if Consultation.none?
  consultation = Consultation.new(
    project: Project.find_by(slug: "reamenagement-du-parc-central"),
    kind: "opinion", status: "open", opens_at: Time.current, closes_at: 30.days.from_now
  )
  consultation.title_fr = "Parc central : votre avis sur l'aire de jeux"
  consultation.title_en = "Central park: your opinion on the playground"
  consultation.description_fr = "Quelle place donner à l'aire de jeux dans le futur parc ? Donnez votre avis."
  consultation.description_en = "How much space should the playground take in the future park? Share your opinion."
  consultation.save!
end

if Idea.none?
  author = User.find_by(email: "citoyen@novaterra.fr")
  idea = author.ideas.new(category: "environnement")
  idea.title = "Plus de composteurs partagés"
  idea.description = "Installer des composteurs partagés dans chaque quartier pour réduire nos déchets."
  idea.save!
end
puts "  Participation: #{Project.count} projects, #{Consultation.count} consultations, #{Idea.count} ideas"

# --- Partners, pinned message and reviews (F73/F74/F76) --------------------
if Partner.none?
  partner = Partner.new(category: "sante", address: "Centre de santé partenaire, 5 rue des Soins",
                        latitude: 48.8545, longitude: 2.3495, phone: "01 98 76 54 32",
                        website: "https://partenaire.terra-nova.example", published: true)
  partner.name_fr = "Centre de santé Horizon"
  partner.name_en = "Horizon Health Centre"
  partner.description_fr = "Consultations sans rendez-vous du lundi au samedi."
  partner.description_en = "Walk-in consultations from Monday to Saturday."
  partner.save!
  [ 1, 2, 3, 4, 5 ].each do |wday|
    partner.partner_opening_hours.create!(wday: wday, opens_at: "08:30", closes_at: "18:00")
  end
  partner.partner_opening_hours.create!(wday: 6, opens_at: "09:00", closes_at: "12:00")
  partner.partner_opening_hours.create!(wday: 0, closed: true)
end

if Announcement.exists? && !Announcement.exists?(pinned: true)
  Announcement.published.first&.update(pinned: true)
end

if ServiceReview.none?
  service = Service.publicly_visible.first
  reviewer = User.find_by(email: "citoyen@novaterra.fr")
  if service && reviewer
    service.service_reviews.create!(user: reviewer, rating: 4,
                                    comment: "Service rapide et accueil agréable.")
  end
end
puts "  Partners:     #{Partner.count} partners, #{ServiceReview.count} reviews"

# --- Initial demand sync (optional) -----------------------------------------
if TerraNova::Webcup.configured?
  result = Demands::Sync.call
  status = result.sync.success? ? "ok" : "failed (#{result.sync.error})"
  puts "  Demand sync:  #{status} — #{Demand.count} demands, #{result.new_codes.size} new"
else
  puts "  Demand sync:  skipped (WEBCUP_API_KEY not set)"
end

puts "Done."
