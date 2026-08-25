## [Unreleased]

### Suunnitteilla

- Kirjahyllyjen järjestäminen
- Lajittelu kirjan lisäysajan perusteella
- Lukemisen aloitus- ja lopetuspäivämäärät
- Lukemisen tilastot
- Kirjan lainaustiedot
- Automaattiset varmuuskopiot
- Pilvisynkronointi
- Käyttäjätilit

## [0.12.1-alpha] - 2026-08-25

### Muutettu

- Androidin release-build käyttää nyt projektin omaa pysyvää release-allekirjoitusavainta debug-avaimen sijasta
- Release-allekirjoituksen asetukset luetaan Gitin ulkopuolelle jätetystä `android/key.properties`-tiedostosta

### Testattu

- Release-APK:n onnistunut muodostaminen
- APK:n allekirjoituksen tarkistus `apksigner`-työkalulla
- APK:n SHA-256-sertifikaattitunniste vastaa My Shelf -release-keystoren sertifikaattitunnistetta
- Flutter-analyysi
- Kaikki 140 automaattista testiä

### Huomioitavaa

- `v0.12.0-alpha`-APK oli allekirjoitettu Flutterin debug-avaimella
- `v0.12.1-alpha` ja tulevat julkaisut allekirjoitetaan pysyvällä My Shelf -release-avaimella
- Debug-avaimella asennettua `v0.12.0-alpha`-versiota ei voi päivittää suoraan `v0.12.1-alpha`-versioon, vaan vanha versio täytyy poistaa kerran ennen uuden asentamista

## [0.12.0-alpha] - 2026-08-25

### Lisätty

- `BookBinding`-tietotyyppi kirjan sidosasun mallintamiseen
- Kirjalle julkaisuvuosi (`publicationYear`)
- Kirjalle kustantaja (`publisher`)
- Kirjalle sidosasu (`binding`)
- Julkaisuvuoden, kustantajan ja sidosasun JSON-tallennus
- Vanhojen kirjastotietojen yhteensopiva palautus, kun uusia bibliografisia kenttiä ei vielä ole
- Julkaisuvuoden ja kustantajan lukeminen Finna-tuloksista
- Sidosasun tunnistaminen Finnan ISBN- ja formaattitiedoista
- Finnan kaikkien täsmällisten ISBN-osumien yhdistäminen puuttuvien kenttien täydentämiseksi
- Täydentävä sidosasuhaku Finnan `/v1/record`-rajapinnasta
- Sidosasun tunnistaminen Finnan `fullRecord`-metadatasta silloin, kun tavallinen hakutulos ei sisällä tietoa
- Google Books -varalähde puuttuvalle julkaisuvuodelle
- Google Books -varalähde puuttuvalle kustantajalle
- Uusien bibliografisten tietojen näyttäminen ISBN-haun esikatselussa
- Julkaisuvuoden, kustantajan ja sidosasun näyttäminen kirjan tietosivulla
- Julkaisuvuoden, kustantajan ja sidosasun käsin lisääminen ja muokkaaminen

### Muutettu

- Kirjan tietomalli säilyttää uudet bibliografiset tiedot `copyWith()`-operaatioissa
- Kirjan muokkaaminen säilyttää kannen, oman kansikuvan, lukutilan, arvosanan ja muistiinpanot
- Kirjan hyllyn vaihtaminen säilyttää myös julkaisuvuoden, kustantajan ja sidosasun
- ISBN-haulla löydetyn kirjan siirtäminen valittuun hyllyyn säilyttää kaikki uudet bibliografiset tiedot
- Manuaalisen ISBN-kentän validointi käyttää yhteistä `IsbnUtils`-validointia
- Finna säilyy ensisijaisena lähteenä julkaisuvuodelle ja kustantajalle
- Google Books täydentää julkaisuvuoden ja kustantajan vain, jos Finna ei niitä tarjoa
- Sidosasun täydentävä `fullRecord`-haku tehdään vain, jos sidosasu puuttuu tavallisesta Finna-hakutuloksesta
- Täydentävän Finna-haun epäonnistuminen ei estä muiden kirjatietojen käyttämistä
- Kirjaston JSON- ja ZIP-varmuuskopiot sisältävät uudet kentät osana kirjan JSON-dataa
- Varmuuskopion formaattiversio säilyy ennallaan, koska uudet kentät ovat taaksepäin yhteensopivia ja valinnaisia

### Korjattu

