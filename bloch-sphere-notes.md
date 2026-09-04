# Notes sur la sphère de Bloch

### Pourquoi une bascule de phase Z ne fait rien de visible sur |0⟩ ou |1⟩

- **Algébriquement** — pour un état |ψ⟩ = α|0⟩ + β|1⟩, la porte Z change le
  signe de β (l'amplitude de |1⟩) et laisse α inchangé. Sur |0⟩, on a α = 1 et
  β = 0 — inverser le signe de zéro ne change rien. Même chose sur |1⟩, où
  c'est α qui vaut 0. (Voir aussi la porte `Z` dans le Vocabulaire de
  [qsharp-langage.md](qsharp-langage.md).)
- **Géométriquement** — Z correspond à une rotation de 180° autour de l'axe Z
  de la sphère de Bloch. Une rotation autour d'un axe laisse fixes tous les
  points situés exactement sur cet axe — et |0⟩, |1⟩ sont les deux pôles,
  posés pile sur cet axe (pour rendre l'effet de Z visible, il faut
  d'abord sortir l'état de l'axe Z avec une porte `H`, par exemple, qui amène
  sur l'équateur).

### Le vecteur d'état est-il toujours sur la surface de la sphère ?

Pour un **état pur** (le seul cas géré par `bloch-sphere.html`), le
vecteur de Bloch a toujours une longueur de 1 et pointe exactement sur la
surface de la sphère unité.

L'intérieur de la sphère existe aussi en théorie, mais il représente un
**état mixte** — un mélange statistique (pas une superposition) de plusieurs
états purs, typique d'un qubit qui a perdu de la cohérence (décohérence,
bruit, intrication partielle avec un système non observé). Plus le vecteur
raccourcit vers le centre, plus l'état est mélangé ; au centre exact (rayon
nul), l'état est complètement mixte — aucune information de phase ni de
direction ne subsiste. C'est exactement ce que vit un qubit d'une paire de
Bell pris isolément (voir « Comprendre l'état de Bell » dans le
[README](README.md)) : son vecteur individuel s'effondre au centre, alors
même que la paire, prise dans son ensemble, décrit un état parfaitement
défini.
