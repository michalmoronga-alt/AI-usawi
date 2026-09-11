# Postup implementácie a handoff

Stav k 2026-09-11: **D-015 povoľuje živé napojenie po prijatí DEMO.** Codex je napojený, Claude blokuje prihlásenie potvrdené aj majiteľom. Implementované sú zber/normalizácia/izolované nasadenie a testy, bez detektora resetov a upozornení. Aktuálne dôkazy: [LIVE_CHECKPOINT.md](LIVE_CHECKPOINT.md). Historický krok B: [DEMO_CHECKPOINT.md](DEMO_CHECKPOINT.md). Zvyšok roadmap nie je automaticky povolený.

## Predchádzajúci technický prieskum

Majiteľ poskytol report lokálneho agenta. Podľa neho sú k dispozícii Rainmeter 4.5.26.3894, RunCommand, Win-CodexBar 0.56.8 a systémový Windows PowerShell 5.1. Sú to **údaje z reportu**, nie testy vykonané pri založení tohto repa. Pred implementáciou overiť aktuálny stav primerane rozsahu; nepublikovať osobné cesty, účty a ich hodnoty.

Report mapoval weekly v skúmanej verzii na `usage.secondary.used_percent` pri overenom týždennom okne. Pri Claude uvádzal pôvod `weekly_all` alebo `seven_day.utilization`. Konkrétne živé hodnoty a zhoda účtov neboli úplne overené. Toto nie je univerzálny kontrakt CLI; implementácia musí mapovanie znova doložiť a nesmie sa riadiť iba názvom `secondary`.

Podstatné zistenia z reportu boli znovu overené pre 0.56.8: export vykonáva zber a môže zapisovať interný stav či obnovovať existujúce prihlásenie. Nový export nedokazuje čerstvosť prenesenej Codex weekly. Aktuálne obmedzenia vrátane neoveriteľnej nuly sú v LIVE_CHECKPOINT.

## A: uzavrieť víziu

Uzavreté pre DEMO v PROMPT 2: schválená predloha, dve služby, spoločný klikateľný detail a fialový weekly/jantárový 5h. Implementačné tokeny a správanie okrajov sa zaznamenávajú v `DESIGN_BRIEF.md`.

## B: DEMO skin – povolené PROMPT 2

Implementovať natívne Rainmeter zobrazenie a interakcie na syntetických fixtures. Viditeľné označenie DEMO; žiadny tichý fallback z live dát na ukážku. Nepotrebovať Win-CodexBar ani auth súbory. Otestovať dva prstence, skrytý Codex 5h, detail, mierku a chyby. Nezasahovať do iných skinov alebo startupu.

Konkrétne rozdelenie: `skin/DEMO.ini` vykresľuje, `Model.lua` normalizuje a počíta geometriu/časy, `Fixtures.lua` vytvára ručné scenáre s pevnou časovou kotvou, `Runtime.lua` riadi kliknutia a TEST kartu. Runtime používa len vstavané možnosti Rainmetera a Lua 5.1. Žiadny proces na periodickú aktualizáciu.

`tools/Deploy-Demo.ps1` kopíruje do skutočného SkinPath samostatnú kópiu a kontroluje hashe; `Remove-Demo.ps1` odmietne neznáme/upravené súbory. `Test-Demo.ps1` testuje zdroj a nasadenie v izolovanom lokálnom priečinku. Lua suite sa vykoná priamo v Rainmeteri cez `RunTests()`. Ručné natívne testy sa nesmú zameniť za tieto dátové assertions.

## C: kontrolované živé overenie – povolené D-015

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

Aktuálne `V1_SPEC.md`, `DECISIONS.md`, `DESIGN_BRIEF.md`, `LIVE_CHECKPOINT.md` a historický `DEMO_CHECKPOINT.md`. Do verejného repa patria iba anonymné fixtures a DEMO snímky. Po oprave existujúceho Claude prihlásenia používateľom doplniť jeho živé overenie a potvrdiť zhodu účtov. Detektor resetov a jeho prahy zostávajú samostatné rozhodnutie.

Po každom schválenom kroku: PASS/PARTIAL/FAIL, zmenené súbory, vykonané testy, známe obmedzenia a ďalšie rozhodnutie. Mobil, Reset Spy a editor tém zostávajú odložené.
