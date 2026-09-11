# V1 – funkčná špecifikácia

Aktualizované: 2026-09-11. **Stav: potvrdený produktový rozsah; D-015 povoľuje živé pripojenie po prijatí DEMO. Kompletná V1 vrátane detekcie resetov nie je hotová.** Schválený vizuálny smer a implementačné tokeny sú v [vizuálnom briefe](DESIGN_BRIEF.md); dôkazy o DEMO v [checkpointe](DEMO_CHECKPOINT.md).

## Účel a hranice

Dva nenápadné ukazovatele na Windows ploche umožnia sledovať kvóty Codex a Claude a všimnúť si významné nečakané obnovenie kapacity. Nejde o účtovníctvo tokenov, súhrn všetkých funkcií ChatGPT ani automatický výber modelu.

V1 neobsahuje Antigravity, Reset Spy/X, mobilné doručovanie, editor tém, históriu trendov, multi-account dashboard, cloudový backend ani integráciu s riadením agentov. Antigravity nemá ani placeholder, konfiguráciu, testovaciu implementáciu alebo zber na pozadí.

## V1-01: kvóty a prstence

Každý poskytovateľ má mierne širší vonkajší weekly prstenec. Uprostred je veľké **spotrebované weekly percento** a názov `CODEX` alebo `CLAUDE`. Veľké číslo sa neprepína na inú kvótu.

Tenší vnútorný prstenec zobrazuje skutočnú 5h kvótu. Claude sa navrhuje s oboma prstencami; Codex musí 5h podporovať podmienene. Dostupnosť sa určuje podľa dôveryhodných dát, nie podľa názvu predplatného alebo hardcoded zoznamu plánov. Východiskové očakávanie majiteľa je Codex bez 5h; nie je to univerzálne tvrdenie o všetkých účtoch.

| Stav 5h | Správanie |
| --- | --- |
| Preukázateľne neprítomná kvóta | Vnútorný prstenec sa vôbec nevykreslí. Bez informačného placeholdera. |
| Platná kvóta s 0 % | Jemná stopa prstenca bez farebného vyplnenia. |
| Platná nenulová kvóta | Zodpovedajúci vnútorný oblúk. |
| Predtým známa kvóta, nový zber zlyhal | Posledný údaj zostane označený ako neaktuálny; zlyhanie nepredstiera zánik kvóty. |
| Dostupnosť zatiaľ neoverená | Stav neistoty v detaile; neoznačovať ako „bez limitu“. |

Chýbajúci weekly údaj je `—`, aj keď 5h údaj existuje. Žiadne priemerovanie rôznych kvót alebo náhrada weekly krátkodobým limitom. 0 % = nič spotrebované, 100 % = vyčerpané. Konverzia `remaining` na `used` sa robí iba po overení jednotiek a významu zdroja.

Overenie 0.56.8 odhalilo neoveriteľnú nulu v Codex JSON a Claude web exporte: upstream môže chýbajúcu hodnotu nahradiť 0. Aktuálny adaptér ju nepotvrdí ako nulovú spotrebu; ukáže neznámy údaj alebo označenú poslednú platnú hodnotu. Je to výslovné obmedzenie zdroja, nie zmena významu 0 % ani tichý fallback. Podrobnosti v LIVE_CHECKPOINT.

## V1-02: detail po kliknutí

Kliknutie na spodnú hranu/úchytku otvorí detail. Samotný hover nemá otvárať veľký panel. Detail obsahuje identitu kvóty, využitie, odpočet, lokálny dátum/čas resetu, dostupné ďalšie kvóty, čerstvosť a prípadnú neistotu.

Veľkosť klikateľnej plochy musí byť pohodlná aj pri vzdialenom ovládaní. Detail sa nezatvára pri odchode kurzora. Pre DEMO je potvrdený jeden spoločne presúvateľný widget (Codex vľavo, Claude vpravo) a jeden detail: druhá služba prepne obsah, opätovný klik na aktívnu alebo krížik detail zavrie. Pri nedostatku miesta dole sa otvorí nad kruhmi na tom istom monitore; kruhy si zachovajú kotvu.

Čas uchovávaj so známou časovou zónou; na zobrazenie použi lokálnu zónu OS, nie pevné UTC+2. Neznámy reset sa neodhaduje. Odpočet beží lokálne a nikdy sám nevynuluje využitie.

## V1-03: dátový tok a pravdivosť

