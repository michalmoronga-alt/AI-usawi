# Verejné repo, popis a komunitné vydanie

Aktualizované: 2026-09-11. Repo `michalmoronga-alt/AI-usawi` je verejné podľa nastavenia overeného pri založení dokumentácie. Viditeľnosť nemeníme. Projekt je zatiaľ návrh, nie hotové vydanie.

## Krátky popis repa

Navrhnutý text pre GitHub About:

> Pripravovaný Rainmeter widget pre limity Codex a Claude: sústredné prstence, prehľad resetov a lokálne upozornenia na nečakané obnovenie kapacity.

Popis je už obsiahnutý v README. **Nastavenie samotného poľa GitHub About zatiaľ nebolo vykonané**: dostupné akcie použitého GitHub konektora umožňujú zápis súborov, nie úpravu metadát repozitára. Nezamieňať zmenu README za zmenu About.

Neskôr ho možno nastaviť cez About v GitHub UI alebo existujúce prihlásené GitHub CLI. Nasledujúci príkaz je len pripravený, nebol spustený:

```powershell
gh repo edit michalmoronga-alt/AI-usawi --description "Pripravovaný Rainmeter widget pre limity Codex a Claude: sústredné prstence, prehľad resetov a lokálne upozornenia na nečakané obnovenie kapacity."
```

Príkaz nemení viditeľnosť, názov ani pravidlá repozitára. Jeho použitie predpokladá vhodné existujúce oprávnenia. Zdroj: [oficiálna dokumentácia gh repo edit](https://cli.github.com/manual/gh_repo_edit), overená 2026-09-11.

Možné budúce topics: `rainmeter`, `windows`, `desktop-widget`, `codex`, `claude`, `usage-monitor`. Topics zatiaľ neboli nastavované.

## Pozicionovanie – návrh

Jednoduché zobrazenie spotreby viacerých AI predplatných na Windows ploche, ktoré nevyžaduje otvorený dashboard. Pridanou hodnotou nemá byť počet integrácií, ale čitateľný dvojprstenec, pravdivé stavy a užitočné upozornenia.

Nesľubovať vyššie limity, obchádzanie obmedzení, presné zachytenie každého resetu ani oficiálnu podporu poskytovateľov. Projekt nie je náhrada Win-CodexBaru ani všeobecný monitor všetkej spotreby ChatGPT.

## Pred zdieľaním v skupinách

- [ ] Skutočný funkčný prototyp, nie iba dizajnová vizualizácia.
- [ ] Overený spôsob zberu a zrozumiteľné obmedzenia čerstvosti.
- [ ] Aspoň jedno ďalšie testovacie prostredie mimo pôvodného PC; žiadne hardcoded osobné cesty.
- [ ] Schválený spôsob inštalácie, odinštalácie a aktualizácie bez straty nastavení.
- [ ] Anonymné screenshoty/GIF; všetky fiktívne údaje označené DEMO.
- [ ] Jasná verzia závislostí a overená kompatibilita; neponúkať neotestované verzie ako podporované.
- [ ] Vybraná licencia projektu a skontrolované podmienky distribúcie prípadných prevzatých častí.
- [ ] Stručné README, návod a šablóna hlásenia problému bez citlivých údajov.
- [ ] Anglická dokumentácia, ak bude cieľom aj medzinárodná komunita.
- [ ] Samostatné označenie hotových funkcií a roadmap; Reset Spy a mobil nesmú vyzerať ako už dostupné.

Jednoduchý `.rmskin` balík je návrh na komunitné vydanie, nie aktuálny artefakt. Win-CodexBar a jeho prihlasovacie údaje sa automaticky nepribaľujú. Binárky, podpisovanie a prípadné varovania Windows treba posúdiť až podľa skutočného balenia.

## Licencia a cudzie podklady

Licencia je **otvorené rozhodnutie majiteľa**. Verejné GitHub repo samo nenahrádza výber licencie na používanie, úpravy a distribúciu. Žiadny súbor LICENSE ani tvrdenie „MIT licensed“ nebolo automaticky pridané. Pred komunitným vydaním zvoliť vhodný režim a skontrolovať závislosti.

Zdroj: [GitHub – Licensing a repository](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository), overený 2026-09-11.

Referenčný obrázok z rozhovoru je iba dizajnová inšpirácia. Nie je súčasťou verejného repa; nevytvára sa predpoklad, že môžeme redistribuovať jeho cudzie prvky. Budúce vizuálne podklady vytvoriť samostatne. Fontové súbory, cudzie logá a internú dokumentáciu iných projektov nepribaľovať.

## Primeraná údržba

Verejné repo neznamená záväzok podporovať každú službu a každé predplatné. Základ musí fungovať bez budúceho X feedu, mobilných kľúčov a proprietárneho pracovného procesu. Funkciu pre jediného poskytovateľa, lokalizáciu a presety najprv vyhodnotiť ako samostatné malé rozšírenia, nie automaticky zväčšiť V1.