- Korjattu tilanne, jossa sidosasu jäi löytymättä, vaikka se oli saatavilla Finnan toisessa täsmällisessä ISBN-osumassa
- Korjattu tilanne, jossa Finnan Search API:n normalisoitu data ei sisältänyt sidosasua mutta tieto löytyi alkuperäisestä `fullRecord`-metadatasta
- Estetty väärän ISBN-painoksen sidosasun käyttäminen täydentävässä Finna-haussa
- Estetty kirjalle jo tallennettujen laajempien metatietojen katoaminen kirjaa uudelleen muodostettaessa
- Korjattu manuaalisen kirjan muokkauksen yhteydessä aiemmin mahdollinen kansi-, lukutila-, arvosana- ja muistiinpanotietojen katoaminen

### Testattu

- Julkaisuvuoden, kustantajan ja sidosasun oletusarvot
- Uusien bibliografisten kenttien JSON-tallennus ja palautus
- Vanhan JSON-datan yhteensopivuus uusien kenttien kanssa
- Tuntemattoman sidosasuarvon palautuminen `unknown`-arvoksi
- Virheellisen julkaisuvuoden hylkääminen
- Virheellisen kustantajatyypin hylkääminen
- Uusien kenttien säilyminen `copyWith()`-metodissa
- Julkaisuvuoden ja kustantajan tyhjentäminen `copyWith()`-metodilla
- Julkaisuvuoden, kustantajan ja kovakantisen sidosasun lukeminen Finnasta
- Sidosasun valinta täsmällisen ISBN:n perusteella, kun samassa tietueessa on useita ISBN-painoksia
- Puuttuvan sidosasun täydentäminen myöhemmästä täsmällisestä Finna-osumasta
- Puuttuvan sidosasun täydentäminen Finnan `fullRecord`-datasta
- Turhan `fullRecord`-haun välttäminen, kun sidosasu löytyi jo normaalista hakutuloksesta
- Google Booksin julkaisupäivän muuntaminen julkaisuvuodeksi
- Puuttuvan julkaisuvuoden ja kustantajan täydentäminen Google Booksista
- Finnan julkaisuvuoden ja kustantajan ensisijaisuus Google Booksiin nähden
- Virheellisen Google Books -julkaisupäivän turvallinen ohittaminen
- ISBN-haun laitetestit suomalaisilla uusilla ja vanhemmilla kirjoilla
- Julkaisuvuoden, kustantajan ja sidosasun näyttäminen oikealla laitteella
- Julkaisuvuoden, kustantajan ja sidosasun käsin muokkaaminen oikealla laitteella
- Sidosasun löytyminen oikealla laitteella myös Finnan `fullRecord`-täydennyksen avulla
- Flutter-analyysi
- Kaikki 140 automaattista testiä

### Tunnetut rajoitukset

- Kirjatietojen ja verkkokansien hakeminen edellyttää verkkoyhteyttä
- Hakutulosten kattavuus riippuu Finnan, Google Booksin ja Open Libraryn aineistoista
- Kaikille kirjoille ei ole saatavilla kaikkia bibliografisia tietoja
- Sidosasun löytyminen riippuu siitä, sisältääkö jokin täsmällinen Finna-tietue sidosasutiedon
- Open Library toimii edelleen varalähteenä muille puuttuville tiedoille ja kansille, mutta sitä ei käytetä painoskohtaisen julkaisuvuoden ensisijaisena lähteenä
- Kaikille kirjoille ei ole saatavilla kansikuvaa missään käytetyssä kirjapalvelussa
- Jos käyttökelpoista verkkokantta ei löydy, sovellus näyttää oman varakantensa

## [0.11.0-alpha] - 2026-08-08


### Lisätty

- Finna uutena suomalaisiin kirjoihin painottuvana ISBN-hakulähteenä
- `FinnaBookSearchService` kirjojen hakemiseen Finna-palvelusta
- `BookSearchResult` eri kirjatietopalvelujen hakutulosten yhteiseksi tietomalliksi
- `BookDataSource` hakutuloksen lähteen tunnistamiseen
- `IsbnUtils` ISBN-tunnusten normalisointiin, validointiin ja vertailuun
- ISBN-10- ja ISBN-13-tunnusten tarkistusnumeroiden validointi
- ISBN-10-tunnuksen muuntaminen vastaavaksi ISBN-13-tunnukseksi
- ISBN-10- ja ISBN-13-tunnusten keskinäisen vastaavuuden tunnistaminen
- Täsmällisen ISBN-painoksen tarkistaminen Finna-tuloksista
- Täsmällisen ISBN-painoksen tarkistaminen Google Books -tuloksista
- Täsmällisen ISBN-painoksen tarkistaminen Open Library -tuloksista
- Useiden Finna-hakutulosten läpikäynti oikean ISBN-painoksen löytämiseksi
- Finna-, Google Books- ja Open Library -tietojen kenttäkohtainen yhdistäminen
- Finna- ja Google Books -hakujen rinnakkainen suorittaminen
- Open Library varalähteeksi puuttuvien tietojen täydentämiseen
- Finnan tietueen tunnisteeseen ja kirjan metatietoihin perustuva kansikuvahaku
- `FinnaCoverValidator` Finnan kansikuvavastausten tarkistamiseen
- Finnan 10 × 10 pikselin läpinäkyvän GIF-paikkamerkin tunnistaminen
- Käyttökelvottoman Finna-kannen poistaminen hakutuloksesta
- Open Libraryn kansikuvan käyttäminen, kun Finnan kansi on paikkamerkki
- `BookSearchResult.withoutCover()` hakutuloksen säilyttämiseen ilman käyttökelvotonta kansikuvaa
- Yhteinen `BookApiException` kirjahakupalvelujen virheiden käsittelyyn

