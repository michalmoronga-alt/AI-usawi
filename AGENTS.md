# Pravidlá práce na AI-usawi

## Aktuálna hranica

Projekt je v návrhovej fáze. Posledné povolenie zahŕňa **dokumentáciu a základné súbory tohto repozitára**, nie implementáciu ani živé volania účtov.

Používateľ odkladá lokálny zber, aby nezasahoval do aktívnej práce v Codexe. Bez nového výslovného súhlasu nespúšťaj Win-CodexBar CLI, refresh prihlásenia, prihlasovanie, prepínanie účtov, inštaláciu ani načítanie skinu. Povolenie na zápis dokumentácie nie je povolenie na tieto akcie.

## Čítanie a priorita

Najprv prečítaj `README.md`, `docs/V1_SPEC.md`, `docs/DECISIONS.md` a dokument k zadanej oblasti. Aktuálne výslovné zadanie majiteľa má prednosť; jeho zmenu zapíš do rozhodnutí a príslušnej špecifikácie v tom istom kroku.

Stavy **POTVRDENÉ**, **NÁVRH**, **BUDÚCI PLÁN** a **NEOVERENÉ** sa nesmú zamieňať. Roadmap nie je zoznam automaticky povolených implementačných úloh. Tieto dokumenty nahrádzajú staršie rozporné prompty; nevyžadujú prístup k súkromnému disku alebo inému projektu.

## Pevné pravidlá

- V1: iba Codex a Claude. Žiadny tretí poskytovateľ, zber `all` ani skryté prípravy pre Antigravity.
- Vonkajší prstenec a veľké číslo vždy znamenajú spotrebované weekly percento. Vnútorný prstenec je voliteľná skutočná 5h kvóta pri oboch službách.
- Neznáma hodnota nie je nula. Nový export nie je automaticky nové meranie každej kvóty. Oznámenie na X nie je údaj o stave účtu.
- Bez vlastného auth systému, testovacích AI promptov, povinného servera, databázy, telemetry a automatického riadenia agentov.
- Win-CodexBar je externá závislosť. Nemeň ho, neforkuj ho a nekopíruj jeho implementáciu bez osobitného rozhodnutia.
- Toto repo je verejné. Žiadne reálne usage výpisy, súkromné cesty, mená účtov, tokeny, cookies, auth súbory ani neanonymizované screenshoty.

## Zmeny a overovanie

Pred zápisom over vetvu a existujúce zmeny. Nezasahuj do iných repozitárov, neprepisuj cudziu prácu, nepoužívaj force push. Rozsah commit/push/PR/merge musí vychádzať z aktuálneho zadania; po úvodnej dokumentácii nejde o trvalé povolenie na ďalšie publikovanie.

Zdrojový projekt drž oddelene od nasadeného Rainmeter skinu. Najprv DEMO bez účtov; živé napojenie až v schválenom kroku. Výstup označ PASS/PARTIAL/FAIL a neotestované oblasti NOT TESTED. Snímka mockupu nie je dôkaz fungujúceho Rainmetera.

Nové nápady najprv zapíš do `docs/ROADMAP.md`. Ak menia V1, vyžiadaj rozhodnutie namiesto tichého rozšírenia rozsahu.
