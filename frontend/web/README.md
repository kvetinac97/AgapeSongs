# Web

Zdrojový kód frontendu aplikace AgapeSongs – webové verze.

## Spuštění

Pokud nechcete aplikaci vyvíjet, ale jen spustit, naleznete ji
na [mých webových stránkách](https://www.kvetinac97.cz/agape/).

## Sestavení

Pro sestavení je využit balíčkovací nástroj [NPM](https://www.npmjs.com).
Balíčky nainstalujete pomocí `npm install`. 

## Spuštění

Před spuštěním webu musíte správně nastavit přihlašovací údaje.

Nejprve je třeba nastavit korektně adresu `API_BASE_URL` pro API v `plugins/axios.js`
(standardní adresa nebude fungovat kvůli omezení CORS).

Následně je třeba vytvořit manuálně uživatele s rolí ZPĚVÁK (SINGER),
a vložit jeho údaje a ID kapely do přihlašovacího formuláře v `components/LoginForm.vue`.

Pak web spustíte pomocí `npm run serve`. Pokud chcete vytvořit verzi pro nahrání na server,
zabalení provedete pomocí `npm build`.

## Upozornění

**Varování**: jedná se o velmi omezenou a osekanou verzi aplikace, která umožňuje
pouze stažení playlistu, zobrazení zpěvníků, písní, transpozici a zvětšení textu.

Webová aplikace byla vytvořena dodatečně, není tedy otestovaná a může obsahovat chyby.
Jakékoliv opravy, nahlášení chyb či Pull Requesty velmi rád uvítám.

## Použité knihovny

Pro práci s API je využita knihovna [Axios](https://axios-http.com), pro navigaci 
[Vue Router](https://router.vuejs.org), pro ukládání dat [Pinia](https://pinia.vuejs.org)
a pro Material design framework [Vuetify](https://vuetifyjs.com/en/).

## Struktura

Aplikace se skládá z pár základních komponent (přihlašovací formulář, app bar, seznam zpěvníků, detail písně)
ve složce `components`, dvou stránek (složka `views`), úvodní komponentou `App.vue`
a nastavením pluginů pro ukládání přihlašovacích údajů a uživatelských preferencí v `plugins/`.

Jedná se o velmi jednoduchou webovou aplikaci, mělo by být tedy jednoduché ji pochopit.
