# Terra Nova — Rapport d'équipe

Plateforme municipale de la ville de Terra Nova, construite avec **Ruby on Rails 8.1**,
**Hotwire** (Turbo + Stimulus) et **ViewComponents**.

Ce document répond au formulaire de déclaration du jury pour chaque demande actuellement
diffusée par l'API Terra Nova : ce que l'équipe a réalisé, où le tester et comment le
vérifier.

---

## Comment lancer et où tester

Démarrer l'application :

```sh
docker compose up -d postgres
bin/rails db:prepare db:seed
bin/rails server
```

Puis ouvrir <http://localhost:3000>.

Comptes de démonstration (tous les mots de passe sont `password123`) :

| Rôle | URL de connexion | Identifiant |
|---|---|---|
| Citoyen | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` | `citoyen@novaterra.fr` |
| Agent | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/sign_in` | `agent@novaterra.fr` |
| Agent administrateur | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/sign_in` | `admin@novaterra.fr` |
| Citoyen administrateur | `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` | `admin@novaterra.fr` |

La clé de l'API externe Terra Nova doit être configurée (`WEBCUP_API_KEY`) pour que le flux
de demandes de l'espace agent (`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/demands`) se remplisse.

> L'application en ligne est déployée à l'adresse
> <https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/>. Les liens de test ci-dessous
> sont des URL absolues pointant vers elle.

---

# Demandes réalisées

## D01 · Facile · 250 XP — Créer un compte

**Ce que nous avons réalisé.** Un parcours d'inscription citoyen complet avec Devise
(`:database_authenticatable`, `:registerable`, `:validatable`) : e-mail unique, validation
du mot de passe (minimum 8 caractères), création automatique du `Profile`, puis redirection
vers la prise en main et enfin vers l'espace personnel. Les formulaires sont étiquetés,
traduits (FR/EN) et accessibles, avec des messages d'erreur clairs.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_up`

**Comment vérifier.**
1. Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_up` et soumettre un e-mail déjà existant → une erreur lisible s'affiche.
2. Créer un compte valide (e-mail + mot de passe) → vous êtes redirigé vers `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding`.
3. Terminer la prise en main (profil, langue, accessibilité) → vous arrivez sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`.
4. Se déconnecter, puis se reconnecter avec les mêmes identifiants → vous revenez sur votre espace personnel.

---

## D03 · Facile · 250 XP — Se connecter à un espace personnel

**Ce que nous avons réalisé.** Connexion Devise pour les citoyens ; l'espace personnel
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` regroupe le profil et l'activité (demandes, rendez-vous, notifications non lues).
La session persiste entre les visites.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in` → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`

**Comment vérifier.** Se connecter avec `citoyen@novaterra.fr` / `password123` → vous êtes
redirigé vers `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace`, qui affiche vos informations et votre activité.

---

## D04 · Facile · 250 XP — Contacter l'administration

**Ce que nous avons réalisé.** Un formulaire de contact public pour les questions,
réclamations, suggestions ou préoccupations liées aux données. Il fonctionne connecté ou en
anonyme (un e-mail est requis en anonyme), génère une référence suivie (`MSG-…`) et confirme
l'envoi. Les agents traitent les messages dans leur espace de travail.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new` → côté agent : `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks`

**Comment vérifier.** 1) Soumettre un message → une confirmation avec une référence s'affiche.
2) Se connecter comme agent → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks` liste le message. 3) Changer son état → le
citoyen lié est notifié.

---

## D05 · Facile · 250 XP — Présenter les services municipaux

**Ce que nous avons réalisé.** Un catalogue de services avec catégories, descriptions,
contacts et mise en avant des services prioritaires ; 12 services sont préchargés.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**Comment vérifier.** Parcourir la liste, rechercher « état civil », ouvrir un service →
la description, les coordonnées et une carte s'affichent.

---

## D06 · Facile · 250 XP — Trouver et lire les actualités

**Ce que nous avons réalisé.** Un index public des actualités et des pages de détail ; seules
les actualités publiées et actives sont visibles.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/announcements`

**Comment vérifier.** Les actualités préchargées sont listées ; en ouvrir une pour lire le
contenu complet.

---

## D07 · Moyen · 500 XP — Page d'accueil claire

**Ce que nous avons réalisé.** Une page d'accueil avec une section principale, les alertes
actives, les contacts d'urgence, les services prioritaires et les dernières actualités,
donnant un accès direct aux principaux services.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`

**Comment vérifier.** Les services prioritaires sont mis en avant en premier et un lien
visible mène vers `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`.

---

## D08 · Moyen · 500 XP — Distinguer citoyen / agent / administrateur

**Ce que nous avons réalisé.** Deux scopes Devise (`User` et `Agent`) avec des énumérations
`role` (`citizen` / `agent` / `admin`) et un espace `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` distinct avec sa propre
navigation et sa propre connexion.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` par rapport à `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`

**Comment vérifier.** L'espace agent est visuellement et fonctionnellement distinct de
l'espace citoyen et nécessite un compte agent.

---

## D09 · Moyen · 500 XP — Accès selon le rôle

**Ce que nous avons réalisé.** Des politiques Pundit et des contraintes de routage ; les
citoyens ne peuvent pas accéder à l'espace agent ni effectuer d'actions sensibles.

**Où tester.** Se connecter comme citoyen, puis ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**Comment vérifier.** Vous êtes redirigé vers la connexion agent ; les pages réservées aux
agents sont inaccessibles aux citoyens.

---

## D11 · Moyen · 540 XP — Suivre l'état et les étapes d'une demande

**Ce que nous avons réalisé.** Une liste des demandes citoyennes avec leur état, et une
chronologie d'événements par demande montrant les étapes déjà franchies.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests` → ouvrir une demande

**Comment vérifier.** Le badge d'état et la chronologie « Avancement » des événements sont
affichés.

---

## D12 · Moyen · 540 XP — Prise en main à la première connexion

**Ce que nous avons réalisé.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding` guide le citoyen dans la complétion de son
profil, le choix de la langue et les réglages d'accessibilité. Les nouveaux citoyens y sont
redirigés automatiquement et arrivent dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` à la fin.

**Où tester.** Créer un nouveau compte → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding`

**Comment vérifier.** Terminer les étapes guidées → la prise en main est marquée comme
terminée et vous rejoignez votre espace personnel.

---

## D13 · Facile · 310 XP — Comprendre les mots difficiles

**Ce que nous avons réalisé.** Un glossaire en langage clair expliquant les termes utilisés
sur la plateforme.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/glossary`

**Comment vérifier.** Les termes préchargés (« Signalement », « Démarche », …) sont expliqués
simplement.

---

## D14 · Moyen · 540 XP — Choisir une autre langue

**Ce que nous avons réalisé.** Une interface français/anglais avec un sélecteur dans l'en-tête
et un réglage de profil ; le choix est enregistré sur le compte.

**Où tester.** Sélecteur de langue dans l'en-tête, ou `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/edit`

**Comment vérifier.** Basculer en anglais → la navigation et les pages se mettent à jour ;
recharger la page → le choix persiste.

---

## D15 · Facile · 270 XP — Savoir où l'on se trouve

**Ce que nous avons réalisé.** Un fil d'Ariane accessible (avec un « aria-label ») sur toutes
les pages clés, montrant le chemin de retour vers les niveaux précédents.

