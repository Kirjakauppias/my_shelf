# My Shelf

My Shelf on Flutterilla toteutettu henkilökohtainen ja visuaalinen kirjastosovellus oman kirjakokoelman hallintaan.

Sovelluksen keskiössä on virtuaalinen kirjahylly, jossa kirjat esitetään oletuksena kansikuvina. Kirjoja voi lisätä skannaamalla ISBN-viivakoodin, hakemalla ISBN-numerolla tai syöttämällä kirjan tiedot käsin.

Kirjat voidaan järjestää omiin hyllyihin, lajitella, suodattaa ja asettaa haluttuun järjestykseen raahaamalla. Jokaiselle kirjalle voidaan tallentaa lukutila, tähtiarvosana, henkilökohtainen muistiinpano ja käyttäjän itse valitsema kansikuva.

## Nykyinen versio

**v0.10.0-alpha**

Tämä on sovelluksen kehitysversio. Sovelluksen keskeiset toiminnot ovat käytettävissä, mutta ominaisuudet, käyttöliittymä ja tietojen tallennustapa voivat vielä muuttua.

Version v0.10.0-alphan pääpaino on siirrettävässä ZIP-varmuuskopiossa, joka sisältää kirjastotietojen lisäksi käyttäjän omat paikalliset kansikuvat.

## Ominaisuudet

### Visuaalinen kirjahylly

* Kansikuvat kirjojen oletusnäkymänä
* Vaihtoehtoinen selkämyksenäkymä
* Koko ruudun kirjahyllynäkymä
* Hyllyn nimi koko ruudun näkymän nimikyltissä
* Responsiivinen asettelu pysty- ja vaakasuunnassa
* Kansien koon ja sarakemäärän automaattinen mukautuminen
* Kirjojen järjestäminen raahaamalla ja pudottamalla
* Pudotusalue kirjan siirtämiseksi järjestyksen loppuun
* Hero-animaatio kirjahyllyn ja kirjan tietosivun välillä
* Viimeistellyt puupinnat, hyllylaudat, varjot ja kansien välit
* Visuaaliset näkymät tyhjälle hyllylle sekä tyhjille haku- ja suodatustuloksille

Kirjahyllynäkymä toimii sekä puhelimen pysty- että vaakasuunnassa. Vaakasuunnassa käyttöliittymä tiivistyy automaattisesti, jotta hyllylle ja sen vierittämiselle jää riittävästi tilaa.

### Kansikuvat

Kirjan kansi valitaan seuraavassa järjestyksessä:

1. käyttäjän itse valitsema kansikuva
2. kirjatietopalvelusta löytynyt verkkokansi
3. sovelluksen muodostama varakansi

Kansikuville tuetaan seuraavia toimintoja:

* Kansikuvan hakeminen kirjatietopalvelusta
* Oman kansikuvan valitseminen laitteen kuvakirjastosta
* Oman kansikuvan vaihtaminen
* Oman kansikuvan poistaminen
* Verkosta haetun kannen palauttaminen
* Paikallisten kansikuvatiedostojen turvallinen tallentaminen
* Vanhan kansikuvatiedoston poistaminen kantta vaihdettaessa
* Kansikuvatiedoston poistaminen kirjaa poistettaessa
* Pehmeä lataustila verkko- ja paikallisille kuville
* Tyylitelty varakansi kirjoille, joilla ei ole kansikuvaa

Varakannen väri perustuu kirjan selkämyksen väriin. Tekstin väri valitaan automaattisesti kannen vaaleuden perusteella.

### Kirjojen hallinta

* Kirjan ISBN-viivakoodin skannaus
* ISBN-numeron syöttäminen käsin
* Kirjatietojen haku Google Books -palvelusta
* Vaihtoehtoinen haku Open Library -palvelusta
* Kirjan lisääminen kokonaan käsin
* Kirjan tietojen tarkasteleminen
* Kirjan tietojen muokkaaminen
* Kansikuvan vaihtaminen
* Kirjan poistaminen
* Kirjan siirtäminen hyllystä toiseen

