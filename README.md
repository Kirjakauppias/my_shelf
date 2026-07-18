# My Shelf

My Shelf on Flutterilla toteutettu mobiilisovellus oman kirjakokoelman hallintaan.

Sovelluksella voi skannata kirjojen ISBN-viivakoodeja, hakea kirjan tiedot verkkopalveluista ja järjestää kirjat omiin virtuaalisiin kirjahyllyihin.

## Nykyinen versio

**v0.4.0-alpha**

Tämä on sovelluksen kehitysversio. Sovelluksen perustoiminnot ovat käytettävissä, mutta ominaisuudet, käyttöliittymä ja tietojen tallennustapa voivat vielä muuttua.

## Ominaisuudet

* Kirjan ISBN-viivakoodin skannaus
* Kirjatietojen haku Google Books -palvelusta
* Vaihtoehtoinen haku Open Library -palvelusta
* Kirjan lisääminen manuaalisesti
* Kirjan tietojen muokkaaminen
* Kirjan poistaminen
* Kirjojen järjestäminen kirjahyllyssä raahaamalla
* Useiden kirjahyllyjen luominen
* Kirjahyllyn valitseminen
* Kirjahyllyn nimeäminen uudelleen
* Kirjahyllyn poistaminen
* Poistetun hyllyn kirjojen siirtäminen oletushyllyyn
* Kirjojen ja kirjahyllyjen paikallinen tallennus
* Tallennettujen tietojen palauttaminen sovelluksen käynnistyessä

## Kirjahyllyt

Sovelluksessa on aina oletushylly, jota ei voi poistaa.

Käyttäjä voi luoda uusia hyllyjä esimerkiksi seuraaville kokoelmille:

* Fantasia
* Scifi
* Historia
* Sarjakuvat
* Lukemattomat kirjat

Uusi kirja lisätään sillä hetkellä valittuna olevaan hyllyyn.

Kun käyttäjän luoma hylly poistetaan, sen sisältämät kirjat siirretään automaattisesti oletushyllyyn.

## Tietojen tallennus

Kirjat ja kirjahyllyt tallennetaan laitteen paikalliseen tallennustilaan `SharedPreferences`-paketin avulla.

Tallennettavat tiedot muunnetaan JSON-muotoon ennen tallentamista.

Nykyinen alpha-versio ei vielä sisällä:

* pilvisynkronointia
* käyttäjätilejä
* varmuuskopiointia tiedostoon
* tietojen synkronointia useiden laitteiden välillä

## Käytetyt teknologiat

* Flutter
* Dart
* Material 3
* SharedPreferences
* Google Books API
* Open Library API
* ISBN-viivakoodin skannaus

## Projektin rakenne

Projektin keskeiset hakemistot:

```text
lib/
├── models/
│   ├── book.dart
│   └── shelf.dart
├── screens/
│   └── home_screen.dart
├── services/
│   ├── book_storage_service.dart
│   ├── shelf_storage_service.dart
│   └── ...
├── widgets/
│   ├── bookshelf.dart
│   └── ...
└── main.dart
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

## Kehitystilanne

Version `v0.4.0-alpha` pääpaino oli useiden kirjahyllyjen tuessa.

Toteutettuja kokonaisuuksia ovat:

* `Shelf`-tietomalli
* kirjahyllyjen paikallinen tallennus
* oletushyllyn automaattinen luominen
* valitun hyllyn kirjojen näyttäminen
* uuden hyllyn luominen
* hyllyn uudelleennimeäminen
* hyllyn poistaminen
* kirjojen säilyttäminen oikeissa hyllyissä sovelluksen uudelleenkäynnistyksen jälkeen

## Suunniteltuja ominaisuuksia

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

* kirjan siirtäminen hyllystä toiseen
* kirjahyllyjen järjestäminen
* kirjojen hakutoiminto
* lajittelu nimen, tekijän tai lisäysajan mukaan
* lukutila: lukematta, kesken ja luettu
* arviot ja muistiinpanot
* JSON-varmuuskopiointi ja palautus
* pilvisynkronointi

## Versiohistoria

Katso tarkemmat muutokset tiedostosta [CHANGELOG.md](CHANGELOG.md).

## Lisenssi

Tälle projektille ei ole vielä määritelty erillistä lisenssiä.