**Où tester.** N'importe quelle page interne, par ex. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**Comment vérifier.** Le fil d'Ariane affiche Accueil / Services / page et permet de revenir.

---

## D16 · Facile · 270 XP — Confirmation après envoi

**Ce que nous avons réalisé.** La soumission d'une demande affiche un message de confirmation
avec sa référence, ouvre la page de la demande (qui contient la référence et une chronologie)
et met en file un e-mail de confirmation.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new` → soumettre

**Comment vérifier.** 1) Vous êtes redirigé vers la nouvelle demande avec un message de succès.
2) La demande apparaît dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`. 3) L'e-mail est mis en file (vérifié par la suite de
tests ; configurez un SMTP ou un outil de prévisualisation comme Letter Opener pour le lire).

---

## D17 · Facile · 270 XP — Nombre de demandes en attente

**Ce que nous avons réalisé.** Le tableau de bord agent et la liste des demandes affichent
combien de demandes nécessitent encore une action.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**Comment vérifier.** Les compteurs « Demandes en attente » et les statistiques par état sont
visibles.

---

## D18 · Difficile · 840 XP — Diffuser un message général

**Ce que nous avons réalisé.** Les agents publient des actualités (gravité, audience, fenêtre
de publication) ; les actualités publiées apparaissent sur la page d'accueil et la page
d'actualités.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` → Nouveau

**Comment vérifier.** Créer une actualité → elle apparaît sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/announcements`.

---

## D19 · Difficile · 750 XP — Espace agent lisant l'API Terra Nova

**Ce que nous avons réalisé.** Un client côté serveur pour l'API Webcup (authentifié par
l'en-tête `X-Webcup-Api-Key`), une synchronisation idempotente basée sur `request_code`, une
interrogation environ toutes les 30 secondes via Solid Queue, et une console en direct avec
l'état de la session, des filtres et un tableau de traitement
(`unseen → reviewing → planned → in progress → done/ignored`).

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/demands`

**Comment vérifier.** 1) Le flux liste les demandes actuelles avec XP et difficulté.
2) « Actualiser » le met à jour ; il s'actualise aussi automatiquement toutes les 30 secondes.
3) Changer l'état de traitement d'une demande → il persiste.

---

## D20 · Difficile · 930 XP — Utilisable par tous (accessibilité)

**Ce que nous avons réalisé.** Un programme d'accessibilité WCAG 2.2 AA : repères sémantiques,
lien d'évitement vers le contenu, focus clavier visible, formulaires étiquetés avec résumé
des erreurs, modes contraste élevé et texte agrandi, prise en charge de `prefers-reduced-motion`
et régions live pour les alertes.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility` et le menu « Accessibilité » de l'en-tête

**Comment vérifier.** Activer contraste élevé / texte agrandi ; naviguer uniquement au clavier ;
la déclaration d'accessibilité liste chaque fonctionnalité prise en charge.

---

## F21 · Moyen · 520 XP — Utilisabilité avec lecteur d'écran

**Ce que nous avons réalisé.** HTML sémantique, attribut `lang` correct, rôles de repères,
contrôles étiquetés, fils d'Ariane `aria-current` et `role="alert"` / régions live pour les
alertes.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility` et n'importe quel formulaire (par ex. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new`)

**Comment vérifier.** Avec VoiceOver/NVDA, les titres, les étiquettes et les erreurs sont
annoncés correctement, et le lien d'évitement saute au contenu principal.

---

## F22 · Facile · 250 XP — File de demandes agent avec états

**Ce que nous avons réalisé.** Une liste agent des demandes citoyennes avec badges d'état,
filtres et compteurs en attente, pour que les agents voient rapidement ce qui reste à traiter.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`

**Comment vérifier.** Filtrer par état et ouvrir une demande pour voir son état et ses détails.

---

## F23 · Moyen · 520 XP — Contraste / lisibilité

**Ce que nous avons réalisé.** Un mode contraste élevé (persistant) et des choix de couleurs
qui ne reposent jamais sur la seule couleur pour transmettre une information.

**Où tester.** Menu « Accessibilité » de l'en-tête

**Comment vérifier.** Activer « Contraste élevé » → l'interface bascule vers des couleurs à
fort contraste et le choix persiste.

---

## F24 · Facile · 260 XP — Texte plus grand

**Ce que nous avons réalisé.** Un mode texte agrandi qui augmente la taille de police racine ;
les mises en page se réorganisent sans casser.

**Où tester.** Menu « Accessibilité » de l'en-tête

**Comment vérifier.** Activer « Texte agrandi » → le texte grandit et la mise en page reste
utilisable ; le choix persiste.

---

## F25 · Moyen · 540 XP — Signaler un lampadaire cassé avec localisation

**Ce que nous avons réalisé.** Un formulaire de signalement avec un service facultatif, une
description, un texte de localisation et un sélecteur de carte interactif pour placer le point
exact.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**Comment vérifier.** Renseigner le problème, cliquer sur la carte pour placer le repère (les
coordonnées remplissent le formulaire), soumettre → la demande est créée et suivie.

---

## F26 · Facile · 270 XP — Historique des demandes passées

**Ce que nous avons réalisé.** Un historique personnel des demandes avec leur état et leurs
dates.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**Comment vérifier.** Toutes les demandes créées précédemment sont listées et peuvent être
ouvertes.

---

## F27 · Moyen · 540 XP — Contenu des services multilingue

**Ce que nous avons réalisé.** Les noms et descriptions des services sont stockés par langue
et suivent la langue d'interface sélectionnée.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` après avoir basculé l'interface en anglais

**Comment vérifier.** Les noms/descriptions des services s'affichent en anglais ; revenir au
français.

---

## F28 · Facile · 270 XP — Mettre en avant les services prioritaires

**Ce que nous avons réalisé.** Un indicateur `priority` sur les services, exposé dans une
section « Services prioritaires » dédiée sur la page d'accueil et le catalogue.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**Comment vérifier.** Les services prioritaires apparaissent dans une section dédiée avec un
badge « Prioritaire ».

---

## F29 · Difficile · 840 XP — Alerte inondation de quartier

**Ce que nous avons réalisé.** Des alertes avec un type (inondation / canicule / sécurité /
autre), une gravité, une zone et une programmation ; elles sont affichées sous forme de
bandeaux visibles et annoncées aux lecteurs d'écran.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**Comment vérifier.** L'alerte préchargée « inondation — quartier sud » est affichée de façon
visible sur la page d'accueil.

---

## F30 · Moyen · 560 XP — Notifier lors d'une actualité importante

**Ce que nous avons réalisé.** La publication d'une actualité notifie chaque citoyen dans
l'application (et met un e-mail en file), pour que personne ne manque une information
importante.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` → Nouveau ; puis `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications`

**Comment vérifier.** Après publication, la notification apparaît dans la liste de
notifications du citoyen.

---

## F31 · Difficile · 840 XP — Consignes canicule pour les personnes vulnérables

**Ce que nous avons réalisé.** Les alertes portent un segment cible (par ex. « personnes
vulnérables ») et des recommandations, et sont affichées comme un bandeau d'avertissement
distinct.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**Comment vérifier.** L'alerte canicule préchargée avec ses recommandations est visible.

---

## F32 · Facile · 280 XP — Trouver rapidement les services de santé

**Ce que nous avons réalisé.** Une recherche et des filtres par catégorie, un service « Santé »
dédié et un panneau d'urgence pour trouver immédiatement les besoins urgents.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services?q=santé`