### Muutettu

- ISBN-dialogi käyttää nyt rakenteellisen tarkistuksen lisäksi ISBN:n oikeaa tarkistusnumeroa
- ISBN-tunnuksesta poistetaan välilyönnit ja väliviivat ennen hakua
- ISBN-tunnuksen X-tarkistusmerkki muunnetaan isoksi kirjaimeksi
- Kirjahaku käyttää nyt Google Booksin ja Open Libraryn lisäksi Finnaa
- Kirjan nimi ja tekijä valitaan ensisijaisesti Finnasta
- Puuttuvia sivumäärä- ja kansikuvatietoja täydennetään muista kirjapalveluista
- Google Booksin hakutulosten enimmäismäärä nostettiin yhteen tulokseen rajoittumisen sijasta
- Open Libraryn hakutulosten enimmäismäärä nostettiin yhteen tulokseen rajoittumisen sijasta
- Google Booksin ja Open Libraryn tuloksia ei enää hyväksytä ilman haettua ISBN-painosta vastaavaa tunnistetta
- Open Librarya kutsutaan vain, jos Finnan ja Google Booksin tuloksista puuttuu edelleen tietoja
- Yhden kirjapalvelun tekninen virhe ei enää estä muiden palvelujen tulosten käyttämistä
- Tekninen virhe näytetään käyttäjälle vasta, jos kaikki käytetyt kirjapalvelut epäonnistuvat
- Finnan kansikuva muodostetaan samalla metatietopohjaisella `/Cover/Show`-haulla, jolla myös Finna-verkkopalvelu löytää vanhempien kirjojen kansia
- Kansikuvaksi valitaan käyttökelpoinen kuva Google Booksista, Open Librarysta tai Finnasta
- Kirja palautetaan ilman verkkokantta, jos mikään palvelu ei tarjoa käyttökelpoista kansikuvaa

### Korjattu

- Korjattu suomalaisten kirjojen heikko löytyminen pelkillä Google Books- ja Open Library -hauilla
- Korjattu väärän kirjan tai väärän painoksen hyväksyminen epätarkan ISBN-hakutuloksen perusteella
- Korjattu vanhempien suomalaisten kirjojen Finna-kansien puuttuminen sovelluksesta
- Korjattu tilanne, jossa Finna-sivulla näkyvä kansikuva ei löytynyt pelkän API:n `images`-kentän avulla
- Korjattu Finnan suhteellisten kansikuvaosoitteiden muodostaminen täydellisiksi HTTPS-osoitteiksi
- Estetty Finnan 10 × 10 pikselin läpinäkyvän GIF-paikkamerkin näyttäminen kirjan kantena
- Estetty virheellisen ISBN-tarkistusnumeron sisältävän tunnuksen lähettäminen verkkohakuun
- Estetty yhden kirjapalvelun verkkovirhettä katkaisemasta koko ISBN-hakua
- Korjattu puuttuvan sivumäärän käsittely niin, että toinen palvelu voi täydentää tiedon ennen oletusarvon käyttämistä
- Korjattu puuttuvan tekijän käsittely niin, että toinen palvelu voi täydentää tiedon
- Korjattu puuttuvan kansikuvan käsittely niin, että toinen palvelu voi tarjota varakannen

### Testattu

