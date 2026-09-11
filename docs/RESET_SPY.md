# Reset Spy – prieskumný návrh

Aktualizované: 2026-09-11. **MIMO V1. Žiadny feed, watcher ani X integrácia nie sú implementované alebo spustené.**

## Myšlienka

Majiteľ navrhol sledovať [@thsottiaux na X](https://x.com/thsottiaux), ktorý podľa jeho skúsenosti zverejňuje dôveryhodné informácie o resetoch. Widget by neskôr mohol zobraziť, čo bolo oznámené, pre koho to platí a kedy sa zmena očakáva.

Nie je to tá istá funkcia ako lokálna detekcia poklesu weekly vo V1. **Externý zdroj oznamuje zámer alebo udalosť na úrovni produktu; lokálny zberač pozoruje konkrétny účet.** Ani dôveryhodný autor nezaručuje, že sa každá jeho správa týka daného plánu, regiónu a konkrétnej kvóty.

## Hranice dôvery

| Druh informácie | Povolené zobrazenie | Čo nesmie urobiť |
| --- | --- | --- |
| Oznámený plán | „Oznámený reset“ so zdrojom a časom publikovania. | Vynulovať percentá alebo prepísať reset účtu. |
| Oznámená vykonaná zmena | „Zdroj hlási obnovenie“ s rozsahom platnosti. | Označiť účet ako obnovený bez lokálnych dát. |
| Pozorovaný pokles na účte | „Využitie kleslo“ / primerane označený možný reset. | Pripísať príčinu správe len preto, že bola blízko v čase. |
| Nejasná alebo expirovaná správa | Informácia s výhradou, prípadne bez upozornenia. | Vymyslieť dátum, časové pásmo alebo univerzálnu platnosť. |

Oznámenia majú vlastný indikátor a odlišné znenie od lokálnych udalostí. Chyba externého feedu nesmie zastaviť kruhy alebo lokálnu detekciu. Prípadné prepájanie je iba kontext, nie dôkaz príčiny.

## Najmenší overovací experiment

**a) Ručne kurátorovaný zoznam – odporúčaný prvý experiment.** Maintainer pridá stručnú vlastnú parafrázu, odkaz na originál, dátum, rozsah a expiráciu. Neskôr by sa dal poskytovať ako malý verejný dátový feed bez používateľských účtov či usage údajov. Výhodou je kontrola kvality a žiadne povinné X kľúče u každého používateľa. Nevýhodou je ručná práca a oneskorenie. Aj tento variant potrebuje schválenie; teraz sa feed nevytvára.

**b) Priame oficiálne X API.** Dokumentácia uvádza endpoint na čítanie príspevkov používateľa. Pred experimentom overiť autentifikáciu, identitu účtu, limity, aktuálne ceny, povolené spracovanie a spôsob ukladania. Nepredpokladať bezplatný ani neobmedzený prístup. Žiadne prevzatie prihlasovacích cookies z prehliadača.

**c) Spoločný automatizovaný zdroj pre komunitu.** Jeden schválený zber môže neskôr zásobovať verejný feed stručných udalostí. Zníži duplicitnú prácu používateľov, ale pridá prevádzkové náklady, údržbu, kontrolu zdrojov a zodpovednosť za opravy. Nie je to potrebné pre prvý experiment a nie je to schválená architektúra.

Žiadne krehké automatické prihlasovanie cez web, obchádzanie prístupu, trvalý LLM agent alebo plné kopírovanie príspevkov ako východiskové riešenie. AI sumarizácia prípadne neskôr a iba ako pomoc pri príprave, nie autorita nad stavom účtu.

## Čo by oznámenie potrebovalo

Stabilné ID udalosti a pôvodného príspevku; autora a odkaz; čas publikovania a overenia; stručný súhrn; poskytovateľa, produkt a druh kvóty; rozsah plánov alebo explicitné „neznámy“; oznámený čas/zónu alebo „nešpecifikované“; stav plánované/vykonané/odvolané; expiráciu a opravy.

Počiatočné načítanie histórie nesmie spustiť záplavu starých oznámení. Upravené alebo odvolané správy musia mať možnosť korekcie. Nejasné „zajtra“ sa nesmie premeniť na presný odpočet bez časového kontextu. Zdrojová URL sa validuje; obsah sa nikdy nevykonáva ako príkaz alebo Rainmeter konfigurácia.

## Prieskum pri založení dokumentácie

**Overené z oficiálnej dokumentácie X:** existuje `GET /2/users/{id}/tweets` pre príspevky používateľa. Cenník opisuje kreditový pay-per-use prístup; konkrétne sadzby a oprávnenia sa musia znovu overiť pri implementácii. Nezakladáme developer účet, nenakupujeme kredity a nepridávame X závislosť.

**Neoverené:** konkrétne resetové príspevky, frekvencia ich publikovania, úplnosť prístupu k účtu a kvalita parsovania. Priamy pokus načítať dodanú X stránku v tomto prieskume skončil HTTP 403. Skúsenosť majiteľa je podnet na prieskum, nie meranie spoľahlivosti alebo prísľub zachytenia každej udalosti. Pred automatizáciou overiť profil a ukážky originálnych správ, nie iba reposty.

Primárne zdroje, skontrolované 2026-09-11:
- [X – Get Users Posts](https://docs.x.com/x-api/users/get-posts)
- [X – API pricing and credits](https://docs.x.com/x-api/getting-started/pricing)
- [Navrhnutý zdroj od majiteľa](https://x.com/thsottiaux) – samotný obsah pri tomto overení nedostupný.

## Kritérium pokračovania

Najprv na malej vzorke preukázať, že oznámenia bývajú včasné, správne sa priraďujú ku kvóte a plánom a znižujú potrebu manuálnej kontroly. Ak bude výsledkom šum alebo drahší zber než prínos, ponechať ručný zoznam alebo funkciu odložiť. Jadrový widget musí zostať použiteľný bez Reset Spy.
