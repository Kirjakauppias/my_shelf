# My Shelf

My Shelf on Flutterilla toteutettu mobiilisovellus oman kirjakokoelman hallintaan.

Sovelluksella voi skannata kirjojen ISBN-viivakoodeja, hakea kirjan tiedot verkkopalveluista sekä järjestää kirjat omiin virtuaalisiin kirjahyllyihin.

Kirjoja voi hakea, lajitella ja suodattaa. Jokaiselle kirjalle voidaan tallentaa lukutila, tähtiarvosana ja henkilökohtainen muistiinpano. Kirjastosta voidaan myös luoda JSON-varmuuskopio ja palauttaa tiedot myöhemmin varmuuskopiotiedostosta.

## Nykyinen versio

**v0.8.0-alpha**

Tämä on sovelluksen kehitysversio. Sovelluksen keskeiset perustoiminnot ovat käytettävissä, mutta ominaisuudet, käyttöliittymä ja tietojen tallennustapa voivat vielä muuttua.

## Ominaisuudet

### Kirjojen hallinta

* Kirjan ISBN-viivakoodin skannaus
* ISBN-numeron syöttäminen käsin
* Kirjatietojen haku Google Books -palvelusta
* Vaihtoehtoinen haku Open Library -palvelusta
* Kirjan lisääminen manuaalisesti
* Kirjan tietojen tarkasteleminen
* Kirjan tietojen muokkaaminen
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

### Haku

Kirjoja voidaan hakea reaaliaikaisesti:

* kirjan nimellä
* tekijän nimellä
* ISBN-numerolla

Haku kohdistuu sillä hetkellä valittuna olevan kirjahyllyn kirjoihin.

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
* näkyy kirjan tietonäkymässä
* voidaan vaihtaa kirjan tietonäkymästä
* näkyy tunnisteena kirjan selkämyksessä
* voidaan käyttää kirjojen suodattamiseen

### Arvosanat

Kirjalle voidaan antaa arvosana yhdestä viiteen tähteä.

Arvosana:

* tallennetaan kirjan mukana
* näkyy kirjan tietonäkymässä
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

### Varmuuskopiointi ja palautus

Kirjoista ja kirjahyllyistä voidaan luoda JSON-muotoinen varmuuskopio.

Varmuuskopio sisältää:

* varmuuskopioformaatin versionumeron
* varmuuskopion luontiajankohdan
* kaikki kirjat ja niiden perustiedot
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

## Kirjahyllyt

Sovelluksessa on aina oletushylly, jota ei voi poistaa.

Käyttäjä voi luoda uusia hyllyjä esimerkiksi seuraaville kokoelmille:

* Fantasia
* Scifi
* Historia
* Sarjakuvat
* Tietokirjat

Uusi kirja lisätään sillä hetkellä valittuna olevaan hyllyyn.

Kirja voidaan myöhemmin siirtää toiseen hyllyyn kirjan toimintovalikon kautta.

Kun käyttäjän luoma hylly poistetaan, sen sisältämät kirjat siirretään automaattisesti oletushyllyyn.

## Tietojen tallennus

Kirjat ja kirjahyllyt tallennetaan laitteen paikalliseen tallennustilaan `SharedPreferences`-paketin avulla.

Tallennettavat tiedot muunnetaan JSON-muotoon ennen tallentamista.

Paikallisesti tallennettavia tietoja ovat esimerkiksi:

* kirjojen perustiedot
* ISBN-numero
* kansikuvan osoite
* kirjan selkämyksen väri
* kirjan hylly
* kirjan lukutila
* kirjan arvosana
* kirjan muistiinpano
* kirjojen oma järjestys
* käyttäjän luomat kirjahyllyt

Tallennetut tiedot palautetaan automaattisesti sovelluksen käynnistyessä.

JSON-varmuuskopio tarjoaa erillisen tavan säilyttää ja siirtää kirjaston tietoja sovelluksen paikallisen tallennuksen lisäksi.

Nykyinen alpha-versio ei vielä sisällä:

* automaattista pilvisynkronointia
* käyttäjätilejä
* automaattisia varmuuskopioita
* tietojen automaattista synkronointia useiden laitteiden välillä

## Käytetyt teknologiat

* Flutter
* Dart
* Material 3
* SharedPreferences
* JSON
* Google Books API
* Open Library API
* ISBN-viivakoodin skannaus
* `share_plus`
* `file_selector`

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
│   └── shelf.dart
├── screens/
│   ├── book_details_screen.dart
│   └── home_screen.dart
├── services/
│   ├── backup_export_service.dart
│   ├── backup_import_service.dart
│   ├── book_storage_service.dart
│   ├── shelf_storage_service.dart
│   └── ...
├── utils/
│   └── book_query.dart
├── widgets/
│   ├── book_spine.dart
│   ├── bookshelf.dart
│   ├── shelf_board.dart
│   ├── shelf_row.dart
│   └── ...
└── main.dart

test/
├── models/
│   ├── book_notes_test.dart
│   ├── book_rating_test.dart
│   └── library_backup_test.dart
├── services/
│   └── backup_import_service_test.dart
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

Version `v0.8.0-alpha` valmistuessa projektissa oli **49 läpäisevää automaattista testiä**.

Testit kattavat muun muassa:

* kirjamallin JSON-muunnokset
* arvosanojen validoinnin
* muistiinpanojen tallennuksen
* varmuuskopion viennin tietomallin
* varmuuskopion palautuksen validoinnin
* kirjahaun
* kirjahyllyrajauksen
* lukutilasuodatuksen
* arvosana- ja muistiinpanosuodatuksen
* lajittelun
* eri hakujen ja suodattimien yhdistelmät
* alkuperäisen kirjalistan järjestyksen säilymisen

## Kehitystilanne

Version `v0.8.0-alpha` pääpaino on ollut kirjojen henkilökohtaisten tietojen ja kirjaston selaustoimintojen laajentamisessa.

Toteutettuja kokonaisuuksia ovat:

* yhden–viiden tähden arvosanat
* arvosanan vaihtaminen ja poistaminen
* kirjakohtaiset muistiinpanot
* muistiinpanon lisääminen, muokkaaminen ja poistaminen
* arvosanaan perustuva lajittelu
* arvioitujen ja arvioimattomien kirjojen suodatus
* muistiinpanoja sisältävien kirjojen suodatus
* hakujen, suodatusten ja lajittelun yhteistoiminta
* haku- ja suodatuslogiikan siirtäminen erilliseen `book_query.dart`-tiedostoon
* uuden hakulogiikan kattavat automaattiset testit

## Suunniteltuja ominaisuuksia

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

* kirjahyllyjen järjestäminen
* lajittelu kirjan lisäysajan mukaan
* lukemisen aloitus- ja lopetuspäivämäärät
* kirjan lainaustiedot
* automaattiset varmuuskopiot
* käyttöliittymän ja lukutilatunnisteiden viimeistely
* pilvisynkronointi
* käyttäjätilit

## Versiohistoria

Katso tarkemmat muutokset tiedostosta [CHANGELOG.md](CHANGELOG.md).

## Lisenssi

Tälle projektille ei ole vielä määritelty erillistä lisenssiä.