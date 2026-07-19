# My Shelf

My Shelf on Flutterilla toteutettu mobiilisovellus oman kirjakokoelman hallintaan.

Sovelluksella voi skannata kirjojen ISBN-viivakoodeja, hakea kirjan tiedot verkkopalveluista sekä järjestää kirjat omiin virtuaalisiin kirjahyllyihin.

Kirjoja voi hakea, lajitella ja suodattaa lukutilan perusteella. Kirjastosta voi myös luoda JSON-varmuuskopion ja palauttaa tiedot myöhemmin varmuuskopiotiedostosta.

## Nykyinen versio

**v0.7.0-alpha**

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

### Haku ja lajittelu

* Reaaliaikainen hakutoiminto
* Haku kirjan nimellä
* Haku tekijän nimellä
* Haku ISBN-numerolla
* Haun tyhjentäminen yhdellä painikkeella
* Kirjojen näyttäminen omassa järjestyksessä
* Lajittelu kirjan nimen mukaan A–Ö tai Ö–A
* Lajittelu tekijän mukaan A–Ö tai Ö–A

Kirjojen raahaaminen on käytettävissä vain silloin, kun lajittelutavaksi on valittu **Oma järjestys** eikä tekstihaku tai lukutilasuodatus ole aktiivinen.

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

Kirjat voidaan suodattaa näyttämään:

* kaikki kirjat
* lukemattomat kirjat
* kesken olevat kirjat
* luetut kirjat

### Varmuuskopiointi ja palautus

Kirjoista ja kirjahyllyistä voidaan luoda JSON-muotoinen varmuuskopio.

Varmuuskopio sisältää:

* varmuuskopioformaatin versionumeron
* varmuuskopion luontiajankohdan
* kaikki kirjat ja niiden tiedot
* kirjojen lukutilat
* kirjojen kirjahyllyt
* kirjojen järjestyksen
* kaikki käyttäjän luomat kirjahyllyt

Varmuuskopio voidaan tallentaa tai jakaa käyttöjärjestelmän jakovalikon kautta.

Aiemmin luotu varmuuskopio voidaan palauttaa valitsemalla JSON-tiedosto laitteen tiedostonvalitsimesta.

Ennen palauttamista sovellus:

* tarkistaa varmuuskopion version
* tarkistaa JSON-rakenteen
* tarkistaa kirjojen ja kirjahyllyjen tunnisteet
* tarkistaa, että jokaisen kirjan kirjahylly löytyy varmuuskopiosta
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
* kirjojen oma järjestys
* käyttäjän luomat kirjahyllyt

Tallennetut tiedot palautetaan automaattisesti sovelluksen käynnistyessä.

JSON-varmuuskopio tarjoaa erillisen tavan siirtää tai säilyttää kirjaston tietoja sovelluksen paikallisen tallennuksen lisäksi.

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
├── widgets/
│   ├── book_spine.dart
│   ├── bookshelf.dart
│   ├── shelf_board.dart
│   ├── shelf_row.dart
│   └── ...
└── main.dart

test/
├── models/
│   └── library_backup_test.dart
├── services/
│   └── backup_import_service_test.dart
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

Version `v0.7.0-alpha` valmistuessa projektissa oli 20 läpäisevää testiä.

## Kehitystilanne

Version `v0.7.0-alpha` pääpaino on ollut kirjaston tietojen varmuuskopioinnissa ja palauttamisessa.

Toteutettuja kokonaisuuksia ovat:

* `LibraryBackup`-tietomalli
* versionumeroitu JSON-varmuuskopioformaatti
* kirjojen ja kirjahyllyjen vienti samaan tiedostoon
* varmuuskopion aikaleima
* JSON-tiedoston jakaminen ja tallentaminen
* JSON-varmuuskopion valitseminen tiedostonvalitsimella
* varmuuskopion rakenteen tarkistaminen
* kirjojen ja kirjahyllyjen eheystarkistukset
* palautuksen yhteenveto- ja vahvistusdialogi
* nykyisten tietojen korvaaminen varmuuskopion tiedoilla
* palautettujen tietojen tallentaminen paikalliseen tallennustilaan
* kattavat varmuuskopion validointitestit

## Suunniteltuja ominaisuuksia

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

* kirjahyllyjen järjestäminen
* lajittelu kirjan lisäysajan mukaan
* kirjan arvosana
* kirjakohtaiset muistiinpanot
* lukemisen aloitus- ja lopetuspäivämäärät
* automaattiset varmuuskopiot
* käyttöliittymän ja lukutilatunnisteiden viimeistely
* pilvisynkronointi
* käyttäjätilit

## Versiohistoria

Katso tarkemmat muutokset tiedostosta [CHANGELOG.md](CHANGELOG.md).

## Lisenssi

Tälle projektille ei ole vielä määritelty erillistä lisenssiä.