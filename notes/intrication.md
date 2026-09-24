# Comprendre l'état de Bell (démo 2)

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
affiché correctement sur une sphère de Bloch individuelle, précisément car chaque qubit pris séparément n'a pas
d'état bien défini (son vecteur de Bloch s'effondrerait vers le centre de
la sphère).