**Comment vérifier.** Le service Santé est renvoyé et le panneau d'urgence est affiché à côté
des résultats.

---

## F33 · Facile · 290 XP — Supprimer mon compte en toute sécurité

**Ce que nous avons réalisé.** La suppression du compte est protégée par confirmation du mot de
passe, afin qu'une personne non autorisée disposant d'une session ouverte ne puisse pas
supprimer le compte.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account`

**Comment vérifier.** 1) Saisir un mauvais mot de passe → une erreur s'affiche et le compte est
conservé. 2) Saisir le bon mot de passe → le compte est supprimé et vous êtes redirigé vers
l'accueil. (Utiliser un compte jetable.)

---

## F34 · Moyen · 580 XP — Les agents administrent les comptes citoyens

**Ce que nous avons réalisé.** Gestion par les agents des comptes citoyens : liste, recherche,
consultation, édition (langue, prise en main), changement de rôle (administrateurs uniquement)
et déverrouillage de compte.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users`

**Comment vérifier.** Rechercher un citoyen et ouvrir sa fiche ; modifier des champs ; un
administrateur peut changer le rôle et déverrouiller un compte verrouillé.

---

## F35 · Facile · 290 XP — Accompagnement à la prise en main

**Ce que nous avons réalisé.** La page de prise en main guide pas à pas le nouvel habitant dans
la complétion du profil, la langue, l'accessibilité et une courte visite guidée.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/onboarding` (avec un nouveau compte)

**Comment vérifier.** Les quatre étapes guidées sont présentées clairement avec de courtes
indications.

---

## F36 · Moyen · 580 XP — Horaires et informations de transport

**Ce que nous avons réalisé.** Des lignes de transport avec leur mode, leurs horaires par jour
de la semaine et les perturbations en cours, sur un seul écran.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/transports`

**Comment vérifier.** Les lignes préchargées affichent leurs horaires, et une perturbation
active est signalée sur une ligne.

---

## F37 · Difficile · 900 XP — Protection contre la force brute

**Ce que nous avons réalisé.** Limitation `rack-attack` sur la connexion (par IP et par
compte), les réinitialisations de mot de passe et les points sensibles ; `:lockable` de Devise
pour le verrouillage de compte ; les agents peuvent déverrouiller les comptes.

**Où tester.** Connexions échouées répétées sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in`

**Comment vérifier.** Après plusieurs tentatives rapides, vous recevez **HTTP 429 (Trop de
requêtes)** ; des échecs prolongés verrouillent le compte, qu'un agent peut déverrouiller sur
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users/:id`.

---

## F38 · Moyen · 600 XP — Service en maintenance

**Ce que nous avons réalisé.** Les services ont un état (`active` / `maintenance` / `inactive`).
Un service en maintenance affiche un bandeau avec un message et un retour prévu ; les services
inactifs sont masqués du catalogue public.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/eau-assainissement`

**Comment vérifier.** Un bandeau de maintenance avec le message et le retour prévu s'affiche.

---

## F39 · Moyen · 600 XP — Prendre un rendez-vous

**Ce que nous avons réalisé.** Les citoyens choisissent un agent et une date, voient les
créneaux disponibles calculés et confirment ; la réservation envoie une confirmation et une
notification. L'annulation est prise en charge, et les agents gèrent leur planning et leurs
disponibilités.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/appointments/new`

**Comment vérifier.** 1) Choisir un agent et une date → les créneaux disponibles apparaissent.
2) Choisir un créneau → confirmer → la page du rendez-vous affiche un message de succès.
3) Le rendez-vous apparaît dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/appointments`.

---

## F40 · Facile · 300 XP — Rappel avant un rendez-vous

**Ce que nous avons réalisé.** `Appointments::ReminderJob` envoie par e-mail les rendez-vous
confirmés environ 24 heures à l'avance ; il est planifié via les tâches récurrentes de Solid
Queue.

**Où tester.** Créer un rendez-vous ~24 heures à l'avance, puis lancer
`bin/rails runner 'Appointments::ReminderJob.new.perform'`

**Comment vérifier.** Un rappel est mis en file/envoyé exactement une fois (jamais deux) ;
c'est couvert par la suite de tests.

---

## F41 · Moyen · 620 XP — Navigation au clavier uniquement

**Ce que nous avons réalisé.** Un lien d'évitement vers le contenu, un ordre de focus logique,
un indicateur de focus visible et aucune trappe au clavier.

**Où tester.** N'importe quelle page, en utilisant uniquement Tab/Maj+Tab

**Comment vérifier.** Vous atteignez l'en-tête, la navigation, les formulaires et le contenu,
et l'indicateur de focus est toujours visible.

---

## F42 · Difficile · 930 XP — Formulaires et erreurs accessibles

**Ce que nous avons réalisé.** Étiquettes programmatiques, résumé des erreurs avec liens, et
liaisons `aria-describedby` / `aria-invalid`. Les champs d'authentification autorisent le
collage et les gestionnaires de mots de passe.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new` → soumettre le formulaire vide

**Comment vérifier.** Un résumé des erreurs apparaît ; les champs sont marqués invalides et
associés à leurs messages pour les technologies d'assistance.

---

## F43 · Facile · 310 XP — Daltonisme

**Ce que nous avons réalisé.** L'état n'est jamais transmis par la couleur seule — chaque badge
coloré porte une étiquette lisible — et un mode contraste élevé est disponible.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/alerts`

**Comment vérifier.** Chaque badge coloré affiche une étiquette textuelle.

---

## F44 · Moyen · 620 XP — Agrandir sans casser la mise en page

**Ce que nous avons réalisé.** Des mises en page responsives qui se réorganisent, plus un mode
texte agrandi ; le contenu reste utilisable en largeur réduite et à fort zoom.

**Où tester.** Zoom navigateur à 200–400 % sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**Comment vérifier.** Le contenu se réorganise en une seule colonne sans chevauchement ni perte
d'information.

---

## F45 · Difficile · 960 XP — Localiser les services physiques

**Ce que nous avons réalisé.** Une carte Leaflet/OpenStreetMap sur les pages de service avec
l'adresse et un lien « Ouvrir dans OpenStreetMap », plus une alternative textuelle pour les
technologies d'assistance.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**Comment vérifier.** Une carte avec un repère et l'adresse s'affiche ; le lien OpenStreetMap
ouvre la localisation.

---

## F46 · Facile · 320 XP — Hôpitaux et services d'urgence

**Ce que nous avons réalisé.** Les services d'urgence (appel au 112) sont mis en avant dans un
panneau dédié sur la page d'accueil et le catalogue, avec numéro de téléphone et adresse.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` (panneau d'urgence) et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/urgences`

**Comment vérifier.** Le panneau d'urgence et la page de détail « Services d'urgence »
affichent le numéro et la localisation.

---

## F47 · Difficile · 960 XP — Justifier et tracer les actions

**Ce que nous avons réalisé.** PaperTrail enregistre les modifications sur les modèles clés avec
l'utilisateur agissant et un horodatage, et une page de journal d'audit destinée aux agents les
rend consultables dans le temps.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs`

**Comment vérifier.** Les modifications passées sont listées avec leur auteur et leur date.

