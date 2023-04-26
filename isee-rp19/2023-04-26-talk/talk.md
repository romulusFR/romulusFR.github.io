# Retours sur les RPs 2009-2014-2019 ISEE

[Rapport (2022-12-27)](https://romulusfr.github.io/isee-rp19/etude_nem_2009_2014_2019.html)

[Slides (2023-04-26)](https://romulusfr.github.io/isee-rp19/2023-04-26-talk/talk.html)

## Introduction

### Rappel du contexte

**But** exploiter les données 2019, compléter les analyses 2014 et 2009 sur l'indicateur de _Niveau d'Équipement des Ménages_ (NEM).

### Retour sur la réunion de travail du 2022-11-16

- Données ISEE 2019, accès aux RPs via OpenData​, SD-Box​, _in situ_ et le Teams `Data​`
- Retour sur les sessions de travail à l'ISEE du 2022-11-07 et 2022-11-15
- Questions discutées le 2022-11-28 :
  - **Qui** souhaite faire **quoi** sur le RP 2019 ?​
  - Avec quelles **autres sources** et quels **outils** ?​

### Priorités identifiées le 2022-11-28

- 😐 calcul _à l'identique_ du NEM sur le RP 2019
  - variables/modalités différentes selon RP (e.g., tel. mobile.)
  - reprise de certain codages (e.g., voiture)
  - **calculs homogènes** sur 2009, 2014 et 2019
- 😀 extractions du NEM 2019
  - [par communes](https://romulusfr.github.io/isee-rp19/output/nem_communes.csv)
  - [par IRIS](https://romulusfr.github.io/isee-rp19/output/nem_iris.csv>)
  - [poids du NEM](https://romulusfr.github.io/isee-rp19/output/nem_weights.csv)
- 😢 comparer le NEM à l'indicateur NdV de l'ISEE
  - pas eu d'accès au NdV de l'ISEE

---

- 🤔 bâtir un autre indicateur
  - non réalisé
- 😀 analyse des variances du NEM / inégalités
  - analyse de la variance province/commune/VKPP
  - évolutions spatiales / analyses diachronique
- 😵‍💫 méthodes de _matching_ sur le RP 2019
  - méthodes non maîtrisées
  - analyse des _degrés de libertés_ de modèles linéaires
- 🤠 (non prévu) contributions au NEM
  - comprendre les poids des équipements
  - analyser équipements et les autres variables

### Données utilisées

- **RP** = recensement de la population 2009, 2014 et 2019 (**BL** = base logements + **BI** = base individuelle)
- définition géographiques (_shapefile_)
  - IRIS dits _UNC_
  - communes et provinces
- _durées de trajet_ mines/IRIS (a.k.a., _matrice de desserte_)

---

- ⚠️ résidences **principales**
- ⚠️ ménages **hors** du Grand-Nouméa (GN)
  - effet limité sur les évolutions du NEM
  - améliore la qualité des regressions.
- volumes
  - 2009 : 22090 ménages / 70 variables,
  - 2014 : 25477 ménages / 73 variables,
  - 2019 : 27613 ménages / 76 variables,
    - 111467 individus BI

### Variables étudiées

#### Variables d'équipement ménages

`NEM` et `NEM100` construits à partir de `ELEC`, `EAU`, `BATI/TYPC14`, `BAIN`, `WC`, `MAL` (ajouté), `REFRI`, `CLIM`, `CHOS`, `TFIXE`, `INTER`, `VOIT` (re-codé), `BATO` (re-codé), `DEROU` (re-codé), ~~`TMOB`~~, ~~`ORDI`~~.

---

#### Variables d'analyse

- code IRIS (variable `IRISUNC`),
- commune (variable `NC`)
- province (variable `PROV`)
- CSP (8 postes) (variable `CS8M`)
- diplôme (variable `DIPLM/DIPLM14`)
- age révolu (variable `AGERM`)
- ethnie (variable `RETH`)
- employeur nickel (variable `MINE`)
  - industries extractives sauf celles hors secteur nickel (e.g., carrières).
- durée de trajet à la mine (matrice de desserte, variable `DUREE`)

## Résultats

### Contributions des équipements au NEM

- Sensibilités des poids du `NEM` selon codage
  - peu d'impact _in fine_ sur les variations base 100 (`NEM100`)
- Les _groupements_ d'équipements
  - `CLIM`, `TFIXE`, `INTER` et `CHOS`
  - `REFRI`, `ELEC`, `BAIN`, `WC`, `EAU`, `BATI` et `MAL`
  - `BATO`, `DEROU` et `VOIT` (fortes variations)

---

#### Exemples

![AFC équipements/CSP](./img/afc_equip_csp.png)

---

![AFC équipements/ethnie](./img/afc_equip_ethnie.png)

---

#### Conclusions sur la constitution du NEM

- la méthode _top 5 des axes de l'ACP_ semble avoir un effet limité
  - le re-codage des variables a plus d'impact
- voir une analyse différenciée par groupe d'équipements
- les ordres totaux sur les _x_ confortent le choix de la méthode

### Distributions et évolutions du NEM

On veut apprécier le `NEM100` spatialement et temporellement.

---

#### Exemples d'évolutions du NEM

![Evolutions du NEM par province](img/violin_nem_province.png)

---

![NEM par IRIS de VKPP en 2019](img/violin_nem_vkpp.png)

---

#### Exemples de distributions du NEM

![Evolution écart-type 2009-2019](img/carte_nc_nem_09-19.png)

---

![Evolution écart-type 2009-2014](img/carte_nc_nem_09-14.png)

---

![Evolution écart-type 2014-2019](img/carte_nc_nem_14-19.png)

---

#### Conclusions sur les distributions et les évolutions du NEM

- **diminution substantielle** de l'écart-type entre 2009 et 2019
  - réductions **importantes** entre 2009 et 2014
  - **stabilité** entre 2014 et 2019
  - identifier une mesure de pertinence statistique pour la comparaison d'écarts-types ?
- des différences infra communales **importantes**
  - limite de l'analyse des durées de trajet à la mine

### Distance à la mine

#### Matrice de desserte

![Durée médiane de trajet en minutes à l'usine par IRIS](img/carte_nc_usine_desserte.png)

---

#### Analyse desserte / NEM

![AFC durée d'accès (discrétisée en groupe de 15' de trajet) et déciles du NEM](img/afc_nem_desserte.png)

---

#### Conclusions sur la variable durée de trajet

- **Absence de linéarité** entre la distance à la mine et la variable `MINE` :
  - les actifs de la mine sur-représentés dans `[0-30[`
  - puis chutent _brutalement_ dans `[45-60[`
  - actifs de la mine sont de moins en moins représentés avec la distance croissante.
- sur-représentation des Européens/Calédoniens une sous-représentation des Kanaks dans `[45-60[`.
- sur-représentation des cadre dans `[15-30[`.

Est-ce que finalement, en excluant le GN, on aurait pas essentiellement des résultats sur **l'impact de l'usine Koniambo sur VKPP et la province Nord** ?

### Modèles linéaires pour le NEM

Comparaison des modèles `NEM100 ~ X` avec `X` dans

- diplôme, groupe d'age, CSP, variable `MINE`
- 1/4h de trajet calculées par IRIS

```raw
                       dev dof dev_by_dof  dev_pc
DUREE_USINE_QUART  2147830   9     238648 14.5211
DUREE_CENTRE_QUART  993045   8     124131  6.7138
DUREE_QUART         508703   7      72672  3.4392
DIPLR_             2047411   7     292487 13.8421
AGER_               260642   6      43440  1.7621
CS8_               1844840   5     368968 12.4726
MINE_                13074   1      13074  0.0884
ETH                3997596   4     999399 27.0270
```

---

#### `NEM100 ~ DIPL + CS8 + ETH`

![Coefficients du modèle **sans** durée de trajet](img/modele1.png)

---

#### `NEM100 ~ USINE_QUART + DIPL + CS8 + ETH`

![Coefficients du modèle **avec** durée de trajet](img/modele2.png)

---

#### Conclusions sur le pouvoir explicatif des facteurs sur le NEM100

- des trois durées, c'est celle **à l'usine** qui capture le plus de variance
- l'impact est du même ordre de grandeur que le **diplôme** ou la **CSP**
- mais très inférieur à l'**influence ethnique**
- l'age et l'employeur minier on des influences **très limitées**
- les coefficient de la durée de trajet ne sont **pas linéaires**