### Kirjahyllyt

* Useiden kirjahyllyjen luominen
* Kirjahyllyn valitseminen
* Kirjahyllyn nimeäminen uudelleen
* Kirjahyllyn poistaminen
* Poistetun hyllyn kirjojen siirtäminen oletushyllyyn
* Kirjojen järjestäminen raahaamalla
* Kirjojen järjestyksen säilyttäminen sovelluksen käynnistysten välillä

Sovelluksessa on aina oletushylly, jota ei voi poistaa.

Käyttäjä voi luoda uusia hyllyjä esimerkiksi seuraaville kokoelmille:

* Fantasia
* Scifi
* Historia
* Sarjakuvat
* Tietokirjat

Uusi kirja lisätään sillä hetkellä valittuna olevaan hyllyyn. Kirja voidaan myöhemmin siirtää toiseen hyllyyn kirjan toimintojen kautta.

Kun käyttäjän luoma hylly poistetaan, sen sisältämät kirjat siirretään automaattisesti oletushyllyyn.

### Haku

Kirjoja voidaan hakea reaaliaikaisesti:

* kirjan nimellä
* tekijän nimellä
* ISBN-numerolla

Haku kohdistuu sillä hetkellä valittuna olevan kirjahyllyn kirjoihin.

Hakukenttä avataan päänäkymän hakukuvakkeesta, jotta kirjahyllylle jää mahdollisimman paljon näkyvää tilaa.

### Lajittelu

Kirjat voidaan järjestää seuraavilla tavoilla:

* Oma järjestys
* Nimi A–Ö
* Nimi Ö–A
* Tekijä A–Ö
* Tekijä Ö–A
* Arvosana 5–1
* Arvosana 1–5

Arvioimattomat kirjat sijoitetaan arvosanalajittelussa listan loppuun.

Kirjojen raahaaminen on käytettävissä vain silloin, kun lajittelutavaksi on valittu **Oma järjestys** eikä haku tai suodatus ole aktiivinen.

### Lukutilat

Jokaiselle kirjalle voidaan määrittää yksi seuraavista lukutiloista:

* Lukematta
* Kesken
* Luettu

Lukutila:

* tallennetaan kirjan mukana
* näkyy kirjan tietosivulla
* voidaan vaihtaa kirjan tietosivulta
* voidaan käyttää kirjojen suodattamiseen
* voidaan näyttää tunnisteena kansikuvassa
* voidaan näyttää tunnisteena kirjan selkämyksessä

Lukutilatunnisteiden näyttäminen on valinnainen asetus. Valinta säilyy sovelluksen uudelleenkäynnistyksen jälkeen.

### Arvosanat

Kirjalle voidaan antaa arvosana yhdestä viiteen tähteä.

Arvosana:

* tallennetaan kirjan mukana
* näkyy kirjan tietosivulla
* voidaan vaihtaa tai poistaa
* säilyy sovelluksen uudelleenkäynnistyksen jälkeen
* sisältyy varmuuskopioon
* voidaan käyttää lajitteluun ja suodattamiseen

Kirja voi olla myös arvioimaton.

### Muistiinpanot

Jokaiselle kirjalle voidaan tallentaa henkilökohtainen muistiinpano.

Muistiinpanoa voidaan käyttää esimerkiksi:

* oman lukukokemuksen kirjaamiseen
* huomioiden tallentamiseen
* muistettavien asioiden merkitsemiseen
* lainassa olevan kirjan tietojen kirjaamiseen

Muistiinpano voidaan lisätä, muokata tai poistaa. Se tallennetaan kirjan mukana ja sisältyy varmuuskopioon.

### Suodatus

Kirjoja voidaan suodattaa lukutilan perusteella:

* Kaikki
* Lukematta
* Kesken
* Luettu

Lisäksi kirjoja voidaan suodattaa sisällön perusteella:

