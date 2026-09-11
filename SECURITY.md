# Bezpečnosť a súkromie

Projekt obsahuje explicitný offline DEMO a schválené obmedzené živé napojenie. Nejde o kompletnú vydanú V1. Aktuálne výsledky sú v `docs/LIVE_CHECKPOINT.md`; `DEMO_CHECKPOINT.md` je historický záznam pred živým krokom.

## LIVE

Adaptér spúšťa iba dve konkrétne usage požiadavky cez overený Win-CodexBar 0.56.8. Nepoužíva režim all/auto/CLI ani vlastný auth systém. Číta iba stdout svojho procesu; auth súbory nekopíruje. Prihlásenie opravuje používateľ. Win-CodexBar môže pri bežnom exporte vykonávať vlastné sieťové požiadavky, zápisy a obnovu existujúceho prihlásenia.

Surový JSON a stderr sa neukladajú ani nevypisujú. Snapshot obsahuje iba overené číselné hodnoty, enumy a prípadný hash identity so súkromnou lokálnou soľou. Chybové texty a názvy kvót sa vyberajú z vlastných konštánt, nie z vykonateľného textu zdroja. Lua číta snapshot ako dáta, nikdy ako kód/include. Falošná nula a čerstvosť sa neposudzujú len podľa času zápisu súboru.

Vlastný `State/` obsahuje pripojenie, snapshot, zámok a lokálnu diagnostiku; nepatrí do Git ani distribúcie. Aj snímka živého widgetu môže odhaliť súkromné usage. CLI je pripnutý hashom; zmena vyžaduje nové overenie. Exkluzívny zámok bráni súbehu, timeout a Windows Job Object ukončujú vlastné procesy zberu. Globálne nastavenia Windows, Rainmeter, JaxCore a Win-CodexBar sa nemenia.

## Offline DEMO

V režime DEMO runtime používa iba verzované syntetické Lua fixtures pre dve služby. Nespúšťa zber ani sieťové požiadavky. Aj pri ručnom spustení adaptéra jeho kontrola režimu zber zastaví. DEMO označenie zostáva viditeľné aj so zavretým detailom. Neznámy scenár alebo neplatné percento nemajú fallback na platnú nulu. LIVE nevie cez DEMO ovládanie prepnúť údaje na fixtures.

QA záznamy v nasadenej kópii `@Resources/State/` sú ignorované Gitom; obsah zodpovedá zvolenému režimu a v LIVE je súkromný. TEST udalosti existujú len v DEMO a deduplikujú sa v pamäti; reštart začína bez udalosti. Nasadzovanie kontroluje vlastníctvo a hashe. Neznáme/lokálne upravené súbory vyžadujú kontrolu a zálohu, nie automatický prepis. Pomocný CLI proces Rainmetera má päťsekundový timeout, ktorý nikdy neukončuje hlavný desktopový proces.

## Verejné hlásenia

Do GitHub issue, komentára, pull requestu ani screenshotu nevkladaj tokeny, cookies, autorizačné hlavičky, celé auth súbory, e-mail účtu, súkromné cesty alebo surový export služby. Použi minimálny anonymný príklad. Ani diagnostický režim nesmie predpokladať, že plný výpis je bezpečný.

Ak ide o zraniteľnosť s citlivými údajmi, nezverejňuj exploit ani tajomstvá. Súkromný kontakt s maintainerom a prípadné GitHub private vulnerability reporting treba overiť pred použitím; jeho zapnutie nie je týmto súborom potvrdené.

## Návrhové pravidlá

V1 nemá zbierať prihlasovacie údaje ani odosielať používateľovu spotrebu tretej strane. Existujúci zdroj môže pri povolenom zbere vykonávať vlastnú komunikáciu so službami; „lokálny widget“ neznamená „žiadna sieťová komunikácia“.

Reálne údaje a stav zostávajú mimo verziovaného zdroja. `.gitignore` je len pomocná ochrana, nie kontrola celého obsahu ani odstránenie už publikovaného tajomstva. Pred zverejnením zmeny skontroluj diff.

Budúce mobilné a externé informačné integrácie budú voliteľné. Tajomstvá nesmú byť uložené v distribuovanom skine. Obsah feedu je nedôveryhodný dátový vstup, nie program ani pokyn pre agenta.