---

## F48 · Moyen · 640 XP — Qui a modifié quoi

**Ce que nous avons réalisé.** Chaque entrée d'audit affiche l'auteur (`Agent:` / `User:`) et un
diff avant/après au niveau des attributs.

**Où tester.** En tant qu'agent, changer l'état d'une demande → `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs` → ouvrir
l'entrée

**Comment vérifier.** Le diff montre le champ modifié avec ses valeurs avant et après.

---

## F49 · Facile · 330 XP — Me notifier quand ma demande change d'état

**Ce que nous avons réalisé.** Lorsqu'un agent change l'état d'une demande, une notification
dans l'application est créée (et un e-mail d'état est mis en file).

**Où tester.** En tant qu'agent, mettre à jour une demande sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference` ;
puis visiter `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications`

**Comment vérifier.** Le citoyen reçoit une notification décrivant le nouvel état.

---

## F50 · Difficile · 990 XP — Tableau de bord d'activité

**Ce que nous avons réalisé.** Un tableau de bord agent montrant l'activité de la plateforme
(citoyens, demandes, demandes en attente, rendez-vous à venir) ainsi que les statistiques du
flux de l'API Terra Nova et les éléments récents.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents`

**Comment vérifier.** Les cartes de statistiques et les listes d'activité récente sont
affichées.

---

## F51 · Difficile · 990 XP — Questions sur l'usage des données, traçables

**Ce que nous avons réalisé.** Une page de transparence expliquant l'usage des données et les
droits des citoyens, un type de contact « préoccupation liée aux données » dédié, et une
référence suivie pour que le citoyen sache que sa contribution a été reçue. Les agents traitent
ces messages dans leur espace.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/transparency` → « Signaler une préoccupation liée aux données »

**Comment vérifier.** Soumettre une préoccupation → une confirmation avec une référence
s'affiche ; le message apparaît dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/feedbacks`.

---

## F52 · Moyen · 660 XP — Soutenir une demande existante

**Ce que nous avons réalisé.** Les citoyens peuvent co-signer la demande d'un autre citoyen ;
le nombre de soutiens est suivi, affiché, et peut être retiré.

**Où tester.** Ouvrir une demande (par ex. depuis `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`) → « Soutenir cette demande »

**Comment vérifier.** Le clic enregistre votre soutien et le compteur augmente ; vous pouvez
retirer votre soutien.

---

# Demandes supplémentaires (vagues API ultérieures) — réalisées

Ces demandes sont apparues lors de vagues API ultérieures. Elles sont désormais réalisées
également.

## D02 · Difficile · 1020 XP — Se connecter sans mot de passe classique

**Ce que nous avons réalisé.** Connexion sans mot de passe par lien magique envoyé par e-mail.
Le lien est signé, à usage unique et valable 15 minutes ; le consommer fait tourner un nonce
par utilisateur, empêchant toute relecture. La réponse à la demande est volontairement
générique pour ne pas révéler si un e-mail existe, et le point d'accès est limité en débit. Le
second facteur s'applique toujours lorsqu'il est activé.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/magic_link` (lien « Se connecter sans mot de passe » dans l'en-tête)

**Comment vérifier.** 1) Saisir `citoyen@novaterra.fr` → un message générique « lien envoyé ».
2) Ouvrir le lien reçu par e-mail (configurez un SMTP ou une prévisualisation pour le lire) →
vous êtes connecté. 3) Ouvrir le même lien à nouveau → il est rejeté (usage unique). 4) Saisir
un e-mail inconnu → le même message générique. Couvert par des tests automatisés.

---

## F53 · Difficile · 1020 XP — Vérification supplémentaire (double authentification)

**Ce que nous avons réalisé.** Double authentification TOTP via une application
d'authentification. Les citoyens l'activent depuis leur profil (QR code + secret manuel),
confirment avec un code à 6 chiffres, et le compte est ensuite protégé par un défi de
vérification après chaque connexion par mot de passe ou lien magique. Elle peut être
désactivée depuis la même page.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/two_factor`

**Comment vérifier.** 1) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/profile/two_factor` et scanner le QR code avec une
application d'authentification. 2) Saisir le code à 6 chiffres courant → l'activation est
confirmée. 3) Se déconnecter puis se reconnecter avec son mot de passe → vous êtes redirigé
vers `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/two_factor`. 4) Saisir le code → l'accès est accordé. 5) La désactiver depuis la
même page.

---

## F54 · Moyen · 680 XP — Alerte de connexion depuis un nouvel appareil

**Ce que nous avons réalisé.** Chaque connexion est enregistrée avec son adresse IP et une
empreinte d'appareil. Une connexion depuis un appareil jamais vu crée une notification dans
l'application et un e-mail de sécurité. Les connexions récentes sont listées dans la page de
données personnelles.

**Où tester.** Notification de nouvel appareil sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/notifications` ; historique sur
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data`

**Comment vérifier.** 1) Se connecter normalement, puis se reconnecter depuis un autre
navigateur (autre user agent). 2) Une notification « Nouvelle connexion détectée » apparaît, et
un e-mail de sécurité est mis en file. 3) Se connecter deux fois depuis le même appareil ne
déclenche pas de nouvelle alerte.

---

## F55 · Difficile · 1020 XP — Récupérer mes données personnelles

**Ce que nous avons réalisé.** Une page de données personnelles donnant un résumé clair et
structuré (réglages du compte, statut de la double authentification, date d'inscription,
compteurs d'activité et connexions récentes), plus un export JSON portable couvrant le compte,
le profil, les demandes avec leurs étapes, les rendez-vous, les notifications, les messages et
les soutiens.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data` → « Télécharger mes données (JSON) »

**Comment vérifier.** 1) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/account/data` → un résumé lisible s'affiche. 2) Cliquer sur le
bouton de téléchargement → un fichier JSON structuré est renvoyé. 3) Vérifier qu'il reflète vos
demandes et rendez-vous réels.

---

## F56 · Moyen · 680 XP — Télécharger un récapitulatif de mes demandes

**Ce que nous avons réalisé.** Un export CSV de l'historique des demandes du citoyen :
référence, date de soumission, objet, état, service, lieu, nombre d'étapes, soutiens et
dernière mise à jour — prêt à ouvrir dans un tableur.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests` → « Télécharger (CSV) », ou directement `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests.csv`

**Comment vérifier.** 1) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`. 2) Cliquer sur « Télécharger (CSV) » → un fichier
de données est téléchargé. 3) Vérifier que les lignes correspondent à vos demandes et à leurs
états.

---

## F57 · Moyen · 700 XP — Diagnostic de performance environnementale

**Ce que nous avons réalisé.** Une page `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` indiquant le poids mesuré des feuilles de style
et du JavaScript de l'application par rapport à des budgets explicites, ainsi que les choix de
conception qui réduisent l'empreinte. La bibliothèque de cartes Leaflet est désormais importée
dynamiquement, si bien que son poids n'est payé que sur les pages qui affichent réellement une
carte.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`

