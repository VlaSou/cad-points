# CadPoints pro AutoCAD LT

CadPoints je lehký AutoLISP balíček pro AutoCAD LT. Umí z vybraných hladin vytahovat body, dávat jim jména, vytvářet `POINT` a popisy ve zvláštních hladinách, exportovat CSV, vložit tabulku do výkresu a volitelně dělat přibližné vrstevnice ze souřadnice Z.

Tato verze je připravená pro Windows a pro podporu AutoCAD LT 2026.1.1 (`W.164.0.0`).

## Verze

```text
0.6.0
```

## Rychlá instalace ve Windows

Nejjednodušší způsob je použít připravený PowerShell skript. Nepotřebuje administrátorská práva.

### Varianta 1: doporučená

1. Stáhni nebo rozbal CadPoints do nějaké složky, například na Plochu nebo do Dokumentů.
2. Otevři PowerShell v kořenové složce projektu.
3. Spusť:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install_windows.ps1
```

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

## Vrstevnice

Generování vrstevnic je jen přibližné. Nejde o skutečný TIN model jako v Civil 3D.

CadPoints:

1. vezme segmenty z podporované geometrie,
2. najde průsečíky s vybranými hladinami Z,
3. seskupí body podle výšky,
4. zkusí vytvořit `SPLINE`,
5. když to nejde, použije `LWPOLYLINE`.

To je vhodné pro jednoduché vstupy, ale ne pro přesný geodetický model terénu.

## Testovací soubory

V balíčku jsou testovací soubory ve složce:

```text
Contents\Test
```

Obsah:

```text
example_test.dxf
create_example_test.scr
cadpoints_smoke_test.lsp
README_TEST.md
```

## Ruční ribbon / CUI

Balíček obsahuje ikony a menu, ale hotový `.cuix` se negeneruje.

Pro běžné použití stačí vytvořit panel v AutoCAD LT přes `CUI` a přidat příkazy:

```text
^C^C_CPEXPORT
^C^C_CPSETTINGS
^C^C_CPHELP
```

## Rychlé řešení problémů

- Pokud AutoCAD LT nic nenačítá, zkontroluj cestu `%APPDATA%\Autodesk\ApplicationPlugins`.
- Pokud `CPEXPORT` nic nenajde, zkontroluj nastavení zdrojových hladin v `CPSETTINGS`.
- Pokud jsou popisy nebo tabulka moc velké nebo malé, zkontroluj `drawing scale` a `table scale`.
- Pokud se vrstvy nebo tabulka objeví špatně, zkontroluj, že výkres opravdu pracuje v milimetrech.