* Kaikki
* Arvioidut
* Arvioimattomat
* Sisältää muistiinpanon

Tekstihaku, lukutilasuodatus, sisältösuodatus ja lajittelu toimivat yhdessä.

### Kirjan tietosivu

Kirjan tietosivu on suunniteltu vastaamaan virtuaalisen kirjahyllyn visuaalista tyyliä.

Tietosivulla voidaan:

* tarkastella kirjan kantta, nimeä ja tekijää
* vaihtaa tai poistaa kansikuva
* palauttaa verkkokansi
* tarkastella ISBN-numeroa ja sivumäärää
* vaihtaa lukutilaa
* antaa, muuttaa tai poistaa arvosana
* lisätä tai muokata muistiinpanoa
* muokata kirjan perustietoja
* poistaa kirja

Lukutilaa, arvosanaa ja muistiinpanoa voidaan muuttaa suoraan niitä vastaavia tietorivejä napauttamalla.

### Näkymäasetukset

Käyttäjä voi valita:

* kansikuvanäkymän
* selkämyksenäkymän
* lukutilatunnisteiden näyttämisen

Näkymäasetukset tallennetaan paikallisesti ja palautetaan automaattisesti sovelluksen käynnistyessä.

Kansikuvanäkymä on sovelluksen oletusnäkymä.

### Varmuuskopiointi ja palautus

Kirjoista, kirjahyllyistä ja käyttäjän omista kansikuvista voidaan luoda siirrettävä ZIP-varmuuskopio.

ZIP-varmuuskopio sisältää:

* arkiston rakennetta kuvaavan `manifest.json`-tiedoston
* kirjastotiedot sisältävän `library.json`-tiedoston
* varmuuskopion luontiajankohdan
* kaikki kirjat ja niiden perustiedot
* kirjojen verkkokansien osoitteet
* käyttäjän paikalliset kansikuvat varsinaisina kuvatiedostoina
* kirjojen lukutilat
* kirjojen arvosanat
* kirjojen muistiinpanot
* kirjojen kirjahyllyt
* kirjojen järjestyksen
* kaikki käyttäjän luomat kirjahyllyt

Varmuuskopio voidaan tallentaa tai jakaa käyttöjärjestelmän jakovalikon kautta.

Sovellus tukee palautuksessa kahta tiedostomuotoa:

* uusi kansikuvat sisältävä ZIP-varmuuskopio
* aiemmissa versioissa luotu JSON-varmuuskopio

Vanha JSON-varmuuskopio sisältää kirjastotiedot mutta ei varsinaisia paikallisia kansikuvatiedostoja.

Ennen palauttamista sovellus:

* tunnistaa JSON- ja ZIP-varmuuskopiot
* tarkistaa varmuuskopion ja arkiston version
* tarkistaa JSON-rakenteen
* tarkistaa ZIP-arkiston sallitut tiedostot ja hakemistot
* estää turvattomat tiedostopolut ja symboliset linkit
* rajoittaa arkiston ja yksittäisten tiedostojen kokoa
* tarkistaa kirjojen ja kirjahyllyjen tunnisteet
* tunnistaa päällekkäiset tunnisteet
* tarkistaa kirjojen viittaukset kirjahyllyihin
* tarkistaa paikallisten kansikuvien viittaukset ja kuvatiedostot
* näyttää palautettavien kirjojen, kirjahyllyjen ja kansikuvien määrän
* pyytää käyttäjältä vahvistuksen

ZIP-varmuuskopion kansikuvat otetaan käyttöön transaktiona. Vanhoista samannimisistä kuvista tehdään väliaikaiset varakopiot, ja palautus vahvistetaan vasta kirjastotietojen onnistuneen tallennuksen jälkeen.

Jos tallennus epäonnistuu, sovellus yrittää palauttaa sekä aiemmat kirjastotiedot että aiemmat kansikuvat. Onnistuneen palautuksen jälkeen tarpeettomiksi jääneet vanhan kirjaston kansikuvat poistetaan.

