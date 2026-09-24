# Téléportation quantique — comment fonctionne la démo 3

Ce document détaille le fonctionnement de `TeleportRandomState()` dans
[src/Program.qs](../src/Program.qs).

## Vue d'ensemble : qui fait quoi

Le code utilise 3 qubits, tous alloués dans le même programme (c'est une
simulation), mais qui représentent conceptuellement **deux personnes
séparées** :

```qsharp
use (msg, here, there) = (Qubit(), Qubit(), Qubit());
```

- **`msg`** — le qubit qui porte l'état secret à téléporter. Il appartient
  à **Alice**.
- **`here`** — la moitié d'Alice de la paire intriquée partagée avec Bob.
  Elle lui appartient aussi.
- **`there`** — la moitié de Bob de cette même paire intriquée. C'est le
  qubit qui, à la fin, doit se retrouver dans l'état qu'avait `msg` au
  départ — sans que `msg` n'ait jamais quitté Alice, et sans qu'aucun
  qubit physique n'ait voyagé.

Le principe de la téléportation quantique : Alice et Bob partagent au
préalable une paire de qubits intriqués (un **état de Bell**, voir
[intrication.md](intrication.md)). Alice combine son
état secret avec sa moitié de la paire, effectue deux mesures, puis
envoie le résultat de ces deux mesures à Bob **par un canal classique**
(un téléphone, un e-mail... deux bits). Bob applique une correction
sur sa moitié en fonction de ces deux bits, et se retrouve avec l'état
secret d'Alice — qu'aucun des deux n'a jamais eu besoin de connaître.

## Étape par étape

### 1. Préparer l'état secret

```qsharp
operation PrepareState(q : Qubit) : Unit is Adj {
    Rx(1.234, q);
    Ry(0.567, q);
}
```

```qsharp
PrepareState(msg);
```

`PrepareState` place `msg` dans un état arbitraire, ni |0⟩ ni |1⟩ ni même
une superposition « ronde » comme |+⟩ — deux angles un peu quelconques
(1.234 et 0.567 radians) pour que la démo soit convaincante : on ne
téléporte pas un simple bit déguisé, mais un point précis sur la sphère
de Bloch, avec une phase relative bien définie. Voir
[qsharp-notes.md](qsharp-notes.md) pour le détail de `Rx`/`Ry` et de la
notation |ψ⟩ = α|0⟩ + β|1⟩.

Notez la signature : `is Adj`. Cette annotation déclare que `PrepareState`
supporte le functor `Adjoint` — Q# génère automatiquement son inverse.
On y revient au point 6.

### 2. Créer la paire intriquée partagée (Alice ↔ Bob)

```qsharp
H(here);
CNOT(here, there);
```

Exactement la recette de `DemoBellState` (démo 2) : `H` puis `CNOT` créent
l'état de Bell |Φ⁺⟩ = (|00⟩ + |11⟩)/√2 entre `here` (Alice) et `there`
(Bob). C'est la ressource partagée qui va permettre le « transport » de
l'état — elle doit être établie **avant** qu'Alice ne touche à son message
secret.

### 3. Alice intrique son message avec sa moitié de la paire

```qsharp
CNOT(msg, here);
H(msg);
```

Alice fait interagir son état secret (`msg`) avec sa moitié de la paire
de Bell (`here`). Après ce `CNOT` puis ce `H`, les 3 qubits (`msg`,
`here`, `there`) sont dans un état intriqué à trois — et il faut être
précis sur ce que ça veut dire, y compris sur la base dans laquelle cet
état s'exprime naturellement.

**Avant toute mesure**, les trois qubits sont intriqués : leur sort est
lié. Le système est en équilibre entre 4 possibilités à la fois — comme
si `msg` et `here` valaient simultanément 00, 01, 10 et 11, chaque
possibilité étant aussi probable que les autres. Et ce n'est pas un
hasard : chacune de ces 4 possibilités correspond très exactement à ce
qu'on aurait obtenu en comparant directement `msg` et `here` à l'aune des
4 états de Bell — `CNOT` et `H` ont simplement « traduit » cette
information dans un langage que la mesure classique (0 ou 1) sait lire.

Pour ceux qui veulent voir la formule exacte, l'état est :

