# AI-usawi

**Pripravovaný Rainmeter widget pre limity Codex a Claude: sústredné prstence, prehľad resetov a lokálne upozornenia na nečakané obnovenie kapacity.**

> **Stav: návrh a dokumentácia, nie funkčná aplikácia.** Implementácia, živé napojenie a inštalačný balík ešte nie sú hotové. Repo je verejné; licencia zatiaľ nebola vybraná.

Cieľom je vidieť využitie predplatných priamo na pracovnej ploche bez otvárania ďalšieho dashboardu. Projekt vznikol z návrhu „NOXUN AI Usage“, ale má byť samostatný a použiteľný aj mimo pôvodného pracovného prostredia.

## Plánovaná V1

| Oblasť | Dohodnutý smer |
| --- | --- |
| Poskytovatelia | Iba **Codex a Claude**. Antigravity je úplne mimo V1. |
| Vonkajší prstenec | Mierne širší; **spotrebovaný týždenný limit**. |
| Vnútorný prstenec | Tenší; reálna **5-hodinová kvóta**, pokiaľ existuje. Aj pri Codexe je podpora podmienená dátami, nie názvom plánu. |
| Stred | Veľké týždenné percento a názov poskytovateľa. |
| Detaily | Otvoria sa kliknutím na spodnú hranu/úchytku. |
| Upozornenia | Lokálne PC oznámenia na významné nečakané poklesy vykázaného weekly využitia. |
| Dátový zdroj | Plánované využitie existujúceho Win-CodexBaru; bez vlastného prihlasovania k AI účtom. |
| Prevádzka | Lokálna, bez AI promptov na kontrolu limitu a bez povinnej integrácie s JaxCore. |

**0 % znamená nič spotrebované; 100 % znamená vyčerpaný limit. Neznámy údaj nie je nula.** Oznámenie o poklese využitia nie je automaticky dôkaz resetu.

Presné farby, rozmery a spoločný rozbaľovací panel sú zatiaľ návrhy na vizuálne doladenie, nie schválený finálny dizajn.

## Dokumentácia

| Dokument | Účel |
| --- | --- |
| [V1 – záväzný rozsah](docs/V1_SPEC.md) | Funkcie, dátové pravidlá, lokálne upozornenia a hranice prvej verzie. |
| [Vizuálny brief](docs/DESIGN_BRIEF.md) | Prstence, interakcie, stavy a otvorené dizajnové rozhodnutia. |
| [Rozhodnutia](docs/DECISIONS.md) | Čo je potvrdené, čo je návrh a čo nahradilo staršie zadania. |
| [Ďalšie plány](docs/ROADMAP.md) | Nastavenia vzhľadu, mobilné oznámenia, Reset Spy a komunitné vydanie. |
| [Reset Spy](docs/RESET_SPY.md) | Budúci prieskum oznámení o resetoch; striktne oddelený od merania účtu. |
| [Postup implementácie](docs/IMPLEMENTATION_PLAN.md) | Najprv vizuálna predloha a DEMO, potom samostatne schválené živé napojenie. |
| [Verejné vydanie a nastavenie repa](docs/PUBLIC_RELEASE.md) | Popis repa, distribúcia, licencia a kontrola pred zdieľaním. |
| [Pravidlá pre agentov](AGENTS.md) | Rozsah zmien, bezpečnosť a spôsob práce s dokumentáciou. |
| [Bezpečnostné poznámky](SECURITY.md) | Čo neposielať do verejného repa a hlásení chýb. |

## Ďalšie plány, nie súčasné funkcie

**Nastavenia vzhľadu:** farby, priehľadnosť, veľkosť a neskôr presety. Vo V1 má byť iba jednoduchý základ s prehľadne oddelenými hodnotami, nie editor tém.

**Reset Spy:** samostatná informačná vrstva s odkazmi na dôveryhodné oznámenia o plánovaných resetoch. Správa na sociálnej sieti nebude meniť namerané percentá ani potvrdený stav účtu.

**Mobilné oznámenia:** neskôr napríklad Telegram alebo ntfy; bez povinnej cloudovej služby vo V1.

**Komunitné vydanie:** najprv spoľahlivá verzia a jednoduchá inštalácia, potom zdieľanie v skupinách. Verejné repo samo osebe neznamená, že je produkt hotový.

## Aktuálna hranica práce

Teraz sa dopĺňa dokumentácia a dolaďuje vízia. Bez ďalšieho súhlasu sa nespúšťa implementácia, export usage, refresh AI prihlásení ani inštalácia skinu. Staršie prompty sa nemajú spúšťať bez zosúladenia s aktuálnou špecifikáciou.

V repozitári nebudú reálne snapshoty účtov, prihlasovacie údaje, súkromné cesty ani osobné screenshoty. Budúce ukážky budú výslovne označené ako DEMO.

## Pôvod a licencia

Plánovaný externý zdroj údajov: [Win-CodexBar](https://github.com/nesszer/Win-CodexBar). Tento projekt nie je jeho fork a zatiaľ nedistribuuje jeho kód ani binárky.

AI-usawi je nezávislý komunitný projekt, nie oficiálny produkt OpenAI, Anthropic alebo Rainmeter. Licenciu zvolí majiteľ pred komunitným vydaním; v tejto fáze nebola automaticky pridaná.
