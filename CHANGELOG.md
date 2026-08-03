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