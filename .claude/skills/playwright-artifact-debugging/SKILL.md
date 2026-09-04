---
name: playwright-artifact-debugging
description: Diagnose and verify visual/layout bugs in an HTML/CSS/JS artifact empirically with Playwright (screenshots, DOM measurements, isolated-variable tests) before declaring a fix — use instead of guessing from code alone.
---

# Débogage empirique d'artefacts avec Playwright

Quand un bug est visuel ou dépend du layout (un élément invisible, une forme
déformée, un clic qui ne déclenche rien), le code seul ne suffit souvent pas
à trancher entre plusieurs hypothèses plausibles. Ce skill décrit la boucle à
suivre : mesurer avant de corriger, corriger, puis re-mesurer pour confirmer.

## Principe général

Ne jamais déclarer un bug corrigé sur la seule base d'une théorie "qui
semble logique". Toujours produire une preuve empirique (capture d'écran,
mesure DOM, ou les deux) avant et après le correctif.

## Étapes

1. **Ne jamais déboguer sur le fichier final.** Travailler sur une copie
   jetable (`fichier.testcopy.html`) pendant tout le diagnostic ; le fichier
   réel n'est modifié qu'une fois la cause confirmée.

2. **Dépendances externes bloquées par le sandbox** (ex. un CDN inaccessible
   depuis l'environnement d'exécution) : installer l'équivalent en local
   (`npm install <lib>@<version-exacte>`), copier le build vers un fichier
   local, et substituer l'URL du CDN par ce fichier local **uniquement dans
   la copie de test** (`sed` ciblé). Ne jamais laisser ce remplacement dans
   le fichier réel — le vérifier avec un `grep` de l'URL CDN juste avant de
   republier.

3. **Écrire un petit script Playwright jetable** qui : ouvre la copie de
   test (`file://...`), reproduit exactement les actions décrites par
   l'utilisateur (clics, changements de mode, saisies), puis capture une
   preuve — une capture d'écran ET, si possible, une mesure DOM directe
   (`clientWidth`/`clientHeight`, `getBoundingClientRect()`, un état
   JavaScript exposé). Ne pas se fier à la capture seule si une mesure
   chiffrée peut lever l'ambiguïté.

4. **Zoomer/recadrer une capture ambiguë** plutôt que de deviner à l'œil sur
   une vignette pleine page (ex. avec Pillow : `crop()` puis `resize()` en
   `NEAREST` ou `LANCZOS` pour agrandir la zone concernée).

5. **Isoler une variable à la fois pour trancher entre hypothèses** : si
   plusieurs causes sont plausibles (couleur trop proche du fond ? ordre de
   rendu/profondeur ? police trop grande pour son conteneur ?), modifier
   temporairement UNE SEULE propriété vers une valeur extrême et sans
   ambiguïté (couleur rouge vif, `depthTest:false`, police énorme...) puis
   re-capturer. Si le symptôme disparaît, la cause est confirmée ; sinon,
   passer à l'hypothèse suivante. Ne jamais appliquer le correctif définitif
   avant d'avoir isolé la vraie cause de cette façon.

6. **Appliquer le correctif minimal sur le fichier réel**, avec un
   commentaire de code expliquant POURQUOI (pas seulement quoi), pour que la
   prochaine personne qui touche ce code ne retombe pas dans le même piège.

7. **Rejouer le même script Playwright** contre une copie fraîche du fichier
   réel corrigé, pour confirmer que le correctif tient — pas seulement dans
   le cas testé en isolation à l'étape 5, mais dans le scénario original
   rapporté par l'utilisateur.

8. **Nettoyer systématiquement avant de terminer** : copies de test,
   fichiers de dépendances locales, captures d'écran, dossiers npm
   temporaires. Reconfirmer que les références externes du fichier réel
   (URLs CDN, etc.) sont intactes.

9. Republier/livrer seulement après ce nettoyage.

## Signal d'alerte

Si la justification d'un correctif commence par "ça devrait être ça" ou
"probablement parce que" sans capture ni mesure à l'appui, revenir à
l'étape 3 avant de toucher au fichier réel.
