# AI-usawi

**Natívny Rainmeter widget: weekly a voliteľná 5h kvóta Codex a Claude, explicitný LIVE alebo offline DEMO režim.**

> **Stav: PARTIAL — živý Codex funguje, Claude blokuje existujúce prihlásenie aj vo Win-CodexBare.** Offline DEMO zostal zachovaný. Aktuálne výsledky, mapovanie a obmedzenia sú v [LIVE_CHECKPOINT.md](docs/LIVE_CHECKPOINT.md); pôvodný DEMO krok v [DEMO_CHECKPOINT.md](docs/DEMO_CHECKPOINT.md). Kompletná V1 s detekciou resetov ešte nie je hotová.

Vonkajší fialový prstenec a veľké číslo vždy ukazujú **spotrebované weekly percento**. Jantárový vnútorný prstenec sa riadi stavom 5h kvóty. Chýbajúci weekly údaj je „—“. Nula, ktorú upstream nedokáže odlíšiť od chýbajúceho údaja, sa nepotvrdzuje ako skutočná nulová spotreba. Reset odpočítava lokálne a nikdy sám nevynuluje percentá.

## Živé napojenie

Na overenom PC je aktuálne načítaný režim **LIVE**. Používa existujúci Win-CodexBar 0.56.8, iba cielené OAuth exporty Codex/Claude. Žiadny server, nový login alebo testovacie AI prompty. Export môže vykonávať bežné zápisy a refresh existujúceho prihlásenia vo Win-CodexBare.

```powershell
# Návrat do LIVE s už overeným lokálnym pripojením
.\tools\Deploy-Demo.ps1 -Mode LIVE -Load
# Výslovný offline režim, bez zberu
.\tools\Deploy-Demo.ps1 -Mode DEMO -Load
```

Prvé LIVE nasadenie vyžaduje `-CliPath` a `-VerifiedCliSha256` po kontrole konkrétnej binárky a lokálneho helpu. Nepoužívaj vymyslenú cestu/hash. Zmenená binárka sa odmietne, kým sa znova neoverí kontrakt. `-ClaudeSource oauth` je predvolený; `web` má iné požiadavky na existujúce prihlásenie a vyžaduje overenie. Automatický ani CLI fallback nie je zapnutý.

Nasadený priečinok **NOXUN AI Usage DEMO / DEMO.ini** má historický názov, aby sa nemuseli obnovovať ostatné skiny. Viditeľný režim je vždy jasný. `@Resources/State/connection.json`, snapshot a zámok zostávajú iba lokálne. Do repa sa nekopírujú prihlasovacie údaje. Pre Claude musí fungovať rovnaký OAuth zdroj, ktorý používa CLI; oprava iba webových cookies aplikácie nemusí opraviť OAuth. Po oprave používateľom sa zber zopakuje podľa aktuálneho intervalu/backoffu.

## Spustenie DEMO

Potrebuješ už nainštalovaný a spustený Rainmeter na Windows. Žiadne nové balíky, fonty alebo doplnky. Zdrojový clone nechaj mimo priečinka aktívnych skinov.

V PowerShelli z koreňa repa:

~~~powershell
.\tools\Test-Demo.ps1
.\tools\Deploy-Demo.ps1 -Load
~~~

Nasadenie číta SkinPath z existujúcej konfigurácie Rainmetera a vytvorí iba **NOXUN AI Usage DEMO**. Pri inom umiestnení konfigurácie zadaj parameter -RainmeterIni so skutočnou cestou. Parameter -RainmeterExe určuje existujúcu binárku, ak sa nedá zistiť z procesu. Skripty nemenia execution policy.

**Úplne nový priečinok:** Rainmeter 4.5.26 môže vyžadovať obnovenie zoznamu skinov. Skript zámerne nespúšťa „Refresh All“, pretože obnovuje aj ostatné skiny. Po vlastnom rozhodnutí použi túto funkciu v Rainmeteri, potom načítaj **NOXUN AI Usage DEMO / DEMO.ini**. Ďalšie aktualizácie používajú iba refresh konkrétneho DEMO. Neznámy existujúci obsah a lokálne úpravy sa neprepisujú; najprv ich skontroluj a zálohuj.

## Ovládanie

- **LIVE/DEMO · presuň** hore: presunie oba kruhy spolu.
- **Kruh alebo spodná úchytka:** otvorí detail; druhá služba prepne obsah, aktívna ho zavrie. Krížik tiež zatvára. Odchod kurzora nič nezatvára.
- **‹ / ›:** predchádzajúci/nasledujúci syntetický scenár. Scenáre sa samy nemenia.
- **100 % / 150 %** hore: prepne mierku.
- **TEST:** nová označená udalosť pre vybranú službu (inak Codex). **Potvrdiť** odstráni kartu a neprečítanú značku. Karta nikdy neznamená detekciu skutočného resetu.