**Comment vérifier.** Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` → les poids mesurés et les budgets sont affichés. Puis
ouvrir une page sans carte et vérifier dans l'onglet Réseau du navigateur : `leaflet.js` n'est
pas téléchargé.

---

## F58 · Difficile · 1050 XP — Réduction durable de l'impact numérique

**Ce que nous avons réalisé.** Des choix systématiquement légers sur les parcours clés : pas de
framework SPA (Hotwire rendu côté serveur), pas de polices web externes ni de traqueurs, import
dynamique de la bibliothèque de cartes, et un **budget automatisé de taille des ressources**
imposé par la suite de tests, afin que le poids ne puisse pas régresser sans être remarqué.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` ; test `test/performance/asset_budget_test.rb`

**Comment vérifier.** 1) Lancer `bin/rails test test/performance/asset_budget_test.rb` → il
passe et échoue si les budgets CSS/JS sont dépassés. 2) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` documente la politique et les
chiffres actuels.

---

## F59 · Moyen · 700 XP — Fonctionne en connexion lente

**Ce que nous avons réalisé.** Une préférence **mode économie de données**, persistée dans le
profil et la session, qui désactive les cartes (aucune requête de tuiles) et d'autres
ressources optionnelles lourdes. Les pages sont rendues côté serveur, donc le contenu reste
disponible et lisible sans JavaScript.

**Où tester.** Menu « Accessibilité » de l'en-tête → « Mode économie de données »

**Comment vérifier.** 1) Activer « Mode économie de données ». 2) Ouvrir un service avec une
localisation → la carte n'est pas chargée et une note s'affiche à la place. 3) Dans l'onglet
Réseau, confirmer qu'aucune requête de tuiles n'est effectuée.

---

## F60 · Facile · 350 XP — Images et médias légers

**Ce que nous avons réalisé.** Aucune police externe ni média lourd ; le QR code 2FA est une
URI de données en ligne ; les tuiles de carte ne sont demandées que lorsqu'une carte est
réellement affichée (et jamais en mode économie de données). Les choix de médias et les budgets
sont documentés sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` et l'onglet Réseau de n'importe quelle page

**Comment vérifier.** 1) Parcourir les pages principales → aucun média lourd n'est chargé.
2) Activer le mode économie de données → aucune requête de tuiles. 3) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` décrit les choix
de médias.

---

## F61 · Difficile · 1080 XP — Rapide même sur appareils peu puissants

**Ce que nous avons réalisé.** Les pages restent légères par défaut : la bibliothèque JavaScript
Leaflet n'est plus préchargée en module sur chaque page (elle est importée dynamiquement et
récupérée uniquement là où une carte est réellement rendue), et la feuille de style Leaflet a
été sortie du bundle global pour n'être chargée que sur les pages à carte. Les pages sont
rendues côté serveur sans framework SPA, `prefers-reduced-motion` est respecté, et un test
automatisé de budget des ressources protège le poids contre les régressions.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` (sans bibliothèque de cartes), une page à carte `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`, et
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`

**Comment vérifier.** 1) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` et vérifier l'onglet Réseau → `leaflet.js` n'est pas
préchargé. 2) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil` → la bibliothèque de cartes ne se charge que là.
3) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco` → les poids mesurés sont dans le budget ; lancer
`bin/rails test test/performance/asset_budget_test.rb` → passe.

---

## F62 · Moyen · 720 XP — Une version plus simple et plus rapide des pages

**Ce que nous avons réalisé.** Une préférence persistante **« Mode simple »** qui rend des
versions plus légères et plus rapides des pages clés : la page d'accueil supprime les blocs
décoratifs, le catalogue de services supprime la mise en avant des priorités, et les cartes ne
sont pas chargées — tout en conservant l'ensemble des informations et actions essentielles.

**Où tester.** Menu Accessibilité → « Mode simple » ; puis `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`

**Comment vérifier.** 1) Activer « Mode simple » depuis le menu Accessibilité de l'en-tête.
2) La page d'accueil n'affiche plus les blocs « Ce que vous pouvez faire » et actualités.
3) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` n'affiche plus la section des priorités et ne charge aucune carte, mais la
recherche et la liste complète restent disponibles.

---

## F63 · Difficile · 1080 XP — Désactiver rapidement un service défaillant

**Ce que nous avons réalisé.** Une zone de gestion des services dans l'espace agent
(`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`) avec un **« Désactiver » en un clic** qui met immédiatement un service en
maintenance, un « Activer » en un clic pour le rétablir, et un formulaire d'édition pour le
message de maintenance (FR/EN), le retour prévu et les contacts. Les changements sont
enregistrés dans la piste d'audit.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`

**Comment vérifier.** 1) Se connecter comme agent et ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/services`. 2) Cliquer sur
« Désactiver » sur un service → il passe « En maintenance », et le côté citoyen (`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`)
affiche immédiatement le bandeau de maintenance. 3) Cliquer sur « Activer » pour le rétablir.

---

## F64 · Facile · 360 XP — Voir l'état d'un service avant de commencer

**Ce que nous avons réalisé.** Chaque carte de service porte désormais un badge d'état (Ouvert
/ En maintenance / Fermé), la page du service affiche l'état de façon visible avec le bandeau
de maintenance, et le formulaire de demande affiche un avertissement en direct lorsqu'un
service indisponible est sélectionné — les citoyens savent ainsi avant de commencer et savent
quoi faire ensuite.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services`, une page de service (par ex. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/eau-assainissement`), et
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**Comment vérifier.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services` affiche un badge Ouvert / En maintenance / Fermé sur chaque
carte. 2) Ouvrir un service en maintenance → un bandeau avec le message et le retour prévu
s'affiche. 3) Dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`, sélectionner un service en maintenance → un avertissement
apparaît avant la soumission.

---

## F65 · Difficile · 1110 XP — Soumettre des décisions à l'avis des habitants

**Ce que nous avons réalisé.** Des consultations (rattachées à un projet, avec un type : avis,
sondage ou décision) auxquelles les citoyens peuvent répondre. Chaque réponse est enregistrée
avec une **référence traçable** et une notification de confirmation, et les agents peuvent
consulter les résultats agrégés — la ville peut ainsi justifier la participation et le citoyen
sait que sa contribution a été reçue.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/consultations/:id` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/consultations`

**Comment vérifier.** 1) Ouvrir une consultation depuis une page projet. 2) Soumettre votre avis
→ la confirmation affiche une référence. 3) En tant qu'agent, ouvrir la consultation → les
résultats et la liste des réponses sont affichés.

---

## F66 · Moyen · 740 XP — Donner un avis sans vote formel

**Ce que nous avons réalisé.** Un formulaire de réponse simple sur chaque consultation
(Favorable / Défavorable / Sans avis + commentaire facultatif). Une réponse par citoyen,
enregistrée instantanément, avec une référence et une confirmation pour lever toute ambiguïté.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/consultations/:id`

**Comment vérifier.** 1) Se connecter et ouvrir une consultation → choisir une option et
soumettre. 2) Une confirmation avec une référence s'affiche. 3) Rouvrir la consultation → votre
réponse enregistrée et sa référence sont affichées.

---

## F67 · Moyen · 740 XP — Consulter les projets en cours de la ville

**Ce que nous avons réalisé.** Un espace projets public : un index qui met en avant les projets
**en cours** et une page de détail par projet, listant ses consultations, sa chronologie et sa
catégorie.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects/:slug`

**Comment vérifier.** 1) Ouvrir `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/projects` → les projets en cours apparaissent dans une
section dédiée. 2) Ouvrir un projet → sa description, ses dates, sa catégorie et les
consultations associées sont affichées.

---

