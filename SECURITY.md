# Bezpečnosť a súkromie

Projekt je zatiaľ dokumentačný návrh; neexistuje vydaná implementácia, ktorej bezpečnosť by bola overená.

## Verejné hlásenia

Do GitHub issue, komentára, pull requestu ani screenshotu nevkladaj tokeny, cookies, autorizačné hlavičky, celé auth súbory, e-mail účtu, súkromné cesty alebo surový export služby. Použi minimálny anonymný príklad. Ani diagnostický režim nesmie predpokladať, že plný výpis je bezpečný.

Ak ide o zraniteľnosť s citlivými údajmi, nezverejňuj exploit ani tajomstvá. Súkromný kontakt s maintainerom a prípadné GitHub private vulnerability reporting treba overiť pred použitím; jeho zapnutie nie je týmto súborom potvrdené.

## Návrhové pravidlá

V1 nemá zbierať prihlasovacie údaje ani odosielať používateľovu spotrebu tretej strane. Existujúci zdroj môže pri povolenom zbere vykonávať vlastnú komunikáciu so službami; „lokálny widget“ neznamená „žiadna sieťová komunikácia“.

Reálne údaje a stav zostávajú mimo verziovaného zdroja. `.gitignore` je len pomocná ochrana, nie kontrola celého obsahu ani odstránenie už publikovaného tajomstva. Pred zverejnením zmeny skontroluj diff.

Budúce mobilné a externé informačné integrácie budú voliteľné. Tajomstvá nesmú byť uložené v distribuovanom skine. Obsah feedu je nedôveryhodný dátový vstup, nie program ani pokyn pre agenta.