- ISBN-tunnuksen välilyöntien ja väliviivojen poistaminen
- Kelvollisen ISBN-13-tunnuksen tarkistus
- Kelvollisen ISBN-10-tunnuksen tarkistus
- Virheellisen ISBN-tarkistusnumeron hylkääminen
- ISBN-10- ja ISBN-13-tunnusten vastaavuuden tunnistaminen
- ISBN-10-tunnuksen muuntaminen ISBN-13-muotoon
- Finna-hakupyynnön osoite ja hakuehdot
- Finna-haun kirjaformaattirajaus
- Täsmällisen Finna-ISBN-osuman valitseminen
- Väärän Finna-painoksen ohittaminen
- ISBN-10- ja ISBN-13-muotojen tunnistaminen samaksi Finna-painokseksi
- Finnan päätekijän lukeminen
- Finnan vaihtoehtoisen tekijäkentän käyttäminen
- Finnan sivumäärän lukeminen fyysisestä kuvauksesta
- Finnan kansikuvaosoitteen muodostaminen
- Finna-haun HTTP-virheen käsittely
- Virheellisen Finna-vastauksen käsittely
- Finnan ja Google Booksin tietojen yhdistäminen
- Finnan nimen ja tekijän käyttäminen Google Booksin tietojen sijasta
- Google Booksin sivumäärän käyttäminen Finnan tiedon puuttuessa
- Google Booksin kansikuvan käyttäminen Finnan perustietojen kanssa
- Väärän Google Books -painoksen ohittaminen
- Täsmällisen Google Books -ISBN-osuman valitseminen
- Open Libraryn käyttäminen varalähteenä
- Väärän Open Library -painoksen ohittaminen
- Finnan teknisen virheen ohittaminen Google Books -tuloksen löytyessä
- Kaikkien kirjapalvelujen teknisen virheen käsittely
- Verkkohakujen estäminen virheellisellä ISBN-tunnuksella
- Null-arvon palauttaminen, kun täsmällistä ISBN-osumaa ei löydy
- Finnan 10 × 10 pikselin GIF-paikkamerkin hylkääminen
- Oikean kokoisen GIF-kansikuvan hyväksyminen
- Muun kuin kuvasisällön hylkääminen kansikuvana
- Epäonnistuneen kansikuva-HTTP-vastauksen hylkääminen
- Kansikuvan tarkistuksen verkkovirheen käsittely
- Open Libraryn kannen käyttäminen Finnan paikkamerkin sijasta
- Suomalaisten kirjojen ISBN-haku oikealla laitteella
- Uusien ja vanhempien suomalaisten kirjojen Finna-kansikuvat oikealla laitteella
- Kirjat, joille Finna ei tarjoa kansikuvaa
- Flutter-analyysi
- Kaikki 123 automaattista testiä

### Tunnetut rajoitukset

- Kirjatietojen ja verkkokansien hakeminen edellyttää verkkoyhteyttä
- Hakutulosten kattavuus riippuu Finnan, Google Booksin ja Open Libraryn aineistoista
- Kaikille kirjoille ei ole saatavilla kansikuvaa missään käytetyssä kirjapalvelussa
- Jos käyttökelpoista verkkokantta ei löydy, sovellus näyttää oman varakantensa
- Kirjahaku ei vielä tallenna tai näytä kustantajaa, julkaisuvuotta tai kieltä

### Suunnitteilla

- Kirjahyllyjen järjestäminen
- Lajittelu kirjan lisäysajan perusteella
- Lukemisen aloitus- ja lopetuspäivämäärät
- Lukemisen tilastot
- Kirjan lainaustiedot
- Automaattiset varmuuskopiot
- Pilvisynkronointi
- Käyttäjätilit

## [0.10.0-alpha] - 2026-08-03

### Lisätty

