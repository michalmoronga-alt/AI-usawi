# Postup implementácie a handoff

Stav k 2026-09-11: **dokumentácia, bez implementácie a bez nového živého overenia**. Tento plán nie je príkaz na okamžité spustenie všetkých krokov.

## Predchádzajúci technický prieskum

Majiteľ poskytol report lokálneho agenta. Podľa neho sú k dispozícii Rainmeter 4.5.26.3894, RunCommand, Win-CodexBar 0.56.8 a systémový Windows PowerShell 5.1. Sú to **údaje z reportu**, nie testy vykonané pri založení tohto repa. Pred implementáciou overiť aktuálny stav primerane rozsahu; nepublikovať osobné cesty, účty a ich hodnoty.

Report mapoval weekly v skúmanej verzii na `usage.secondary.used_percent` pri overenom týždennom okne. Pri Claude uvádzal pôvod `weekly_all` alebo `seven_day.utilization`. Konkrétne živé hodnoty a zhoda účtov neboli úplne overené. Toto nie je univerzálny kontrakt CLI; implementácia musí mapovanie znova doložiť a nesmie sa riadiť iba názvom `secondary`.

Podstatné zistenia z reportu: export môže vykonať nový zber, zapisovať interný stav a štandardne obnovovať existujúce prihlásenie. Čas nového exportu nemusí dokazovať čerstvosť prenesenej weekly hodnoty. Práve preto sa teraz na živé overenie čaká.

## A: uzavrieť víziu

Doplniť rozhodnutia o spoločnom paneli, rozložení, palete a správaní na okraji monitora. Vytvoriť vizuálnu predlohu stavov z `DESIGN_BRIEF.md`. Bez účtov, ich exportu a lokálneho nasadenia. Výstupom má byť schválená predloha, nie iba náladový obrázok.

## B: DEMO skin – až po povolení

Implementovať natívne Rainmeter zobrazenie a interakcie na syntetických fixtures. Viditeľné označenie DEMO; žiadny tichý fallback z live dát na ukážku. Nepotrebovať Win-CodexBar ani auth súbory. Otestovať dva prstence, skrytý Codex 5h, detail, mierku a chyby. Nezasahovať do iných skinov alebo startupu.

## C: kontrolované živé overenie – osobitný súhlas

Najprv overiť presnú verziu, help a cielené príkazy pre Codex a Claude; žiadny režim `all`. Pred spustením vysvetliť bežné zápisy a refresh existujúceho prihlásenia. Potom porovnať správny účet/kvótu s aplikáciou a zaznamenať iba bezpečné schéma a obmedzenia. Chýbajúce údaje alebo neistota majú byť výsledkom overenia, nie dôvodom na vymyslený mapping.

## D: adaptér a lokálna detekcia

Na základe C vybrať najmenšie potrebné riešenie. Predbežne jeden PowerShell adaptér a malý Lua pomocník, bez servera alebo databázy. Oddeliť zber, normalizáciu, detekciu a oznámenie. Konkrétne prahy sú návrh na schválenie, nie skryté konštanty.

Zdrojové súbory, lokálne nastavenia a runtime stav oddeliť. Do zdieľaného zdroja patria iba anonymné fixtures. Verejný PR nesmie obsahovať reálne výpisy ani snímky účtov. Bez zmeny upstreamu.

## E: integrované testy, nasadenie a dogfooding

Nasadzovať iba schválenú konkrétnu verziu do samostatného skinu. Overiť kolízie, zálohu a rollback. Projektové repo nedržať ako pracovný priestor priamo v aktívnom skine. Bez zmeny existujúceho JaxCore/Rainmeter rozloženia, politika PowerShellu sa globálne nemení.

Testovať aspoň:

| Oblasť | Scenáre |
| --- | --- |
| Mapping | Weekly vs. 5h; used vs. remaining; 0/100/null; chýbajúci weekly bez náhrady. |
| Voliteľný 5h | Skutočne absentuje, platná nula, novo dostupný Codex 5h, dočasný výpadok. |
| Čerstvosť | Prenesená cache, neznámy čas kvóty, reset prešiel bez nového údaja. |
| Detekcia | Významný pokles pred resetom, pokles bez dosiahnutia 100 %, drobná korekcia, neplatná nula. |
| Identita | Zmena účtu, kvóty alebo známej kapacity; prvé meranie. |
| Robustnosť | Timeout, jedna služba zlyhá, uspanie, reštart, nesúbežnosť zberov. |
| Oznámenia | Bez kradnutia fokusu, deduplikácia, potvrdenie, neskoršia nová udalosť, izolovaný TEST. |
| UI | Dva poskytovatelia, otvorený detail, okraje monitorov, DPI/mierka a vzdialené kliknutie. |
| Súkromie | Bez auth údajov v súboroch, logoch, repozitári a distribučnom balíku. |

Bez prístupu k natívnej ploche označiť vizuálny test NOT TESTED, nie PASS. Počet testov a výsledky uvádzať až po reálnom spustení. Minimálna používateľská skúška má pokryť bežný zber, chybu, spánok a aspoň jeden reálny plánovaný reset; dĺžka dogfoodingu nie je záruka zachytenia nečakaného resetu.

## Balík pre agenta

Aktuálne `V1_SPEC.md`, `DECISIONS.md`, `DESIGN_BRIEF.md`, schválené predlohy (ešte chýbajú), anonymné fixtures (ešte chýbajú), výsledky povoleného živého overenia (zatiaľ neúplné) a jeden konkrétny task s hranicou STOP. Nie súbor starých navzájom rozporných promptov.

Po každom schválenom kroku: PASS/PARTIAL/FAIL, zmenené súbory, vykonané testy, známe obmedzenia a ďalšie rozhodnutie. Mobil, Reset Spy a editor tém zostávajú odložené.
