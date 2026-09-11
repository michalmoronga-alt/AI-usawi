# DEMO checkpoint — 2026-09-11

Toto je historický výsledok pred schválením živého kroku. Aktuálne napojenie, testy a rozsah podľa D-015 sú v [LIVE_CHECKPOINT.md](LIVE_CHECKPOINT.md); nižšie uvedený zákaz živého zberu opisuje vtedajší DEMO krok.

**PARTIAL — natívny DEMO je načítaný; dátové a programové ovládacie testy prešli. Zostáva reprodukovateľný vizuálny defekt pri prepínaní detailu a neoverené fyzické ovládanie myšou.** Nie je to hotová V1 ani živé napojenie.

## OVERENÉ

- Celý PROMPT 2, START_HERE a požadované dokumenty boli prečítané; schválená obrazová predloha bola otvorená.
- Samostatný clone, pôvodne čistý základ `ac6d14a`, vetva **feat/demo-skin**. Zmeny zostali lokálne bez commitu; otvorený vizuálny defekt sa neoznačuje ako hotová dodávka. Žiadny push, PR alebo merge.
- Rainmeter **4.5.26.3894 x64** a skutočný SkinPath z jeho konfigurácie. Repo je mimo aktívnych skinov; načítaná je samostatná kópia **NOXUN AI Usage DEMO / DEMO.ini**.
- Dva monitory 1920 × 1080, pracovné oblasti 1920 × 1032; ľavý monitor má X = −1920. DEMO bolo presunuté aj na ľavý monitor bez návratu na hlavný. Súradnice a render sa overili; snímka s pozadím inej aplikácie sa nedistribuuje.
- Win-CodexBar v tomto DEMO kroku nebol spustený, jeho cache ani auth sa nečítali. Žiadne AI API, účty, nové závislosti alebo zmeny execution policy. Widget za behu nevytvára pomocné procesy.

## Výsledky skutočných testov

| Kontrola | Výsledok |
| --- | --- |
| `tools/Test-Demo.ps1 -NativeReport …` | **21 PASS / 0 FAIL**, PowerShell 7.6.5 aj Windows PowerShell 5.1. Syntax piatich skriptov, kontroly zdroja, reálne izolované nasadenie/rollback, ochrana upravených súborov, Unicode príprava a úspešný natívny Lua report. |
| `tests/demo_spec.lua`, interpreter Rainmetera | **35 PASS / 0 FAIL**. Geometria, 0/100/neplatné hodnoty, absencia/neistota 5h, weekly bez náhrady, posledné hodnoty, reset, čerstvosť, layout a TEST deduplikácia. |
| `tools/Test-NativeDemo.ps1`, načítaná kópia | **27 PASS / 0 FAIL**. Všetkých 14 scenárov, otvorenie/prepnutie/zatvorenie cez reálne obslužné funkcie, skutočná veľkosť okna pri 1.0/1.5, otvorenie nad kruhmi, zväčšenie pri okraji, TEST/ack a uplynutie resetu bez vynulovania. Programové natívne testy, nie fyzické kliky. |
| Nula, 25 %, 50 %, 65 %, 100 % | **PASS — natívne snímky skontrolované.** Nula bez farebnej koncovky, 25 % horná pravá štvrtina, 50 % pravá polovica, 65 % = 234°, 100 % uzavretý kruh. |
| Mierky 100 % a 150 % | **PASS** pre rozmery a skontrolovaný bežný stav/detail. Zatvorené okno 376 × 236 / 564 × 354 px. Bežný Claude detail: celkové okno 376 × 530 / 564 × 795 px. |
| Zima/leto podľa OS | **PASS** v natívnej Lua: 15. 1. 2026 o 12:00 → `+0100`; 15. 7. 2026 o 12:00 → `+0200`. Bez pevného UTC+2. |
| Procesy a timeout | **PASS**: jeden rovnaký reagujúci hlavný proces počas záverečných kontrol. V predošlom blokovanom stave sa odovzdávací proces ukončil po 5.13 s, hlavný zostal zachovaný. |
| Natívny Rainmeter log | V skontrolovanej časti žiadna Lua chyba DEMO. Opakované nasadenie hlásilo iba „already active“ a vlastný refresh. To nevysvetľuje vizuálny defekt. |
| Text detailu po prepnutí | **FAIL / otvorený defekt:** po niektorých prepnutiach chýbajú časti písmen alebo riadkov, hoci hodnoty sú správne. Čisté načítanie ten istý scenár vykreslí správne. |
| Fyzický klik, presúvanie úchytom, mouse-leave a fokus | **NOT TESTED.** Computer Use poskytol správcu a diagnostiku Rainmetera; priehľadné DEMO okno nebolo samostatne zacieliteľné. Manuálne potvrdenie nebolo do checkpointu prijaté. |
| Zmena systémového DPI, zmiešané DPI a vzdialený klik | **NOT TESTED.** Systémové nastavenia sa nemenili. Mierka skinu 1.5 nie je test systémového DPI. |

