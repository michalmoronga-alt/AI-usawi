# Vizuálny brief

Aktualizované: 2026-09-11. **Slovný návrh; schválená vizuálna predloha zatiaľ neexistuje.**

## Potvrdené zadanie

Referenciou z rozhovoru je dvojica sústredných oblúkov s jemnou nevyplnenou stopou a veľkým percentom uprostred. Preberáme princíp, nie cudzí dizajn kartičky, texty, logo alebo kompletný screenshot. Referenčný screenshot zatiaľ nepublikujeme v repozitári.

Dva poskytovatelia: Codex a Claude. Vonkajší prstenec je weekly a mierne širší; vnútorný je tenší 5h. Codex bez reálnej 5h kvóty nemá vnútorný prstenec. Veľké percento vo vnútri je vždy weekly a spolu s ním je vo vnútri aj názov poskytovateľa. Detaily sa otvárajú kliknutím na spodnú hranu.

## Návrhy na schválenie, nie finálne tokeny dizajnu

| Prvok | Východiskový návrh |
| --- | --- |
| Usporiadanie | Codex vľavo, Claude vpravo; jeden spoločne presúvateľný widget. |
| Detail | Jeden tmavý panel pod dvojicou, prepínaný výberom poskytovateľa. |
| Priemer | Približne 140 px pri mierke 1.0. |
| Hrúbky | Vonkajšia približne 8 px, vnútorná 5 px; vzdušná medzera. |
| Weekly farba | Fialová s rovnakým významom pri oboch službách. |
| 5h farba | Tlmená jantárová s rovnakým významom pri oboch službách. |
| Text | Svetlé percento, čitateľný systémový font, nenápadné doplňujúce štítky. |
| Oblúky | Od hornej pozície, v smere hodinových ručičiek, zaoblené konce. |
| Podklad | Transparentná oblasť kruhov; čitateľný tmavý podklad detailu. |
| Pohyb | Bez pulzovania, neustálej rotácie a rušivých prechodov. |

Tieto farby a rozmery sa nemajú vyhlásiť za schválené iba preto, že sú v dokumente. Pri zmiznutí vnútorného prstenca sa vonkajší a stred nemajú presúvať; návrh zachováva zarovnanie oboch poskytovateľov.

## Návrh správania detailu

Kliknutie na úchytku otvorí poskytovateľa, druhé kliknutie na rovnakú úchytku ho zavrie; kliknutie na druhú službu prepne obsah. Odchod kurzora panel nezavrie. Klikateľná plocha je väčšia než samotná tenká grafická značka. Zatváranie klávesom alebo kliknutím mimo nie je vo V1 povinné.

Kruhy pri otvorení zostávajú na mieste. Treba rozhodnúť, či sa pri spodnom okraji monitora detail otvorí nahor alebo sa použije iné jednoduché ohraničenie. Nepriehľadné ani neviditeľné plochy nesmú zbytočne zachytávať kliky na plochu. Vzdialené ovládanie, kliknutie a presúvanie sa otestujú oddelene.

Detail ukáže týždeň, dostupnú 5h kvótu, lokálne časy/odpočty, časovú neistotu, stav zberu a neprečítanú udalosť. Chýbajúci blok nezanechá prázdne rezervované riadky.

## Stavy pre budúcu vizuálnu predlohu

| Stav | Čo musí predloha ukázať |
| --- | --- |
| Bežný stav | Codex iba weekly; Claude weekly a 5h. |
| Codex s dostupným 5h | Vnútorný kruh bez rozbitia zarovnania. |
| Otvorený detail | Obe služby s rozdielnym počtom dostupných riadkov. |
| Nulová a plná kvóta | 0 % nie je chýbajúci údaj; 100 % sa korektne uzavrie. |
| Weekly chýba, 5h existuje | Veľké `—`, nikdy číslo z náhradnej kvóty. |
| Staré údaje / chyba | Stlmenie a stavový indikátor, nie falošných 0 %. |
| Nová udalosť | Nenápadná trvalá značka a samostatné oznámenie. |
| Kraj monitora a mierka | Bez odrezaného detailu a rozbitých popisov. |

Všetky čísla na predlohách majú byť označené DEMO. Dodávka pre agenta má obsahovať prehľad stavov, rozmery a rozostupy, farebné tokeny, typografiu a klikateľné oblasti; nie iba jeden náladový obrázok. Finálne systémové fonty sa nebudú distribuovať ako súbory.

## Voliteľné návrhy, zatiaľ mimo záväznej V1

Malý štítok „5h vyčerpané“, ktorý nemení weekly číslo; tlačidlo „Kopírovať stav“; kompaktná legenda v detaile. Prínos treba posúdiť pri vizuálnom doladení, nie ich automaticky implementovať.

## Nastavenia vzhľadu neskôr

Používateľský panel farieb, priehľadnosti a veľkosti patrí do [roadmap](ROADMAP.md). Vo V1 stačí udržať hodnoty oddelené od dátovej logiky. Zmena farby nesmie meniť význam prstenca a priehľadnosť nesmie nechtiac znečitateľniť text alebo stav chyby.