Navrhovaná jednoduchá architektúra: povolený export Win-CodexBaru pre dve služby → lokálny adaptér → atomický snapshot → Rainmeter. Živé napojenie používa jednorazový PowerShell adaptér a malý Lua čítač; presný kontrakt a výsledky sú v LIVE_CHECKPOINT.md. JaxCore nie je povinný.

Zber má spoločný cyklus, timeout, ochranu pred prekrytím a spomalenie pri opakovaných chybách. Návrh intervalu je 180 s; musí rešpektovať zistené obmedzenia zdroja. Hover, kreslenie a odpočty nevolajú služby. Bez terminálových okien a bez testovacích AI promptov.

Normalizácia má oddeliť identitu účtu/kvóty, `used`, reset, čas exportu a skutočný čas pozorovania kvóty, ak je známy. Názvy budúcich interných polí nie sú názvy overeného provider API. `primary`, `secondary` ani samotná hodnota 10080 minút bez overenia jej pôvodu nedokazujú weekly.

Nový úspešný export môže obsahovať starší údaj. Ak čerstvosť konkrétnej kvóty nevieme zistiť, nesmie sa prezentovať ako nové meranie. Platná nula, chýbajúci údaj, starý údaj, chyba auth a chyba exportu sú odlišné stavy. Výpadok jednej služby nevymaže druhú.

## V1-04: lokálna detekcia obnovenia kapacity

Upozornenia na PC patria do V1. Sleduje sa významný pokles vykázaného weekly využitia aj bez predchádzajúceho dosiahnutia 100 %. Konkrétne prahy a tolerancie sa pred implementáciou navrhnú a schvália; nie sú pravidlami poskytovateľov.

Porovnávaj tú istú identifikovanú kvótu a účet. Pri zmene účtu, plánu/kapacity, kvóty alebo významu polí založ novú základnú hodnotu. Ak identitu nevieš spoľahlivo porovnať, nepredstieraj bezpečný resetový záver. Prvé meranie nevyvolá resetový alarm.

Kandidát sa podľa možností potvrdí ďalším platným zberom. Opakované čítanie tej istej cache nie je nezávislé potvrdenie. Chyba, null, placeholder alebo neoveriteľná nula nevyvolávajú pozitívne oznámenie.

Rozlišuj významný pokles využitia, pravdepodobný predčasný reset, plánovanú obnovu a neoveriteľnú zmenu. Predčasnosť posudzuj voči **predchádzajúcemu** očakávanému resetu a časovému intervalu meraní. Zmena `reset_at` ani uplynutie odpočtu sama nie je dôkaz.

Pokles môže byť opravou dát, navýšením kapacity alebo uvoľnením limitného okna. Text musí priznať neistotu. Po uspaní/výpadku rozlišuj čas zistenia a neznámy čas samotnej udalosti. Nesľubuj záchyt každého resetu.

V1 má lokálne oznámenie, voliteľný zvuk a pretrvávajúcu značku neprečítanej udalosti. Presný vizuál je v briefingu. Oznámenie nesmie kradnúť fokus; rovnaká udalosť sa neopakuje po každom zbere alebo reštarte. Minimálny perzistentný stav umožní potvrdenie a deduplikáciu, ale nezablokuje neskoršiu novú udalosť. TEST oznámenie nesmie meniť produkčnú detekciu.

**Rozsah DEMO:** iba syntetická TEST karta, značka a potvrdenie. Žiadny detektor, prahy, zvuk, Windows toast registrácia ani tvrdenie o skutočnom resete. Deduplikácia je v pamäti; načítanie skinu začína bez udalosti. Produkčná perzistencia a detekcia naďalej čakajú na osobitné zadanie.

## V1-05: vzhľad a konfigurácia

Vo V1 oddeliť základné vizuálne hodnoty a interval do prehľadných nastavení. Nerobiť grafický editor farieb, presety, import tém ani synchronizáciu. Používateľský panel nastavení je potvrdený **budúci plán**.

## V1-06: bezpečné nasadenie

Repo a nasadený skin majú byť oddelené. Najprv schválený DEMO bez účtov, potom samostatne povolený živý zber, potom inštalácia konkrétnej verzie. Nenastavovať startup, systémové služby, politiku PowerShellu, povinné admin práva ani automatické prihlasovanie.

Počítač a zberač musia bežať. Vypnutie/spánok znamená medzeru v sledovaní. Žiadne tajomstvá alebo reálne snapshoty v Gite. Podrobnosti testov a schvaľovacích krokov sú v [implementačnom pláne](IMPLEMENTATION_PLAN.md).
