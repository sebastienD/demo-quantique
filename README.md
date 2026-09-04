# Démo Q# — Superposition, intrication & téléportation

## Sphère de Bloch interactive

`bloch-sphere.html` est aussi disponible en ligne, sans rien installer :
[claude.ai/code/artifact/d87d68e1-4bbc-4b22-87e9-2247f01d2f1c](https://claude.ai/code/artifact/d87d68e1-4bbc-4b22-87e9-2247f01d2f1c)

## Installation

1. Installer le SDK .NET (6.0 ou plus récent) : https://dotnet.microsoft.com/download
2. Installer le Quantum Development Kit :
   ```
   dotnet workload install qsharp
   ```
3. Créer le projet et  dedans :
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
- **Démo 3 (téléportation)** — la pièce maîtresse pour un public technique :
  - **Contrôle classique conditionné par une mesure** (`if m2 == One { X(there); }`) —
    Q# mélange nativement logique classique et quantique dans le même flux.
  - **Le functor `Adjoint`** — Q# génère automatiquement l'inverse de
    `PrepareState` (`is Adj` dans la signature suffit). Bon point de comparaison
    si quelqu'un du public connaît Qiskit : ce n'est pas natif de la même façon ailleurs.
  - Tu peux mentionner le functor `Controlled` en bonus à l'oral, sans le coder
    en live si le temps manque.

## Comprendre l'état de Bell (démo 2)

Un **état de Bell** est un état à 2 qubits **maximalement intriqué** :
impossible de décrire l'état de l'un des deux qubits indépendamment de
l'autre, alors même que l'état des deux qubits pris ensemble est parfaitement
défini.

"Maximalement intriqué" veut dire précisément ceci : si on essaie d'écrire
l'état individuel d'un seul des deux qubits (en "oubliant" l'autre), on ne
retombe sur aucun état bien défini sur la sphère de Bloch — son vecteur
s'effondre littéralement au centre de la sphère (voir « Le vecteur d'état
est-il toujours sur la surface ? » dans
[bloch-sphere-notes.md](bloch-sphere-notes.md)). Toute l'information sur
l'état est contenue dans la corrélation entre les deux qubits, il n'en
reste aucune sur chaque qubit pris séparément. C'est un maximum au sens où
il existe des états "partiellement" intriqués, où chaque qubit garde un peu
d'information individuelle (son vecteur de Bloch reste non nul, juste
raccourci) ; un état de Bell est le cas extrême où ce vecteur individuel
tombe strictement à zéro.

Le plus classique des 4 états de Bell s'écrit :

|Φ⁺⟩ = (|00⟩ + |11⟩) / √2

Les deux qubits sont chacun en superposition (impossible de prédire à
l'avance si on mesurera 0 ou 1), mais leurs résultats sont **parfaitement
corrélés** : si le premier donne 0, le second donnera 0 à coup sûr ; s'il
donne 1, l'autre donnera 1. Cette propriété reste vraie même si les deux
qubits sont physiquement séparés — c'est elle qui a inspiré à John Bell, en
1964, le théorème qui porte son nom, d'où le nom "état de Bell".

Il existe 4 états de Bell au total, formant une base complète pour 2 qubits
intriqués :

- |Φ⁺⟩ = (|00⟩ + |11⟩)/√2
- |Φ⁻⟩ = (|00⟩ − |11⟩)/√2
- |Ψ⁺⟩ = (|01⟩ + |10⟩)/√2
- |Ψ⁻⟩ = (|01⟩ − |10⟩)/√2 — souvent utilisé comme exemple
  "d'anti-corrélation" (les deux qubits donnent toujours des résultats
  opposés).

C'est exactement ce que fait `DemoBellState` : `H(q1)` met `q1` en
superposition, puis `CNOT(q1, q2)` intrique `q2` avec `q1` — le résultat est
précisément l'état |Φ⁺⟩ ci-dessus. Les 1000 mesures répétées donnent ~50 %
de "00" et ~50 % de "11", jamais de "01" ni "10" : c'est la signature
visible de la corrélation parfaite d'un état de Bell.

Lien avec `bloch-sphere.html` : un état de Bell **ne peut pas** être
affiché correctement sur une sphère de Bloch individuelle, précisément à
cause de ce qu'on vient de voir — chaque qubit pris séparément n'a pas
d'état bien défini (son vecteur de Bloch s'effondrerait vers le centre de
la sphère). C'est une façon très parlante d'illustrer à l'oral ce que veut
dire "intrication", en s'appuyant sur l'outil que le public vient de voir.

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
