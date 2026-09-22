# Comprendre le langage Q#

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
  fait rien de visible... » dans
  [bloch-sphere-notes.md](bloch-sphere-notes.md)) ; `Y` combine les
  deux effets. Q# les mesures correspondantes (mesures de Pauli) sont
  d'ailleurs ce que fait l'opération `M` : mesurer un qubit avec `M`
  équivaut à `Measure([PauliZ], [qubit])`.

  Ces portes fixes ne sont d'ailleurs pas indépendantes des rotations
  paramétrées ci-dessus : `X` correspond exactement à `Rx(π)`, **à une
  phase globale près**. En effet, `Rx(θ) = cos(θ/2)·I − i·sin(θ/2)·X`, donc
  pour θ = π (cos(π/2)=0, sin(π/2)=1) : `Rx(π) = −i·X`. Le facteur `−i` est
  un facteur de phase globale (voir « Phase » plus bas) — donc physiquement
  invisible : `X` et `Rx(π)` ont exactement le même effet sur la sphère de
  Bloch et donnent les mêmes probabilités de mesure. Même relation pour les
  deux autres : `Y` = `Ry(π)` et `Z` = `Rz(π)`, toujours à une phase
  globale près. Les portes nommées de la bibliothèque standard sont donc,
  pour la plupart, des points particuliers (des angles remarquables) de ces
  familles de rotations continues — `S` = `Rz(π/2)` et `T` = `Rz(π/4)` en
  sont deux autres exemples.
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
- **`is Adj + Ctl`** — clause ajoutée après le type de retour d'une
  opération (ex. `operation Rx(...) : Unit is Adj + Ctl { ... }`) pour
  déclarer qu'elle supporte à la fois les functors `Adjoint` et
  `Controlled`. C'est cette annotation qui autorise à écrire ensuite
  `Adjoint MonOperation(...)` ou `Controlled MonOperation(...)` ailleurs
  dans le code ; le compilateur Q# génère alors automatiquement ces deux
  variantes (ou, si leur comportement n'est pas déductible mécaniquement,
  oblige à les définir soi-même via les blocs `adjoint ...` et
  `controlled (ctls, ...) ...`, comme dans l'exemple commenté ci-dessous).
  On peut aussi ne déclarer qu'un seul des deux functors (`is Adj` ou
  `is Ctl` seul) si l'autre n'est pas nécessaire.
