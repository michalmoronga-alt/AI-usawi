# Register rozhodnutí

Záznam zo zakladania dokumentácie: 2026-09-11. Zdrojom produktových požiadaviek je rozhovor s majiteľom. Toto nie je záznam vykonaných testov.

## Potvrdené

| ID | Rozhodnutie | Dopad |
| --- | --- | --- |
| D-001 | Repo `michalmoronga-alt/AI-usawi` zostáva verejné. | Verejné materiály bez osobných údajov; komunitné zdieľanie až neskôr. |
| D-002 | V1 má iba Codex a Claude. | Antigravity úplne preč vrátane zberu, konfigurácie a placeholdera. |
| D-003 | Vonkajší prstenec a veľké percento sú spotrebované weekly. | Nesmú sa prepínať na 5h alebo zostávajúcu kapacitu. |
| D-004 | Vnútorný tenší prstenec je skutočná 5h kvóta. | Podpora aj pri Codexe, ale iba keď ju zdroj naozaj poskytne. |
| D-005 | Vo vnútri je percento a poskytovateľ. | Detaily sa otvárajú kliknutím na spodnú hranu, nie veľkým hover panelom. |
| D-006 | Lokálne upozornenia na nečakaný pokles weekly patria do V1. | Minimálny perzistentný stav je povolený v návrhu; nie historická databáza. |
| D-007 | Farby, priehľadnosť, veľkosť a ďalší používateľský editor vzhľadu sú budúci plán. | Vo V1 iba jednoduché oddelené hodnoty, bez grafického editora tém. |
| D-008 | Reset Spy sa uchová ako nápad/prieskum, nie V1. | Externé oznámenie nikdy nemení nameraný stav účtu. |
| D-009 | Mobilné oznámenia sú na neskôr. | V1 zostáva lokálna. |
| D-010 | Pôvodná hranica bola iba dokumentácia; PROMPT 2 ju 2026-09-11 mení výlučne pre offline DEMO. | Živý zber a účty naďalej čakajú. |
| D-011 | PROMPT 2 povoľuje implementovať a izolovane načítať DEMO, syntetické scenáre, testy a checkpoint. | Zdroj v `skin/`, nasadená kópia samostatne. Bez živého adaptéra. Lokálny commit áno, publikovanie nie. |
| D-012 | Schválená predloha: dva kruhy a jeden spoločný klikateľný detail; fialová weekly, jantárová 5h. | Preberá sa vizuálny smer, nie poster, falošné Online, vysvetlenia neprítomného Codex 5h alebo nefunkčné nastavenia. |
| D-013 | DEMO udalosť je výlučne TEST, potvrdenie a deduplikácia podľa ID. | Žiadny skutočný resetový detektor; pri novom načítaní nevznikne udalosť automaticky. |
| D-014 | Implementačné voľby DEMO: presúvanie horným DEMO úchytom, 14 ručných scenárov, mierka 1–1.5 jedným klikom. | Ovládacie prvky nepresúvajú widget. Detail mení stranu podľa pracovnej plochy; pri tesnom priestore sa zmenší iba detail. |

| D-015 | 2026-09-11: majiteľ prijal vzhľad DEMO a výslovne požiadal o ďalšiu fázu – pripojenie k dátam. | Povolené cielené živé overenie Codex/Claude, adaptér, izolované nasadenie a testy. Bez automatizácie nového loginu, all alebo AI promptov. Detektor a oznámenia sa týmto neimplementujú. |
| D-016 | Technická voľba: existujúca zaregistrovaná konfigurácia DEMO.ini dostane explicitný režim LIVE/DEMO. | LIVE je jasne označený, fixtures sú prístupné len v DEMO. Názov nasadeného priečinka zostáva historický, aby nebolo potrebné obnoviť ostatné skiny. Zdroj a lokálny stav sú oddelené. |

## Návrhy stále otvorené

Potvrdené doplnenie **D-017 (2026-09-12):** majiteľ požiadal o vyčistenie plochy a push na GitHub. Výslovne ponechal DEMO režim a testovacie scenáre v projekte. LIVE skrýva pomocné nápisy, podtituly kruhov, tlačidlo mierky a technický podnadpis detailu; zachováva mená služieb, percentá, stavy a detaily limitov. Mierka je v kontextovom menu, DEMO položky z neho odstránené. Povolený push pracovnej vetvy, bez PR alebo merge. D-016 sa mení iba v zobrazovaní nápisu LIVE; DEMO zostáva vždy označené.

| ID | Návrh | Stav |
| --- | --- | --- |
| P-001 | Jeden spoločný presúvateľný widget a spoločný panel detailov. | Uzavreté pre DEMO rozhodnutím D-012. |
| P-002 | Fialový weekly, jantárový 5h, priemer okolo 140 px. | Smer schválený D-012; presné DEMO tokeny zapísané v briefingu. |
| P-003 | Štítok vyčerpaného 5h a „Kopírovať stav“. | Doplnky na posúdenie, nie záväzná V1. |
| P-004 | Presné prahy detekcie, tvar oznámenia a správanie na okraji monitora. | Navrhnúť pred implementáciou príslušnej časti. |
| P-005 | Licencia a finálny verejný názov/branding. | Bez automatického výberu licencie či premenovania repa. |

## Čo je prekonané

Pôvodné tri kruhy s Antigravity nahradilo D-002. Pôvodné krátkodobé číslo v hlavnom kruhu nahradilo D-003. Pôvodný zákaz podpory Codex 5h bol nahradený D-004: nevymýšľať neexistujúci limit, ale podporiť reálny budúci 5h. Pôvodné detaily iba po hoveri nahradilo D-005. Pôvodné vylúčenie notifikácií z V1 nahradilo D-006.

D-015 nahrádza odklad živého zberu z DEMO kroku. Historický DEMO checkpoint zostáva záznamom vtedy vykonaných testov, nie aktuálnym zákazom napojenia.

## Ako zapisovať ďalšie doplnenia

Každé nové rozhodnutie má stav, dátum a dopad na rozsah. Potvrdená zmena V1 sa zapíše súčasne do špecifikácie; nápad ide do roadmap. Zachovať zmysel zmeny, nie nekonečné kópie celých promptov. Žiadne budúce želanie sa nesmie pri handoffe tváriť ako hotová funkcia alebo povolený task.
