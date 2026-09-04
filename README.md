# Démo Q# — Superposition, intrication & téléportation

## Sphère de Bloch interactive

`bloch-sphere.html` est aussi disponible en ligne, sans rien installer :
[claude.ai/code/artifact/d87d68e1-4bbc-4b22-87e9-2247f01d2f1c](https://claude.ai/code/artifact/d87d68e1-4bbc-4b22-87e9-2247f01d2f1c)

## Installation (à faire avant le jour J)

1. Installer le SDK .NET (6.0 ou plus récent) : https://dotnet.microsoft.com/download
2. Installer le Quantum Development Kit :
   ```
   dotnet workload install qsharp
   ```
3. Créer le projet et copier le fichier `Program.qs` dedans :
   ```
   dotnet new console -lang Q# -o SuperpositionDemo
   ```
   Puis remplace le contenu de `SuperpositionDemo/Program.qs` par celui fourni ici.

## Lancer la démo

```
cd SuperpositionDemo
dotnet run
```

## Ce que tu dois voir s'afficher

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
est-il toujours sur la surface ? » plus bas). Toute l'information sur
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

## Documentation — comprendre le langage Q#

### Le lien avec C#, et le principe général

Q# est un langage de programmation **open source**, de haut niveau,
développé par Microsoft pour écrire des programmes quantiques ; il est
inclus dans le Kit de développement Microsoft Quantum (QDK). Sa syntaxe est
proche de C# (accolades, points-virgules, typage statique fort), mais en
tant que langage de programmation *quantique*, il répond à des exigences que
C# n'a pas :

- **Indépendance vis-à-vis du matériel** — les qubits manipulés dans le code
  ne sont pas liés à un matériel précis ; le compilateur et le runtime Q#
  gèrent le mapping entre les qubits du programme et les qubits physiques,
  ce qui permet au même code de tourner sur différents processeurs
  quantiques (ou, comme ici, sur un simulateur).
- **Intégration du calcul quantique et classique** — un même programme
  mélange librement boucles, conditions et variables classiques avec des
  instructions qui agissent sur des qubits ; c'est indispensable pour
  l'informatique quantique universelle.
- **Gestion des qubits** — Q# fournit des opérations et fonctions intégrées
  pour créer des états de superposition, intriquer des qubits et effectuer
  des mesures quantiques.
- **Respect des lois de la physique** — un qubit n'est jamais une simple
  variable qu'on peut copier ou lire directement : c'est une ressource qu'on
  alloue, qu'on manipule via des portes, puis qu'on doit explicitement
  remettre à zéro et libérer.

### Vocabulaire

- **`namespace`** — regroupe du code associé, comme en C#. Un programme Q#
  peut optionnellement commencer par un espace de noms défini par
  l'utilisateur ; chaque fichier ne peut avoir qu'un seul `namespace`, et si
  on n'en spécifie aucun, le compilateur utilise le nom du fichier comme
  espace de noms.
- **`open`** — rend disponibles, sans avoir à écrire leur chemin complet,
  toutes les fonctions et opérations d'un espace de noms (par exemple
  `open Microsoft.Quantum.Intrinsic;` pour utiliser directement `H`, `X`,
  `M`... au lieu de `Microsoft.Quantum.Intrinsic.H`). Deux espaces de noms
  très utilisés (`Std.Core` et `Std.Intrinsic`, contenant entre autres `M`
  et `Message`) sont d'ailleurs chargés automatiquement par l'environnement
  Q#, sans même avoir besoin d'un `open`. À noter : la documentation la plus
  récente de Microsoft utilise plutôt le mot-clé `import` (ex.
  `import Std.Intrinsic.*;`), qui joue exactement le même rôle qu'`open`
  dans le style de Q# utilisé dans ce projet.
- **`operation`** — une opération est une sous-routine quantique : le bloc
  de construction de base d'un programme Q#, celui qui a le droit de
  contenir des instructions modifiant l'état d'un registre de qubits
  (contrairement à une `function` classique, purement calculatoire, qui n'a
  pas ce droit). Pour définir une opération, on précise son nom, ses entrées
  et sa sortie, par exemple `operation MonOperation() : Result { ... }`.
- **`@EntryPoint()`** — chaque programme Q# doit avoir un point d'entrée, le
  point de départ de son exécution. Par défaut, le compilateur démarre à
  partir d'une opération nommée `Main()`, où qu'elle se trouve dans le
  programme ; l'attribut `@EntryPoint()` permet de désigner explicitement
  n'importe quelle autre opération comme point de départ, comme
  `RunDemo()` dans `Program.qs`.
