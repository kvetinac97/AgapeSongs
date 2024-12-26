# AgapeSongs

AgapeSongs je aplikace zpěvníku pro náboženská shromáždění.
Umožňuje zobrazení a správu písní, jejich uspořádávání do zpěvníků
a přiřazení zpěvníků jednotlivým kapelám. V rámci kapely je pak
možná správa členů a oprávnění (vedoucí spravuje členy a zpěvníky,
hudebník spravuje písně, zpěvák pouze vidí).
Písním lze nastavit jejich tempo a výchozí capo (transpozici), které
lze následně upravovat, stejně jako velikost zobrazovaného textu
nebo soukromé poznámky k písni.

## Instalace

Aplikace je primárně určena pro Apple zařízení (iPhony, iPady a Macbooky).
Naleznete ji ke stažení na [App Storu](https://apps.apple.com/cz/app/agapesongs/id1589595680?l=cs).

Aplikace je dále dostupná také v Android verzi na [Google Play](https://play.google.com/store/apps/details?id=cz.fit.cvut.wrzecond)
a ve Webové verzi na [mých webových stránkách](https://www.kvetinac97.cz/agape/).

## Uživatelé

Vývoj aplikace a její provoz je PLNĚ závislý na [sponzorech](https://kvetinac97.github.io/AgapeSongs/support.html).
Ti mají také prioritní právo navrhovat další vylepšení.

Aktuální sponzoři:

 - Apoštolská církev Agapé Český Těšín ([sboragape.cz](http://sboragape.cz))
 - Křesťanský sbor Český Těšín ([kstesin.cz](http://kstesin.cz))
 - Mládež Přístav Český Těšín ([kcmojska.cz/pristav](https://kcmojska.cz/pristav/))

## Pro vývojáře

iOS a macOS aplikace jsou vytvořeny jako nativní SwiftUI aplikace ve Swiftu.
Android aplikace je vytvořena jako nativní Jetpack Compose aplikace v Kotlinu.
Webová aplikace je vytvořena ve frameworku Vue.js v JavaScriptu.

Aplikace i web komunikují s podpůrným webovým serverem poskytujícím API.
Tento server je napsán v Kotlinu.

Celý systém byl vytvořen v rámci mé [Bakalářské práce](https://dspace.cvut.cz/handle/10467/102238)
a je nadále rozvíjen občasnými aktualizacemi dle potřeby aktuálních uživatelů.

Od prosince 2024 je projekt **open-source** pod licencí GPL, to znamená, že veškeré jeho zdrojové kódy
jsou veřejné a otevřené ke změnám.

Ve složce **backend** naleznete zdrojový kód backendu.
Ve složkách **frontend/app** zdrojový kód iOS/macOS aplikace, **frotend/lite** Android aplikace,
**frontend/web** webové verze.
