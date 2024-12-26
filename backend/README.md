# Backend

Zdrojový kód backendu aplikace AgapeSongs.

## Sestavení

K sestavení je využit balíčkovací nástroj [Maven](https://maven.apache.org).
Backend sestavíte pomocí příkazu `mvn package`.

## Spuštění

Pro spuštění backendu je potřeba doplnit konfigurační soubor aplikace `application.properties`:

```properties
spring.datasource.type=org.springframework.jdbc.datasource.SimpleDriverDataSource
spring.datasource.url=jdbc:mysql://dburl:3306/dbname
spring.datasource.username=dbuser
spring.datasource.password=dbpass
spring.jpa.hibernate.ddl-auto=update

auth.keyPath=APPLE_KEY_PATH
auth.keyId=APPLE_KEY_ID
auth.teamId=APPLE_TEAM_ID
```

Je třeba doplnit údaje o připojení k databázi (zde placeholder hodnoty `dburl`, `dbname`, `dbuser` a `dbpass`).

Pro funkční přihlášení přes Apple je pak potřeba také v Apple vývojářském účtu vytvořit klíč a nastavit
jeho cestu, identifikátor a identifikátor týmu.

V `AuthService` je také třeba změnit hodnotu konstanty `CLIENT_ID` na identifikátor aplikace
(aktuální je `cz.cvut.fit.wrzecond.AgapeSongs`, ten je ale pod mým vývojářským účtem).

V konfiguračním souboru lze samozřejmě nastavovat všechny typické parametry Spring Web, jako `server.port`
pro port serveru, `server.ssl.key-store` apod. pro cestu k SSL certifikátu apod.

Podrobný popis nastavování, včetně obrázků kde v Apple vývojářském účtu vytvořit klíč naleznete
v [Bakalářské práci](https://dspace.cvut.cz/handle/10467/102238).

Spuštění následně provedete standardně příkazem `java -jar agapesong.jar`.

## Použité knihovny

Backend je postaven na frameworku [Spring Boot](https://spring.io/guides/gs/spring-boot) s využitím Spring Web.
Dále využívá knihovny pro práci s JWT, který je využit v práci přihlašování pomocí **Sign with Apple**.

## Struktura

Architektura backendu je detailně popsána v mé [Bakalářské práci](https://dspace.cvut.cz/handle/10467/102238).
V balíčku `controller` jsou třídy poskytující Rest API, `service` poskytují aplikační logiku, `repository` definují
komunikaci s databází a `entity` s `dto` datový model aplikace.

## Testování

Projekt obsahuje také UNIT testy vytvořené v rámci bakalářské práce. Ty lze normálně spustit v IDE, spouští se také
při každé archivaci pomocí `mvn package`.
