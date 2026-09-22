# Raccourcis VS Code (macOS)

| Action | Raccourci |
|---|---|
| **Nouveau fichier** | `Cmd+N` |
| **Formatter le document** | `Shift+Option+F` |
| **Ouvrir/fermer le terminal intégré** | `` Ctrl+` `` (Control + accent grave, la touche sous Échap) |
| **Zen Mode** | `Cmd+K Z` |
| **Plein écran** | `Ctrl+Cmd+F` |

Quelques précisions utiles :

- `Cmd+N` crée un fichier **non enregistré** (« Untitled »). Pour créer un fichier directement dans l'explorateur avec un nom, il n'y a pas de raccourci par défaut — c'est un clic droit sur le dossier → *New File*, ou `Cmd+Shift+E` pour focus l'explorateur puis touche `A`.
- Le formatage (`Shift+Option+F`) ne marche que si un formateur est installé/configuré pour le langage du fichier ouvert (ex. pour du Markdown ou du Q#, vérifie qu'une extension le supporte — sinon VS Code te propose d'en choisir une).
- `` Ctrl+` `` **bascule** l'affichage du terminal (l'ouvre s'il est fermé, le ferme s'il est déjà au premier plan) plutôt que d'en ouvrir un nouveau à chaque fois. Pour un **nouveau** terminal (en plus d'un existant) : `` Cmd+Shift+` ``.
- `Cmd+K Z` (Zen Mode) cache toute l'interface (barre latérale, onglets, barre de statut) pour ne garder que l'éditeur — pratique pour une démo. `Échap` ou `Cmd+K Z` à nouveau pour en sortir.
- `Ctrl+Cmd+F` bascule le plein écran au niveau du système (macOS), indépendamment de Zen Mode — les deux se combinent bien pour présenter.