Varmuuskopion palauttaminen korvaa sovelluksessa sillä hetkellä olevat kirjat ja kirjahyllyt. ZIP-varmuuskopio palauttaa lisäksi siihen sisältyvät paikalliset kansikuvat.

## Tietojen tallennus

Kirjat, kirjahyllyt ja käyttöliittymän näkymäasetukset tallennetaan laitteen paikalliseen tallennustilaan.

Kirjat ja hyllyt muunnetaan JSON-muotoon ennen tallentamista. Käyttäjän omat kansikuvat tallennetaan sovelluksen omaan pysyvään tiedostohakemistoon.

Paikallisesti tallennettavia tietoja ovat esimerkiksi:

* kirjojen perustiedot
* ISBN-numero
* verkkokannen osoite
* oman kansikuvan tiedostonimi
* kirjan selkämyksen väri
* kirjan hylly
* kirjan lukutila
* kirjan arvosana
* kirjan muistiinpano
* kirjojen oma järjestys
* käyttäjän luomat kirjahyllyt
* valittu kirjojen esitystapa
* lukutilatunnisteiden näkyvyys

Tallennetut tiedot palautetaan automaattisesti sovelluksen käynnistyessä.

ZIP-varmuuskopio tarjoaa erillisen tavan säilyttää ja siirtää kirjaston tiedot sekä käyttäjän omat kansikuvat sovelluksen paikallisen tallennuksen lisäksi. Vanhojen JSON-varmuuskopioiden palautusta tuetaan edelleen.

Nykyinen alpha-versio ei vielä sisällä:

* automaattista pilvisynkronointia
* käyttäjätilejä
* automaattisia varmuuskopioita
* tietojen automaattista synkronointia useiden laitteiden välillä

## Käytetyt teknologiat

* Flutter
* Dart
* Material 3
* Shared Preferences
* JSON
* Google Books API
* Open Library API
* HTTP
* Mobile Scanner
* Image Picker
* Path Provider
* Path
* Share Plus
* File Selector
* Archive
* ZIP

## Projektin rakenne

Projektin keskeiset hakemistot:

```text
lib/
├── dialogs/
│   ├── manual_book_dialog.dart
│   └── ...
├── models/
│   ├── book.dart
│   ├── library_backup.dart
│   ├── library_view_settings.dart
│   ├── portable_backup_archive_data.dart
│   ├── portable_backup_manifest.dart
│   ├── shelf.dart
│   └── ...
├── screens/
│   ├── book_details_screen.dart
│   └── home_screen.dart
├── services/
│   ├── backup_export_service.dart
│   ├── backup_import_service.dart
│   ├── book_storage_service.dart
│   ├── custom_cover_service.dart
│   ├── library_backup_validator.dart
│   ├── library_view_settings_service.dart
│   ├── portable_backup_archive_reader.dart
│   ├── portable_backup_archive_service.dart
│   ├── portable_cover_restore_service.dart
│   ├── shelf_storage_service.dart
│   └── ...
├── theme/
│   └── app_theme.dart
├── utils/
│   └── book_query.dart
├── widgets/
│   ├── book_cover_card.dart
│   ├── book_cover_hero.dart
│   ├── book_cover_image.dart
│   ├── book_cover_shelf.dart
│   ├── book_spine.dart
│   ├── bookshelf.dart
│   ├── reading_status_badge.dart
│   ├── shelf_board.dart
│   ├── shelf_empty_state.dart
│   ├── shelf_row.dart
│   └── ...
└── main.dart

test/
├── models/
│   ├── book_custom_cover_test.dart
│   ├── book_notes_test.dart
│   ├── book_rating_test.dart
│   ├── library_backup_test.dart
│   ├── library_view_settings_test.dart
│   └── ...
├── services/
│   ├── backup_export_service_test.dart
│   ├── backup_import_service_test.dart
│   ├── custom_cover_service_test.dart
│   ├── portable_backup_archive_reader_test.dart
│   ├── portable_backup_archive_service_test.dart
│   ├── portable_cover_restore_service_test.dart
│   └── ...
├── utils/
│   └── book_query_test.dart
└── ...
```

