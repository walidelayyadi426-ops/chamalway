# 📱 Checklist de Test Finale — Chamal Way (v1.0.1+30)

---

### 1. 🚀 Écran de Démarrage & Onboarding (Splash & Onboarding)
- [ ] **Splash Screen** : Lancement avec animation du logo et redirection automatique vers `/onboarding` (premier lancement) ou `/home` (déjà vu).
- [ ] **Bouton "Skip"** : Passe directement à l'accueil et enregistre l'état dans `SharedPreferences`.
- [ ] **Bouton "Next / Get Started"** : Fait défiler les 4 diapositives et ouvre l'accueil.

### 2. 🏠 Écran d'Accueil (Home)
- [ ] **En-tête** : Salutation "Salam! Explore the North 🇲🇦" et bouton Paramètres (sans la cloche de notification).
- [ ] **Bouton Engrenage ⚙️** : Navigue vers l'écran des paramètres (`/settings`).
- [ ] **Barre de Recherche** : Clic sur le conteneur redirige vers la vue d'exploration (`/explore`).
- [ ] **Carrousel Villes Vedettes** : Défilement automatique fluide toutes les 5 secondes et balayage manuel.
- [ ] **Puces de Catégories** : Filtrage instantané des destinations recommandées.
- [ ] **Bouton "See All"** : Redirige vers la vue d'exploration (`/explore`).
- [ ] **Cartes de Destinations** : Clic sur la carte ouvre la page de détails ; clic sur le cœur bascule l'état favori.

### 3. 🔍 Écran de Recherche & Exploration (Explore / Search)
- [ ] **Champ de Saisie** : Recherche dynamique accent-insensitive et case-insensitive avec délai de 300 ms.
- [ ] **Bouton Effacer (X)** : Efface la saisie de texte et réinitialise la recherche.
- [ ] **Filtres Puces Catégories & Villes** : Filtrage combiné en temps réel.
- [ ] **Bouton Rouge de Réinitialisation** : Réinitialise tous les filtres actifs vers "All".
- [ ] **Puces de Recherches Populaires** : Remplit automatiquement le champ de recherche au clic.

### 4. 📍 Écran de Détail d'une Destination (Place Detail)
- [ ] **Bouton Retour (Flèche App Bar)** : Retourne à l'écran précédent (ou redirige vers `/home` si accès direct sans historique).
- [ ] **Icône Cœur (App Bar & Action Bar)** : Ajoute/retire des favoris avec persistance `SharedPreferences`.
- [ ] **Bouton "Directions"** : Ouvre l'application de cartes natives (Apple Maps / Google Maps) avec les coordonnées exactes et gestion d'erreur visible.
- [ ] **Bouton "Share"** : Ouvre le panneau de partage natif iOS/Android via `SharePlus.instance.share(ShareParams(...))` avec ancrage `sharePositionOrigin` calculé sur le RenderBox du bouton et repli au centre.
- [ ] **Bouton "My Trip"** : Ouvre la feuille modale d'ajout à l'itinéraire.
- [ ] **Galerie Photos Miniatures** : Clic sur une miniature bascule la photo principale de présentation.

### 5. 🧳 Écran d'Itinéraire de Voyage (My Trip)
- [ ] **Sélecteur de Durée (Dropdown)** : Ajuste la durée du séjour de 1 à 7 jours.
- [ ] **Dialogue de Confirmation** : Demande confirmation avant de réduire le nombre de jours.
- [ ] **Réordonnancement** : Mouvement de glisser-déposer (*Drag & Drop*) pour réorganiser les lieux dans une journée.
- [ ] **Suppression de Lieu (X)** : Retire la destination de la journée avec notification SnackBar.
- [ ] **Bouton "Share Itinerary"** : Génère et partage le résumé texte complet par jour via `SharePlus.instance.share(ShareParams(...))` et ancrage RenderBox sécurisé.

### 6. ❤️ Écran des Favoris (Favorites)
- [ ] **Persistance des Favoris** : Les favoris restent sauvegardés après la fermeture et le redémarrage complet de l'application via `SharedPreferences`. Les identifiants inexistants sont ignorés.
- [ ] **Bouton "My Trip" sur Carte** : Ouvre la feuille modale d'ajout à l'itinéraire.
- [ ] **Retrait des Favoris** : Clic sur le cœur retire immédiatement le lieu de la liste.
- [ ] **État Vide** : Affiche l'icône et le bouton d'action "Explore Destinations" si aucun favori n'est enregistré.

### 7. 🗺️ Écran de Carte Interactive (Map)
- [ ] **Navigation Carte** : Déplacement et zoom tactiles fluides avec Tuiles OpenStreetMap.
- [ ] **Lien Attribution OSM** : Ouvre le lien de copyright avec gestion d'erreur visible (SnackBar) en cas d'échec.
- [ ] **Marqueurs GIS** : Clic sur un repère agrandit le pointeur et ouvre la carte d'aperçu en bas de l'écran.
- [ ] **Filtres de la Carte** : Filtre dynamiquement les marqueurs visibles selon la catégorie sélectionnée.
- [ ] **Bouton de Recentrage (FAB)** : Recentre la caméra sur la région Nord du Maroc (Tangier/Chefchaouen).
- [ ] **Bouton "View Details" (Pop-up)** : Redirige vers la page de détails de la destination.

### 8. ⚙️ Écran de Paramètres (Settings & Info)
- [ ] **Switch Thème Sombre** : Bascule instantanément l'apparence Clair/Sombre.
- [ ] **Persistance du Thème** : Le thème choisi (Sombre/Clair) est conservé au redémarrage complet de l'application via `SharedPreferences`.
- [ ] **Lien "About Chamal Way"** : Ouvre la page d'information du projet et conseils de voyage.
- [ ] **Lien "Emergency & Travel Tips"** : Ouvre la liste des numéros d'urgence officiels.
- [ ] **Affichage Dynamique de Version** : Affiche la version réelle extraite du système via `PackageInfo` (`v1.0.1 (Build 30)`).

### 9. 🚨 Écran d'Urgence & Sécurité (Emergency)
- [ ] **Numéros Officiels** : Affiche uniquement les numéros valides (Police `19`, Protection Civile `15`, Gendarmerie Royale `177`).
- [ ] **Appel Direct / Fallback Copie** : Sur appareil avec SIM, précompose l'appel. Sur tablette/iPad sans SIM ou échec d'ouverture `tel:`, affiche une boîte de dialogue avec le numéro en grand et un bouton "Copy" pour copier le numéro dans le presse-papiers.