- Kansikuvat sisältävä siirrettävä ZIP-varmuuskopio
- `archive`-paketti ZIP-arkistojen muodostamiseen ja lukemiseen
- ZIP-varmuuskopion `manifest.json`-tiedosto
- ZIP-varmuuskopion `library.json`-tiedosto
- ZIP-varmuuskopion `covers/`-hakemisto paikallisille kansikuville
- `PortableBackupManifest` ZIP-arkiston rakenteen versiointiin
- ZIP-arkistolle kirjaston JSON-rakenteesta erillinen versionumero
- My Shelf -varmuuskopioarkiston formaattitunniste
- `PortableBackupArchiveService` ZIP-varmuuskopioiden muodostamiseen
- `PortableBackupArchiveReader` ZIP-varmuuskopioiden turvalliseen lukemiseen
- `PortableBackupArchiveData` puretun varmuuskopion tietojen säilyttämiseen muistissa
- `LibraryBackupValidator` kirjastotietojen yhteiseen eheystarkistukseen
- `PortableCoverRestoreService` paikallisten kansikuvien turvalliseen palauttamiseen
- `PortableCoverRestoreTransaction` kansikuvien palautuksen vahvistamiseen tai perumiseen
- Käyttäjän omien kansikuvatiedostojen sisällyttäminen varmuuskopioon
- Vain kirjojen käyttämien kansikuvatiedostojen lisääminen ZIP-arkistoon
- Saman kansikuvatiedoston lisääminen arkistoon vain kerran
- ZIP-varmuuskopion jakaminen käyttöjärjestelmän jakovalikolla
- `.zip`-tiedostopääte uusille siirrettäville varmuuskopioille
- JSON- ja ZIP-varmuuskopioiden valitseminen samalla tiedostonvalitsimella
- Varmuuskopion tiedostomuodon automaattinen tunnistaminen tiedostopäätteestä
- Vanhojen JSON-varmuuskopioiden yhteensopiva palauttaminen
- ZIP-varmuuskopion kansikuvien pitäminen muistissa ennen palautuksen vahvistamista
- Kansikuvien kirjoittaminen ensin väliaikaiseen valmisteluhakemistoon
- Vanhojen samannimisten kansikuvien väliaikainen varmistaminen
- Kansikuvien palautuksen `commit`-toiminto
- Kansikuvien palautuksen `rollback`-toiminto
- Palautettavien kansikuvien määrän näyttäminen vahvistusdialogissa
- JSON- ja ZIP-varmuuskopioiden tiedostomuodon näyttäminen vahvistusdialogissa
- Tarpeettomiksi jääneiden vanhojen kansikuvien poistaminen onnistuneen palautuksen jälkeen
- Arkiston pakatun koon enimmäisraja
- Arkiston puretun sisällön yhteinen enimmäisraja
- Manifestin, kirjastotiedoston ja yksittäisten kansikuvien kokorajat
- Arkiston tiedostojen ja hakemistojen määrän enimmäisraja
- Turvattomien tiedostopolkujen tarkistaminen
- Windows-asematunnusten ja varattujen tiedostonimien tarkistaminen
- Symbolisten linkkien hylkääminen ZIP-arkistosta
- Päällekkäisten arkistomerkintöjen tarkistaminen
- Puuttuvien kansikuvatiedostojen tarkistaminen
- Käyttämättömien kansikuvatiedostojen tarkistaminen
- Tyhjien kansikuvatiedostojen tarkistaminen
- Manifestin ja kirjastotiedoston luontiaikojen vastaavuuden tarkistaminen
- JSON-tiedostojen UTF-8-sisällön tarkistaminen

### Muutettu

- Varmuuskopion vienti luo nyt oletuksena kansikuvat sisältävän ZIP-tiedoston
- JSON-varmuuskopion vientitoiminto säilytettiin palvelutasolla yhteensopivuutta varten
- Varmuuskopion palautus hyväksyy sekä `.json`- että `.zip`-tiedostot
- JSON- ja ZIP-varmuuskopiot käyttävät samaa kirjaston `LibraryBackup`-tietomallia
- `LibraryBackup.currentFormatVersion` säilytettiin arvossa 1
- ZIP-arkiston rakenne versioidaan erillään kirjaston JSON-rakenteesta
- Kirjaston eheystarkistus siirrettiin `LibraryBackupValidator`-palveluun
- Varmuuskopion tiedostonvalitsin päivitettiin tukemaan JSON- ja ZIP-tiedostoja
- Varmuuskopion vahvistusdialogi näyttää tiedostomuodon
- ZIP-varmuuskopion vahvistusdialogi näyttää paikallisten kansikuvien määrän
- Palautuksen ajaksi päänäkymä asetetaan lataustilaan
- Kansikuvat otetaan käyttöön ennen kirjastotietojen tallentamista odottavana transaktiona
- Kansikuvien palautus vahvistetaan vasta kirjojen ja kirjahyllyjen onnistuneen tallennuksen jälkeen
- Tallennusvirheessä yritetään palauttaa aiemmat kirjat, kirjahyllyt ja kansikuvat
- Uuden ZIP-varmuuskopion kuvaus päivitettiin jakovalikossa
- Varmuuskopion onnistumisilmoitus näyttää palautettujen kirjojen, hyllyjen ja kansikuvien määrän

### Korjattu

- Korjattu kirjan tietojen katoaminen kirjaa hyllystä toiseen siirrettäessä
- Kirjan hyllyn vaihtaminen säilyttää nyt oman kansikuvan
- Kirjan hyllyn vaihtaminen säilyttää nyt lukutilan
- Kirjan hyllyn vaihtaminen säilyttää nyt arvosanan
- Kirjan hyllyn vaihtaminen säilyttää nyt muistiinpanon
- Estetty ZIP-varmuuskopion kirjoittaminen sovelluksen kansikuvahakemiston ulkopuolelle
- Estetty polut, jotka sisältävät `..`- tai `.`-segmenttejä
- Estetty absoluuttiset Unix- ja Windows-polut
- Estetty alihakemistojen käyttäminen kansikuvatiedostojen nimissä
- Estetty tyhjien kansikuvatiedostojen palauttaminen
- Estetty puuttuvaan kansikuvatiedostoon viittaavan varmuuskopion palauttaminen
- Estetty ylimääräisiä käyttämättömiä kansikuvia sisältävän arkiston palauttaminen
- Estetty tuntemattomia tiedostoja tai hakemistoja sisältävän arkiston palauttaminen
- Estetty manifestittoman ZIP-varmuuskopion palauttaminen
- Estetty `library.json`-tiedostottoman ZIP-varmuuskopion palauttaminen
- Estetty tuntemattoman ZIP-arkistoversion palauttaminen
- Estetty virheellisen My Shelf -formaattitunnisteen sisältävän arkiston palauttaminen
- Estetty liian suuren ZIP-arkiston purkaminen
- Estetty aiemman samannimisen kansikuvan häviäminen epäonnistuneessa palautuksessa
- Estetty uuden kansikuvatiedoston jääminen tallennustilaan palautuksen peruuntuessa
- Estetty palautuksen väliaikaishakemistojen jääminen tallennustilaan vahvistuksen tai perumisen jälkeen

