# LIVE checkpoint — 2026-09-11

**Aktualizácia 2026-09-12:** používateľ obnovil prihlásenia cez oficiálne CLI. Následný zber aj natívne hodnoty boli úspešné pre Codex a Claude. Pôvodné auth blokery nižšie sú historické. Aktuálne vyčistenie plochy a výsledky sú v [CLEANUP_CHECKPOINT.md](CLEANUP_CHECKPOINT.md). Neznámy vek Codex weekly a ostatné obmedzenia zdroja zostávajú.

**PARTIAL: Codex živo funguje v Rainmeteri. Claude blokuje existujúce prihlásenie; majiteľ potvrdil rovnakú chybu v aplikácii Win-CodexBar.** DEMO zostáva funkčný. Detektor resetov a upozornenia nie sú implementované.

## OVERENÉ

- Majiteľ po prijatí vzhľadu povolil živé napojenie (D-015). Bežné vedľajšie zápisy a refresh existujúceho prihlásenia zo strany exportu boli vysvetlené pred zberom.
- Windows, bežný používateľ, Rainmeter **4.5.26.3894 x64**, Win-CodexBar CLI aj aplikácia **0.56.8**. CLI verzia/argumenty overené lokálnym helpom; zdroj na tage `v0.56.8`, commit `f6501478bcf4feea366cb88d488e9c83c9fa1548`.
- Úspešný cielený Codex OAuth export. Claude web aj OAuth zlyhali prihlásením; LIVE používa OAuth. Žiadny zber `all`, Claude CLI `/usage` probe, AI prompt, nový login alebo kopírovanie auth súborov.
- Source repo mimo skutočného SkinPath. Aktualizovaná iba vlastná konfigurácia `NOXUN AI Usage DEMO / DEMO.ini`; explicitné LIVE/DEMO. Syntetické akcie nemôžu nahradiť živé údaje.
- Natívne percento, reset a dostupnosť 5h zodpovedajú normalizovanému živému exportu. Codex primary je informačná položka, vnútorný 5h prstenec sa nevytvára.
- Nasledujúci automatický Codex export sa vykonal bez ručného refreshu približne po 182 s. Claude dodržal vlastný backoff. Po dokončení nezostali procesy nášho zberu.

## Presné mapovanie

| Údaj | Kontrakt 0.56.8 | Správanie |
| --- | --- | --- |
| Codex weekly | `usage.secondary.used_percent`, `window_minutes == 10080`, `is_informational == false`. Zdroj normalizuje API okná podľa trvania. | Spotrebované percento spoločnej Codex weekly kvóty. Žiadny Spark alebo session fallback. |
| Claude weekly | Rovnaká secondary validácia. OAuth/web preferujú `limits[]` typu `weekly_all` a podporované ekvivalenty, inak `seven_day.utilization`; nastavujú 10080 min. | Spoločný weekly všetkých modelov. Živé hodnoty **NEOVERENÉ kvôli auth**. |
| Skutočný 5h | `usage.primary.used_percent`, presne 300 min, neinformatívne okno. | Voliteľný vnútorný prstenec. Informačná primary sa nevydáva za kvótu. |
| Reset | `resets_at` konkrétneho okna, ISO8601 so zónou. | Epochové sekundy → lokálny čas OS a odpočet. Bez zóny sa odmietne. Uplynutie nevynuluje percentá. |
| Čas zdroja | `usage.updated_at`, vytvorenie snapshotu vo Win-CodexBare. | Pri Claude označený ako zber zdroja. Pri Codexe nedokazuje vek weekly merania. |
| Čas adaptéra | Interné `fetched_at`, `attempted_at`, per-quota `received_at`. | Úspešné prijatie exportu, posledný pokus a prijatie poslednej hodnoty zostávajú oddelené. |
| Identita | Voliteľné `account_email`/`account_organization`; aktuálny Codex ich nemá. | Ak existujú, uloží sa iba hash so súkromnou lokálnou soľou. Inak detail prizná chýbajúcu identitu. |
| Ďalšie kvóty | `extra_rate_windows`, vždy oddelene. | Overené lokálne pomenované lanes; ostatné sa priznajú počtom a odkazom na Win-CodexBar. Bez priemerovania. |