Test nasadenia skutočne odmietol neznámy cieľ, zachoval cudzí súbor a odmietol prepísať alebo vymazať upravenú kópiu. Rollback sa vykonal v izolovanom testovacom priečinku; finálna DEMO kópia zostáva načítaná.

## Natívne snímky

Orezané na DEMO a podklad, bez predlohy, HTML alebo generovaných obrázkov:

| Stav | Súbor |
| --- | --- |
| Bežný, detail zavretý | [demo-normal.png](images/demo-normal.png) |
| Otvorený Claude detail | [demo-detail.png](images/demo-detail.png) |
| Mierka 150 % | [demo-scale-150.png](images/demo-scale-150.png) |
| Geometria | [0 %](images/demo-zero.png), [25 %](images/demo-quarter.png), [50 %](images/demo-half.png), [100 %](images/demo-full.png) |
| Otvorený vizuálny defekt | [demo-known-text-issue.png](images/demo-known-text-issue.png) |

## Mapovanie výlučne syntetických údajov

Interný kontrakt nie je schémou Win-CodexBaru:

| Pole | Význam |
| --- | --- |
| `codex.weekly.used`, `claude.weekly.used` | Spotrebované weekly percento 0–100; jediný zdroj veľkého čísla a vonkajšieho prstenca. |
| `*.session.used` | Syntetické spotrebované 5h percento; nikdy nenahrádza weekly. |
| `availability` | `present` / `absent` / `unknown`. Absent odstráni stopu aj riadky 5h; unknown netvrdí, že kvóta neexistuje. |
| `quality` | `fresh` / `stale` / `error` / `unknown`; chýbajúca hodnota nie je nula. |
| `observed_at`, `reset_at` | Epoch sekundy ukotvené pri spustení scenára. Odpočet reset neposúva a po uplynutí nezmení percento. |

Bežný scenár: Codex weekly 65 % bez 5h; Claude weekly 42 % a 5h 65 %. Syntetické scenáre Codex s 5h vrátane nuly nevyjadrujú plán používateľa. Žiadne živé mapovanie sa tu neoverovalo.

## Opravy overené natívne