### Testattu

- ZIP-varmuuskopion manifestin JSON-muunnos
- Manifestin nykyinen arkistoversio
- Virheellisen formaattitunnisteen hylkääminen
- Tuntemattoman arkistoversion hylkääminen
- Virheellisen manifestin luontiajan hylkääminen
- ZIP-arkiston muodostaminen manifestista, kirjastosta ja kansikuvista
- ZIP-arkiston muodostaminen ilman paikallisia kansikuvia
- Tarpeettomien kansikuvatiedostojen jättäminen arkiston ulkopuolelle
- Puuttuvan kansikuvatiedoston hylkääminen viennissä
- Tyhjän kansikuvatiedoston hylkääminen viennissä
- Turvattoman kansikuvatiedostonimen hylkääminen viennissä
- Kahden kirjan yhteisen kansikuvan lisääminen arkistoon vain kerran
- Paikallisen kansikuvatiedoston lukeminen vientipalvelussa
- Kahden kirjan yhteisen kansikuvan lukeminen vain kerran
- Vientipalvelun toiminta ilman paikallisia kansikuvia
- Kelvollisen ZIP-varmuuskopion lukeminen
- Virheellisen ZIP-tiedoston hylkääminen
- Puuttuvan `manifest.json`-tiedoston hylkääminen
- Puuttuvan `library.json`-tiedoston hylkääminen
- Turvattoman arkistopolun hylkääminen
- Puuttuvan viitatun kansikuvan hylkääminen
- Käyttämättömän kansikuvan hylkääminen
- Tyhjän kansikuvatiedoston hylkääminen
- Tietosisällöltään epäkelvon kirjaston hylkääminen
- JSON-varmuuskopion tunnistaminen tiedostopäätteestä
- ZIP-varmuuskopion tunnistaminen tiedostopäätteestä
- Tiedostopäätteen kirjainkoosta riippumaton tunnistaminen
- Tuntemattoman tiedostomuodon hylkääminen
- Virheellisen UTF-8-muotoisen JSON-tiedoston hylkääminen
- Uuden kansikuvan ottaminen käyttöön
- Kansikuvien palautuksen vahvistaminen
- Uuden kansikuvan poistaminen rollbackissa
- Ylikirjoitetun vanhan kansikuvan palauttaminen rollbackissa
- Turvattoman tiedostonimen hylkääminen ennen tiedostojen kirjoittamista
- Tyhjän kansikuvan hylkääminen ennen palautuksen aloittamista
- Vahvistetun palautustapahtuman uudelleenkäytön estäminen
- ZIP-varmuuskopion vienti oikealla laitteella
- ZIP-varmuuskopion palautus oikealla laitteella
- Käyttäjän omien kansikuvien siirtyminen varmuuskopion mukana
- Vanhan JSON-varmuuskopion palauttaminen oikealla laitteella
- Kirjojen, kirjahyllyjen, lukutilojen, arvosanojen ja muistiinpanojen säilyminen palautuksessa
- Flutter-analyysi
- Kaikki 98 automaattista testiä

### Tunnetut rajoitukset

- Aiemmissa versioissa luodut JSON-varmuuskopiot eivät sisällä varsinaisia paikallisia kansikuvatiedostoja
- JSON-varmuuskopiosta palautettu kirja voi viitata paikalliseen kansikuvatiedostonimeen, jota toisella laitteella ei ole
- Varmuuskopiointi käynnistetään edelleen käyttäjän toimesta eikä automaattisia varmuuskopioita vielä ole

## [0.9.0-alpha] - 2026-08-02

### Lisätty

