# Terra Nova — Dossier de soumission Webcup

## Présentation du projet

**Terra Nova — le cœur numérique de la ville**

Terra Nova est une plateforme municipale tout-en-un qui place la relation entre les
habitants et leur administration au centre : accéder aux services de la ville, signaler
un problème, suivre l'avancement d'une demande, prendre rendez-vous, consulter les
actualités et les alertes, et participer aux projets et consultations de la commune.

Partis pris forts de l'équipe :

- **Accessibilité d'abord** — interface utilisable par tous (contraste élevé, texte
  agrandi, navigation clavier, lecteurs d'écran), déclaration WCAG 2.2 AA, mode
  « économie de données » et mode « simple » pour les connexions lentes.
- **Multilingue** — français, anglais et espagnol, avec des contenus traduisibles
  (services, actualités, alertes, partenaires).
- **Souveraineté et traçabilité** — comptes distincts citoyens / agents / administrateurs
  (rôles, Pundit), journal d'audit (PaperTrail) et journal d'événements de sécurité
  réservé aux administrateurs.
- **Sécurité au service de l'habitant** — connexion sans mot de passe par lien magique,
  authentification à deux facteurs (TOTP), alerte de connexion depuis un nouvel appareil,
  protection anti-robots et anti-doublons des formulaires.
- **Éco-conception** — mesures de poids d'actifs et budgets de performance affichés sur une
  page dédiée, compression des réponses, chargement conditionnel des cartes.
- **Ouverture** — la plateforme consomme en direct l'API « Terra Nova » diffusée pendant
  l'événement et expose chaque demande dans l'espace agent, qui peut la traiter sans
  reconstruction.

Pensée comme un produit réel et évolutif, l'application absorbe de nouvelles exigences
sans refonte : base Rails 8.1 avec Hotwire, composants d'interface réutilisables et
couverture de tests automatisés complète.

## Technologies utilisées

- **Back-end** : Ruby **3.3.12**, Ruby on Rails **8.1** (MVC, Active Job, Action Mailer,
  multi-bases de données)
- **Front-end / interactivité** : Hotwire — **Turbo + Stimulus** (sans SPA),
  **importmaps** (aucun outillage Node.js)
- **Composants d'interface** : **ViewComponents**
- **Styles** : **Tailwind CSS** + **daisyUI** (thème, contraste élevé), via
  `tailwindcss-rails`
- **Base de données** : **MySQL 8.4**
- **Files d'attente / cache / temps réel** : **Solid Queue**, **Solid Cache**,
  **Solid Cable**
- **Authentification & autorisation** : **Devise** (deux scopes : citoyen et agent),
  **Pundit**
- **Traçabilité** : **PaperTrail** (journal d'audit) et journal d'événements de sécurité
- **Sécurité** : **rack-attack** (limitation de débit / anti-force brute), CSP avec nonces,
  HSTS, cookies sécurisés, protection anti-robots et anti-doublons des formulaires
- **Cartographie** : **Leaflet** + **OpenStreetMap** (import dynamique)
- **Internationalisation** : I18n (FR / EN / ES)
- **Tests & qualité** : **Minitest** (unitaires, contrôleurs, intégration, système),
  **RuboCop**, **Brakeman**, audit des dépendances et des importmaps
- **Infrastructure** : **cPanel / Hostinger** (application Ruby, base MySQL 8.4),
  **SMTP** (envoi d'e-mails via variables d'environnement), CI **GitHub Actions**

## Informations utiles pour tester votre projet

**URL de l'application :** <https://preskenlair.lareunion.webcup.hodi.cloud/>

### Comptes de démonstration (créés pour le jury)

| Rôle | Identifiant | Mot de passe |
|---|---|---|
| Citoyen (espace personnel) | `citoyen@novaterra.fr` | `password123` |
| Agent municipal | `agent@novaterra.fr` | `password123` |
| Agent **administrateur** (sécurité, comptes, audit) | `admin@novaterra.fr` | `password123` |

> La langue se change à tout moment (FR / EN / ES) et les réglages d'accessibilité
> (contraste, texte agrandi, mode simple, économie de données) sont accessibles depuis le
> bandeau « Accessibilité ».

### Parcours conseillé (environ 10 minutes)

1. **Pages publiques** — accueil, `/services` (catalogue, services prioritaires, statut
   « en maintenance »), `/transports`, `/glossary`, `/projects` et `/ideas` (démocratie
   participative), `/alerts` (alerte inondation / canicule), `/partners` (horaires).
2. **Espace citoyen** — se connecter avec `citoyen@novaterra.fr` : onboarding, puis
   **créer une demande** (objet, description, localisation sur la carte). On obtient un
   **accusé de réception avec une référence** (`NOVA-AAAA-XXXXX`) ; renvoyer le même
   formulaire immédiatement montre la **protection anti-doublon**.
3. **Suivi** — retrouver sa demande, son avancement et ses réponses ; prendre un
   **rendez-vous** ; tester les **notifications** ; consulter `/account/data` (export JSON
   de ses données) et l'export **CSV** de ses demandes.
4. **Sécurité** — demander un **lien de connexion sans mot de passe**
   (`/users/magic_link`) et activer la **double authentification** dans
   `Profil → Double authentification`.
5. **Espace agent** — se connecter avec `admin@novaterra.fr` : `/agents` (tableau de bord),
   **`/agents/demands`** qui affiche **en direct le flux de l'API Terra Nova**, la **file
   des demandes citoyennes** (priorisation, détection de doublons, **réponse directe à un
   citoyen**), les actualités/alertes, les avis, les projets/consultations/idées, le
   **journal d'audit** et le **journal de sécurité** (administrateurs uniquement).
6. **Qualité & éco-conception** — `/status` (état du système), `/eco` (poids et budgets des
   ressources), `/accessibility` (déclaration WCAG 2.2 AA) et `/transparency`.

**Consignes spécifiques :** la protection anti-robots des formulaires est active (un envoi
suspect est bloqué avec un message clair et journalisé) ; les e-mails sont envoyés via SMTP
(configuré par variables d'environnement), donc un lien magique arrive dans la boîte configurée.

## Déclaration des fonctionnalités (automatisée)

Les textes de déclaration sont générés **en français** depuis `REPORT.fr.md`, puis envoyés au
tableau de bord Webcup.

1. **Générer** les déclarations (JSON + `WEB_CUP_DECLARATIONS.md`) :

   ```sh
   ruby script/generate_webcup_declarations.rb
   ```

2. **Envoyer** au dashboard (le nonce est récupéré automatiquement ; l'authentification utilise
   le cookie de session `WEBCUP_ADMIN_COOKIE`, stocké dans `.env`, **non versionné**) :

   ```sh
   ruby script/webcup_declare.rb                 # dry-run (aperçu, par défaut)
   ruby script/webcup_declare.rb --only=D05,F91  # cibler des codes
   ruby script/webcup_declare.rb --submit        # envoi réel
   ```

   Le cookie WordPress expire régulièrement : le recopier depuis le navigateur dans `.env` en
   cas de message « Session invalide ».

