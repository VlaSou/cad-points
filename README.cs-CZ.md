# CadPoints pro AutoCAD LT

CadPoints je lehký AutoLISP balíček pro AutoCAD LT. Umí z vybraných hladin vytahovat body, dávat jim jména, vytvářet `POINT` a popisy ve zvláštních hladinách, exportovat CSV, vložit tabulku do výkresu a volitelně dělat přibližné vrstevnice ze souřadnice Z.

Tato verze je připravená pro Windows a pro podporu AutoCAD LT 2026.1.1 (`W.164.0.0`).

## Verze

```text
0.6.5
```

## Stáhnout

Doporučený Windows instalátor:

- [`CadPoints_LT_Plugin_v0_6_5.exe`](releases/CadPoints_LT_Plugin_v0_6_5.exe)

Záložní release ZIP:

- [`CadPoints_LT_Plugin_v0_6_5.zip`](releases/CadPoints_LT_Plugin_v0_6_5.zip)

## Rychlá instalace ve Windows

Nejjednodušší způsob je použít připravený `.exe` instalátor. Nepotřebuje administrátorská práva.

ZIP fallback pořád obsahuje `install_windows.bat`.
V release ZIPu je tento soubor v kořenové složce vedle `CadPoints.bundle`.
Instalátor záměrně není uvnitř `CadPoints.bundle`, aby bundle zůstal čistý AutoCAD plugin payload.
Ve zdrojovém repozitáři je instalační skript v `scripts\install_windows.bat`.

Složka `dist/` je generovaný payload balíčku pro publikování přes npm/GitHub Packages.
Složka `releases/` je verzovaná v repozitáři a obsahuje autoinstaller ZIP artefakty pro jednotlivé vydané verze.

### Varianta 1: doporučená

1. Stáhni nebo rozbal CadPoints do nějaké složky, například na Plochu nebo do Dokumentů.
2. Dvojklikni na `install_windows.bat` v kořenové složce release ZIPu.

Skript:

- najde balíček `CadPoints.bundle` v `dist\`, `src\` nebo v aktuální složce,
- zkopíruje ho do uživatelské složky AutoCAD pluginů,
- typicky sem:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

4. Zavři a znovu spusť AutoCAD LT.

### Varianta 2: ručně

Pokud nechceš použít skript, zkopíruj celou složku:

```text
CadPoints.bundle
```

do této složky:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

Pak restartuj AutoCAD LT.

Pro vývojářské poznámky, build/release postup a runtime test workflow viz:

```text
docs/development.md
docs/settings.md
.agents/requirements.md
```

Release poznámka: před každým releasem zvedni verzi přes `pnpm version:patch` (nebo `minor`/`major` podle potřeby) a srovnej verzi ve všech verzovaných souborech ještě před spuštěním balíčkovacích skriptů.
Balíčkové příkazy přes pnpm: `pnpm check`, `pnpm package:dist`, `pnpm build:autoinstaller`, `pnpm build:installer-exe`, `pnpm installer-exe:check`, `pnpm release`, `pnpm release:check`.
`pnpm package:dist` připraví payload pro npm/GitHub Packages do `dist/`, `pnpm build:autoinstaller` a `pnpm release` vytvoří ZIP pro autoinstalátor v `releases/`, `pnpm build:installer-exe` vytvoří samostatný Windows `.exe` instalátor.

### Co když se nic nenačte

- zkontroluj, že se kopíruje celá složka `CadPoints.bundle`, ne jen její obsah,
- zkontroluj, že jsi kopíroval do uživatelského `ApplicationPlugins`, ne do nějaké náhodné podsložky,
- pokud už AutoCAD běžel, úplně ho zavři a spusť znovu.

## Co CadPoints dělá

- exportuje body z nakonfigurovaných zdrojových hladin do CSV,
- může vytvořit skutečné entity `POINT`,
- může přidat popisy bodů do samostatné hladiny,
- může vložit tabulku bodů do výkresu,
- může zkusit vytvořit přibližné vrstevnice ze Z souřadnic,
- umí vzorkovat zakřivenou geometrii po délce.

## Příkazy

### `CPSETTINGS`

Hlavní nastavení. V něm se nastavuje například:

- zdrojové hladiny,
- sloupce CSV a tabulky,
- měřítko výkresu,
- měřítko tabulky,
- pojmenování bodů,
- hladina pro body,
- hladina pro popisy,
- zapnutí a vypnutí tabulky,
- výška textu a odsazení tabulky na papíře,
- zapnutí a vypnutí vrstevnic,
- interval vrstevnic,
- vzorkování křivek a jeho krok.

### `CPEXPORT`

Spustí export bodů z nakonfigurovaných hladin.

Při exportu může podle nastavení:

- vytvořit CSV,
- vytvořit `POINT` entity,
- vytvořit popisy bodů,
- vložit tabulku do DWG,
- vygenerovat přibližné vrstevnice.

### `CPHELP`

Krátká nápověda k příkazům a postupu.

## Výchozí hladiny

Generované objekty jsou schválně oddělené od zdrojové geometrie.

```text
CADPOINTS_POINTS
CADPOINTS_POINT_LABELS
CADPOINTS_TABLE
CADPOINTS_CONTOURS
```

## Jednotky a měřítko

CadPoints předpokládá, že výkres je v milimetrech.

```text
1 výkresová jednotka = 1 mm
```

Výchozí hodnoty jsou proto v milimetrech:

```text
krok vzorkování křivek = 1000 mm
interval vrstevnic      = 1000 mm
výška popisu bodu       = 2.5 mm na papíře
výška textu tabulky     = 2.5 mm na papíře
odsazení tabulky        = 50 mm na papíře
```

Používají se dvě různá měřítka:

- `drawing scale` pro popisy bodů a další výkresové poznámky,
- `table scale` pro tabulku bodů.

Povolené hodnoty:

```text
1:25
1:50
1:100
1:500
1:1000
```

## Pojmenování bodů

Jsou dva režimy:

### 1. Podle suffixu hladiny

Když je vzor názvu bodu prázdný, prefix se vezme z poslední části názvu hladiny za `_`.

Příklad:

```text
CP_POINTS_A -> A001, A002, A003
CP_POINTS_B -> B001, B002, B003
```

Číslování je pro každý suffix samostatné.

### 2. Podle vzoru

Když je vzor vyplněný, použije se místo suffixu.

Příklad:

```text
A-SO01-### -> A-SO01-001
P-####     -> P-0001
```

Pravidla:

1. `#` znamená číselný zástupný znak.
2. Počet `#` určuje počet číslic.
3. Když ve vzoru není `#`, přidá se na konec 3místné číslo.

## Sloupce CSV a tabulky

Stejné nastavení se používá pro CSV i pro tabulku ve výkresu.

Formát:

```text
FIELD_ID:Nadpis;FIELD_ID:Nadpis
```

Výchozí konfigurace:

```text
POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

Dostupná pole:

```text
POINT_NAME
POINT_NO
LAYER
ENTITY_TYPE
HANDLE
VERTEX_NO
Y_SJTSK
X_SJTSK
Z
```

## Souřadnice S-JTSK

CadPoints souřadnice nepřepočítává. Předpokládá, že výkres už je ve správné souřadnicové soustavě.

Používaná konvence je:

```text
Y_SJTSK = hodnota X z DWG
X_SJTSK = hodnota Y z DWG
Z       = hodnota Z z DWG
```

## Vzorkování křivek

Zakřivená geometrie se může vzorkovat po délce. Výchozí krok je `1000 mm`, tedy přibližně 1 bod na 1 m.

Podporované entity:

```text
LINE
LWPOLYLINE
POLYLINE
ARC
CIRCLE
ELLIPSE
SPLINE
```

CadPoints vzorkuje zakřivenou geometrii jen jako pomocný výstup. Pokud některá operace v AutoCAD LT není dostupná, balíček má selhat bezpečně a nahlásit typ nebo handle objektu, který nešlo zpracovat.

## Vrstevnice

Generování vrstevnic je jen přibližné. Nejde o skutečný TIN model jako v Civil 3D.

CadPoints:

1. vezme segmenty z podporované geometrie,
2. najde průsečíky s vybranými hladinami Z,
3. seskupí body podle výšky,
4. zkusí vytvořit `SPLINE`,
5. když to nejde, použije `LWPOLYLINE`.

To je vhodné pro jednoduché vstupy, ale ne pro přesný geodetický model terénu.

Správný pracovní postup pro přesné terénní vrstevnice je:

```text
body -> TIN / povrchový model -> extrakce vrstevnic
```

To je vhodnější řešit v Civil 3D, ve full AutoCADu se silnějším API nebo v dedikovaném geodetickém / GIS nástroji.

## Testovací výkres a smoke test

Balíček obsahuje testovací soubory ve složce:

```text
Contents\Test
```

Obsah:

```text
example_test.dxf
create_example_test.scr
cadpoints_smoke_test.lsp
cadpoints_runtime_smoke.scr
cadpoints_runtime_smoke_test.lsp
expected_output.csv
README_TEST.md
```

Nativní `example_test.dwg` se v balíčku negeneruje, protože zápis DWG vyžaduje AutoCAD nebo jiné licencované DWG runtime. Otevři `example_test.dxf` v AutoCAD LT a ulož ho jako `example_test.dwg`, nebo spusť `create_example_test.scr` a ulož vzniklý výkres.

Smoke test pro pojmenování bodů:

```text
APPLOAD CadPoints.bundle\Contents\LISP\cadpoints.lsp
APPLOAD CadPoints.bundle\Contents\Test\cadpoints_smoke_test.lsp
CPTESTNAMES
```

Očekávaný výstup:

```text
CPTESTNAMES OK
```

Runtime smoke test pro celý export:

```text
APPLOAD CadPoints.bundle\Contents\LISP\cadpoints.lsp
APPLOAD CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke_test.lsp
CPFULLSMOKE
```

Pro automatické `/b` spuštění použij:

```text
CadPoints.bundle\Contents\Test\cadpoints_runtime_smoke.scr
```

Pomocný `.scr` soubor před načtením testovacího LISP přidá `CadPoints.bundle\...` do `TRUSTEDPATHS`, takže AutoCAD nemá zobrazovat hlášku o nepodepsaném spustitelném souboru pro testovací helper.

`CPFULLSMOKE` vytvoří deterministický testovací vstup v aktuálním výkresu, vyexportuje body do CSV, vytvoří generované body a popisy, vykreslí tabulku a porovná CSV s:

```text
CadPoints.bundle\Contents\Test\expected_output.csv
```

Tento test je určený pro skutečné ověření v AutoCAD LT. Statické testy repozitáře samy o sobě neověřují chování AutoCAD LISP runtime.

## Ruční ribbon / panel

Hotový binární `.cuix` se nepřikládá. V AutoCAD LT je bezpečnější vytvořit panel ručně přes vestavěný editor `CUI`, protože AutoCAD ukládá data pracovního prostoru přímo do vlastních CUIx souborů.

Balíček obsahuje připravené ikony a starší menu šablonu:

```text
Contents\Menu\cadpoints.mnu
Contents\Resources\cp-export.bmp
Contents\Resources\cp-settings.bmp
Contents\Resources\cp-help.bmp
Contents\Resources\cp-export-16.bmp
Contents\Resources\cp-settings-16.bmp
Contents\Resources\cp-help-16.bmp
```

### Vytvoření panelu ručně

1. Spusť AutoCAD LT.
2. Spusť příkaz:

```text
CUI
```

3. V levém stromu rozbal:

```text
Ribbon > Panels
```

4. Vytvoř nový panel:

```text
CadPoints
```

5. V seznamu příkazů vytvoř tyto tři vlastní příkazy.

### Příkaz: CadPoints Export

Název:

```text
CadPoints Export
```

Makro:

```text
^C^C_CPEXPORT
```

Velká ikona:

```text
Contents\Resources\cp-export.bmp
```

Malá ikona:

```text
Contents\Resources\cp-export-16.bmp
```

### Příkaz: CadPoints Settings

Název:

```text
CadPoints Settings
```

Makro:

```text
^C^C_CPSETTINGS
```

Velká ikona:

```text
Contents\Resources\cp-settings.bmp
```

Malá ikona:

```text
Contents\Resources\cp-settings-16.bmp
```

### Příkaz: CadPoints Help

Název:

```text
CadPoints Help
```

Makro:

```text
^C^C_CPHELP
```

Velká ikona:

```text
Contents\Resources\cp-help.bmp
```

Malá ikona:

```text
Contents\Resources\cp-help-16.bmp
```

6. Přetáhni všechny tři příkazy do nového panelu `CadPoints`.
7. Přetáhni panel `CadPoints` na existující kartu ribbonu, například:

```text
Ribbon > Tabs > Home - 2D
```

8. Klikni na `Apply` a potom `OK`.

## Alternativní import toolbaru

Soubor níže lze použít jako výchozí bod pro starší menu / toolbar:

```text
Contents\Menu\cadpoints.mnu
```

Podle verze AutoCAD LT a nastavení profilu ho můžeš importovat přes CUI transfer nástroje nebo převést na částečný customizační soubor a načíst ho přes:

```text
CUILOAD
```

Pro denní použití je ruční nastavení ribbonu přes `CUI` předvídatelnější.

## Řešení problémů

- Pokud se bundle nenačítá automaticky, ověř, že `CadPoints.bundle` leží v `%APPDATA%\Autodesk\ApplicationPlugins` a AutoCAD LT restartuj.
- Pokud `APPAUTOLOADER` ukazuje `0` balíků, AutoCAD LT bundle v důvěryhodné cestě nevidí.
- Pokud `CPEXPORT` nic nenajde, zkontroluj zdrojové hladiny v `CPSETTINGS` a ověř, že výkres skutečně obsahuje odpovídající geometrii.
- Pokud jsou popisy nebo tabulka moc velké nebo malé, zkontroluj `drawing scale` a `table scale`; jsou to dvě různé volby.
- Pokud vzorkování křivek selže na konkrétním objektu, může AutoCAD LT pro daný typ neposkytnout potřebné curve funkce. Balíček by měl typ nebo handle nahlásit a pokračovat dál.
- Pokud vrstvy vypadají nepřesně, pamatuj, že CadPoints vytváří jen přibližné vrstevnice ze segmentů, ne skutečný povrch jako v Civil 3D.
- Pokud instalátor zkopíruje soubory správně, ale příkazy se pořád nezobrazí, spusť diagnostický report níže a pošli ho zpátky spolu s výstupem z AutoCAD LT.

### Rychlá diagnostika

V AutoCAD LT použij tyto příkazy, když chceš zjistit, kde je problém:

```text
APPAUTOLOAD
APPAUTOLOADER
APPLOAD
TRUSTEDPATHS
```

Co zkontrolovat:

- `APPAUTOLOAD` by měl běžně umožnit načítání plug-inů. Pokud je `0`, pluginy se nenačítají automaticky.
- `APPAUTOLOADER` ukáže, jestli AutoCAD LT vidí nainstalované pluginy a umí je znovu načíst.
- `APPLOAD` lze použít k ručnímu načtení `CadPoints.bundle\Contents\LISP\cadpoints.lsp` pro jednorázový test.
- `TRUSTEDPATHS` je důležitý, pokud secure mode blokuje bundle nebo LISP soubor.

Když příkazy po restartu pořád nefungují:

1. Ověř, že je bundle v `%APPDATA%\Autodesk\ApplicationPlugins\CadPoints.bundle`.
2. Ověř, že uvnitř té složky je přímo `PackageContents.xml`.
3. Spusť `APPAUTOLOADER` a zkontroluj, jestli se CadPoints zobrazuje.
4. Když je potřeba, načti ručně `CadPoints.bundle\Contents\LISP\cadpoints.lsp` přes `APPLOAD` a otestuj `CPSETTINGS` a `CPEXPORT`.

### Sdílitelný diagnostický report

Spusť z kořene repozitáře:

```text
pnpm diagnostics
```

Nebo ulož výstup do souboru:

```text
py -3 scripts/diagnostics.py > cadpoints-diagnostics.txt
```

Report vypíše:

- informace o repozitáři a prostředí,
- kontrolu shody verzí,
- kontrolu přítomnosti důležitých souborů,
- přehled verzovaných release ZIPů,
- a seznam AutoCAD hodnot, které je vhodné poslat zpátky.

Když žádáš o pomoc, pošli:

- celý diagnostický report,
- výstup `APPAUTOLOAD`, `APPAUTOLOADER`, `SECURELOAD` a `TRUSTEDPATHS`,
- přesný výstup příkazů po `APPLOAD` a `CPEXPORT`.
