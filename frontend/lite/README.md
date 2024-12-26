# Android

Zdrojový kód frontendu aplikace AgapeSongs pro Android.

## Spuštění

Pokud nechcete aplikaci vyvíjet, ale jen spustit, naleznete ji
na [Google Play](https://play.google.com/store/apps/details?id=cz.fit.cvut.wrzecond).

## Sestavení

K sestavení je využit balíčkovací nástroj [Gradle](https://gradle.org).
Aplikaci lze otevřít standardně v Android Studiu.
Spuštění a sestavení probíhá jako u běžné Android aplikace.

## Přihlášení

Pro přihlášení do Android aplikace je nutné vytvořit si uživatele s rolí ZPĚVÁK (SINGER)
v kapele, kterou chcete používat. Jeho login secret je pak přihlašovacím kódem.

Pro jednodušší přihlášení uživatelům můžete poslat odkaz / ukázat QR kód na adresu:
`agape://join?secret=LOGIN_SECRET`.

## Upozornění

**Varování**: jedná se o velmi omezenou a osekanou verzi aplikace, která umožňuje
pouze stažení playlistu, zobrazení zpěvníků, písní, transpozici a zvětšení textu.

Android aplikace byla vytvořena dodatečně, není tedy otestovaná a může obsahovat chyby.
Jakékoliv opravy, nahlášení chyb či Pull Requesty velmi rád uvítám.

## Struktura

Aplikace je běžná Android aplikace v Kotlinu s Jetpack Compose.

Nastavení pro Gradle naleznete v souborech `build.gradle` na úrovni projektu
a aplikace, ikony aplikace najdete ve složce `app/src/main/res`.

Nastavení aplikace jsou v tradičně v souboru `AndroidManifest.xml`,
zdrojový kód ve sloužce `app/src/main/java`.

Pro komunikaci s API je využita knihovna [Retrofit](https://square.github.io/retrofit/),
třídy `api/Api` a `api/RestClient`. Definice modelů shodné s API naleznete ve složce `entity/`.

Obrazovky v Jetpack Compose se nachází ve složce `ui/`, ViewModely zpracovávající logiku `viewmodel/`.