- **Phase** — l'angle associé à un nombre complexe, généralement noté φ. Un
  nombre complexe s'écrit r·e^(iφ) : r est son module (l'amplitude "en
  grandeur"), φ sa phase. Une image simple : un nombre complexe est un point
  du plan repéré non pas par ses coordonnées (partie réelle, partie
  imaginaire) mais comme l'aiguille d'une montre — sa longueur, c'est le
  module r ; la direction vers laquelle elle pointe, c'est la phase φ. Deux
  nombres complexes peuvent avoir le même module (la même longueur
  d'aiguille) mais des phases différentes (des directions différentes) :
  par exemple 1 et i ont tous les deux un module de 1, mais des phases de
  0° et 90° respectivement, puisque i = e^(iπ/2). Deux distinctions
  comptent en informatique quantique :
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

### Exemple commenté de `Rx`

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

### Exécuter cette démo sur un vrai ordinateur quantique (Azure Quantum)

Jusqu'ici, `dotnet run` exécute `Program.qs` sur le **simulateur** fourni
par le QDK — un programme classique qui calcule exactement les amplitudes
α et β (voir le vocabulaire ci-dessus), sans aucun bruit. Faire tourner le
même code sur du **vrai matériel quantique** passe par le service Azure
Quantum, qui joue le rôle d'intermédiaire entre ce code Q# et les
fournisseurs de processeurs quantiques (IonQ, Quantinuum, Rigetti,
Pasqal...). Voici la procédure, et surtout ce qui change par rapport au
simulateur.

#### Ce qui change fondamentalement par rapport au simulateur

- **Un job, pas un `dotnet run`** — on ne "lance" plus le programme
  directement : on **soumet un job** à un fournisseur choisi, avec un
  nombre de répétitions ("shots") fixé au moment de la soumission. Le
  résultat n'arrive pas en direct dans le terminal ; il faut interroger le
  service pour savoir si le job est terminé, puis récupérer les résultats.
- **`Message()` ne s'affiche plus pendant l'exécution** — sur du matériel
  réel, il n'y a pas de flux `stdout` en direct comme sur le simulateur.
  Seuls les résultats de mesure (les valeurs de `Result`) sont renvoyés à
  la fin du job.
- **Chaque shot coûte réellement quelque chose** — contrairement au
  simulateur (gratuit et instantané), chaque exécution sur du matériel
  réel consomme du temps machine facturé (ou déduit d'un crédit gratuit).
  Relancer 1000 mesures comme dans `DemoSuperposition` ou `DemoBellState`
  a donc un coût réel, à multiplier par le nombre de shots demandés.
- **Le bruit change tout** — un vrai qubit subit de la décohérence, des
  erreurs de porte et des erreurs de mesure. La démo 3 (téléportation) ne
  donnera **plus 100 % de ✅** comme sur le simulateur : un certain taux
  d'échec (souvent quelques %, très variable selon le fournisseur et le
  jour) devient normal et attendu — voir « État pur / état mixte »
  ci-dessus pour l'intuition physique de ce qu'introduit ce bruit.
- **Le contrôle classique conditionné par une mesure n'est pas garanti
  partout** — la démo de téléportation dépend de manière essentielle des
  deux `if` conditionnés par une mesure en plein milieu du circuit (voir
  [teleportation.md](teleportation.md)). Cette capacité, appelée
  **mesure et rétroaction en temps réel** ("mid-circuit measurement" +
  "classical feedforward"), n'est pas supportée par tous les processeurs
  quantiques ; il faut choisir une cible qui la propose explicitement
  (au moment de l'écriture de ce document, les machines Quantinuum
  System Model H1/H2 et certaines cibles IonQ le permettent — à vérifier
  cible par cible, cette liste évolue vite).

#### Prérequis

1. Un abonnement Azure (un compte gratuit suffit pour commencer).
2. Un **espace de travail Azure Quantum** ("workspace"), créé depuis le
   [portail Azure](https://portal.azure.com) : *Créer une ressource →
   Azure Quantum → Workspace*. À la création, on choisit un ou plusieurs
   **fournisseurs** (providers) à activer — chacun propose ses propres
   cibles matérielles et/ou simulateurs cloud, avec sa propre grille
   tarifaire (souvent un crédit gratuit est offert aux nouveaux
   workspaces).
3. L'extension Azure Quantum de la CLI Azure :
   ```
   az extension add --name quantum
   az login
   ```
4. Le SDK Python `azure-quantum` (et `qsharp` pour rester en Q#) si l'on
   préfère soumettre les jobs depuis un script plutôt qu'en ligne de
   commande :
   ```
   pip install azure-quantum qsharp
   ```

#### Étapes

1. **Associer la CLI au workspace créé :**
   ```
   az quantum workspace set \
     --resource-group <mon-groupe-de-ressources> \
     --workspace <mon-workspace> \
     --location <ma-region>
   ```
2. **Lister les cibles disponibles**, pour choisir un fournisseur qui
   supporte le type de circuit de la démo choisie :
   ```
   az quantum target list -o table
   ```
   Pour les démos 1 et 2 (`DemoSuperposition`, `DemoBellState`), qui ne
   demandent aucune correction conditionnée par une mesure en cours de
   circuit, la plupart des cibles matérielles conviennent. Pour la démo 3
   (téléportation), s'assurer que la cible choisie annonce le support du
   contrôle classique en temps réel (voir plus haut).
3. **Adapter le point d'entrée avant de soumettre.** Sur du matériel réel,
   un job correspond à **une seule opération**, exécutée `N` fois (le
   nombre de shots est un paramètre du job, pas une boucle `for` dans le
   code Q#). Il faut donc soumettre séparément, par exemple,
   `DemoBellState` ou `TeleportRandomState` — plutôt que `RunDemo()`, qui
   enchaîne les trois démos et gère elle-même sa propre boucle de
   1000 essais côté simulateur (inutile et coûteux à reproduire telle
   quelle sur du matériel facturé au shot).
4. **Soumettre le job**, en ligne de commande :
   ```
   az quantum job submit \
     --target-id <id-de-la-cible> \
     --project . \
     --job-name teleportation-demo \
     --shots 100
   ```
   ou depuis Python avec le SDK `qsharp` :
   ```python
   import qsharp
   import qsharp.azure

   qsharp.azure.connect(
       resourceId="<resource-id-du-workspace>",
       location="<ma-region>",
   )
   qsharp.azure.target("<id-de-la-cible>")
   result = qsharp.azure.execute(TeleportRandomState, shots=100)
   ```
5. **Suivre l'avancement et récupérer le résultat** — un job réel peut
   rester en file d'attente (statut `Waiting`) le temps qu'un créneau se
   libère sur le processeur physique, avant de passer à `Executing` puis
   `Succeeded` :
   ```
   az quantum job show --job-id <id-du-job>
   az quantum job output --job-id <id-du-job>
   ```
6. **Interpréter les résultats** — contrairement au simulateur qui
   affichait un `Message` de succès/échec par shot, le résultat renvoyé
   est un histogramme des valeurs de `Result` obtenues sur l'ensemble des
   shots. Pour la démo téléportation, il faut alors compter soi-même la
   proportion de `Zero` (téléportation réussie) parmi les shots — c'est
   cette proportion, inférieure à 100 %, qui donne une mesure concrète du
   niveau de bruit du processeur utilisé ce jour-là.

#### Pour aller plus loin

- [Documentation Azure Quantum (doc Microsoft)](https://learn.microsoft.com/fr-fr/azure/quantum/) —
  vue d'ensemble du service, création de workspace, tarification.
- [Comprendre les cibles et fournisseurs Azure Quantum](https://learn.microsoft.com/fr-fr/azure/quantum/qc-target-list) —
  liste et caractéristiques des processeurs quantiques disponibles.