- **`ψ` (psi)** — la notation physique (pas un mot-clé Q#) pour désigner
  l'état quantique d'un qubit : |ψ⟩ = α|0⟩ + β|1⟩, où α et β sont les deux
  amplitudes complexes manipulées par `applyMatrix` dans `bloch-sphere.html`.
  Au sens strict, "fonction d'onde" désigne plutôt ψ(x), une fonction
  continue de la position (formalisme historique de Schrödinger) ; pour un
  qubit, système à deux états sans notion de position, on parle plus
  rigoureusement de **vecteur d'état**. Dans l'usage courant, "fonction
  d'onde" est cependant souvent employé de façon large pour désigner
  l'objet qui décrit complètement l'état d'un système quantique, discret ou
  continu — l'usage n'est donc pas faux, juste approximatif au sens
  historique. C'est ce vecteur ψ, projeté sur la sphère via
  x=2Re(α*β), y=2Im(α*β), z=|α|²−|β|², que `bloch-sphere.html` visualise en direct.
- **`Result`** — un type spécifique au quantique qui représente le résultat
  d'une mesure de qubit ; il ne peut valoir que **`Zero`** ou **`One`**.
- **`Qubit()`** — le type représentant un bit quantique. Les qubits sont
  toujours alloués dans l'état |0⟩, qu'ils soient physiques (sur du vrai
  matériel) ou simulés (comme ici).
- **`Unit`** — le type de retour d'une opération qui ne renvoie aucune
  valeur, l'équivalent de `NULL`/`void` dans d'autres langages.
- **`use`** — le mot-clé utilisé pour allouer un ou plusieurs qubits
  (toujours dans l'état |0⟩). On peut aussi bien allouer un qubit unique
  (`use q = Qubit();`) qu'un registre (`use qubits = Qubit[2];`, avec accès
  à chaque qubit par son index, `qubits[0]`). Les qubits alloués avec `use`
  sont automatiquement libérés à la fin du bloc, à condition d'avoir été
  remis à |0⟩ au préalable.
- **`Reset`** — dans Q#, les qubits **doivent** être dans l'état |0⟩ au
  moment où ils sont libérés, pour éviter des erreurs sur du matériel
  quantique réel. `Reset(q)` remet un qubit à |0⟩ ; ne pas le faire avant la
  fin d'un bloc `use` provoque une erreur d'exécution.
- **`let`** — déclare une variable **immuable** (valeur fixée une fois pour
  toutes). C'est la façon habituelle de stocker un résultat, par exemple
  `let result = M(q);`.
- **`mutable` / `set`** — `mutable` déclare, à l'inverse, une variable que
  l'on pourra modifier ; `set` est le mot-clé utilisé pour la réassigner
  ensuite, ce qui distingue visuellement, dans le code, les variables qui
  changent de celles qui ne changent pas.
- **`Message`** — affiche un texte pour l'utilisateur, où que ce soit dans
  le programme ; c'est l'équivalent de `Console.WriteLine` en C#. Elle fait
  partie de l'espace de noms `Std.Intrinsic`, chargé automatiquement.
- **`H`** — l'opération Hadamard, fournie par la bibliothèque standard de
  Q#. Appliquée à un qubit dans la base Z, elle le place dans une
  superposition égale, avec 50 % de chances d'être mesuré comme `Zero` ou
  `One`.
- **`CNOT`** — porte "NOT contrôlé" : inverse le qubit cible seulement si le
  qubit de contrôle vaut |1⟩. C'est l'outil de base pour créer de
  l'intrication entre deux qubits.
- **`Rx`, `Ry`** — rotations paramétrées d'un angle `theta` autour des axes
  X et Y de la sphère de Bloch (la représentation géométrique de l'état d'un
  qubit). Elles permettent de préparer des états qui ne sont ni |0⟩ ni |1⟩.
- **Les portes de Pauli `X`, `Y`, `Z`** — trois rotations "de base" à 180°
  autour des axes X, Y et Z. `X` est l'équivalent quantique du NOT classique
  (inverse |0⟩ et |1⟩) ; `Z` laisse |0⟩ et |1⟩ inchangés mais inverse le
  signe de la partie "|1⟩" d'une superposition (effet invisible sans les
  combiner à d'autres portes — voir « Pourquoi une bascule de phase Z ne
  fait rien de visible... » plus bas) ; `Y` combine les deux effets. Q# les
  mesures correspondantes (mesures de Pauli) sont d'ailleurs ce que fait
  l'opération `M` : mesurer un qubit avec `M` équivaut à
  `Measure([PauliZ], [qubit])`.
