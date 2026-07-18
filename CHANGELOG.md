Changelog

Kaikki My Shelf -sovelluksen merkittävät muutokset dokumentoidaan tähän tiedostoon.

Projektissa käytetään semanttista versionumerointia soveltuvin osin.

[Unreleased]
Suunnitteilla
Kirjojen siirtäminen kirjahyllystä toiseen
Kirjahyllyjen järjestäminen
Kirjojen haku ja lajittelu
Lukutilan lisääminen
JSON-varmuuskopiointi ja palautus
[0.4.0-alpha] - 2026-07-18
Lisätty
Uusi Shelf-tietomalli
Kirjahyllyn yksilöllinen tunniste
Kirjahyllyn nimi
Kirjahyllyn järjestysnumero
shelfId-kenttä Book-malliin
Takautuva yhteensopivuus vanhoille kirjoille, joilta puuttuu shelfId
ShelfStorageService kirjahyllyjen paikallista tallennusta varten
Kirjahyllyjen lataaminen sovelluksen käynnistyessä
Oletushyllyn automaattinen luominen
Kirjahyllyn valintavalikko
Valitun kirjahyllyn kirjojen suodatus
Kirjojen määrän näyttäminen hyllyn nimen yhteydessä
Tyhjän kirjahyllyn näkymä
Uuden kirjahyllyn luontidialogi
Samannimisten kirjahyllyjen estäminen
Automaattinen siirtyminen juuri luotuun kirjahyllyyn
Uuden kirjan lisääminen valittuna olevaan kirjahyllyyn
Kirjahyllyn uudelleennimeäminen
Kirjahyllyn poistamisen vahvistusdialogi
Kirjahyllyn toimintovalikko
Oletushyllyn poistamisen estäminen
Poistettavan kirjahyllyn kirjojen siirtäminen oletushyllyyn
Kirjahyllyjen järjestysnumeroiden päivittäminen poiston jälkeen
Kirjahyllyjen ja kirjojen säilyminen sovelluksen uudelleenkäynnistyksen jälkeen
Muutettu
Kirjojen järjestely toimii vain sillä hetkellä valitun kirjahyllyn sisällä
Bookshelf-widgetin järjestelycallback käyttää kirjoja indeksien sijaan
Sovelluksen käynnistys lataa kirjat ja kirjahyllyt rinnakkain
Kirjojen tallennus huomioi kirjan kirjahyllyn
Kirjahyllyn poistaminen vaihtaa aktiiviseksi hyllyksi oletushyllyn
Kirjahyllyn uudelleennimeäminen säilyttää hyllyn alkuperäisen tunnisteen
Korjattu
Korjattu Bookshelf-widgetin callbackin väärä parametrityyppi
Korjattu valitun hyllyn kirjojen drag and drop -järjestely
Korjattu muiden hyllyjen kirjojen järjestyksen tahaton muuttuminen
Korjattu uuden kirjahyllyn luontidialogin TextEditingController-elinkaariongelma
Estetty tyhjän nimisen kirjahyllyn luominen
Estetty kahden samannimisen kirjahyllyn luominen kirjainkoosta riippumatta
Testattu
Kirjahyllyn luominen
Kirjahyllyn valitseminen
Kirjan skannaaminen valittuun kirjahyllyyn
Kirjahyllyn uudelleennimeäminen
Kirjahyllyn poistaminen
Kirjojen siirtyminen oletushyllyyn hyllyn poiston yhteydessä
Tietojen säilyminen sovelluksen uudelleenkäynnistyksen jälkeen
Flutter-analyysi
Sovelluksen yksikkötestit
[0.3.0-alpha]
Lisätty
Kirjojen paikallinen tallennus
Tallennettujen kirjojen lataaminen sovelluksen käynnistyessä
Kirjan lisääminen
Kirjan muokkaaminen
Kirjan poistaminen
Kirjojen järjestäminen raahaamalla
Google Books -haku
Open Library -varahaku
ISBN-viivakoodin skannaus
Manuaalinen kirjan lisääminen
Muutettu
Kirjalistan käsittely keskitettiin sovelluksen päänäkymään
Tallennusratkaisuksi otettiin SharedPreferences
Testattu
Kirjamallin JSON-muunnokset
Kirjojen tallennus ja lataaminen
Kirjojen järjestäminen