- Kansikuvanäkymä kirjojen uudeksi oletusnäkymäksi
- Selkämyksenäkymä vaihtoehtoiseksi esitystavaksi
- Koko ruudun kirjahyllynäkymä
- Kirjahyllyn nimi koko ruudun näkymän nimikyltissä
- Koko ruudun näkymän oma paluupainike ja asetusvalikko
- Skannauspainike koko ruudun näkymään
- `BookViewMode`-näkymätyyppi kansi- ja selkämyksenäkymille
- Käyttäjän oman kansikuvan valitseminen laitteen kuvakirjastosta
- Oman kansikuvan vaihtaminen
- Oman kansikuvan poistaminen
- Verkosta haetun kansikuvan palauttaminen
- `customCoverFileName`-kenttä `Book`-malliin
- Oman kansikuvan tiedostonimen tallentaminen paikalliseen JSON-dataan
- Oman kansikuvan tiedostonimen sisällyttäminen JSON-varmuuskopioon
- `CustomCoverService` omien kansikuvatiedostojen tallentamiseen, hakemiseen ja poistamiseen
- Kansikuvien tallentaminen sovelluksen omaan pysyvään `covers`-hakemistoon
- Vanhan kansikuvatiedoston automaattinen poistaminen kantta vaihdettaessa
- Kansikuvatiedoston automaattinen poistaminen kirjaa poistettaessa
- `BookCoverImage`-widget oman kannen, verkkokannen ja varakannen näyttämiseen
- `BookCoverCard` yksittäisen kansikuvan esittämiseen kirjahyllyssä
- `BookCoverShelf` kansikuvista muodostuvaa kirjahyllyä varten
- `BookCoverHero` kirjahyllyn ja kirjan tietosivun väliseen Hero-animaatioon
- Hero-animaatio kirjan kannen avaamiseen ja sulkemiseen
- Tyylitelty varakansi kirjoille, joilla ei ole omaa tai verkosta löytyvää kantta
- Automaattisesti kannen vaaleuteen mukautuva varakannen tekstiväri
- Viimeistelty latausnäkymä paikallisille ja verkosta haettaville kansikuville
- Pehmeä kansikuvan ilmestymisanimaatio
- Lukutilatunnisteiden valinnainen näyttäminen kansikuvanäkymässä
- Lukutilatunnisteiden valinnainen näyttäminen selkämyksenäkymässä
- Kirjojen esitystavan paikallinen tallentaminen
- Lukutilatunnisteiden näkyvyysasetuksen paikallinen tallentaminen
- `LibraryViewSettings`-tietomalli
- `LibraryViewSettingsService` näkymäasetusten tallentamista varten
- Responsiivinen kansien sarakemäärä
- Näytön suunnan huomioiva kansien koko ja asettelu
- Viimeisen vajaan hyllyrivin näkymätön pudotusalue
- Siirrä loppuun -pudotusvihje kirjaa raahattaessa
- Visuaalinen tyhjän hyllyn näkymä
- Visuaalinen tyhjän hakutuloksen näkymä
- Visuaalinen tyhjän suodatustuloksen näkymä
- Yhteinen `ShelfEmptyState`-widget tyhjille tiloille
- Kompakti kelluva skannauspainike puhelimen vaakasuunnassa

### Muutettu

- Päänäkymä uudistettiin kirjahyllykeskeiseksi
- Kirjahylly saa aiempaa suuremman osan näytön käytettävissä olevasta tilasta
- Sovelluksen nimi siirrettiin kompaktiin ylätunnisteeseen
- Kirjaston yhteenveto siirrettiin sovelluksen nimen ja päävalikon väliin
- Varmuuskopiointi ja palautus siirrettiin päävalikkoon
- Kirjojen esitystavan valinta siirrettiin päävalikkoon
- Lukutilatunnisteiden näkyvyys siirrettiin päävalikkoon
- Uuden hyllyn luominen siirrettiin hyllyn toimintovalikkoon
- Hakukenttä piilotetaan oletuksena ja avataan hakukuvakkeesta
- Lajittelu muutettiin nimetyksi pudotusvalikoksi
- Lukutila- ja sisältösuodattimet yhdistettiin samaan valikkoon
- Hyllyvalitsimen ja työkalurivin ulkoasua tiivistettiin
- Kirjahyllyn kehystä ohennettiin
- Kirjahyllyn tausta muutettiin puunsävyiseksi liukuväriksi
- Hyllylaudat uudistettiin ohuemmiksi ja hillitymmiksi
- Kansien välejä, mittasuhteita, reunuksia ja varjoja viimeisteltiin
- Kansille lisättiin kevyt painallusanimaatio
- Raahattava kansi nousee ja kallistuu hieman
- Pudotuskohteen korostusta viimeisteltiin
- Viimeisen vajaan rivin tyhjät korttipaikat poistettiin
- Kansikuvien koko mukautuu tavalliseen ja koko ruudun näkymään
- Kansien koko mukautuu puhelimen pysty- ja vaakasuuntaan
- Tavallisen vaakasuuntaisen näkymän ulkomarginaaleja ja välejä pienennettiin
- Alareunan suuret lisäyspainikkeet piilotetaan vaakasuunnassa
- Kirjan tietosivu uudistettiin kirjahyllyn visuaaliseen tyyliin
- Kirjan kansi esitetään tietosivulla hyllylaudan päällä
- Kirjan nimi ja tekijä nostettiin tietosivun pääsisällöksi
- Lukutila ja arvosana muutettiin suoraan napautettaviksi tietoriveiksi
- Muistiinpano muutettiin napautettavaksi kortiksi
- Kirjan perustietojen muokkaaminen siirrettiin yläpalkin muokkauspainikkeeseen
- Kirjan poistaminen muutettiin hillitymmäksi tekstipainikkeeksi
- Selkämyksen ja kansikuvan lukutilatunniste käyttävät yhteistä `ReadingStatusBadge`-widgetiä
- Näkymäasetukset palautetaan automaattisesti sovelluksen käynnistyessä

