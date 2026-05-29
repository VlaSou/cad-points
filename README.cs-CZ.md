# CadPoints pro AutoCAD LT

Balíček AutoLISP kompatibilní s AutoCAD LT pro export pojmenovaných souřadnic bodů z vybraných hladin, generování entit `POINT` a popisů do samostatných hladin, vzorkování zakřivené geometrie, vložení konfigurovatelné tabulky bodů do DWG a volitelné generování přibližných vrstevnic ze souřadnic Z.

## Verze

```text
0.6.0
```

## Podporovaný AutoCAD

- AutoCAD LT 2024+
- nasazení ve Windows pomocí `.bundle` ve složce Autodesk `ApplicationPlugins`

## Instalace

Zkopírujte celou složku:

```text
CadPoints.bundle
```

do jedné z těchto složek:

```text
%APPDATA%\Autodesk\ApplicationPlugins
```

nebo pro všechny uživatele:

```text
%PROGRAMDATA%\Autodesk\ApplicationPlugins
```

Restartujte AutoCAD LT.

## Příkazy

```text
CPSETTINGS
```

Konfiguruje:

- zdrojové hladiny oddělené čárkou, například `CP_POINTS_A,CP_POINTS_B`
- desetinnou přesnost
- sloupce CSV/DWG tabulky
- měřítko výkresu: `1:25`, `1:50`, `1:100`, `1:500` nebo `1:1000`
- vzor názvu bodu, například `A-SO01-###`
- generované entity `POINT` v samostatné hladině
- hladinu bodů, výchozí `CADPOINTS_POINTS`
- popisy bodů v samostatné hladině
- výšku textu popisu na papíře, výchozí `2.5` mm
- hladinu popisů, výchozí `CADPOINTS_POINT_LABELS`
- zda vložit tabulku bodů do výkresu
- měřítko tabulky: `1:25`, `1:50`, `1:100`, `1:500` nebo `1:1000`
- odsazení tabulky na papíře doprava od maximální souřadnice X, výchozí `50` mm na papíře
- výšku textu tabulky na papíře, výchozí `2.5` mm
- hladinu tabulky
- volitelné generování vrstevnic ze souřadnic Z
- interval vrstevnic Z, výchozí `1000` mm
- hladinu vrstevnic
- zda mají být vrstevnice generovány jako entity `SPLINE`, pokud je to možné
- zda má být zakřivená geometrie vzorkována podle délky
- interval vzorkování křivek, výchozí `1000` mm

```text
CPEXPORT
```

Exportuje všechny podporované objekty z nakonfigurovaných hladin do CSV.

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

Přímé objekty `LINE` a přímé polyčáry se exportují podle skutečných koncových bodů / vrcholů. Zakřivená geometrie se při povoleném vzorkování křivek vzorkuje podle délky.

Pokud je povoleno vložení tabulky, příkaz zároveň vloží vykreslenou tabulku bodů do DWG. Tabulka se umístí napravo od nejpravějšího exportovaného bodu:

```text
souřadnice X vložení tabulky = maximální X exportovaného bodu + nakonfigurované odsazení na papíře * nakonfigurované měřítko tabulky
```

Výchozí umístění tabulky v měřítku `1:100`:

```text
odsazení na papíře = 50 mm
odsazení v modelu = 50 * 100 = 5000 mm
```

Pokud je povoleno generování vrstevnic, příkaz zároveň vygeneruje přibližné vrstevnice do nakonfigurované hladiny vrstevnic.

```text
CPHELP
```

Zobrazí souhrn příkazů.

## Výkresové jednotky a měřítko tabulky

CadPoints předpokládá, že DWG je kresleno v milimetrech. Všechny hodnoty v modelovém prostoru jsou proto považovány za milimetry, pokud nejsou ručně změněny.

Výchozí hodnoty založené na milimetrech:

```text
interval vzorkování křivek = 1000 mm
interval vrstevnic          = 1000 mm
výška popisu bodu           = 250 mm
```

Popisy bodů jsou řízeny měřítkem výkresu. Vložená tabulka je řízena měřítkem tabulky. Obě měřítka používají stejné povolené hodnoty:

```text
1:25
1:50
1:100
1:500
1:1000
```

Interně se výška popisu, výška textu tabulky a pravé odsazení tabulky převádějí z papírových milimetrů na modelové milimetry:

```text
modelová hodnota popisu = hodnota na papíře * měřítko výkresu
modelová hodnota tabulky = hodnota na papíře * měřítko tabulky
```

Příklad pro měřítko `1:100`:

```text
výška textu tabulky na papíře = 2.5 mm
výška textu tabulky v modelu = 250 mm

odsazení tabulky na papíře = 50 mm
odsazení tabulky v modelu = 5000 mm
```

## Pojmenování bodů a generované hladiny bodů

