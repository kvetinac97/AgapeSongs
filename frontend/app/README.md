# iOS / macOS

Zdrojový kód frontendu aplikace AgapeSongs pro iOS / macOS.

## Spuštění

Pokud nechcete aplikaci vyvíjet, ale jen spustit, naleznete ji
na [App Storu](https://apps.apple.com/cz/app/agapesongs/id1589595680?l=cs).

## Sestavení

Projekt `AgapeSongs.xcodeproj` lze otevřít standardně v XCode.
Spuštění a sestavení probíhá jako u běžné iOS / macOS aplikace.

## Struktura

Aplikace je běžná multiplatformní aplikace pro iOS a macOS
vytvořená ve frameworku SwiftUI v programovacím jazyce Swift.

Ve složkách `iOS`, případně `macOS` je specifický kód pro dané platformy.
Společný kód (většina celkového kódu) je ve složce `Shared`.

Lokalizace naleznete v `Localizable.strings`, objekty pro komunikaci s API
ve složce `DTO`, modely ve složce `Model`.

O zobrazení se starají komponenty ze složky `View`, logiku řeší `Service`,
komunikaci mezi Service a View a držení dat pak `ViewModel`.

Architektura aplikace, včetně speciálních řešení (jako `AlwaysPopover` nebo `KeyEventHandling`)
je detailně popsána v mé [Bakalářské práci](https://dspace.cvut.cz/handle/10467/102238).

## Testování

Projekt obsahuje také UNIT testy vytvořené v rámci bakalářské práce.
Ty lze normálně spustit v XCode.
