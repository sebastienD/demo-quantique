# Téléportation quantique — comment fonctionne la démo 3

Ce document détaille le fonctionnement de `TeleportRandomState()` dans
[src/Program.qs](src/Program.qs).

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
[README.md](README.md#comprendre-létat-de-bell-démo-2)). Alice combine son
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
`here`, `there`) sont dans un état intriqué à trois où, selon le résultat
des deux mesures qui suivent, la moitié de Bob (`there`) se retrouve dans
l'état secret d'origine **à une rotation Pauli près** (identité, X, Z ou
les deux). C'est tout l'intérêt du calcul : ces quatre cas sont
équiprobables et parfaitement identifiables par les deux bits classiques
qu'Alice va mesurer.

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