```
(1/2) [ |00⟩(msg,here) ⊗ (α|0⟩+β|1⟩)there
      + |01⟩(msg,here) ⊗ (β|0⟩+α|1⟩)there
      + |10⟩(msg,here) ⊗ (α|0⟩−β|1⟩)there
      + |11⟩(msg,here) ⊗ (−β|0⟩+α|1⟩)there ]
```

La formulation la plus juste : c'est le système entier à 3 qubits (msg,
here et there ensemble) qui est intriqué et en superposition pure des 4
branches.

Les 4 branches coexistent réellement, ce n'est pas une information cachée
qu'on ignorerait simplement. **Chaque branche, prise individuellement,
correspond à l'état secret d'origine tourné par un Pauli précis**
(identité, X, Z, ou les deux) — c'est justement ce que détaille le
tableau du point 5. Ces 4 combinaisons calculatoires correspondent très
exactement à l'information qu'aurait donnée une vraie mesure de Bell
directe sur `(msg, here)` (voir l'encart ci-dessous) — c'est un raccourci
de langage courant de les appeler informellement « les 4 cas de Bell »,
mais l'état lui-même, une fois l'étape 3 passée, vit dans la base
calculatoire, pas dans la base de Bell.

Ce n'est donc pas qu'une rotation Pauli précise est déjà « décidée »
quelque part pour `there`, en attente d'être découverte : c'est la mesure
qui suit (étape 4) qui va faire s'effondrer le système sur une seule de
ces 4 branches, et c'est seulement à ce moment-là que la relation entre
`there` et l'état secret devient déterminée. C'est tout l'intérêt du
calcul : ces quatre cas sont équiprobables et parfaitement identifiables
par les deux bits classiques qu'Alice va mesurer.

**Pourquoi `CNOT` puis `H`, et pas `H` puis `CNOT` comme à l'étape 2 ?**
Cette inversion d'ordre n'est pas un détail — elle a un sens précis, et ce
n'est volontairement pas la même opération qu'à l'étape 2.

- **À l'étape 2**, on *crée* une intrication à partir de rien : `here` part
  de |0⟩, `H` puis `CNOT` construisent la paire de Bell. C'est la recette
  « aller ».
- **Ici, à l'étape 3**, `msg` porte déjà un état arbitraire et `here` est
  déjà intriqué avec `there` — il n'y a rien à « créer ». Le but d'Alice
  est de **mesurer `msg` et `here` dans la base de Bell** (savoir dans
  lequel des 4 états de Bell se trouve la paire), mais `M()` ne sait
  mesurer que dans la base calculatoire (`Zero`/`One`), jamais directement
  dans une autre base.

  **Attention à une confusion fréquente : ce n'est pas parce que `here` est
  en superposition qu'il faut appliquer cette inversion.** Mesurer un qubit
  en superposition ne pose aucun problème en soi — c'est exactement ce que
  fait la démo 1 (`H(q); let resultat = M(q);`, sans rien inverser avant).
  Si la superposition à elle seule obligeait à « défaire » quelque chose
  avant de mesurer, cette démo ne fonctionnerait pas telle quelle. La
  vraie raison est ailleurs : ce n'est pas *que* `here` soit en
  superposition qui compte, c'est *quelle information précise* on veut
  extraire de la mesure. Alice a besoin que le résultat lui dise
  spécifiquement dans lequel des 4 états de Bell se trouve la paire — une
  mesure directe en base calculatoire, sans rien faire avant, donnerait
  bien deux bits, mais des bits qui ne renseigneraient sur rien d'utile
  pour la correction de Bob.

  L'astuce standard pour mesurer dans une base différente : appliquer
  l'**inverse** de la transformation qui définit cette base, puis mesurer
  normalement — exactement le même principe que `Adjoint PrepareState` à
  l'étape 6, mais écrit ici, porte par porte, plutôt qu'avec le functor
  `Adjoint`. Pour inverser une suite d'opérations, il faut (1) inverser
  chacune d'elles et (2) inverser leur ordre. Comme `H` et `CNOT` sont
  toutes les deux leur propre inverse (portes hermitiennes/unitaires — voir
  le functor `Adjoint` dans [qsharp-notes.md](qsharp-notes.md)), l'inverse
  de « `H` puis `CNOT` » (la recette de l'étape 2) est très exactement
  « `CNOT` puis `H` » : les mêmes portes, dans l'ordre inverse. C'est
  précisément le code ci-dessus. Résultat : mesurer `msg` et `here` en
  base calculatoire *après* ce `CNOT`/`H` équivaut exactement à les avoir
  mesurés en base de Bell *avant*.

  **Attention à ne pas croire que `CNOT`/`H` défait une relation de Bell
  préexistante entre `msg` et `here` — il n'y en a pas.** Avant l'étape 3,
  `msg` n'est **pas du tout intriqué** avec `here`/`there` : l'état global
  est un simple produit, `msg` porte α|0⟩+β|1⟩ tout seul dans son coin,
  totalement indépendant de la paire de Bell `(here, there)` déjà formée à
  l'étape 2. C'est au contraire **`CNOT`/`H` qui crée cette intrication**
  — pas qui en défait une.

  Alors pourquoi parler de « base de Bell » ici ? Parce que `CNOT` puis
  `H`, suivi d'une mesure en base calculatoire, est **la recette standard
  pour implémenter une mesure en base de Bell** — une technique générale
  en info quantique (*pour mesurer deux qubits dans une base donnée, on
  applique la transformation inverse qui définit cette base, puis on
  mesure normalement*) qui fonctionne sur **n'importe quels** deux qubits,
  qu'ils soient déjà intriqués entre eux ou pas. `msg` et `here` ne le sont
  pas au départ (ils sont même totalement indépendants) : c'est justement
  `CNOT`/`H` qui, en une seule opération, **les intrique et configure
  cette intrication** de sorte qu'une simple mesure `M()` en base
  calculatoire donne exactement l'information qu'aurait donnée une mesure
  de Bell directe. Autrement dit, `CNOT`/`H` fait deux choses à la fois :
  il crée la première intrication de `msg` avec le reste du système, et il
  la construit de façon à ce qu'elle se lise comme de l'information de
  Bell une fois mesurée.

  **Pour rendre l'équivalence avec `Adjoint` bien concrète** : si on avait
  défini une petite opération séparée pour la recette de l'étape 2, comme

  ```qsharp
  operation FaireIntriquer(a : Qubit, b : Qubit) : Unit is Adj {
      H(a);
      CNOT(a, b);
  }
  ```

  alors écrire `Adjoint FaireIntriquer(msg, here);` aurait produit
  **exactement** le même résultat que `CNOT(msg, here); H(msg);` — c'est
  la même chose, juste exprimée différemment. À l'étape 6, le code utilise
  le mot-clé `Adjoint` sur une opération nommée (`PrepareState`) parce
  qu'elle existe déjà et est déclarée `is Adj` ; ici, à l'étape 3, il n'y a
  pas d'opération nommée équivalente pour « créer une paire de Bell », donc
  le code écrit directement, à la main, le résultat de ce même calcul
  d'inversion, porte par porte.

### 4. Alice mesure ses deux qubits

```qsharp
let m1 = M(msg);
let m2 = M(here);
```

Ce sont ces deux mesures — et seulement elles — qu'Alice enverrait
réellement à Bob par un canal classique dans un scénario physique réel
(deux bits, rien de plus). Dans la démo, tout tourne dans le même
programme donc « l'envoi » est implicite, mais conceptuellement c'est
l'unique information qui doit voyager entre les deux parties.

Notez qu'à cette étape, `msg` et `here` sont **mesurés** : leur état
quantique s'est effondré sur `Zero` ou `One`. L'état secret original a
disparu du côté d'Alice — il n'existe plus que sous forme d'information
classique (`m1`, `m2`) plus l'état encore intriqué de `there`. C'est
cohérent avec le théorème de non-clonage : l'état n'est pas copié, il est
détruit chez Alice au moment même où il apparaît chez Bob.

#### Pourquoi les deux mesures, et pas une seule ?

`m1` à lui seul ne suffit pas à savoir dans laquelle des 4 branches
(4 états de Bell) on se trouve — il faut **les deux**, `m1` **et** `m2`.

Il y a 4 branches possibles (voir le point 3), donc il faut pouvoir
distinguer parmi **4** possibilités. Un seul bit (`m1`, valant `Zero` ou
`One`) ne peut distinguer qu'entre **2** possibilités — il ne peut donc, à
lui seul, qu'éliminer la moitié des cas, jamais identifier une branche
précise. Il faut fondamentalement 2 bits pour indexer 4 cas — c'est
exactement ce que fait le tableau du point 5, qui a bien deux colonnes
d'entrée (`m1` et `m2`).

Concrètement, si on ne mesurait que `msg` (obtenant par exemple
`m1 = Zero`), l'état restant sur la paire (`here`, `there`) ne serait
**pas encore** un état à une seule rotation Pauli bien définie : ce serait
encore un état intriqué à 2 qubits entre `here` et `there` (une
superposition des 2 branches restantes, `(Zero,Zero)` et `(Zero,One)`).
`there` n'aurait donc pas encore d'état individuel bien défini à ce
stade — impossible de savoir s'il faut appliquer `X` ou non. C'est
seulement en mesurant *aussi* `here` (obtenant `m2`) que cet
entrelacement restant s'effondre à son tour, et que `there` se retrouve
enfin dans un état pur unique, précisément l'un des 4 du tableau.

**Attention à ne pas mal interpréter ce moment intermédiaire.** À cet
instant (`m1` connu, `here` pas encore mesuré), ce n'est **pas** « `here`
classique, `there` encore en superposition ». `here` n'a pas encore été
mesuré à ce stade — rien ne l'a effondré, il fait toujours pleinement
partie du système quantique. Ce qui est vrai est plus subtil : `here` et
`there` sont **intriqués l'un avec l'autre**, et forment ensemble une
superposition des 2 branches restantes — mais **aucun des deux pris
individuellement n'a d'état bien défini**. C'est exactement le même
phénomène que celui décrit pour la paire de Bell dans
[intrication.md](intrication.md) : un qubit intriqué, considéré isolément
en « oubliant » son partenaire, n'a pas de vecteur de Bloch bien défini
(état mixte), même si le système conjoint, lui, est parfaitement défini.
Concrètement, si `m1 = Zero`, l'état conjoint restant sur (`here`,
`there`) est (à une normalisation près) :

```
α|00⟩ + β|01⟩ + β|10⟩ + α|11⟩
```

— un état intriqué à 2 qubits, pas un produit de deux états individuels.
C'est seulement en mesurant aussi `here` que cette intrication se résout,
et que `there` se retrouve enfin avec un état individuel bien défini.

### 5. La correction de Bob — les deux `if`

```qsharp
if m2 == One { X(there); }
if m1 == One { Z(there); }
```

C'est le cœur du protocole, et la partie la plus dense en apparence. Voici
pourquoi ces deux corrections sont exactement ça, et pourquoi elles sont
**indépendantes l'une de l'autre** (chacune ne dépend que d'un seul des
deux bits).

En développant l'algèbre de l'état à 3 qubits après les étapes 2 et 3 (H
sur `here`, CNOT `here→there`, CNOT `msg→here`, H sur `msg`), on obtient
une superposition des 4 combinaisons possibles de mesure (m1, m2), et pour
chacune, l'état restant sur `there` est **exactement** l'état secret
original transformé par une porte de Pauli bien précise :

| `m1` (msg) | `m2` (here) | État obtenu sur `there`     | Correction nécessaire |
|:----------:|:-----------:|:-----------------------------|:-----------------------|
| `Zero`     | `Zero`      | α\|0⟩ + β\|1⟩ (déjà correct) | aucune                 |
| `Zero`     | `One`       | α\|1⟩ + β\|0⟩ (bits échangés)| `X`                    |
| `One`      | `Zero`      | α\|0⟩ − β\|1⟩ (signe inversé)| `Z`                    |
| `One`      | `One`       | −(α\|1⟩ − β\|0⟩)             | `X` puis `Z`           |

(la dernière ligne comporte un signe global −1, mais une phase globale est
invisible — voir la section « Phase » de
[qsharp-notes.md](qsharp-notes.md) — donc elle n'a aucune conséquence
physique.)

En regardant cette table colonne par colonne :

- **`X` est nécessaire si et seulement si `m2 == One`**, quel que soit
  `m1`. D'où `if m2 == One { X(there); }`, sans jamais regarder `m1`.
- **`Z` est nécessaire si et seulement si `m1 == One`**, quel que soit
  `m2`. D'où `if m1 == One { Z(there); }`, sans jamais regarder `m2`.

C'est la propriété remarquable du protocole : bien que les deux mesures
soient corrélées à l'état secret dans son ensemble, chacune détermine
**une seule et unique porte de correction**, indépendamment de l'autre.
Ça permet d'écrire la correction comme deux `if` complètement séparés,
sans `else if` ni cas combinés à gérer explicitement — le quatrième cas
du tableau (les deux corrections) sort naturellement de l'exécution des
deux `if` l'un après l'autre.

Physiquement, `X` corrige une éventuelle inversion bit-flip (les
amplitudes de |0⟩ et |1⟩ échangées) et `Z` corrige une éventuelle
inversion de phase relative (voir « Pourquoi une bascule de phase Z ne
fait rien de visible... » dans
[bloch-sphere-notes.md](bloch-sphere-notes.md) pour l'effet géométrique de
`Z` sur la sphère de Bloch) — les deux seules façons dont un qubit à un
seul bit d'information classique par mesure peut avoir « dévié » de
l'état visé.

#### Vérification : la correction retombe bien exactement sur α|0⟩ + β|1⟩

Le but de la correction est de ramener `there` très précisément dans
l'état α|0⟩ + β|1⟩ — le même état que celui préparé sur `msg` par
`PrepareState` à l'étape 1. On peut le vérifier ligne par ligne sur le
tableau ci-dessus :

- **(Zero, Zero)** : déjà α|0⟩ + β|1⟩ — rien à faire.
- **(Zero, One)** : `there` vaut α|1⟩ + β|0⟩. `X` échange les coefficients
  de |0⟩ et |1⟩ (puisque X|0⟩=|1⟩ et X|1⟩=|0⟩) → on retombe exactement sur
  α|0⟩ + β|1⟩.
- **(One, Zero)** : `there` vaut α|0⟩ − β|1⟩. `Z` inverse juste le signe du
  coefficient de |1⟩ → −β devient β, on retombe sur α|0⟩ + β|1⟩.
- **(One, One)** : `there` vaut −(α|1⟩ − β|0⟩). `X` puis `Z` ramènent aussi
  sur α|0⟩ + β|1⟩, à un facteur global −1 près (invisible physiquement,
  voir la remarque sur la phase globale ci-dessus).

Dans les 4 cas, après correction, `there` est **exactement** l'état secret
d'origine — c'est précisément ce que `Adjoint PrepareState(there)` vient
vérifier à l'étape 6 : si on a bien reconstitué α|0⟩ + β|1⟩, défaire la
préparation doit ramener sur |0⟩ à coup sûr.

### 6. Vérification : pourquoi `Adjoint PrepareState` ?

```qsharp
Adjoint PrepareState(there);
let verif = M(there);

if verif == Zero {
    Message("✅ État correctement téléporté");
} else {
    Message("❌ Échec inattendu (ne devrait jamais arriver)");
}
```

**C'est la partie qui prête le plus à confusion, donc à bien distinguer du
protocole lui-même : cette étape ne fait pas partie de la téléportation.
Elle sert uniquement à *vérifier*, dans la démo, que la téléportation a
fonctionné.**

Le problème que cette étape résout : après la correction de Bob (étape 5),
`there` est censé être exactement dans l'état préparé par
`PrepareState(msg)` au tout début. Mais comment le vérifier dans le code
sans « tricher » en lisant directement les amplitudes α et β (ce qui
n'aurait physiquement aucun sens — un programme quantique réel n'a jamais
accès aux amplitudes d'un qubit, seulement au résultat de mesures) ?

L'astuce : puisque `PrepareState` est déclarée `is Adj`, Q# a généré
automatiquement son inverse exact `Adjoint PrepareState` (voir la section
`functor` de [qsharp-notes.md](qsharp-notes.md)). Si `PrepareState`
correspond à l'application d'une transformation unitaire U sur |0⟩ pour
obtenir |ψ⟩ = U|0⟩, alors `Adjoint PrepareState` applique U†, l'inverse de
U. Mathématiquement :

```
U† U |0⟩ = |0⟩
```

Donc : si `there` est effectivement dans l'état U|0⟩ = |ψ⟩ (la
téléportation a réussi), lui appliquer U† doit le ramener **exactement**
sur |0⟩. En mesurant ensuite `there` avec `M`, on doit alors lire `Zero`
à coup sûr. Si la téléportation avait échoué (par exemple une des deux
corrections `X`/`Z` avait été oubliée ou appliquée à tort), `there`
serait dans un état différent de |ψ⟩, et lui appliquer U† ne le ramènerait
généralement pas sur |0⟩ — la mesure donnerait alors parfois `One`,
révélant l'échec.

C'est une technique de test classique en programmation quantique : pour
vérifier qu'un qubit est dans un état donné sans pouvoir « lire » cet état
directement, on applique l'inverse de l'opération qui l'a produit, puis on
mesure — on doit retomber sur |0⟩.

#### Pourquoi ne pas simplement mesurer `there` et comparer avec `here` ?

Une idée naturelle serait de vérifier la téléportation « à la manière de
la démo 2 » : mesurer `there`, et comparer son résultat à celui de
`here` — un peu comme on compte les mesures identiques dans
`DemoBellState`. Ça ne fonctionne pas ici, pour trois raisons qui
s'enchaînent :

1. **`here` n'est déjà plus un état quantique.** `m2 = M(here)` l'a
   mesuré à l'étape 4 : son état s'est effondré sur `Zero` ou `One` (voir
   la note du point 4 plus haut). Il ne reste donc rien à comparer côté
   `here` — ce n'est plus qu'un bit classique, pas un vecteur d'état.
2. **Même en imaginant comparer autrement, une seule mesure de `there`
   ne donne qu'un seul bit d'information** (`Zero` ou `One`), alors que
   l'état secret à vérifier est un point *continu* sur la sphère de Bloch
   (deux nombres réels, θ et φ — voir [qsharp-notes.md](qsharp-notes.md)).
   Un bit unique ne peut renseigner, au mieux, que sur la composante z du
   vecteur de Bloch — il ne dit strictement rien sur la phase relative φ,
   qui fait pourtant partie intégrante de l'état à vérifier.
3. **On ne peut pas non plus répéter la mesure pour faire des
   statistiques.** Caractériser complètement un état par la mesure (la
   « tomographie ») demande de mesurer plusieurs copies identiques du même
   état, dans plusieurs bases différentes. Le théorème de non-clonage
   l'interdit : impossible de dupliquer `there` pour en avoir plusieurs
   exemplaires à mesurer sous des angles différents. Une seule mesure
   effondre l'information une fois pour toutes, sans deuxième chance.

C'est exactement pour contourner ces trois obstacles que la démo n'essaie
jamais de « lire » l'état de `there` directement : `Adjoint PrepareState`
transforme la question impossible à trancher avec une seule mesure
(« `there` est-il exactement dans l'état U|0⟩, phase comprise ? ») en une
question binaire simple (« `there` retombe-t-il exactement sur |0⟩ ? »),
tranchable en une seule mesure — au prix de connaître `U`, un luxe que le
vrai Bob n'a pas dans un protocole physique réel, mais parfaitement
légitime ici puisque c'est nous, auteurs de la démo, qui vérifions notre
propre code.

### 7. Nettoyage

```qsharp
ResetAll([msg, here, there]);
```

Comme rappelé dans [qsharp-notes.md](qsharp-notes.md) (mot-clé `Reset`),
tout qubit alloué avec `use` doit être remis à |0⟩ avant d'être libéré.
`ResetAll` le fait pour les trois qubits en une seule fois. Notez que ce
`Reset` fonctionne même quand `there` n'est pas exactement à |0⟩ (cas
d'échec théorique) : `Reset` force la remise à zéro quel que soit l'état
de départ, contrairement à `Adjoint PrepareState` qui ne le fait que *si*
l'état était bien celui attendu.

## Résumé

- Les 3 qubits (`msg`, `here`, `there`) jouent respectivement : l'état
  secret d'Alice, la moitié d'Alice de la paire intriquée, la moitié de
  Bob de cette même paire.
- Le protocole en lui-même (étapes 2 à 5) ne demande **jamais** à Bob de
  connaître comment l'état secret a été fabriqué — seuls deux bits
  classiques (`m1`, `m2`) transitent, et ils suffisent à déterminer une
  correction Pauli (`X` et/ou `Z`) totalement indépendante l'un de
  l'autre.
- `Adjoint PrepareState(there)` (étape 6) n'est **pas** une étape du
  protocole de téléportation : c'est un outil de vérification propre à la
  démo, qui exploite le functor `Adjoint` généré automatiquement par Q#
  pour confirmer, sans jamais lire directement les amplitudes, que
  `there` contient bien l'état d'origine.
