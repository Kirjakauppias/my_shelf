## [Unreleased]

### Suunnitteilla

- Käyttäjän omien kansikuvatiedostojen sisällyttäminen varmuuskopioon
- Kirjahyllyjen järjestäminen
- Lajittelu kirjan lisäysajan perusteella
- Lukemisen aloitus- ja lopetuspäivämäärät
- Lukemisen tilastot
- Kirjan lainaustiedot
- Automaattiset varmuuskopiot
- Pilvisynkronointi
- Käyttäjätilit

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