# Reset Spy – prieskumný návrh

Aktualizované: 2026-09-11. **MIMO V1. Žiadny feed, watcher ani X integrácia nie sú implementované alebo spustené.**

## Myšlienka

Majiteľ navrhol sledovať [@thsottiaux na X](https://x.com/thsottiaux), ktorý podľa jeho skúsenosti zverejňuje dôveryhodné informácie o resetoch. Následne dodal dva existujúce agregátory: AI Radar a Codex Reset Monitor. Widget by neskôr mohol zobraziť, čo bolo oznámené, pre koho to platí a kedy sa zmena očakáva.

Nie je to tá istá funkcia ako lokálna detekcia poklesu weekly vo V1. **Externý zdroj oznamuje zámer alebo udalosť na úrovni produktu; lokálny zberač pozoruje konkrétny účet.** Ani dôveryhodný autor nezaručuje, že sa každá jeho správa týka daného plánu, regiónu a konkrétnej kvóty.

## Hranice dôvery

| Druh informácie | Povolené zobrazenie | Čo nesmie urobiť |
| --- | --- | --- |
| Oznámený plán | „Oznámený reset“ so zdrojom a časom publikovania. | Vynulovať percentá alebo prepísať reset účtu. |
| Oznámená vykonaná zmena | „Zdroj hlási obnovenie“ s rozsahom platnosti. | Označiť účet ako obnovený bez lokálnych dát. |
| Resetový kredit | „Oznámený kredit na obnovu“ s podmienkami a prípadnou potrebou aktivácie. | Zameniť kredit za už vykonaný plošný reset. |
| Pozorovaný pokles na účte | „Využitie kleslo“ / primerane označený možný reset. | Pripísať príčinu správe len preto, že bola blízko v čase. |
| Predikcia alebo náznak | Nanajvýš osobitne označený kontext po budúcom schválení. | Vytvoriť oznámenie o potvrdenom resete alebo záväzný odpočet. |
| Nejasná alebo expirovaná správa | Informácia s výhradou, prípadne bez upozornenia. | Vymyslieť dátum, časové pásmo alebo univerzálnu platnosť. |

Oznámenia majú vlastný indikátor a odlišné znenie od lokálnych udalostí. Chyba externého feedu nesmie zastaviť kruhy alebo lokálnu detekciu. Prípadné prepájanie je iba kontext, nie dôkaz príčiny.

## Kandidáti na externý zdroj – prieskum 2026-09-11

**Stav: overený verejný obsah, nie overená integrácia.** Pozorovania nižšie opisujú weby pri kontrole; nepotvrdzujú presnosť každého záznamu ani dostupnosť stabilného API.

| Kandidát | Pozorovanie na verejnom webe | Zostáva overiť |
| --- | --- | --- |
| [AI Radar – história resetov](https://ai.patrikwagner.cz/signaly?typ=resety) | Záznamy OpenAI aj Anthropic, rozlíšenie vykonané/oznámené/resetový kredit a odkazy na pôvodné správy. V pätičke je RSS. | Či RSS obsahuje resety; stabilná schéma, opravy, interval odberu a podmienky použitia vo verejnom widgete. |
| [Codex Reset Monitor](https://codexreset.org/) | Nezávislý monitor Codexu s časovou osou a pôvodnými odkazmi. Publikuje aj experimentálne pravdepodobnosti. Uvádza minútovú kontrolu a hodinový úplný refresh/zber X. | Dokumentovaný RSS/JSON/API výstup, povolené používanie, cena a limity. Taký výstup pri tejto kontrole nebol potvrdený. |

Na [stránke podmienok Codex Reset Monitor](https://codexreset.org/terms) sa v načítanom texte zobrazil iba obal a „Loading...“. Podmienky automatizovaného odberu preto neboli overené. Samostatné stiahnutie HTML z pracovného prostredia zlyhalo na DNS; nie je to dôkaz nedostupnosti webu. Verejnú stránku bolo možné prečítať webovým nástrojom, ale jej interné sieťové rozhrania neboli otestované.

**NÁVRH po tomto prieskume:** pred vlastným zberom X preveriť existujúce zdroje. AI Radar je kandidát pre obe služby, Codex Reset Monitor je ďalší kandidát pre Codex. Primárny/záložný zdroj sa vyberie až podľa dostupného rozhrania, kvality a podmienok, nie podľa vzhľadu webu. Druhý web nie je automaticky druhé nezávislé potvrdenie, ak oba citujú tú istú pôvodnú správu.

Bezplatný schválený feed by mohol odstrániť potrebu vlastného plateného zberu X. **Verejne čitateľný web však nie je prísľub bezplatného API, povolenia redistribúcie ani trvalej prevádzky.** Bez účtov, kľúčov a reálnych usage údajov používateľa vo vonkajších požiadavkách.

## Najmenší overovací experiment

**a) Existujúci dohodnutý RSS/JSON zdroj – odporúčaný najbližší prieskum.** Overiť, či niektorý kandidát poskytuje údaje s vhodnými podmienkami pre verejný desktopový widget. Ak nie, osloviť autora s návrhom jednoduchého výstupu a uvedením zdroja. Verejná dátová cesta používaná webovým frontendom sama osebe nie je dokumentovaný integračný kontrakt. Prvý schválený experiment má mať jeden zdroj a malú vzorku, nie okamžitý viaczdrojový backend. Dnes sa odber nenastavuje.

**b) Ručne kurátorovaný zoznam – záložný experiment.** Maintainer pridá stručnú vlastnú parafrázu, odkaz na originál, dátum, rozsah a expiráciu. Neskôr by sa dal poskytovať ako malý verejný dátový feed bez používateľských účtov či usage údajov. Výhodou je kontrola kvality a žiadne povinné X kľúče u každého používateľa. Nevýhodou je ručná práca a oneskorenie. Aj tento variant potrebuje schválenie; teraz sa feed nevytvára.

**c) Priame oficiálne X API – až ak hotové zdroje nevyhovujú.** Pred experimentom overiť autentifikáciu, identitu účtu, limity, aktuálne ceny, povolené spracovanie a spôsob ukladania. Nepredpokladať bezplatný ani neobmedzený prístup. Žiadne prevzatie prihlasovacích cookies z prehliadača.

Spoločný automatizovaný zdroj pre komunitu môže neskôr znížiť duplicitný zber, ale pridáva prevádzku, kontrolu zdrojov a zodpovednosť za opravy. Nie je to schválená architektúra ani podmienka prvého experimentu.

Žiadne krehké automatické prihlasovanie cez web, obchádzanie prístupu, trvalý LLM agent alebo plné kopírovanie príspevkov ako východiskové riešenie. AI sumarizácia prípadne neskôr a iba ako pomoc pri príprave, nie autorita nad stavom účtu.

## Čo by oznámenie potrebovalo

Stabilné ID udalosti aj identifikátory zdrojových záznamov; pôvodného autora a odkaz; agregátor a odkaz na jeho záznam; čas publikovania, načítania a prípadnej opravy; stručný súhrn; poskytovateľa, produkt a druh kvóty; rozsah plánov alebo explicitné „neznámy“; oznámený čas/zónu alebo „nešpecifikované“; stav plánované/vykonané/kredit/odvolané; expiráciu a opravy.

**Jedna udalosť, nie jedno upozornenie za každú webovú stránku.** Rovnaký pôvodný príspevok načítaný cez dva agregátory zlúčiť. Oznámenie a následné potvrdenie môžu patriť k tej istej udalosti; neskoršie potvrdenie je zmena stavu, nie automaticky ďalší reset. Rôzne správy nezlučovať iba podľa dátumu alebo podobného názvu. Pri rozpore zdrojov zachovať neistotu a dohľadateľné podklady.

Počiatočné načítanie histórie nesmie spustiť záplavu starých oznámení. Upravené alebo odvolané správy musia mať možnosť korekcie. Nejasné „zajtra“ sa nesmie premeniť na presný odpočet bez časového kontextu. Zdrojová URL sa validuje; obsah sa nikdy nevykonáva ako príkaz alebo Rainmeter konfigurácia.

Navrhovaný externý zber má byť nezávislý od lokálneho usage cyklu, s cache, timeoutom, spomalením pri chybách a intervalom rešpektujúcim podmienky zdroja. Úspešná HTTP odpoveď nie je dôkaz čerstvého zberu originálnych správ. Ak feed poskytuje len čas vygenerovania výstupu, neoznačovať ho za čas poslednej kontroly X. Samotná absencia novej udalosti nedokazuje funkčný monitoring.

Predikcie pravdepodobnosti ďalšieho resetu sa do prvého experimentu nepreberajú. Nepotrebujeme ďalší pravdepodobnostný ukazovateľ ani radu urýchlene minúť kvótu na základe odhadu.

## Prieskum pri založení dokumentácie

**Overené z oficiálnej dokumentácie X pri založení:** existuje `GET /2/users/{id}/tweets` pre príspevky používateľa. Cenník opisuje kreditový pay-per-use prístup; konkrétne sadzby a oprávnenia sa musia znovu overiť pri implementácii. Nezakladáme developer účet, nenakupujeme kredity a nepridávame X závislosť.

**Neoverené:** nezávislá kontrola konkrétnych resetových príspevkov v origináli, frekvencia ich publikovania, úplnosť prístupu k účtu a kvalita parsovania. Priamy pokus načítať dodanú X stránku pri založení skončil HTTP 403. Skúsenosť majiteľa a texty agregátorov sú podnet na prieskum, nie meranie spoľahlivosti alebo prísľub zachytenia každej udalosti.

Primárne zdroje pôvodného prieskumu, skontrolované pri založení 2026-09-11:
- [X – Get Users Posts](https://docs.x.com/x-api/users/get-posts)
- [X – API pricing and credits](https://docs.x.com/x-api/getting-started/pricing)
- [Navrhnutý pôvodný zdroj od majiteľa](https://x.com/thsottiaux) – samotný obsah pri pôvodnom overení nedostupný.

Pozorovania o agregátoroch vychádzajú z ich vlastných stránok uvedených vyššie, nie z dokumentácie OpenAI alebo Anthropic. Žiadne nezávislé testovanie úplnosti ani presnosti ich klasifikácie neprebehlo.

## Kritérium pokračovania

Najprv overiť použiteľný a povolený dátový výstup, potom na malej vzorke preukázať, že oznámenia bývajú včasné, správne sa priraďujú ku kvóte a plánom a znižujú potrebu manuálnej kontroly. Ak bude výsledkom šum alebo drahší zber než prínos, ponechať ručný zoznam alebo funkciu odložiť. Jadrový widget musí zostať použiteľný bez Reset Spy.
