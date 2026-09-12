# Vyčistenie LIVE — 2026-09-12

**PASS pre vyčistenie základnej plochy a programové kontroly.** Codex aj Claude po manuálnom prihlásení úspešne poskytujú údaje; natívne metre zodpovedajú ich snapshotom. Celá V1 vrátane detektora resetov tým nie je dokončená.

## Zmeny

- LIVE ponecháva kruhy, percentá, mená služieb, stavové značky a šípky detailov.
- Odstránené pomocné nápisy LIVE/presuň, automatická obnova, podtituly kruhov a technický podnadpis detailu. Význam kvót, resety a chyby zostávajú v detaile.
- Mierka 100/150 % je v kontextovom menu namiesto tlačidla na LIVE ploche. Presúvanie funguje cez prázdnu oblasť nad kruhmi.
- DEMO položky kontextového menu odstránené. Výslovne označený offline DEMO a testy zostávajú v projekte podľa D-017.
- Historický názov nasadeného priečinka a INI zostáva, aby nebol potrebný globálny refresh. Nasadená je iba vlastná existujúca kópia v LIVE.

## Overenie

| Kontrola | Výsledok |
| --- | --- |
| Test-Demo.ps1 | 22 PASS, 0 FAIL: syntax, izolované nasadenie/odstránenie, ochrana neznámych a upravených súborov. |
| Test-NativeLive.ps1 | 27 PASS, 0 FAIL: skryté pomocné metre, obe služby oproti snapshotom, izolácia DEMO, detaily a mierky 1/1.5. |
| Základná plocha | PASS: skontrolovaná natívna snímka po prepínaní detailov, čitateľné mená a percentá, bez pomocných nápisov. |
| Vizuálny detail | NOT TESTED: snímku zakrývalo iné okno. Programové prepínanie a rozmery prešli. Starší občasný defekt textu tým nie je uzavretý. |
| Fyzické presúvanie, DPI/RDP | NOT TESTED v tomto kroku; žiadne preberanie myši alebo klávesnice. |
| Git | Kontrola diff whitespace a bežných vzorov tajomstiev bez nálezu. Lokálne snapshoty, pripojenie a živé snímky sa nepridávajú. |

Codex výkričník môže označovať neoveriteľný vek weekly merania aj po úspešnom zbere. Neznamená automaticky chybu prihlásenia. Toto obmedzenie zdroja sa vyčistením neskrýva. Po auth chybách môže ďalší zber čakať na predĺžený interval; úspešný zber vráti interval na 180 sekúnd.

## Spustenie a odstránenie

Existujúce overené pripojenie: `tools/Deploy-Demo.ps1 -Mode LIVE -Load`. Mierka/farby/interval v `skin/@Resources/Settings.inc`; mierka aj pravým tlačidlom. Vypnutie: `tools/Send-DemoCommand.ps1 -Action Deactivate`. Odstránenie iba vlastného skinu: `tools/Remove-Demo.ps1`. Podrobnosti a prvé pripojenie sú v README.

Push povolený na pracovnú vetvu `feat/demo-skin`, bez PR, merge alebo vydania. Verejné obrázky zostávajú iba syntetické DEMO; snímky tohto živého overenia sa nepublikujú.
