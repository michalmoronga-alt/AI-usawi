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
| D-010 | Teraz dokumentácia a doladenie vízie; lokálna implementácia/živé overenie čakajú. | Žiadny refresh účtov počas aktuálneho odkladu. |

## Návrhy stále otvorené

| ID | Návrh | Stav |
| --- | --- | --- |
| P-001 | Jeden spoločný presúvateľný widget a spoločný panel detailov. | Potvrdiť pri uzavretí dizajnu. |
| P-002 | Fialový weekly, jantárový 5h, priemer okolo 140 px. | Východisko pre predlohu, nie finálne schválenie. |
| P-003 | Štítok vyčerpaného 5h a „Kopírovať stav“. | Doplnky na posúdenie, nie záväzná V1. |
| P-004 | Presné prahy detekcie, tvar oznámenia a správanie na okraji monitora. | Navrhnúť pred implementáciou príslušnej časti. |
| P-005 | Licencia a finálny verejný názov/branding. | Bez automatického výberu licencie či premenovania repa. |

## Čo je prekonané

Pôvodné tri kruhy s Antigravity nahradilo D-002. Pôvodné krátkodobé číslo v hlavnom kruhu nahradilo D-003. Pôvodný zákaz podpory Codex 5h bol nahradený D-004: nevymýšľať neexistujúci limit, ale podporiť reálny budúci 5h. Pôvodné detaily iba po hoveri nahradilo D-005. Pôvodné vylúčenie notifikácií z V1 nahradilo D-006.

Staršie povolenie na jednorazový živý zber sa počas aktuálneho odkladu nesmie použiť ako súhlas s okamžitým spustením. Najnovší pracovný rozsah je dokumentácia; živé overenie potrebuje nové potvrdenie.

## Ako zapisovať ďalšie doplnenia

Každé nové rozhodnutie má stav, dátum a dopad na rozsah. Potvrdená zmena V1 sa zapíše súčasne do špecifikácie; nápad ide do roadmap. Zachovať zmysel zmeny, nie nekonečné kópie celých promptov. Žiadne budúce želanie sa nesmie pri handoffe tváriť ako hotová funkcia alebo povolený task.