## F68 · Facile · 370 XP — Proposer des idées pour la colonie

**Ce que nous avons réalisé.** Les citoyens peuvent proposer une idée (catégorie, titre,
description) — enregistrée avec une référence et une notification de confirmation — soutenir
les idées des autres (co-signature), et les agents peuvent **modérer** les idées (soumise → en
cours d'examen → acceptée/refusée) avec l'auteur notifié.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/ideas/:reference` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/ideas`

**Comment vérifier.** 1) Proposer une idée → confirmation avec une référence. 2) Ouvrir l'idée
d'un autre citoyen → la soutenir (le compteur augmente). 3) En tant qu'agent, ouvrir
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/ideas`, changer l'état → l'auteur est notifié.

---

## F69 · Expert · 1520 XP — Protéger les données sensibles ; protection perceptible

**Ce que nous avons réalisé.** Un journal `SecurityEvent` enregistre l'activité
d'authentification et de sécurité du compte (connexion, échec de connexion, activation/
désactivation de la double authentification, déverrouillage de compte), exposé sur une page de
surveillance **réservée aux administrateurs**. Cela complète les protections existantes (2FA,
liens sans mot de passe, verrouillage de compte, limitation rack-attack, CSP/HSTS, paramètres
filtrés).

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events` (compte administrateur)

**Comment vérifier.** 1) Se connecter puis provoquer un échec de connexion → les événements
apparaissent dans la liste. 2) Un agent ordinaire ne peut pas ouvrir la page (redirigé).
3) Un administrateur le peut.

---

## F70 · Difficile · 1140 XP — Données administratives strictement restreintes

**Ce que nous avons réalisé.** La piste d'audit et les événements de sécurité sont désormais
**réservés aux administrateurs** (imposé par Pundit), et les changements de rôle restent
réservés aux administrateurs. Les données opérationnelles restent disponibles pour les agents
ordinaires.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**Comment vérifier.** 1) Se connecter comme agent ordinaire → l'accès est refusé (redirection +
message). 2) Se connecter comme administrateur → l'accès est accordé.

---

## F71 · Difficile · 1140 XP — Nouveaux arrivants sans e-mail, en plusieurs langues

**Ce que nous avons réalisé.** Connexion par **e-mail ou identifiant citoyen** (`TN-XXXXXX`).
Les agents peuvent créer un compte **sans adresse e-mail** : le système génère un e-mail de
remplacement, un identifiant citoyen et un mot de passe temporaire, affichés une seule fois
pour la remise. Une troisième langue (espagnol) a été ajoutée pour démontrer la facilité
d'extension linguistique.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users/new`, puis `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/users/sign_in`, et le sélecteur de langue

**Comment vérifier.** 1) En tant qu'agent, créer un compte en laissant l'e-mail vide → les
identifiants sont affichés. 2) Se connecter avec l'**identifiant** et le mot de passe temporaire.
3) Basculer l'interface en Español.

---

## F72 · Facile · 380 XP — Un point de départ sans refaire l'inscription

**Ce que nous avons réalisé.** Une aide « Par où commencer ? » sur l'espace personnel : choisir
une situation (emménagement, déchets, lampadaire, santé, transport, démarches, eau) → des
services suggérés et une demande pré-remplie en un clic. Aucune nouvelle étape d'inscription.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/espace` (section d'orientation)

**Comment vérifier.** 1) Choisir « Santé et urgences » → des services suggérés apparaissent.
2) Choisir « Un lampadaire cassé » → « Commencer une demande » ouvre un formulaire pré-rempli.

---

## F73 · Moyen · 780 XP — Message officiel visible par tous, immédiatement

**Ce que nous avons réalisé.** Les actualités peuvent être **épinglées**, ce qui les affiche
comme un **bandeau sur tout le site, sur chaque page** (mises en page citoyenne et agent), en
plus de la page d'actualités.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/announcements` (épingler) → n'importe quelle page

**Comment vérifier.** 1) Créer ou modifier une actualité et cocher « Épingler comme bandeau sur
tout le site ». 2) Ouvrir n'importe quelle page (par ex. `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/glossary`) → le message apparaît en
haut.

---

## F74 · Facile · 390 XP — Horaires et localisation des partenaires

**Ce que nous avons réalisé.** Un **annuaire de partenaires** avec une page de détail montrant
l'adresse, une carte Leaflet et les horaires sur sept jours, plus une gestion par les agents (y
compris un éditeur d'horaires en masse).

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners/:slug` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/partners`

**Comment vérifier.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/partners` liste le partenaire. 2) L'ouvrir → tableau des horaires et
carte de localisation. 3) En tant qu'agent, modifier les horaires et constater la mise à jour.

---

## F75 · Difficile · 1170 XP — Repérer les demandes en doublon

**Ce que nous avons réalisé.** Une heuristique de similarité (`Requests::Similarity` :
recouvrement de mots-clés plus bonus même service/lieu) fait apparaître les **« doublons
possibles »** sur la page de demande côté agent, avec une action en un clic pour lier la demande
à celle qu'elle duplique.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference`

**Comment vérifier.** 1) Ouvrir une demande → les doublons possibles sont listés. 2) Cliquer sur
« Lier comme doublon » → le lien est enregistré.

---

## F76 · Moyen · 780 XP — Commenter après avoir utilisé un service

**Ce que nous avons réalisé.** Les citoyens peuvent laisser une **note et un commentaire** sur
un service (un par citoyen), enregistrés avec une référence et une notification de confirmation.
Les avis sont affichés sur la page du service et les agents peuvent les **publier/masquer**.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/:slug` (formulaire d'avis) et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/service_reviews`

**Comment vérifier.** 1) Se connecter, ouvrir un service → laisser un commentaire. 2) Il
apparaît sur la page du service avec la confirmation de référence. 3) En tant qu'agent, le
masquer/le publier.

---

## F77 · Difficile · 1200 XP — Rester agréable sous forte charge

**Ce que nous avons réalisé.** Les grandes listes sont désormais **paginées** (25/page) —
demandes agent, demandes citoyennes, comptes citoyens et journal d'audit — afin que les pages
restent bornées. Les requêtes chaudes de la page d'accueil, du catalogue et du message épinglé
sont **mises en cache** brièvement, et les colonnes les plus filtrées sont **indexées**. Une page
publique **`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status`** indique l'état des composants, et les modes économie de données/simple
ainsi que la carte importée dynamiquement gardent déjà les pages légères.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status`, et les contrôles de pagination sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`,
`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/users`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/audit_logs`

**Comment vérifier.** 1) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` indique l'état de la base et du cache ainsi que des compteurs.
2) Les listes affichent « Page X sur Y » avec précédent/suivant. 3) Les filtres continuent de
fonctionner d'une page à l'autre.

---

## F78 · Expert · 1600 XP — Stable avec de nombreuses connexions simultanées

