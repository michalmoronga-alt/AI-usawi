# Vizuálny brief

Aktualizované: 2026-09-11. **Vizuálny smer z `design-reference.png` v handoffe PROMPT 2 je schválený.** Predloha bola pri implementácii otvorená; nie je dôkazom funkčného skinu. Natívne dôkazy a obmedzenia sú v [DEMO checkpointe](DEMO_CHECKPOINT.md).

## Potvrdené zadanie

Referenciou z rozhovoru je dvojica sústredných oblúkov s jemnou nevyplnenou stopou a veľkým percentom uprostred. Preberáme princíp, nie cudzí dizajn kartičky, texty, logo alebo kompletný screenshot. Referenčný screenshot zatiaľ nepublikujeme v repozitári.

Dva poskytovatelia: Codex a Claude. Vonkajší prstenec je weekly a mierne širší; vnútorný je tenší 5h. Codex bez reálnej 5h kvóty nemá vnútorný prstenec. Veľké percento vo vnútri je vždy weekly a spolu s ním je vo vnútri aj názov poskytovateľa. Detaily sa otvárajú kliknutím na spodnú hranu.

## Schválený smer a zvolené DEMO tokeny

| Prvok | Východiskový návrh |
| --- | --- |
| Usporiadanie | Codex vľavo, Claude vpravo; jeden spoločne presúvateľný widget. |
| Detail | Jeden tmavý panel pod dvojicou, prepínaný výberom poskytovateľa. |
| Priemer | 140 px pri mierke 1.0; medzi kruhmi 48 px. |
| Hrúbky | Vonkajšia 8 px, vnútorná 5 px. Vnútorný vonkajší okraj je odsadený 15 px. |
| Weekly farba | Fialová `#A967F6`, pri vysokom využití sa nemení na červenú. |
| 5h farba | Jantárová `#F5B05C`. |
| Text | Svetlé percento, čitateľný systémový font, nenápadné doplňujúce štítky. |
| Oblúky | Od hornej pozície, v smere hodinových ručičiek, zaoblené konce. |
| Podklad | Transparentná oblasť kruhov; čitateľný tmavý podklad detailu. |
| Pohyb | Bez pulzovania, neustálej rotácie a rušivých prechodov. |

Konkrétne tokeny zvolené v povolenom DEMO kroku: text `#F4F3FA`, sekundárny text `#9D9EB1`, stopa `#404152` s nižším alfa, detail `#151721` s alfa 252, okraj `#404256`. Segoe UI zo systému, bez fontových súborov. Percento má 25 pt pri mierke 1, detail približne 8–13 pt. Panel má zaoblenie 14 px. Hodnoty sú v `skin/@Resources/Settings.inc`.

Pri zmiznutí vnútorného prstenca sa vonkajší a stred neposúvajú. Konce oblúkov sú zaoblené iba pri 0 < used < 100: nula nemá farebnú bodku a plný kruh nepotrebuje koncovky. Oblúk 65 % má 234°.

## Správanie DEMO

Kliknutie na úchytku otvorí poskytovateľa, druhé kliknutie na rovnakú úchytku ho zavrie; kliknutie na druhú službu prepne obsah. Odchod kurzora panel nezavrie. Klikateľná plocha je väčšia než samotná tenká grafická značka. Zatváranie klávesom alebo kliknutím mimo nie je vo V1 povinné.

Kruhy pri otvorení zachovávajú kotvu. Pri nedostatku miesta dole sa detail otvorí nahor na aktuálnom monitore. Ak sa nezmestí v plnej veľkosti ani na jednu stranu, zmenší sa iba detail do väčšieho voľného priestoru. Zavretie zmenší celé okno; nevzniká priehľadný panelový hitbox. Horný text `DEMO · presuň` je presúvacia oblasť, ostatné ovládanie presúvanie vypína. Skutočné výsledky okrajov, DPI a vzdialeného ovládania patria do checkpointu.

Detail ukáže týždeň, dostupnú 5h kvótu, lokálne časy/odpočty, časovú neistotu, stav zberu a neprečítanú udalosť. Chýbajúci blok nezanechá prázdne rezervované riadky.

## Stavy požadované od DEMO

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
