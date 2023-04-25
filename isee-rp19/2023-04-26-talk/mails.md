# Notes/ backup email

## 27 décembre 2022

> De : Romuald THION <romuald.thion@unc.nc>
> Envoyé : mardi 27 décembre 2022 10:33
> À : Samuel GOROHOUNA <samuel.gorohouna@unc.nc>; Catherine RIS <catherine.ris@unc.nc>; Laisa ROI <laisa.roi@unc.nc>
> Objet : [CNRT M&T] Evolution du niveau d’équipement des ménages NC
>
> Bonjour à tous les trois,
>
> Pas de réunion prévue avec Fagnot, je n'ai pas eu l'occasion de lui proposer (il était en congé mais reviens je crois).
> On peut essayer de faire ça le 2, 3, ou 4 janvier, limite le 5. Au delà, je serai vraiment sur le départ.
>
> J'ai toujours mon badge ISEE, je compte y retourner pour finaliser l'étude aux dates précédentes.
>
> La nouvelle version du rapport est là :
>
> - <https://romulusfr.github.io/isee-rp19/etude_nem_2009_2014_2019.html>
>
> Avec quelques tableaux :
>
> - <https://romulusfr.github.io/isee-rp19/output/nem_communes.csv>
> - <https://romulusfr.github.io/isee-rp19/output/nem_iris.csv>
> - <https://romulusfr.github.io/isee-rp19/output/nem_weights.csv>
>
> On avait fait un point avec Samuel vendredi passé.
> Le rapport a évolué (mise en forme, nouvelle cartes, ajout variable ethnique).
>
> Là, je pars à Ouvéa et je reviens ce WE.
>
> Donnez mois les regressions que vous souhaitez faire et le découpage binaire de population pour faire de l'appariement et j'essaierai de le faire au retour à l'ISEE
>
> De celles d'Elise, Alban, Heloise, il faut sélectionner les variables qui vous intéressent le plus.

## 08 décembre 2022

> Bonjour,
>
> En PJ, une carte de l'évolution du NEM 2019 viz 2009 par IRIS qui répond en partie à 1) et 5) du mail transmis.
>
> Malheureusement, je ne peux pas reproduire l'indicateur d’Héloïse pour différentes raisons, mais il est dans le même esprit.
>
> J'aurai besoin d'aide pour avancer sur "les analyses de variances" et essayer de constituer un nouveau NEM avec une autre méthode.
>
> N'hésitez pas à me contacter par téléphone pour clarifier le besoin, notamment pour étoffer les rapports à venir.
>
> PS : j'ai réduit à la liste à Math-Info-Eco-Géo

## 28 novembre 2022

> Bonjour,
>
> Un résumé suite au point ce jour sur l'accès au données des RP 2019 (les anciennes étant déjà disponibles).
>
> ---
>
> Présents Samuel G., Laisa L., Nazha S. et Romuald T.
>
> L'ISEE limite à la liste des 8 autorisés via le CASD et demande les dates d'interventions dans leurs murs. Il est (très) difficile d'ajouter d'autres membres (cf. demandes Pascal D. et Amélie C.), en particulier pour les stagiaires, car la procédure est longue et que le projet M&T termine en juillet 2023.
>
> L'accès est plus facile que via la SDBox, mais reste contraint, mettre au point des scripts sur place est compliqué, il faut donc venir tant que possible avec :
>
> - des scripts R ou Python fonctionnels sur les RP dont on dispose déjà et avoir peu d'action pour les lancer sur le RP 2019,
> - une commande précise s'il s'agit de nouvelles statistiques (cf. demande Catherine S. sur l'évolution chasse/pêche/agriculture).
>
> Dans l'ordre de difficultés à peu près croissants, les commandes suivantes sont relevées :
>
> 1. refaire, _à l'identique_, le calcul de l'indicateur de niveau de vie ou plutôt de Niveau d'Équipement des ménages (NEM), pour le RP 2019,
> 2. faire les extractions du NEM et des principales variables des ménages agrégées par IRIS UNC avec le même pré-traitement sur les RPs 2009, 2014 et 2019, _id est_ reproduire une BL agrégée par IRIS que l'ISEE nous autoriserait à exporter
> 3. comparer le NEM à l'indicateur de l'ISEE, si on arrive à l'obtenir sur les années sus-citées,
> 4. bâtir un autre indicateur de niveau de vie via une autre méthode statistique (que celles actuelle du NEM, à savoir les points des 5 premiers axes de l'ACP),
> 5. faire l'étude des inégalités via l'analyse des variances du NEM par IRIS et comparer sur les trois RPs, au moins graphiquement via les cartes,
> 6. faire l'analyse par les méthodes de _matching_ sur le RP 2019 :
>    - NEM _versus_ distance à la mine (matrice de desserte),
>    - emploi, donc taux et précarité (saisonnalité et temps partiel) _versus_ distance à la mine (matrice de desserte),
>
> L'analyse de la décomposition des variations du NEM réalisée par Frédéric C. est à ce jour hors de portée.
>
> Je prévois de flécher environ ou 5j de mon temps de travail à l'ISEE pour réaliser ces commandes dans cet ordre (à peu près) d'ici la fermeture administrative d'été. Après, s'il y a une commande qu'on peut préciser et qu'elle n'est pas trop compliquée pour moi, je peux essayer.
>
> +++
>
> PS pour l'acronyme "NÉM", c'est ce qui m'est venu de plus Calédonien.

## 22 novembre 2022

> De : Romuald THION
> Envoyé : mardi 22 novembre 2022 15:33:24
> À : Catherine SABINOT; Jean-marie FOTSING; Samuel GOROHOUNA; Laisa ROI; Pascal DUMAS; Nazha SELMAOUI; Silvere BONNABEL; valentine.boudjema@gmail.com; Catherine RIS; marc.despinoy@ird.fr; Guillaume WATTELEZ; Amelie Chung
> Objet : [CNRT Mine et territoires] Réunion "RP ISEE 2019" -- lundi 28/11 12h-14h
>
> Bonjour à toutes et tous,
>
> Lors du _workshop_ du mercredi 16/11, un point sur l'accès aux données de l'ISEE a été fait (extrait des slides en PJ), en particulier sur l'accès au Recensement de Population (RP) 2019.
>
> Il a été convenu de faire un point sur cette question **lundi 28/11 de 12h à 14h**, à la suite de la restitution publique du projet le même jour à 10h.
>
> La question à l'ODJ est "qui souhaite faire quoi sur le RP 2019 (et éventuellement les autres), avec quelles autres sources de données et quels outils (informatique) ?"
>
> La collaboration avec l'ISEE avance et nous allons pouvoir avoir accès aux RPs dans leurs locaux. Pour cela il nous faut lister les intervenants et proposer des dates d'accueil sur site, c'est une demande du directeur de l'ISEE.
>
> Initialement, la réunion a été prévue avec Samuel, Laisa et moi-même, mais vue la demande, nous invitons tous ceux qui voudraient travailler sur les RP 2019 à prolonger la restitution du 28/11 et se joindre à nous.
> A défaut de disponibilité, répondez-moi par retour de mail, je ferai une synthèse pour le 28/11.
>
> Bonne journée et au 28/11.
