# Démo Q# — Superposition, intrication & téléportation

[![Netlify Status](https://api.netlify.com/api/v1/badges/1d124264-bfba-4524-9ee7-48bc7661eaac/deploy-status)](https://app.netlify.com/projects/ornate-eclair-7ad406/deploys)

## Sphère de Bloch interactive

`bloch-sphere.html` est aussi disponible en ligne :
[ornate-eclair-7ad406.netlify.app](https://ornate-eclair-7ad406.netlify.app/)

## Installation

1. Installer le SDK .NET (6.0 ou plus récent) : https://dotnet.microsoft.com/download
2. Installer le Quantum Development Kit :
   ```
   dotnet workload install qsharp
   ```
3. Créer le projet :
   ```
   dotnet new console -lang Q# -o demo-quantique
   ```
4. Remplacer le contenu de `demo-quantique/Program.qs` par celui ci `src/Program.qs`.

## Lancer la démo

```
cd demo-quantique
dotnet run
```

## Résulat attendu

```
=== Démo 1 : Superposition ===
Sur 1000 mesures : ~500 fois |0>, ~500 fois |1>
Chaque mesure individuelle donne un résultat net (0 ou 1).
Seule la distribution statistique révèle la superposition initiale.

=== Démo 2 : Intrication (état de Bell) ===
Sur 1000 mesures : ~1000 fois résultats identiques, ~0 fois différents
Les deux qubits sont corrélés à 100%, alors que chaque résultat individuel reste aléatoire.

=== Démo 3 : Téléportation quantique ===
✅ État correctement téléporté
✅ État correctement téléporté
✅ État correctement téléporté
✅ État correctement téléporté
✅ État correctement téléporté
```

Les chiffres exacts de la démo 1 et 2 varient légèrement à chaque exécution
(aléa quantique simulé), mais la démo 1 doit toujours tourner autour de 50/50,
la démo 2 doit montrer une corrélation quasi parfaite, et les 5 répétitions
de la démo 3 doivent toutes afficher "✅".

## Ce que chaque démo permet de mettre en avant

- **Démo 1 (superposition)** — la base : porte `H`, mesure `M`, notion de
  distribution statistique plutôt que valeur "cachée".
- **Démo 2 (intrication)** — `CNOT` pour créer une paire de Bell, corrélation
  parfaite entre deux mesures pourtant individuellement aléatoires.
- **Démo 3 (téléportation)** — :
  - **Contrôle classique conditionné par une mesure** (`if m2 == One { X(there); }`) —
    Q# mélange nativement logique classique et quantique dans le même flux.
  - **Le functor `Adjoint`** — Q# génère automatiquement l'inverse de
    `PrepareState` (`is Adj` dans la signature suffit). Ce n'est pas natif de la même façon dans les auters outils (Qiskit par exemple).


## Références

### Q# et Azure Quantum

- [Présentation du langage Q# (doc Microsoft)](https://learn.microsoft.com/fr-fr/azure/quantum/qsharp-overview) —
  la référence utilisée pour les définitions de ce README.
- [Dépôt GitHub officiel de Q#](https://github.com/microsoft/qsharp) —
  code source du compilateur, du runtime et de la bibliothèque standard.
- [Pourquoi avons-nous besoin de Q# ?](https://devblogs.microsoft.com/qsharp/why-do-we-need-q/) —
  billet du blog Microsoft Quantum sur les origines et les choix de conception du langage.
- [Quantum Katas](https://github.com/microsoft/QuantumKatas) — exercices
  progressifs pour apprendre Q# et les concepts de calcul quantique en pratiquant.

### Actualités et nouveautés sur le quantique

- [The Quantum Insider](https://thequantuminsider.com/) — le site de
  référence pour l'actualité quotidienne du secteur (recherche, matériel, levées de fonds).
- [Quantum Zeitgeist](https://quantumzeitgeist.com/) — actualité et analyses
  couvrant IBM, Google, IonQ, Quantinuum et l'écosystème quantique au sens large.
- [Quantum Computing Report](https://quantumcomputingreport.com/) — suivi
  des annonces industrielles et des avancées matérielles, mis à jour régulièrement.
