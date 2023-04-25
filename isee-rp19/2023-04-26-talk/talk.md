# Retours sur les RPs 2009-2014-2019 ISEE

Rapport (2022-12-27) en ligne :

<https://romulusfr.github.io/isee-rp19/etude_nem_2009_2014_2019.html>

## Introduction

### Rappel du contexte

**But** exploiter les données 2019, compléter les analyses 2014 et 2009 sur l'indicateur de _Niveau d'Équipement des Ménages_ (NEM).

#### Données utilisées

- **RP** = recensement de la population 2009, 2014 et 2019 (**BL** = base logements + **BI** = base individuelle)
- définition géographiques (_shapefile_)
  - IRIS dits _UNC_
  - communes et provinces
- _durées de trajet_ mines/IRIS (a.k.a., _matrice de desserte_)

### Retour sur le workshop du 2022-11-16

- Données ISEE 2019, accès aux RPs via OpenData​, SD-Box​, _in situ_ et le Teams `Data​`
- Retour sur les sessions de travail à l'ISEE du 2022-11-07 et 2022-11-15
- Questions discutées le 2022-11-28 :
  - **Qui** souhaite faire **quoi** sur le RP 2019 ?​
  - Avec quelles **autres sources** et quels **outils** ?​

## Travail réalisé

### Détails sur les données

Variables d'équipement ménages : ELEC, EAU, BATI, BAIN, WC, MAL (ajouté), REFRI, CLIM, CHOS, TFIXE, INTER, VOIT, BATO, DEROU

Cofacteurs d'analyse

- code IRIS (variable `IRISUNC`),
- commune (variable `NC`)
- province (variable `PROV`)
- CSP (8 postes) (variable `CS8M`)
- diplôme (variable `DIPLM`)
- age révolu (variable `AGERM`)

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
  - hors du cadre
- 😀 analyse des variances du NEM / inégalités
  - analyse de la variance province/commune/VKPP
  - évolutions spatiales / analyses diachronique
- 😵‍💫 méthodes de _matching_ sur le RP 2019
  - spécifique à l'économétrie
  - analyse des _degrés de libertés_ de modèles linéaires
- 🤠 (non prévu) contributions au NEM
  - comprendre les poids
  - comparer équipements et cofacteurs

## Conclusions

- définition de la variable `Mine`
  - industries extractives sauf carrières hors secteur nickel.

Une note "perso" orale
