# My Shelf

My Shelf on Flutterilla toteutettu henkilökohtainen ja visuaalinen kirjastosovellus oman kirjakokoelman hallintaan.

Sovelluksen keskiössä on virtuaalinen kirjahylly, jossa kirjat esitetään oletuksena kansikuvina. Kirjoja voi lisätä skannaamalla ISBN-viivakoodin, hakemalla ISBN-numerolla tai syöttämällä kirjan tiedot käsin.

Kirjat voidaan järjestää omiin hyllyihin, lajitella, suodattaa ja asettaa haluttuun järjestykseen raahaamalla. Jokaiselle kirjalle voidaan tallentaa lukutila, tähtiarvosana, henkilökohtainen muistiinpano ja käyttäjän itse valitsema kansikuva.

## Nykyinen versio

**v0.9.0-alpha**

Tämä on sovelluksen kehitysversio. Sovelluksen keskeiset toiminnot ovat käytettävissä, mutta ominaisuudet, käyttöliittymä ja tietojen tallennustapa voivat vielä muuttua.

Version v0.9.0-alphan pääpaino on kirjahyllyn visuaalisessa ilmeessä, kansikuvissa ja käyttöliittymän viimeistelyssä.

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
* sisältyy JSON-varmuuskopioon
* voidaan käyttää lajitteluun ja suodattamiseen

Kirja voi olla myös arvioimaton.

### Muistiinpanot

Jokaiselle kirjalle voidaan tallentaa henkilökohtainen muistiinpano.

Muistiinpanoa voidaan käyttää esimerkiksi:

* oman lukukokemuksen kirjaamiseen
* huomioiden tallentamiseen
* muistettavien asioiden merkitsemiseen
* lainassa olevan kirjan tietojen kirjaamiseen

Muistiinpano voidaan lisätä, muokata tai poistaa. Se tallennetaan kirjan mukana ja sisältyy JSON-varmuuskopioon.

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

Kirjoista ja kirjahyllyistä voidaan luoda JSON-muotoinen varmuuskopio.

Varmuuskopio sisältää:

* varmuuskopioformaatin versionumeron
* varmuuskopion luontiajankohdan
* kaikki kirjat ja niiden perustiedot
* kirjojen verkkokansien osoitteet
* käyttäjän kansikuvatiedostojen nimet
* kirjojen lukutilat
* kirjojen arvosanat
* kirjojen muistiinpanot
* kirjojen kirjahyllyt
* kirjojen järjestyksen
* kaikki käyttäjän luomat kirjahyllyt

Varmuuskopio voidaan tallentaa tai jakaa käyttöjärjestelmän jakovalikon kautta.

Aiemmin luotu varmuuskopio voidaan palauttaa valitsemalla JSON-tiedosto laitteen tiedostonvalitsimesta.

Ennen palauttamista sovellus:

* tarkistaa varmuuskopion version
* tarkistaa JSON-rakenteen
* tarkistaa kirjojen ja kirjahyllyjen tunnisteet
* tunnistaa päällekkäiset tunnisteet
* tarkistaa kirjojen viittaukset kirjahyllyihin
* näyttää palautettavien kirjojen ja kirjahyllyjen määrän
* pyytää käyttäjältä vahvistuksen

Varmuuskopion palauttaminen korvaa sovelluksessa sillä hetkellä olevat kirjat ja kirjahyllyt.

> **Huomio:** käyttäjän itse lisäämät kansikuvat eivät vielä sisälly varsinaisina kuvatiedostoina JSON-varmuuskopioon. Varmuuskopio sisältää tällä hetkellä vain paikallisen kansikuvatiedoston nimen. Palauttaminen toiselle laitteelle ei tämän vuoksi siirrä käyttäjän lisäämiä kansikuvia.

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

JSON-varmuuskopio tarjoaa erillisen tavan säilyttää ja siirtää kirjaston tietoja sovelluksen paikallisen tallennuksen lisäksi.

Nykyinen alpha-versio ei vielä sisällä:

* automaattista pilvisynkronointia
* käyttäjätilejä
* automaattisia varmuuskopioita
* tietojen automaattista synkronointia useiden laitteiden välillä
* paikallisten kansikuvatiedostojen sisällyttämistä varmuuskopioon

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
│   ├── library_view_settings_service.dart
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
│   ├── backup_import_service_test.dart
│   ├── custom_cover_service_test.dart
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

Version `v0.9.0-alpha` valmisteluvaiheessa projektissa on **63 läpäisevää automaattista testiä**.

Testit kattavat muun muassa:

* kirjamallin JSON-muunnokset
* arvosanojen validoinnin
* muistiinpanojen tallennuksen
* käyttäjän oman kansikuvan tietomallin
* paikallisten kansikuvatiedostojen hakemisen ja poistamisen
* varmuuskopion tietomallin
* varmuuskopion palautuksen validoinnin
* kirjahaun
* kirjahyllyrajauksen
* lukutilasuodatuksen
* arvosana- ja muistiinpanosuodatuksen
* lajittelun
* eri hakujen ja suodattimien yhdistelmät
* alkuperäisen kirjalistan järjestyksen säilymisen
* näkymäasetusten oletusarvot ja tallennettujen arvojen palauttamisen

## Kehitystilanne

Version `v0.9.0-alpha` pääpaino on ollut visuaalisen kirjahyllyn ja käyttöliittymän uudistamisessa.

Toteutettuja kokonaisuuksia ovat:

* kansikuvien käyttäminen oletusnäkymänä
* selkämyksenäkymän säilyttäminen vaihtoehtona
* koko ruudun kirjahyllynäkymä
* käyttäjän omat kansikuvat
* omien kansikuvien vaihtaminen ja poistaminen
* tarpeettomien kuvatiedostojen siivous
* responsiivinen kansien asettelu
* puhelimen vaakasuunnan käyttöliittymä
* kirjahyllyn, hyllylautojen ja kansikorttien visuaalinen viimeistely
* tyylitellyt varakannet ja lataustilat
* tyhjän hyllyn sekä tyhjien hakujen ja suodatusten näkymät
* Hero-animaatio kirjan tietosivulle
* kirjan tietosivun visuaalinen uudistus
* näkymäasetusten paikallinen tallennus
* lukutilatunnisteiden valinnainen näyttäminen

## Suunniteltuja ominaisuuksia

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

* käyttäjän kansikuvien sisällyttäminen varmuuskopioon
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