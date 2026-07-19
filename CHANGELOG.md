# Changelog

Kaikki My Shelf -sovelluksen merkittävät muutokset dokumentoidaan tähän tiedostoon.

Projektissa käytetään semanttista versionumerointia soveltuvin osin.

## [Unreleased]

### Suunnitteilla

- Kirjahyllyjen järjestäminen
- Kirjan arvosana
- Kirjakohtaiset muistiinpanot
- Lukemisen aloitus- ja lopetuspäivämäärät
- Lajittelu kirjan lisäysajan perusteella
- JSON-varmuuskopiointi ja palautus
- Käyttöliittymän ja lukutilatunnisteiden viimeistely
- Pilvisynkronointi
- Käyttäjätilit

## [0.6.0-alpha] - 2026-07-19

### Lisätty

- Kirjojen lajittelu kirjan nimen mukaan A–Ö
- Kirjojen lajittelu kirjan nimen mukaan Ö–A
- Kirjojen lajittelu tekijän mukaan A–Ö
- Kirjojen lajittelu tekijän mukaan Ö–A
- Oma järjestys -vaihtoehto käsin tehtävää järjestelyä varten
- `ReadingStatus`-tietotyyppi
- Kirjan lukutilat:
  - Lukematta
  - Kesken
  - Luettu
- Lukutilan tallentaminen `Book`-malliin
- Lukutilan tallentaminen JSON-muotoon
- Lukutilan valinta kirjan tietonäkymässä
- Lukutilan näyttäminen kirjan tietonäkymässä
- Lukutilan tunniste kirjan selkämyksessä
- Lukutilan näyttäminen kirjan tooltipissä
- Kirjojen suodattaminen lukutilan perusteella
- Suodatusvaihtoehdot:
  - Kaikki
  - Lukematta
  - Kesken
  - Luettu
- Tyhjän suodatustuloksen näkymä
- Aktiivisen lukutilasuodatuksen tunniste suodatuspainikkeessa
- `Book.copyWith()` kirjan tietojen turvallista päivittämistä varten

### Muutettu

- Kirjojen näyttöjärjestys muodostetaan valitun lajittelutavan perusteella
- Tekstihaku, lukutilasuodatus ja lajittelu toimivat yhdessä
- Drag and drop toimii vain Oma järjestys -tilassa
- Drag and drop ei muuta järjestystä tekstihakua käytettäessä
- Drag and drop ei muuta järjestystä lukutilasuodatuksen aikana
- Vanhoille tallennetuille kirjoille asetetaan oletuksena lukutilaksi Lukematta
- Kirjan tietonäkymää laajennettiin näyttämään lukutila
- Kirjan selkämyksen tooltip näyttää nimen ja tekijän lisäksi lukutilan

### Korjattu

- Korjattu poistodialogin Peruuta-painikkeen toiminta
- Korjattu lukutilan vaihtometodin sijainti väärässä widget-luokassa
- Estetty kirjojen järjestyksen muuttuminen automaattista lajittelua käytettäessä
- Estetty kirjojen järjestyksen muuttuminen suodatetussa näkymässä

### Testattu

- Lajittelu kirjan nimen perusteella
- Lajittelu tekijän perusteella
- Oma järjestys ja drag and drop
- Lukutilan vaihtaminen
- Lukutilan paikallinen tallentuminen
- Vanhojen kirjojen takautuva yhteensopivuus
- Lukutilatunnisteen näyttäminen kirjahyllyssä
- Kirjojen suodattaminen lukutilan perusteella
- Tekstihaun ja lukutilasuodatuksen yhteistoiminta
- Lajittelun ja suodatuksen yhteistoiminta
- Flutter-analyysi
- Sovelluksen yksikkötestit

## [0.5.0-alpha] - 2026-07-19

### Lisätty

- Kirjan toimintovalikko
- Kirjan siirtäminen kirjahyllystä toiseen
- Kohdehyllyn valintadialogi
- Ilmoitus onnistuneesta kirjan siirtämisestä
- Mahdollisuus siirtyä suoraan kirjan uuteen hyllyyn
- Reaaliaikainen kirjojen hakutoiminto
- Haku kirjan nimellä
- Haku tekijän nimellä
- Haku ISBN-numerolla
- Hakukentän tyhjennyspainike
- Ei hakutuloksia -näkymä

### Muutettu

- Kirjan napauttaminen avaa kirjan toimintovalikon
- Kirjan tietojen avaaminen tapahtuu toimintovalikon kautta
- Hakutoiminto suodattaa vain valittuna olevan kirjahyllyn kirjoja
- Haku ei huomioi kirjainkokoa
- Hakukentän ja näppäimistön yhteistoimintaa parannettiin
- Alareunan lisäyspainikkeet piilotetaan näppäimistön ollessa näkyvissä
- Ei hakutuloksia -näkymä mukautuu käytettävissä olevaan tilaan