CadPoints umí pro každý exportovaný bod generovat skutečné entity `POINT` a textové popisy. Tyto výstupy jsou záměrně odděleny od zdrojové geometrie.

Výchozí výstupní hladiny:

```text
generované entity POINT = CADPOINTS_POINTS
generované popisy bodů  = CADPOINTS_POINT_LABELS
```

Pokud je vzor názvu bodu prázdný, prefix bodu se převezme ze suffixu zdrojové hladiny za posledním podtržítkem.

Příklad:

```text
zdrojová hladina CP_POINTS_A -> A001, A002, A003
zdrojová hladina CP_POINTS_B -> B001, B002, B003
```

Číselná řada je nezávislá pro každý suffix.

Toto chování lze přepsat vlastním vzorem v `CPSETTINGS`. Každý znak `#` v první souvislé řadě znaků `#` se nahradí číslem doplněným nulami zleva.

Příklad:

```text
A-SO01-### -> A-SO01-001, A-SO01-002, A-SO01-003
P-####     -> P-0001, P-0002, P-0003
```

Při použití vlastního vzoru se používá jedna společná číselná řada pro daný vzor.

## Konfigurovatelné sloupce CSV/tabulky

Stejná konfigurace sloupců se používá pro CSV export i pro vloženou DWG tabulku.

Výchozí konfigurace:

```text
POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

Formát:

```text
FIELD_ID:Viditelný název sloupce;FIELD_ID:Viditelný název sloupce
```

Dostupné identifikátory polí:

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

### Příklad: skrytí sloupce hladiny

```text
POINT_NAME:Bod;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y;X_SJTSK:X;Z:Z
```

### Příklad: přejmenování sloupců pro vytyčovací tabulku

```text
POINT_NAME:Cislo bodu;Y_SJTSK:S-JTSK Y;X_SJTSK:S-JTSK X;Z:Vyska
```

### Příklad: zahrnutí AutoCAD handle

```text
POINT_NAME:Bod;HANDLE:Handle;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z
```

## Souřadnice S-JTSK

Plugin neprovádí transformaci souřadnic. Předpokládá, že aktuální DWG je již kresleno v S-JTSK nebo v souřadnicové konvenci používané daným projektem.

Výchozí mapování souřadnic je:

```text
Y_SJTSK = hodnota X bodu z DWG
X_SJTSK = hodnota Y bodu z DWG
Z       = hodnota Z bodu z DWG, nebo 0.000, pokud chybí
```

Toto chování je záměrné, protože mnoho českých CAD workflow ukládá souřadnice S-JTSK v DWG jako výkresové souřadnice X/Y, ale v geodetické notaci je označuje jako Y/X.

Pokud vaše kancelář používá opačnou konvenci, prohoďte hodnoty ve funkci `cp:field-value` uvnitř souboru:

```text
Contents\LISP\cadpoints.lsp
```

## Vzorkování křivek

Vzorkování křivek se nastavuje v `CPSETTINGS`.

Související nastavení:

```text
Vzorkovat oblouky, spliny a krivky po delce? [Ano/Ne]
Krok vzorkovani krivek ve vykresovych jednotkach
```

Výchozí interval:

```text
1000
```

U výkresů v milimetrech to znamená jeden generovaný bod přibližně po každém 1 m délky křivky.

Při povoleném vzorkování se vzorkuje tato geometrie:

- `ARC`
- `CIRCLE`
- `ELLIPSE`
- `SPLINE`
- `LWPOLYLINE` s bulge / obloukovými segmenty
- starší entity `POLYLINE` podobné křivkám, pokud je AutoCAD zpřístupní přes funkce pro křivky

Uzavřené křivky, například kružnice, neduplikují koncový bod uzavření. Otevřené křivky obsahují počáteční i koncový bod.

Vzorkované body jsou zahrnuty do:

- CSV exportu
- vložené DWG tabulky bodů
- volitelných popisů bodů
- volitelných zdrojových segmentů pro interpolaci vrstevnic

Důležité: vzorkování vychází z výkresových jednotek. Protože výchozí jednotkou projektu jsou milimetry, výchozí interval je `1000`.

## Volitelné generování vrstevnic

Generování vrstevnic se nastavuje v `CPSETTINGS`.

Související nastavení:

```text
Vykreslit interpolovane vrstevnice podle Z? [Ano/Ne]
Interval vrstevnic Z
Hladina vrstevnic
Kreslit vrstevnice jako SPLINE? [Ano/Ne]
```

Výchozí interval a hladina vrstevnic:

```text
CONTOUR_INTERVAL = 1000 mm
CONTOUR_LAYER    = CADPOINTS_CONTOURS
```

### Jak se vrstevnice generují

Plugin používá exportovanou geometrii a vzorkované body křivek jako zdrojové segmenty:

- `LINE`: jeden segment mezi počátečním a koncovým bodem
- `LWPOLYLINE`: segment mezi každou dvojicí sousedních vrcholů
- uzavřená `LWPOLYLINE`: také segment mezi posledním a prvním vrcholem
- `POLYLINE`: segment mezi každou dvojicí sousedních vrcholů
- uzavřená `POLYLINE`: také segment mezi posledním a prvním vrcholem
- vzorkované křivky: segment mezi každou dvojicí sousedních vzorkovaných bodů

Pro každou nakonfigurovanou úroveň Z plugin najde průsečíky, kde zdrojové segmenty protínají danou úroveň Z. Tyto interpolované body poté seřadí podle X/Y a vykreslí jednu křivku pro danou úroveň Z.

Pokud je povolen režim spline, pokusí se vytvořit entity `SPLINE`. Pokud se to nepodaří nebo jsou k dispozici pouze dva body, použije jako náhradní řešení `LWPOLYLINE`.

### Důležité omezení

Toto není skutečný model terénu ani TIN triangulace. Jde o přibližnou interpolaci nad existujícími zdrojovými segmenty. Je vhodná jako pomocný výstup pro jednoduché liniové/polygonové vstupy, ale neměla by být považována za certifikovaný geodetický model vrstevnic.

Pro přesné vrstevnice terénu by správný workflow byl:

```text
body -> TIN / model povrchu -> extrakce vrstevnic
```

Tato úroveň zpracování se lépe řeší v Civil 3D, plném AutoCADu se silnějším plugin API nebo ve specializovaném geodetickém/GIS nástroji.

## Testovací výkres a smoke test

Balíček obsahuje testovací assety ve složce:

```text
Contents/Test
```

Obsažené soubory:

```text
example_test.dxf
create_example_test.scr
cadpoints_smoke_test.lsp
README_TEST.md
```

Nativní `example_test.dwg` se v tomto balíčku negeneruje, protože zápis DWG vyžaduje AutoCAD nebo jiný licencovaný DWG runtime. Otevřete `example_test.dxf` v AutoCAD LT a uložte jej jako `example_test.dwg`, nebo spusťte `create_example_test.scr` a výsledný výkres uložte.

Smoke test pro pojmenování bodů:

```text
APPLOAD cadpoints.lsp
APPLOAD Contents/Test/cadpoints_smoke_test.lsp
CPTESTNAMES
```

Očekávaný výstup:

```text
CPTESTNAMES OK
```

## Nastavení ribbonu / panelu

Hotový binární `.cuix` není součástí balíčku. V AutoCAD LT je bezpečnější vytvořit částečný ribbon/panel přímo přes vestavěný editor `CUI`, protože AutoCAD ukládá data ribbonu specifická pro pracovní prostor do souborů přizpůsobení CUIx.

Balíček obsahuje připravené soubory ikon a šablonu legacy menu:

```text
Contents\Menu\cadpoints.mnu
Contents\Resources\cp-export.bmp
Contents\Resources\cp-settings.bmp
Contents\Resources\cp-help.bmp
Contents\Resources\cp-export-16.bmp
Contents\Resources\cp-settings-16.bmp
Contents\Resources\cp-help-16.bmp
```

### Ruční vytvoření ribbon panelu

1. Spusťte AutoCAD LT.
2. Spusťte příkaz:

```text
CUI
```

3. V levém stromu rozbalte:

```text
Ribbon > Panels
```

4. Vytvořte nový panel:

```text
CadPoints
```

5. V seznamu příkazů vytvořte tyto tři vlastní příkazy.

### Příkaz: CadPoints Export

Název:

```text
CadPoints Export
```

Makro:

```text
^C^C_CPEXPORT
```

Velký obrázek:

```text
Contents\Resources\cp-export.bmp
```

Malý obrázek:

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

Velký obrázek:

```text
Contents\Resources\cp-settings.bmp
```

Malý obrázek:

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

Velký obrázek:

```text
Contents\Resources\cp-help.bmp
```

Malý obrázek:

```text
Contents\Resources\cp-help-16.bmp
```

6. Přetáhněte tři příkazy do nového panelu `CadPoints`.
7. Přetáhněte panel `CadPoints` do existující karty ribbonu, například:

```text
Ribbon > Tabs > Home - 2D
```

8. Klikněte na `Apply` a poté na `OK`.

## Alternativní import toolbaru

Níže uvedený soubor lze použít jako výchozí bod pro legacy menu/toolbar:

```text
Contents\Menu\cadpoints.mnu
```

Podle verze AutoCAD LT a nastavení profilu jej importujte přes nástroje pro přenos CUI, nebo jej převeďte na částečný soubor přizpůsobení a načtěte přes:

```text
CUILOAD
```

Pro každodenní použití je ruční nastavení ribbonu přes `CUI` popsané výše předvídatelnější.
