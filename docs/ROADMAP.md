# Roadmap a zásobník nápadov

Aktualizované: 2026-09-11. **Zápis nápadu nie je súhlas s jeho implementáciou.** Číslovanie je identifikátor, nie záväzný termín alebo prísľub vydania.

## Teraz: uzavretie vízie

Dokumentácia, vizuálne rozhodnutia a predloha. Potom výslovne povolené DEMO bez účtov. Živé overenie sa odkladá, kým majiteľ dovolí zásah do zberu a existujúcich prihlásení. Presný postup je v [implementačnom pláne](IMPLEMENTATION_PLAN.md).

## V1: funkčný lokálny základ

Dva poskytovatelia; weekly vonkajší a voliteľný 5h vnútorný prstenec; weekly percento v strede; detail po kliknutí; pravdivé chybové stavy; lokálne upozornenia na nečakané poklesy weekly; minimálny stav a deduplikácia. Bez sociálnych sietí a bez mobilného doručovania.

## B-01: používateľské nastavenia vzhľadu

**Zdroj: výslovný nápad majiteľa. Stav: potvrdený budúci plán, mimo V1.**

Panel na zmenu weekly/5h farieb, stopy prstencov, pozadia detailu, priehľadnosti a veľkosti. Prínos: použiteľnosť na rôznych plochách a monitoroch bez ručnej úpravy súborov.

Odporúčaný malý prvý krok: niekoľko ovládacích prvkov, náhľad, uloženie a „Obnoviť predvolené“. Oddeliť priehľadnosť panelu od textu, určiť bezpečné rozsahy mierky a zachovať klikateľnosť. Nastavenia majú prežiť aktualizáciu skinu.

Presety, svetlá téma, zmena hrúbok/rozostupov a import/export témy sú ďalšie nápady, nie automatická súčasť prvej verzie nastavení.

## B-02: Reset Spy – externé oznámenia

**Zdroj: výslovný nápad majiteľa. Stav: prieskum, mimo V1.**

Pôvodným podnetom bol účet X `@thsottiaux`, ktorý majiteľ považuje za dôveryhodný pri oznamovaní resetov. Následne dodal [AI Radar](https://ai.patrikwagner.cz/signaly?typ=resety) a [Codex Reset Monitor](https://codexreset.org/) ako kandidátov na hotový externý zdroj. Cieľom je upozorniť na relevantné zmeny, nie nahrádzať meranie účtu.

**Odporúčaný ďalší prieskum:** najprv preveriť existujúci dohodnutý RSS/JSON výstup; až keď hotové zdroje nevyhovujú, zvažovať ručný zoznam alebo vlastný zber X. Verejný obsah bol prečítaný, ale stabilný dátový kontrakt, podmienky odberu a bezplatné používanie vo verejnom widgete zatiaľ potvrdené nie sú. Žiadny odber nie je implementovaný ani spustený.

Rozlišovať oznámenie, vykonanie, resetový kredit a odhad. Predikcie pravdepodobnosti ďalšieho resetu nepreberať do prvého experimentu. Rovnakú správu cez dva agregátory nepovažovať za dve nezávislé potvrdenia ani dva resety; plán a následné potvrdenie môžu aktualizovať jednu udalosť. Výpadok externého zdroja nesmie ovplyvniť kruhy a lokálnu detekciu.

Podrobné pozorovania, obmedzenia overenia, hranice dôvery a varianty získania dát sú v [RESET_SPY.md](RESET_SPY.md). Primárny/záložný zdroj nie je vybraný. Žiadny zber X ani externých resetových feedov vo V1.

## B-03: mobilné doručovanie udalostí

**Zdroj: výslovný nápad majiteľa. Stav: budúci plán.**

Možnosti: Telegram alebo ntfy; e-mail iba ak sa ukáže ako vhodnejší. Najprv stabilná lokálna detekcia, potom jeden voliteľný odosielateľ bez frameworku pre desiatky služieb. Opt-in, lokálne chránené nastavenia, bez tokenov v balíku, kontrola duplicitných správ.

Mobilné doručenie neznamená monitoring počas spánku alebo vypnutia PC. Neprisľubovať nepretržitú prevádzku bez osobitnej architektúry.

## B-04: komunitné vydanie

**Zdroj: výslovný zámer majiteľa. Stav: verejné repo teraz; propagácia až neskôr.**

Cieľová skupina: používatelia Windows/Rainmeter s viacerými AI predplatnými. Navrhovaná hodnota je čitateľnosť na ploche, dvojité prstence a zmysluplné oznámenia bez povinného vlastného účtu v novej službe.

Pred zdieľaním: funkčný prototyp, anonymné screenshoty, jednoduchá inštalácia, viditeľné obmedzenia, vybraná licencia, otestovanie na ďalšom PC a aspoň ďalšej kombinácii dostupných kvót. Podrobný checklist: [PUBLIC_RELEASE.md](PUBLIC_RELEASE.md). Anglický README a jednoduché hlásenie chýb sú návrhy pre komunitné vydanie, nie dnešný implementačný záväzok.

## B-05: malé doplnky na posúdenie

**Zdroj: návrhy asistenta, nie osobitne schválené požiadavky.**

„Kopírovať stav“ pre ručné odovzdanie agentovi; drobný štítok pri vyčerpanej 5h kvóte; režim iba jedného poskytovateľa pre komunitných používateľov. Posúdiť až po uzavretí hlavného vzhľadu. Žiadne tiché rozšírenie V1.

## Vedome neplánované vo V1

Antigravity vrátane jeho zberu a placeholderov, automatické prepínanie modelov, Hermes/Noxun Engine integrácia, štatistická databáza, predikcia spotreby, komplexný pluginový systém, povinné platené API a vlastný verejný server. Budúce zvažovanie nie je automatická roadmap položka ani záväzok.