- **`functor`** — une transformation qu'on applique à une opération pour en
  obtenir automatiquement une variante, sans réécrire le code à la main. Une
  opération déclare les functors qu'elle supporte dans sa signature (`is Adj`,
  `is Ctl`, ou `is Adj + Ctl`).
  - **`Adjoint`** — génère l'opération **inverse**. Utile par exemple pour
    "défaire" une préparation d'état et vérifier qu'on retombe bien sur |0⟩
    (voir la démo de téléportation).
  - **`Controlled`** — génère une version **contrôlée** de l'opération, qui
    ne s'applique que si un ou plusieurs qubits de contrôle valent |1⟩.
    `Controlled X([ctrl], target)` équivaut par exemple à un `CNOT`.
- **Phase** — l'angle associé à un nombre complexe, généralement noté φ. Un
  nombre complexe s'écrit r·e^(iφ) : r est son module (l'amplitude "en
  grandeur"), φ sa phase. Deux distinctions comptent en informatique
  quantique :
  - *Phase globale* — un facteur e^(iφ) qui multiplie **tout** l'état (α et
    β en même temps). Elle est physiquement invisible — aucune mesure ne
    peut la détecter — et n'a donc aucun effet sur la sphère de Bloch.
  - *Phase relative* — la différence de phase **entre** α et β. C'est elle
    qui est physiquement observable (elle détermine les interférences, et
    se lit sur la sphère comme l'angle de longitude φ autour de l'axe Z).
    Les portes `Z`, `S`, `T` et `Rz` modifient uniquement cette phase
    relative — c'est pour ça qu'on les appelle des "bascules/portes de
    phase".
- **État pur / état mixte** — un **état pur** est un état quantique
  parfaitement défini, non mélangé avec d'autres ; il se représente par un
  vecteur de longueur 1 sur la sphère de Bloch. Un **état mixte** est un
  mélange statistique de plusieurs états purs (par décohérence, ou — comme
  vu plus haut — en isolant un qubit intriqué de son partenaire) ; il se
  représente par un point à l'intérieur de la sphère, de longueur d'autant
  plus courte que le mélange est important.
- **Notation de Dirac (bra-ket)** — l'écriture |0⟩, |1⟩, |+⟩, |−⟩, |+i⟩,
  |−i⟩, |Φ⁺⟩... utilisée partout dans ce document pour désigner des états
  quantiques ("ket"). |+⟩ et |−⟩ sont les états de superposition égale sur
  l'axe X de la sphère de Bloch ; |+i⟩ et |−i⟩ sont leurs équivalents sur
  l'axe Y.

### Exemple commenté — comment `Rx` elle-même est construite

Le code ci-dessous n'est pas à coder en live : c'est un extrait (simplifié)
de la façon dont une opération comme `Rx` est réellement implémentée dans
Q#. Il est utile à montrer ou évoquer pour illustrer concrètement les
functors, plutôt que de rester sur leur seule définition abstraite.