Tiedostorakenne voi muuttua sovelluksen kehityksen aikana.

## Projektin käynnistäminen

Varmista ensin, että Flutter on asennettu ja käytettävissä komentoriviltä.

Hae projektin riippuvuudet:

```bash
flutter pub get
```

Käynnistä sovellus:

```bash
flutter run
```

## Tarkistukset ja testit

Muotoile lähdekoodi:

```bash
dart format lib test
```

Tarkista lähdekoodi:

```bash
flutter analyze
```

Suorita testit:

```bash
flutter test
```

Version `v0.10.0-alpha` valmisteluvaiheessa projektissa on **98 läpäisevää automaattista testiä**.

Testit kattavat muun muassa:

* kirjamallin JSON-muunnokset
* arvosanojen validoinnin
* muistiinpanojen tallennuksen
* käyttäjän oman kansikuvan tietomallin
* paikallisten kansikuvatiedostojen hakemisen ja poistamisen
* varmuuskopion tietomallin
* siirrettävän varmuuskopion manifestin
* ZIP-varmuuskopion muodostamisen
* kansikuvatiedostojen lisäämisen ZIP-arkistoon
* ZIP-arkiston turvallisen lukemisen
* JSON- ja ZIP-varmuuskopioiden tunnistamisen
* varmuuskopion palautuksen validoinnin
* paikallisten kansikuvien transaktionaalisen palautuksen
* kansikuvien palautuksen vahvistamisen ja perumisen
* kirjahaun
* kirjahyllyrajauksen
* lukutilasuodatuksen
* arvosana- ja muistiinpanosuodatuksen
* lajittelun
* eri hakujen ja suodattimien yhdistelmät
* alkuperäisen kirjalistan järjestyksen säilymisen
* näkymäasetusten oletusarvot ja tallennettujen arvojen palauttamisen

## Kehitystilanne

Version `v0.10.0-alpha` pääpaino on ollut siirrettävän, kansikuvat sisältävän varmuuskopioinnin toteuttamisessa.

Toteutettuja kokonaisuuksia ovat:

* ZIP-muotoinen siirrettävä varmuuskopio
* erilliset `manifest.json`- ja `library.json`-tiedostot
* käyttäjän omien kansikuvien sisällyttäminen varmuuskopioon
* vain käytössä olevien kansikuvatiedostojen lisääminen arkistoon
* JSON- ja ZIP-varmuuskopioiden yhteensopiva palauttaminen
* ZIP-arkiston rakenteen, tiedostopolkujen ja kokorajojen tarkistaminen
* puuttuvien, ylimääräisten ja tyhjien kansikuvatiedostojen tunnistaminen
* kansikuvien turvallinen valmistelu väliaikaishakemistossa
* vanhojen samannimisten kansikuvien väliaikainen varmistaminen
* kansikuvien palautuksen `commit`- ja `rollback`-toiminnot
* aiempien kirjastotietojen palautusyritys tallennusvirheessä
* tarpeettomien vanhojen kansikuvien siivous onnistuneen palautuksen jälkeen
* varmuuskopion tietojen ja kansikuvien määrän näyttäminen vahvistusdialogissa
* kirjan kaikkien tietojen säilyttäminen hyllystä toiseen siirrettäessä

## Suunniteltuja ominaisuuksia

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

* kirjahyllyjen järjestäminen
* lajittelu kirjan lisäysajan mukaan
* lukemisen aloitus- ja lopetuspäivämäärät
* lukemisen tilastot
* kirjan lainaustiedot
* automaattiset varmuuskopiot
* pilvisynkronointi
* käyttäjätilit

## Versiohistoria

Katso tarkemmat muutokset tiedostosta [CHANGELOG.md](CHANGELOG.md).

## Lisenssi

Tälle projektille ei ole vielä määritelty erillistä lisenssiä.