Je dostupných 14 scenárov: bežný stav 65/42 %, dostupný Codex 5h, nulový Codex 5h, geometria 0/25/50/100 %, chýbajúci weekly pri existujúcom 5h, staré hodnoty/chyba služby, neistá dostupnosť 5h, neznámy/uplynutý reset, reset o 5 sekúnd, TEST udalosť a neplatný vstup.

Farby, priemer, hrúbky, font, rozostupy a predvolená mierka sú v [Settings.inc](skin/@Resources/Settings.inc). Po úprave zdroja znovu nasaď požadovaný režim. Interaktívna zmena mierky je dočasná. LIVE používa `RefreshSeconds=180` (180–3600 s) a `TimeoutSeconds=30` na službu (5–35 s). Chyby predlžujú interval iba zlyhávajúcej služby až na hodinu. DEMO nezbiera údaje. Odpočet a kliky sú lokálne; šípky scenárov a TEST fungujú výlučne v DEMO.

## Testy

`tools/Test-Live.ps1` spúšťa anonymné dátové a procesné kontroly. Pri načítanom LIVE spusti `tools/Test-NativeLive.ps1`; overí export proti reálnym metrom a izoláciu od DEMO. Nasledujúce ovládacie testy patria iba k načítanému DEMO.

Po načítaní spusti `tools/Test-NativeDemo.ps1`. Počas testu neklikaj do widgetu: prejde 14 scenárov, oba detaily, mierky, okraj obrazovky, TEST a reset. Na konci vráti bežný scenár. Nenahrádza fyzické klikanie a vizuálny smoke test.

~~~powershell
.\tools\Send-DemoCommand.ps1 -Action Lua -LuaCommand 'RunTests()'
~~~

Výsledok Lua testov je v nasadenej kópii v priečinku **@Resources/State/test-results.txt**. Dá sa zahrnúť do kontrol cez parameter -NativeReport skriptu Test-Demo.ps1. Používa sa priamo Lua 5.1 v Rainmeteri, bez testovacieho frameworku. `CaptureState()` v LIVE obsahuje skutočné usage hodnoty a nesmie sa publikovať. Natívne interakcie a snímky sa overujú osobitne; výsledky sú v checkpointe.

## Vypnutie a odstránenie

Len vypnúť: kontextová ponuka vlastného skinu → Unload / Uvoľniť skin, alebo:

~~~powershell
.\tools\Send-DemoCommand.ps1 -Action Deactivate
~~~

Odpojiť a odstrániť iba vlastnú nasadenú kópiu:

~~~powershell
.\tools\Remove-Demo.ps1
~~~

Repo zostane zachované. Odstránenie počká na prípadný prebiehajúci zber a odstráni iba vlastnú kópiu vrátane jej lokálneho stavu. Odmietne neznáme a zmenené súbory, aby ich bolo možné najprv zálohovať. Parameter -FilesOnly je pre izolované testy alebo už odpojenú kópiu; neposiela príkazy Rainmeteru. Skripty nikdy nereštartujú hlavný Rainmeter pri chybe. Záloha pred prvým LIVE nasadením je lokálne v `.local/backups/`.

## Dokumentácia a ďalší rozsah

[V1 špecifikácia](docs/V1_SPEC.md) · [Dizajn](docs/DESIGN_BRIEF.md) · [Rozhodnutia](docs/DECISIONS.md) · [Implementačný plán](docs/IMPLEMENTATION_PLAN.md) · [Roadmap](docs/ROADMAP.md) · [Reset Spy](docs/RESET_SPY.md) · [Verejné vydanie](docs/PUBLIC_RELEASE.md) · [Bezpečnosť](SECURITY.md) · [AGENTS](AGENTS.md)

Skutočná detekcia resetov, mobilné oznámenia, Reset Spy a editor tém čakajú na samostatné zadanie. Toto nie je všeobecný provider framework.

AI-usawi je nezávislý komunitný projekt, nie oficiálny produkt OpenAI, Anthropic alebo Rainmeter. Externý dátový zdroj je [Win-CodexBar](https://github.com/nesszer/Win-CodexBar); jeho kód ani binárky sa nedistribuujú. Licenciu zatiaľ majiteľ nevybral. Repo je verejné, ale tento krok nepovoľuje push ani vydanie.