- Hlavný `Runtime.lua` sa nasadzuje ako UTF-16 LE s BOM, aby Rainmeter 4.5 používal Unicode reťazce. Zdroj a moduly zostávajú UTF-8; manifest kontroluje skutočné nasadené bajty. Overené [v zdroji vydania](https://github.com/rainmeter/rainmeter/blob/v4.5.26.3894/Library/lua/LuaScript.cpp).
- Zatvorenie odstráni aj pôvodné pozície nepoužitých metrov: nezostáva veľké neviditeľné okno.
- Zväčšenie pri okraji udrží základ widgetu v pracovnej oblasti. Otvorenie detailu inak drží kotvu kruhov.
- Update neschováva celú kartu a znovu nenastavuje všetky vlastnosti. Zvyšný defekt kreslenia textu napriek tomu pretrval.
- Pomocné príkazy prijímajú aj scenáre s číslicou, napríklad `codex5hzero`.

## Otvorený defekt a zostávajúci smoke

Reprodukcia bez živých údajov:

1. Obnov iba DEMO, nechaj bežný scenár a otvor Claude detail.
2. Prejdi na „Weekly chýba, 5h existuje“ a prepni detail na Codex.
3. Skontroluj podnadpis, názov 5h a presný reset. Pri opakovaní sa zachytili chýbajúce časti textu; dáta a obslužný stav zostali správne.

Programové funkcie cez `Send-DemoCommand.ps1 -Action Lua`: `Toggle('claude')`, `LoadScenario('weeklyMissing')`, `Toggle('codex')`. Čistý refresh **iba tohto skinu** a priame otvorenie scenára obnovili čitateľné zobrazenie. Automatický refresh sa nepoužíva na maskovanie chyby.

**NEVIEM:** presnú príčinu artefaktov. Nie je preukázané, či ide o náš update, Rainmeter alebo grafické prostredie. Rainmeter sa neaktualizoval a globálna grafická konfigurácia sa nemenila. Po ohraničených opravách zostáva tento prípad otvorený namiesto neobmedzených experimentov.

Manuálne ešte over klik kruh/úchyt → otvorenie; druhá služba → prepnutie; aktívna → zatvorenie; krížik; odchod kurzora bez zatvorenia; presúvanie iba horným úchytom; TEST/Potvrdiť bez kradnutia fokusu. Počas `Test-NativeDemo.ps1` neklikaj do widgetu: skript dočasne mení scenáre, panel, pozíciu a mierku.

## Súbory, spustenie a odstránenie

Vytvorené:

- `skin/DEMO.ini`, `skin/@Resources/{Settings.inc,Model.lua,Fixtures.lua,Runtime.lua}`.
- `tests/demo_spec.lua`.
- `tools/{Deploy-Demo,Remove-Demo,Send-DemoCommand,Test-Demo,Test-NativeDemo}.ps1`.
- Tento checkpoint a osem anonymných snímok v `docs/images/`.

Zosúladené: `AGENTS.md`, `README.md`, `SECURITY.md`, `docs/{V1_SPEC,DECISIONS,DESIGN_BRIEF,IMPLEMENTATION_PLAN}.md`.

Spustenie z repa: `tools/Deploy-Demo.ps1 -Load`. Ovládanie: ‹ / ›, mierka 100 % / 150 %, TEST a Potvrdiť; kruh alebo spodný úchyt otvára detail. Nastavenia sú v `skin/@Resources/Settings.inc`. Jednosekundový update je iba lokálny odpočet. Podrobnosti: [README](../README.md).

Vypnutie: `tools/Send-DemoCommand.ps1 -Action Deactivate`. Odpojenie a odstránenie vlastnej kópie: `tools/Remove-Demo.ps1`. Neznáme a upravené súbory sa odmietnu; repo zostáva. `-FilesOnly` iba pre už odpojenú kópiu alebo izolovaný test. Ak Rainmeter práve zapisuje konfiguráciu, počkaj na dokončenie zápisu pred spustením skriptu.

## Pôvodný blocker a hranica

Prvý pokus vyžadoval obnovenie zoznamu skinov. Používateľ povolil jeden Refresh All; po ňom proces prestal reagovať ešte pred načítaním DEMO. Agent ho nereštartoval. **Používateľ Rainmeter sám reštartoval a povolil testovanie.** Ďalšie kroky obnovovali iba DEMO; ostatné skiny ani konfigurácie sa neupravovali.

DEMO zostáva načítané. Zostáva oprava vizuálneho defektu a manuálne potvrdenie ovládania. **STOP pred živým napojením**, skutočnou detekciou resetov, Reset Spy, mobilnými oznámeniami, editorom tém a publikovaním.