**Ce que nous avons réalisé.** Des tailles de page et des décalages bornés (aucun jeu de
résultats illimité), des lectures chaudes mises en cache, des index composites pour la file et
les listes, et des pages légères rendues côté serveur sans SPA. Combiné au bassin de connexions
existant, cela maintient la plateforme réactive en accès concurrent.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` et les listes de demandes

**Comment vérifier.** 1) Les listes ne chargent jamais un nombre illimité de lignes (25/page).
2) `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status` indique la base opérationnelle et le cache inscriptible. 3) Le filtrage/tri reste
rapide.

> Remarque : un dispositif complet de test de charge était hors périmètre pour cette passe ; les
> garde-fous ci-dessus (pagination, mise en cache, index, requêtes bornées) sont les mesures
> concrètes et vérifiables.

---

## F79 · Facile · 400 XP — Trier et filtrer mes demandes

**Ce que nous avons réalisé.** Les citoyens peuvent **rechercher** leurs propres demandes par
objet/description, **filtrer par état** et **trier** par plus récentes ou plus anciennes. L'export
CSV suit les filtres appliqués.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**Comment vérifier.** 1) Saisir « lampadaire » → seules les demandes correspondantes restent.
2) Filtrer par « Envoyée ». 3) Trier par « Plus anciennes ».

---

## F80 · Moyen · 800 XP — Classer les demandes prioritaires

**Ce que nous avons réalisé.** Les demandes portent une **priorité** (`normal`https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/`urgent`). Les
agents peuvent la définir sur la page de la demande ; la file affiche un badge de priorité, un
compteur **urgent**, un filtre de priorité et un tri « priorité d'abord ».

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference`

**Comment vérifier.** 1) Ouvrir une demande et la passer en **Urgente** (Enregistrer la
priorité). 2) De retour dans la liste, filtrer par « Urgente » ou trier « Priorité d'abord » →
elle arrive en premier avec un badge « Urgente ».

---

## F81 · Difficile · 1230 XP — Protection perceptible contre les envois automatiques

**Ce que nous avons réalisé.** Les formulaires publics portent un jeton signé généré au rendu
et un champ-piège hors écran, de sorte que les POST scriptés à l'aveugle et les robots qui
remplissent les champs cachés sont rejetés avec une page claire « Envoi bloqué ». `rack-attack`
limite les points d'accès de demande, de contact et d'inscription, et chaque blocage est
enregistré comme `SecurityEvent` : la protection est donc perceptible depuis la console de
sécurité des administrateurs sans compliquer l'usage normal.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/feedback/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`, `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**Comment vérifier.** 1) Les formulaires affichent « Formulaire protégé contre les envois
automatiques. » 2) POST sans le jeton (ou avec le champ-piège rempli) → « Envoi bloqué ».
3) La tentative bloquée apparaît dans `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events` sous `form_protection_blocked`.

---

## F82 · Moyen · 820 XP — Pas d'envois répétés sans contrôle

**Ce que nous avons réalisé.** Avant de créer une demande, l'application vérifie si le citoyen
connecté a soumis une demande identique (même objet et même description) au cours des 10
dernières minutes. Si c'est le cas, elle conserve la première et y redirige le citoyen avec un
avis explicite, au lieu de créer un doublon.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/new`

**Comment vérifier.** Soumettre la même demande deux fois de suite → la seconde soumission
aboutit sur la demande existante et affiche « Vous avez déjà envoyé cette demande (…) ».

---

## F83 · Facile · 410 XP — Accusé de réception avec référence identifiable

**Ce que nous avons réalisé.** Chaque demande possède une référence stable (`NOVA-AAAA-XXXXX`),
affichée dans une carte « Accusé de réception » sur la page de la demande (avec la date de
réception et une action d'impression) et reprise dans l'e-mail de confirmation, afin que le
citoyen puisse la retrouver ou la citer plus tard.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/:reference` et l'e-mail de confirmation.

**Comment vérifier.** Soumettre une demande → la carte d'accusé de réception affiche la
référence ; l'objet et le corps de l'e-mail la reprennent.

---

## F84 · Moyen · 820 XP — Les agents répondent directement à une demande

**Ce que nous avons réalisé.** Les agents publient des réponses filées depuis la page de la
demande — publiques (notifient le citoyen dans l'application et par e-mail) ou internes (note
réservée aux agents). Les réponses publiques apparaissent sur la page de la demande du citoyen.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests/:reference` (formulaire de réponse) et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests/:reference`.

**Comment vérifier.** Publier une réponse publique en tant qu'agent → le citoyen la voit et
reçoit une notification/e-mail ; publier une note interne → le citoyen ne la voit pas.

---

## F85 · Expert · 1680 XP — Activité inhabituelle détectée ; protection perceptible

**Ce que nous avons réalisé.** La console de sécurité des administrateurs agrège les événements
déjà enregistrés (envois automatiques bloqués, connexions échouées, …) sur la dernière heure et
signale un volume inhabituel par un signal clair, avec la liste des événements concernés et
l'adresse la plus active. Aucun nouveau sous-système de surveillance : l'activité suspecte
devient perceptible depuis la trace existante, sans compliquer l'usage normal.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/security_events`

**Comment vérifier.** Ouvrir la console de sécurité : le panneau « Activité récente » affiche le
volume d'événements de la dernière heure et qualifie l'activité de « Normale » ou
« Inhabituelle ». Après plusieurs envois bloqués, une alerte « Activité inhabituelle détectée »
liste les compteurs d'événements concernés.

---

## F86 · Expert · 1680 XP — Les urgences ne sont jamais traitées comme des demandes ordinaires

**Ce que nous avons réalisé.** Les demandes portent déjà une priorité (F80). La file des agents
trie désormais **« priorité d'abord »** par défaut (y compris lorsque le filtre urgent est
sélectionné), un encart bien visible apparaît dès que des demandes urgentes sont en attente, et
le tableau de bord compte les demandes urgentes — ce qui nécessite de l'attention est donc
immédiatement visible à mesure que le volume augmente, au lieu d'être noyé dans la liste.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents`

**Comment vérifier.** Passer une demande en **Urgente**, puis ouvrir la liste des demandes
agents : un encart « demandes urgentes à traiter » s'affiche et la file place les demandes
urgentes en premier ; le tableau de bord affiche le compteur de demandes urgentes.

---

## F87 · Difficile · 1260 XP — Vérifier que les données importantes peuvent être sauvegardées