```qsharp
operation Rx(theta : Double, qubit : Qubit) : Unit is Adj + Ctl {
    // Déclare l'opération Rx : elle prend un angle (theta) et un qubit,
    // ne retourne rien (Unit), et annonce qu'elle supporte les functors
    // Adjoint et Controlled (is Adj + Ctl). Cette annonce oblige à décrire
    // ci-dessous, à la main, comment chacune de ces variantes se comporte.

    body ... {
        // Le bloc "body" décrit le comportement PAR DÉFAUT, c'est-à-dire
        // ce qu'il se passe quand on appelle simplement Rx(theta, qubit)
        // sans aucun functor. Les "..." sont juste une syntaxe imposée ici.
        __quantum__qis__rx__body(theta, qubit);
        // Appelle directement l'implémentation bas niveau (fournie par le
        // simulateur ou le matériel) qui exécute la vraie rotation Rx.
        // Ce n'est plus du Q# "haut niveau", c'est la porte physique elle-même.
    }

    controlled (ctls, ...) {
        // Décrit manuellement le comportement du functor Controlled.
        // "ctls" est la liste des qubits de contrôle passés lors de l'appel
        // (ex: Controlled Rx(ctls, (theta, qubit))).

        if Length(ctls) == 0 {
            // Cas particulier : la version contrôlée a été appelée, mais
            // sans aucun qubit de contrôle fourni.
            __quantum__qis__rx__body(theta, qubit);
            // Dans ce cas, on se comporte simplement comme la version
            // normale, puisqu'il n'y a rien à contrôler.
        } else {
            // Sinon, il y a bien au moins un qubit de contrôle à respecter.
            within {
                // Le bloc "within" ouvre une CONJUGAISON : tout ce qu'il
                // contient sera appliqué, puis automatiquement défait
                // (son Adjoint) juste après le bloc "apply" qui suit.
                // C'est un raccourci pour écrire "fais A, fais B, défais A"
                // sans dupliquer soi-même le code de A à l'envers.
                MapPauliAxis(PauliZ, PauliX, qubit);
                // Change temporairement l'axe de référence du qubit : on
                // convertit l'axe X vers l'axe Z. En effet, matériellement,
                // on ne sait facilement faire une rotation CONTRÔLÉE
                // qu'autour de l'axe Z — donc on "tourne" temporairement
                // le problème pour s'y ramener.
            } apply {
                // Le bloc "apply" contient ce qui doit réellement se
                // produire une fois la conjugaison du "within" en place.
                Controlled Rz(ctls, (theta, qubit));
                // Applique la version contrôlée (via le functor Controlled)
                // d'une rotation Rz, avec les mêmes qubits de contrôle.
                // Comme l'axe X a été basculé vers Z juste avant, cette
                // rotation Rz contrôlée équivaut ici à la Rx contrôlée
                // que l'on voulait obtenir au départ.
            }
            // À la sortie du bloc apply, Q# "défait" automatiquement ce que
            // MapPauliAxis avait fait, remettant le qubit dans son axe
            // d'origine.
        }
    }

    adjoint ... {
        // Décrit manuellement le comportement du functor Adjoint,
        // c'est-à-dire l'INVERSE de l'opération Rx.
        Rx(-theta, qubit);
        // Mathématiquement, l'inverse d'une rotation d'angle theta est
        // simplement la même rotation avec l'angle opposé : on rappelle
        // donc Rx, mais avec -theta au lieu de theta.
    }
}
```

L'intérêt pédagogique de cet exemple : dans toutes tes démos (superposition,
intrication, téléportation), tu utilises `Adjoint` et potentiellement
`Controlled` sans jamais avoir à écrire ce genre de code — c'est justement
parce que des opérations comme `Rx` ou `PrepareState` le font pour toi, une
fois pour toutes, dès qu'elles déclarent `is Adj + Ctl`.

## Notes sur la sphère de Bloch

### Pourquoi une bascule de phase Z ne fait rien de visible sur |0⟩ ou |1⟩

Ce n'est pas un bug de l'outil, c'est attendu :

- **Algébriquement** — pour un état |ψ⟩ = α|0⟩ + β|1⟩, la porte Z change le
  signe de β (l'amplitude de |1⟩) et laisse α inchangé. Sur |0⟩, on a α = 1 et
  β = 0 — inverser le signe de zéro ne change rien. Même chose sur |1⟩, où
  c'est α qui vaut 0. (Voir aussi la porte `Z` dans le Vocabulaire ci-dessus.)
- **Géométriquement** — Z correspond à une rotation de 180° autour de l'axe Z
  de la sphère de Bloch. Une rotation autour d'un axe laisse fixes tous les
  points situés exactement sur cet axe — et |0⟩, |1⟩ sont les deux pôles,
  posés pile sur cet axe.
- **À retenir pour la démo** — pour rendre l'effet de Z visible, il faut
  d'abord sortir l'état de l'axe Z (par exemple avec une porte `H`, qui amène
  sur l'équateur) — c'est là que la rotation de phase devient un vrai
  mouvement visible du vecteur.

### Le vecteur d'état est-il toujours sur la surface de la sphère ?

Pour un **état pur** (le seul cas géré par `bloch-sphere.html`), oui : le
vecteur de Bloch a toujours une longueur de 1 et pointe exactement sur la
surface de la sphère unité.

L'intérieur de la sphère existe aussi en théorie, mais il représente un
**état mixte** — un mélange statistique (pas une superposition) de plusieurs
états purs, typique d'un qubit qui a perdu de la cohérence (décohérence,
bruit, intrication partielle avec un système non observé). Plus le vecteur
raccourcit vers le centre, plus l'état est mélangé ; au centre exact (rayon
nul), l'état est complètement mixte — aucune information de phase ni de
direction ne subsiste. C'est exactement ce que vit un qubit d'une paire de
Bell pris isolément (voir « Comprendre l'état de Bell » plus haut) : son
vecteur individuel s'effondre au centre, alors même que la paire, prise dans
son ensemble, décrit un état parfaitement défini.

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