`used_percent` a Claude `utilization` sú percentá: 1 znamená 1 %, nie 100 %. Neznáme `remaining` pole sa neprepočítava.

Dôkazy: [RateWindow](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/core/rate_window.rs), [Codex API](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/providers/codex/api.rs), [Claude OAuth](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/providers/claude/oauth/mod.rs), [Claude web](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/providers/claude/web_api.rs), [CLI](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/cli/usage.rs).

## Obmedzenia / NEVIEM

1. **Vek Codex weekly:** upstream môže preniesť starú secondary bez samostatného času merania. Widget preto uvádza „vek kvóty neznámy“. Súkromný upstream stav sa nečíta. [Zdroj](https://github.com/nesszer/Win-CodexBar/blob/v0.56.8/rust/src/providers/codex/weekly_reset.rs).
2. **Neoveriteľná nula:** Codex JSON parser a Claude web môžu chýbajúcu utilization nahradiť nulou. CLI stráca pôvodnú validitu; RateWindow navyše normalizuje číselné hranice. Nulový Codex/Claude-web údaj preto nepotvrdíme: bez histórie „—“, inak označená posledná platná hodnota. Nulový doplnkový Spark sa nevydáva za overené 0 %. Claude OAuth s overeným trvaním zachováva explicitnú platnú nulu. DEMO naďalej testuje 0/100 % geometriu. Celú validitu pôvodnej API odpovede export spätne nedokáže doložiť.
3. **Identita Codex:** zhoda skin ↔ export je overená; zhoda účtu CLI ↔ účet vybraný v aplikácii zostáva **NEOVERENÁ**, pretože current usage JSON účet neuvádza. Bez identity sa nerobia resetové závery.
4. **Claude:** potrebuje opravu existujúceho OAuth prihlásenia používateľom a následný kontrolný export. CLI web nemusí zdieľať manuálne cookies aplikácie. Automatický prechod medzi OAuth/web/CLI nie je zapnutý.
5. **Doplnky:** neznáma modelová identita alebo nepodporovaná lane zostáva vo Win-CodexBare. `model_specific` bez presného modelového mena sa nehádá. Spark nikdy nie je spoločná Codex kvóta.
6. **UI — otvorený defekt:** detailové karty boli čitateľné, ale pri záverečných prepnutiach sa aj v LIVE zopakovalo vynechanie časti názvu/podtitulu kruhu známe z DEMO. Číselný stav zostal správny. Koreňová príčina ani trvalá oprava nie sú overené; nejde o vizuálny PASS. Fyzický klik/drag, systémové DPI, RDP, uspanie a reálny reset účtu sú **NOT TESTED**.

## Architektúra a súbory

Jeden Rainmeter RunCommand → krátky PowerShell zber oboch služieb → normalizácia → atomický `State/snapshot.txt` → striktný Lua čítač → existujúce metre. Bez servera, databázy, novej závislosti alebo služby.

- `skin/DEMO.ini`, `@Resources/Runtime.lua`, `Settings.inc`: spoločný vzhľad, explicitná vetva, jeden zber, lokálne odpočty.
- `@Resources/Adapter/Collect.ps1`: pevné cielené argumenty, kontrola hashu CLI, timeout, exkluzívny zámok, nezávislý backoff služieb.
- `@Resources/Adapter/Normalize.ps1`: iba čísla/enumy/hash v snapshote; weekly mapovanie, posledné hodnoty, neoveriteľná nula, atomická náhrada s krátkym opakovaním pri kolízii čítania.
- `@Resources/Adapter/ChildJob.cs`: malá väzba načítaná vstavanou .NET platformou; Windows Job Object ukončí vlastných potomkov zberu pri uzavretí jeho handle. Žiadna inštalácia. [Dokumentácia Windows](https://learn.microsoft.com/en-us/windows/win32/procthread/job-objects).
- `@Resources/Live.lua`: snapshot nikdy nespúšťa ako kód/include; odmieta duplicity, nevhodné znaky, zlú schému a nadmernú veľkosť. Zdrojové názvy sa nevkladajú ako Rainmeter konfigurácia.
- `tools/Deploy-Demo.ps1`, `Remove-Demo.ps1`: marker, manifest/hashe, režim, súkromné pripojenie, rollback. `Send-DemoCommand.ps1` ovláda iba vlastnú konfiguráciu.
- `tests/live_spec.lua`, `transport_fixture.ps1`, `tools/Test-Live.ps1`, `Test-NativeLive.ps1`: anonymné dáta a reálne procesné/natívne kontroly. Pôvodné DEMO testy zostali zachované.

Predvolené 180 s, timeout 30 s na poskytovateľa. Chyby danej služby: 180/360/720/1440/2880/3600 s; rate limit aspoň 900 s. Zber nereštartuje skin. Klik a hover nevolajú služby. Topmost nie je vynútený.

## Skutočne vykonané testy

| Kontrola | Výsledok |
| --- | --- |
| `Test-Live.ps1` | **53 PASS / 0 FAIL** v PowerShell 7.6.5 aj Windows PowerShell 5.1. Reálne procesy, timeout a zánik potomka, zámok, zmenený CLI hash, JSON array/object, opakovaný atomický zápis, DEMO bez zberu. |
| `live_spec.lua` v Rainmeter Lua 5.1 | **27 PASS / 0 FAIL**: parser/injekcia, staré údaje, auth, oddelenie kvót, nula/neoverená nula a resety. |
| Pôvodný `demo_spec.lua` | **35 PASS / 0 FAIL**, vrátane geometrie a OS zimného/letného času (`+0100`/`+0200`). |
| `Test-NativeDemo.ps1` po integrácii | **27 PASS / 0 FAIL**. |
| `Test-NativeLive.ps1` | **15 PASS / 0 FAIL**: export ↔ reálny meter/reset, Claude auth, neprítomný Codex 5h, izolácia od DEMO, detaily/rozmery v 1.0 a 1.5, kliknutia nemenia snapshot mimo pravidelného zberu. |
| Nasadenie/zdroj | Overené odmietnutie neznámeho/upraveného cieľa, Unicode Lua entry a izolované odstránenie. |
| Automatický zber | **PASS**, ďalší Codex export bez ručného spustenia, Claude vlastný backoff, po zbere žiadne zvyšné procesy. |
| Živý Claude úspech, zhoda účtov, reálny reset, spánok/RDP/DPI | **NOT TESTED / BLOCKED**, podľa obmedzení vyššie. |

Testy opravili dve skutočné odlišnosti PowerShellu 5.1: vyhodnotenie predvolenej cesty pred dostupnosťou script root a prevod null backup argumentu pri `File.Replace`. Regresia vykonáva aj druhý atomický zápis, nielen vytvorenie súboru.

## Spustenie a pokračovanie

Nasadená kópia zostáva **LIVE**. Nastavenia, spustenie a odstránenie sú v [README](../README.md). Pred zásahom vznikla lokálna záloha vlastného DEMO. Živé snímky a snapshoty zostávajú v ignorovaných lokálnych priečinkoch; verejné obrázky sú iba syntetické DEMO.

Ďalší krok používateľa: opraviť existujúce Claude OAuth prihlásenie používané Win-CodexBar CLI. Potom overiť jeho weekly/session a zhodu účtu. Dovtedy sa Claude úspech neoznačí PASS. Resetový detektor, upozornenia a publikovanie zostávajú mimo tohto kroku.