### Korjattu

- Korjattu viittaus puuttuvaan `_editBook`-metodiin
- Palautettu `_openBookDetails`-metodi käyttöön
- Korjattu hakutulosten näkymän pystysuuntainen RenderFlex-ylivuoto
- Korjattu kirjahyllyn litistyminen näppäimistön avautuessa

### Testattu

- Kirjan siirtäminen toiseen hyllyyn
- Siirretyn kirjan tallentuminen oikeaan hyllyyn
- Haku kirjan nimellä
- Haku tekijän nimellä
- Haku ISBN-numerolla
- Hakutulosten päivittyminen kirjoittamisen aikana
- Haun tyhjentäminen
- Ei hakutuloksia -näkymä
- Flutter-analyysi
- Sovelluksen yksikkötestit

## [0.4.0-alpha] - 2026-07-18

### Lisätty

- Uusi `Shelf`-tietomalli
- Kirjahyllyn yksilöllinen tunniste
- Kirjahyllyn nimi
- Kirjahyllyn järjestysnumero
- `shelfId`-kenttä `Book`-malliin
- Takautuva yhteensopivuus vanhoille kirjoille, joilta puuttuu `shelfId`
- `ShelfStorageService` kirjahyllyjen paikallista tallennusta varten
- Kirjahyllyjen lataaminen sovelluksen käynnistyessä
- Oletushyllyn automaattinen luominen
- Kirjahyllyn valintavalikko
- Valitun kirjahyllyn kirjojen suodatus
- Kirjojen määrän näyttäminen hyllyn nimen yhteydessä
- Tyhjän kirjahyllyn näkymä
- Uuden kirjahyllyn luontidialogi
- Samannimisten kirjahyllyjen estäminen
- Automaattinen siirtyminen juuri luotuun kirjahyllyyn
- Uuden kirjan lisääminen valittuna olevaan kirjahyllyyn
- Kirjahyllyn uudelleennimeäminen
- Kirjahyllyn poistamisen vahvistusdialogi
- Kirjahyllyn toimintovalikko
- Oletushyllyn poistamisen estäminen
- Poistettavan kirjahyllyn kirjojen siirtäminen oletushyllyyn
- Kirjahyllyjen järjestysnumeroiden päivittäminen poiston jälkeen
- Kirjahyllyjen ja kirjojen säilyminen sovelluksen uudelleenkäynnistyksen jälkeen

### Muutettu

- Kirjojen järjestely toimii vain sillä hetkellä valitun kirjahyllyn sisällä
- `Bookshelf`-widgetin järjestelycallback käyttää kirjoja indeksien sijaan
- Sovelluksen käynnistys lataa kirjat ja kirjahyllyt rinnakkain
- Kirjojen tallennus huomioi kirjan kirjahyllyn
- Kirjahyllyn poistaminen vaihtaa aktiiviseksi hyllyksi oletushyllyn
- Kirjahyllyn uudelleennimeäminen säilyttää hyllyn alkuperäisen tunnisteen

### Korjattu

- Korjattu `Bookshelf`-widgetin callbackin väärä parametrityyppi
- Korjattu valitun hyllyn kirjojen drag and drop -järjestely
- Korjattu muiden hyllyjen kirjojen järjestyksen tahaton muuttuminen
- Korjattu uuden kirjahyllyn luontidialogin `TextEditingController`-elinkaariongelma
- Estetty tyhjän nimisen kirjahyllyn luominen
- Estetty kahden samannimisen kirjahyllyn luominen kirjainkoosta riippumatta

### Testattu

- Kirjahyllyn luominen
- Kirjahyllyn valitseminen
- Kirjan skannaaminen valittuun kirjahyllyyn
- Kirjahyllyn uudelleennimeäminen
- Kirjahyllyn poistaminen
- Kirjojen siirtyminen oletushyllyyn hyllyn poiston yhteydessä
- Tietojen säilyminen sovelluksen uudelleenkäynnistyksen jälkeen
- Flutter-analyysi
- Sovelluksen yksikkötestit

## [0.3.0-alpha]

### Lisätty

- Kirjojen paikallinen tallennus
- Tallennettujen kirjojen lataaminen sovelluksen käynnistyessä
- Kirjan lisääminen
- Kirjan muokkaaminen
- Kirjan poistaminen
- Kirjojen järjestäminen raahaamalla
- Google Books -haku
- Open Library -varahaku
- ISBN-viivakoodin skannaus
- Manuaalinen kirjan lisääminen

### Muutettu

- Kirjalistan käsittely keskitettiin sovelluksen päänäkymään
- Tallennusratkaisuksi otettiin `SharedPreferences`

### Testattu

- Kirjamallin JSON-muunnokset
- Kirjojen tallennus ja lataaminen
- Kirjojen järjestäminen