**Ce que nous avons réalisé.** Les administrateurs peuvent télécharger une **sauvegarde claire
et réutilisable** de toutes les demandes citoyennes (`/agents/exports/requests`). Le fichier
n'est pas un dump brut : il commence par un résumé lisible (date et auteur de génération, nombre
total, nombre d'urgentes, période couverte, répartition par statut), suivi des demandes avec
priorité et citoyen — de quoi confirmer que les données importantes peuvent être sauvegardées et
réutilisées.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/exports/requests` (administrateurs uniquement, lien « Sauvegarde » dans la navigation agent).

**Comment vérifier.** En tant qu'administrateur, cliquer sur **Sauvegarde** dans la navigation
agent → un CSV est téléchargé, dont l'en-tête résume l'export avant les enregistrements. Un
agent non administrateur ne peut pas accéder à la page.

---

## F88 · Moyen · 840 XP — Sélectionner les informations utiles et les exporter simplement

**Ce que nous avons réalisé.** La liste des demandes agents propose une action **« Exporter la
sélection (CSV) »** qui respecte les filtres actifs (recherche, état, priorité, service) : les
agents sélectionnent exactement les informations utiles et les téléchargent dans un CSV simple
et réutilisable (priorité et citoyen inclus). Les citoyens peuvent toujours télécharger
l'historique de leurs propres demandes.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/agents/requests` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/requests`

**Comment vérifier.** Filtrer la file (par ex. état *Envoyée*) puis cliquer sur **Exporter la
sélection (CSV)** → le fichier ne contient que les demandes correspondantes. Refaire depuis
l'espace citoyen avec **Télécharger (CSV)**.

---

## F89 · Moyen · 860 XP — Version en langage clair des informations essentielles

**Ce que nous avons réalisé.** Chaque service porte un **résumé en langage clair** (« En clair »),
affiché dans un bloc `<details>` repliable sur sa page. Il reformule les informations
essentielles en phrases courtes et sans jargon, tout en conservant le sens ; la description
complète reste disponible au-dessus.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**Comment vérifier.** Ouvrir la page d'un service → déplier **« En clair »** pour lire le résumé
simplifié ; la description détaillée reste affichée au-dessus.

---

## F90 · Facile · 430 XP — Demander une explication plus simple à la demande

**Ce que nous avons réalisé.** Un lien **« Demander une explication plus simple »** sur chaque page
de service ouvre le formulaire de contact pré-rempli avec le nom du service, afin qu'un citoyen
puisse demander une explication humaine uniquement quand il en a besoin — sans changer le reste
de la plateforme.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**Comment vérifier.** Sur une page de service, cliquer sur **« Demander une explication plus
simple »** → le formulaire de contact s'ouvre avec l'objet pré-rempli pour ce service.

---

## F91 · Expert · 1720 XP — Assistance automatisée orientée vers un service

**Ce que nous avons réalisé.** Un **assistant d'orientation** public (`/assistant`) qui transforme
un besoin exprimé librement en un service municipal pertinent, même avec une formulation
imparfaite. Il s'agit d'une heuristique transparente et sans dépendance (score par mots-clés sur
les noms, descriptions et résumés en langage clair des services) — aucun service d'IA externe
n'est appelé.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/assistant`

**Comment vérifier.** Saisir par ex. *« je veux signaler un lampadaire cassé »* → l'assistant
propose le ou les services pertinents et une étape suivante recommandée.

---

## F92 · Moyen · 860 XP — Décrire simplement un besoin et être orienté vers le bon service

**Ce que nous avons réalisé.** Le même assistant permet de décrire un besoin avec ses propres mots
et d'être orienté vers le service ou la démarche compétente. Lorsqu'il reconnaît une catégorie
courante, il propose une étape directe (signaler un problème / demander un document / contacter la
ville), en pré-remplissant une demande le cas échéant.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/assistant`

**Comment vérifier.** Décrire *« fuite d'eau dans la cave »* → le service de l'eau est proposé avec
une étape recommandée pour créer une demande.

---

## F93 · Expert · 1760 XP — Les fonctions essentielles restent compréhensibles en cas d'incident

**Ce que nous avons réalisé.** Une page dédiée **« Informations essentielles »** (`/essentials`)
construite à partir d'un instantané mis en cache et défensif (`EssentialInformation`) : numéros
d'urgence, démarches prioritaires et alertes en cours. Si la base de données est inaccessible, une
réponse globale sûre rend la même page avec l'essentiel au lieu d'une erreur brute.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/essentials`

**Comment vérifier.** Ouvrir `/essentials` → les numéros d'urgence et les démarches prioritaires sont
listés ; la page d'état du système y renvoie, et la page reste affichable lorsque les données
essentielles sont dégradées.

---

## F94 · Moyen · 880 XP — Continuer à consulter les informations essentielles en cas d'incident

**Ce que nous avons réalisé.** La page des informations essentielles et son bandeau compact
mettent en avant les informations et contacts utiles dont un citoyen a besoin pendant un incident,
et la page d'état du système affiche le **bandeau d'informations essentielles** dès qu'un composant
est indisponible, afin que l'essentiel reste accessible sans parcourir toute la plateforme.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/essentials` et `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/status`

**Comment vérifier.** Consulter `/essentials` → contacts d'urgence, démarches prioritaires et alertes
actives sont affichés ; lorsqu'un composant d'état est indisponible, `/status` met en avant le même
essentiel.

---

## F95 · Difficile · 1320 XP — Plateforme sobre, sans ressources inutiles

**Ce que nous avons réalisé.** Le mode **économie de données** retire désormais aussi la carte
interactive lourde des pages de service tout en conservant l'adresse et une alternative statique,
et le budget environnemental a été resserré (CSS ≤ 40 Ko, JS ≤ 60 Ko gzip), imposé automatiquement
par le test de budget des ressources afin qu'aucun poids non essentiel ne revienne.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`

**Comment vérifier.** Activer **Économie de données** dans le menu d'accessibilité → les pages de
service se chargent sans la carte interactive mais conservent l'adresse. La page `/eco` rapporte le
poids mesuré dans le budget.

---

## F96 · Moyen · 880 XP — Accéder rapidement à l'essentiel sur mobile ou connexion limitée

**Ce que nous avons réalisé.** Le **mode simple** affiche des pages plus légères ne conservant que
l'essentiel : sur les pages de service, le bloc de services liés et le formulaire d'avis sont
omis, et la page d'accueil retire les sections non essentielles. Il fonctionne avec le mode
économie de données pour les connexions lentes ou mobiles.

**Où tester.** `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/services/etat-civil`

**Comment vérifier.** Activer **Mode simple** via les contrôles d'accessibilité → les pages n'affichent
que le contenu essentiel (ni services liés, ni formulaire d'avis).

---

# Notes globales d'implémentation

- **Stack :** Rails 8.1, PostgreSQL 18.6, Hotwire (Turbo + Stimulus), ViewComponents,
  Tailwind + daisyUI (sans outillage Node.js).
- **Sécurité :** Devise (deux scopes) avec liens magiques sans mot de passe, connexion par
  identifiant citoyen et double authentification TOTP, Pundit, PaperTrail, `rack-attack`,
  alertes de connexion depuis un nouvel appareil, journal d'événements de sécurité (réservé aux
  administrateurs), CSP avec nonces, HSTS et cookies sécurisés en production, paramètres
  filtrés, suppression de compte confirmée par mot de passe.
- **Internationalisation :** français par défaut avec repli sur l'anglais et espagnol ; contenus
  traduisibles des services, actualités, alertes et partenaires ; langue résolue depuis le
  paramètre → le profil → la session → le cookie.
- **Accessibilité :** déclaration orientée WCAG 2.2 AA sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/accessibility`.
- **Environnement :** poids mesurés et budgets sur `https://preskenler-terra-nova-f55b36d739c2.herokuapp.com/eco`, imposés par un test automatisé de
  taille des ressources ; modes économie de données et simple, et bibliothèque de cartes
  importée dynamiquement.
- **Démocratie participative :** projets, consultations avec avis enregistrés (F65/F66), idées
  citoyennes avec soutien et modération (F68).
- **Partenaires & retours :** annuaire de partenaires avec horaires et localisation (F74) ; avis
  sur les services (F76) ; détection des doublons pour les agents (F75).
- **Performance :** la bibliothèque de cartes n'est pas préchargée sur les pages sans carte et
  sa feuille de style n'est chargée que là où une carte est rendue.
- **Qualité :** 378 tests automatisés passent (371 unitaires/contrôleurs/intégration + 7 tests
  système de type navigateur), dont un test de rendu de toutes les pages ; RuboCop, Brakeman,
  bundler-audit et l'audit des importmaps sont tous propres.