### Korjattu

- Korjattu kansiruudukon negatiivisen korkeuden aiheuttanut `BoxConstraints`-virhe
- Korjattu kannettomien kirjojen liian kapea esitys
- Korjattu kannettomien kirjojen otsikon ja tekijän ylivuoto
- Korjattu kirjan tietosivulta palaaminen kansikuvan vaihtamisen jälkeen
- Poistettu tarpeeton seuraavaa ruutua odottanut `addPostFrameCallback`
- Korjattu vanhan kansikuvatiedoston jääminen tallennustilaan kannen vaihtamisen jälkeen
- Korjattu kansikuvatiedoston jääminen tallennustilaan kirjan poistamisen jälkeen
- Lisätty kirjan päivityksen palautus aiempaan tilaan tallennuksen epäonnistuessa
- Korjattu kirjahyllyn vierittäminen puhelimen vaakasuunnassa
- Korjattu vaakasuuntaisen päänäkymän alareunan `RenderFlex`-ylivuoto
- Estetty negatiivisten kansimittojen muodostuminen väliaikaisissa asettelutilanteissa
- Korjattu Hero-animaation yhteydessä syntynyt mahdollisuus saman Hero-tunnisteen monistumiseen raahauksen aikana
- Korjattu lukutilatunnisteiden puuttuminen kansikuvanäkymästä Hero-animaation lisäämisen jälkeen
- Korjattu näkymäasetusten lataaminen sovelluksen alustuksen yhteydessä
- Korjattu käyttäjän valitseman näkymän palautuminen sovelluksen uudelleenkäynnistyksen jälkeen

### Testattu

- Oman kansikuvan oletusarvo
- Oman kansikuvan lisääminen `copyWith()`-metodilla
- Oman kansikuvan poistaminen `copyWith()`-metodilla
- Oman kansikuvan tiedostonimen JSON-tallennus ja palautus
- Vanhan JSON-datan yhteensopivuus oman kansikuvan kanssa
- Tyhjän kansikuvatiedostonimen käsittely
- Virheellisen kansikuvatiedostonimen tyypin hylkääminen
- Puuttuvan paikallisen kansikuvatiedoston käsittely
- Olemassa olevan paikallisen kansikuvatiedoston hakeminen
- Paikallisen kansikuvatiedoston poistaminen
- Kansikuvan vaihtaminen oikealla laitteella
- Oman kansikuvan poistaminen oikealla laitteella
- Verkkokannen palauttaminen
- Oman kansikuvan säilyminen sovelluksen uudelleenkäynnistyksen jälkeen
- Kansikuvanäkymän ja selkämyksenäkymän vaihtaminen
- Lukutilatunnisteiden näyttäminen molemmissa näkymissä
- Näkymäasetusten oletusarvot
- Tallennetun selkämyksenäkymän palauttaminen
- Tallennetun lukutilatunnisteasetuksen palauttaminen
- Tuntemattoman näkymäasetuksen palautuminen kansikuvanäkymään
- Kansikuvien responsiivinen asettelu
- Pysty- ja vaakasuuntainen näkymä
- Koko ruudun kirjahyllynäkymä
- Kirjojen raahaaminen ja pudottaminen kansikuvanäkymässä
- Kirjan siirtäminen järjestyksen loppuun
- Hero-animaatio kirjan tietosivulle
- Kirjan tietosivun toiminnot
- Flutter-analyysi
- Kaikki 63 automaattista testiä

### Tunnetut rajoitukset

- Käyttäjän itse valitsemat kansikuvat tallennetaan paikallisesti laitteen sovellushakemistoon
- JSON-varmuuskopio sisältää oman kansikuvan tiedostonimen, mutta ei itse kuvatiedostoa
- Varmuuskopion palauttaminen toiselle laitteelle ei vielä siirrä käyttäjän lisäämiä kansikuvia