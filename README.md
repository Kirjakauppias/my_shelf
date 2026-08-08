**# My Shelf**

My Shelf on Flutterilla toteutettu henkilökohtainen ja visuaalinen kirjastosovellus oman kirjakokoelman hallintaan.

Sovelluksen keskiössä on virtuaalinen kirjahylly, jossa kirjat esitetään oletuksena kansikuvina. Kirjoja voi lisätä skannaamalla ISBN-viivakoodin, hakemalla ISBN-numerolla tai syöttämällä kirjan tiedot käsin.

Kirjat voidaan järjestää omiin hyllyihin, lajitella, suodattaa ja asettaa haluttuun järjestykseen raahaamalla. Jokaiselle kirjalle voidaan tallentaa lukutila, tähtiarvosana, henkilökohtainen muistiinpano ja käyttäjän itse valitsema kansikuva.

**## Nykyinen versio**

**\*\*v0.11.0-alpha\*\***

Tämä on sovelluksen kehitysversio. Sovelluksen keskeiset toiminnot ovat käytettävissä, mutta ominaisuudet, käyttöliittymä ja tietojen tallennustapa voivat vielä muuttua.

Version v0.11.0-alphan pääpaino on suomalaisen ISBN-haun parantamisessa. Finna toimii uutena hakulähteenä Google Booksin ja Open Libraryn rinnalla, ja eri palvelujen tietoja yhdistetään kenttäkohtaisesti mahdollisimman kattavan kirjatiedon ja kansikuvan löytämiseksi.

**## Ominaisuudet**

**### Visuaalinen kirjahylly**

\* Kansikuvat kirjojen oletusnäkymänä
\* Vaihtoehtoinen selkämyksenäkymä
\* Koko ruudun kirjahyllynäkymä
\* Hyllyn nimi koko ruudun näkymän nimikyltissä
\* Responsiivinen asettelu pysty- ja vaakasuunnassa
\* Kansien koon ja sarakemäärän automaattinen mukautuminen
\* Kirjojen järjestäminen raahaamalla ja pudottamalla
\* Pudotusalue kirjan siirtämiseksi järjestyksen loppuun
\* Hero-animaatio kirjahyllyn ja kirjan tietosivun välillä
\* Viimeistellyt puupinnat, hyllylaudat, varjot ja kansien välit
\* Visuaaliset näkymät tyhjälle hyllylle sekä tyhjille haku- ja suodatustuloksille

Kirjahyllynäkymä toimii sekä puhelimen pysty- että vaakasuunnassa. Vaakasuunnassa käyttöliittymä tiivistyy automaattisesti, jotta hyllylle ja sen vierittämiselle jää riittävästi tilaa.

**### Kansikuvat**

Kirjan kansi valitaan seuraavassa järjestyksessä:

1\. käyttäjän itse valitsema kansikuva
2\. kirjatietopalvelusta löytynyt verkkokansi
3\. sovelluksen muodostama varakansi

Kansikuville tuetaan seuraavia toimintoja:

\* Kansikuvan hakeminen kirjatietopalvelusta
\* Oman kansikuvan valitseminen laitteen kuvakirjastosta
\* Oman kansikuvan vaihtaminen
\* Oman kansikuvan poistaminen
\* Verkosta haetun kannen palauttaminen
\* Paikallisten kansikuvatiedostojen turvallinen tallentaminen
\* Vanhan kansikuvatiedoston poistaminen kantta vaihdettaessa
\* Kansikuvatiedoston poistaminen kirjaa poistettaessa
\* Pehmeä lataustila verkko- ja paikallisille kuville
\* Tyylitelty varakansi kirjoille, joilla ei ole kansikuvaa

Varakannen väri perustuu kirjan selkämyksen väriin. Tekstin väri valitaan automaattisesti kannen vaaleuden perusteella.

**### Kirjojen hallinta**

\* Kirjan ISBN-viivakoodin skannaus
\* ISBN-numeron syöttäminen käsin
\* ISBN-10- ja ISBN-13-tunnusten normalisointi ja tarkistusnumeron validointi
\* Kirjatietojen haku Finna-palvelusta
\* Kirjatietojen haku Google Books -palvelusta
\* Open Library varalähteenä puuttuvien tietojen täydentämiseen
\* Täsmällisen ISBN-painoksen tarkistaminen kaikissa kirjatietopalveluissa
\* Kirjatietojen kenttäkohtainen yhdistäminen useasta tietolähteestä
\* Suomalaisten ja vanhempien kirjojen parempi tunnistaminen Finnan avulla
\* Kansikuvan hakeminen useasta tietolähteestä
\* Finnan puuttuvaa kantta kuvaavan 10 × 10 GIF-paikkamerkin hylkääminen
\* Kirjan lisääminen kokonaan käsin
\* Kirjan tietojen tarkasteleminen
\* Kirjan tietojen muokkaaminen
\* Kansikuvan vaihtaminen
\* Kirjan poistaminen
\* Kirjan siirtäminen hyllystä toiseen

**### ISBN-haku ja kirjatietopalvelut**

ISBN-haussa käytetään kolmea tietolähdettä:

\* Finna
\* Google Books
\* Open Library

Finna ja Google Books haetaan ensisijaisesti rinnakkain. Open Librarya käytetään varalähteenä silloin, kun ensimmäisten palvelujen tiedoista puuttuu esimerkiksi kansikuva tai muu keskeinen tieto.

Hakutuloksia ei hyväksytä pelkän tekstiosuman perusteella, vaan palautetun tietueen ISBN tarkistetaan haettua ISBN-10- tai ISBN-13-tunnusta vastaavaksi. Näin eri painosten ja julkaisumuotojen sekoittumista vähennetään.

Kirjan nimi ja tekijä valitaan ensisijaisesti Finnasta. Puuttuvia tietoja voidaan täydentää Google Booksista ja Open Librarysta. Kansikuvaksi valitaan käyttökelpoinen verkkokansi eri palveluista.

Finnan kansihaku käyttää tietueen tunnistetta sekä kirjan ISBN-, nimi- ja tekijätietoja. Tämä parantaa erityisesti vanhempien suomalaisten kirjojen kansien löytymistä. Jos Finna palauttaa puuttuvan kannen tilalla 10 × 10 pikselin läpinäkyvän GIF-kuvan, se hylätään automaattisesti ja sovellus yrittää käyttää toisen palvelun kantta. Jos käyttökelpoista verkkokantta ei löydy, näytetään sovelluksen oma varakansi.

**### Kirjahyllyt**

\* Useiden kirjahyllyjen luominen
\* Kirjahyllyn valitseminen
\* Kirjahyllyn nimeäminen uudelleen
\* Kirjahyllyn poistaminen
\* Poistetun hyllyn kirjojen siirtäminen oletushyllyyn
\* Kirjojen järjestäminen raahaamalla
\* Kirjojen järjestyksen säilyttäminen sovelluksen käynnistysten välillä

Sovelluksessa on aina oletushylly, jota ei voi poistaa.

Käyttäjä voi luoda uusia hyllyjä esimerkiksi seuraaville kokoelmille:

\* Fantasia
\* Scifi
\* Historia
\* Sarjakuvat
\* Tietokirjat

Uusi kirja lisätään sillä hetkellä valittuna olevaan hyllyyn. Kirja voidaan myöhemmin siirtää toiseen hyllyyn kirjan toimintojen kautta.

Kun käyttäjän luoma hylly poistetaan, sen sisältämät kirjat siirretään automaattisesti oletushyllyyn.

**### Haku**

Kirjoja voidaan hakea reaaliaikaisesti:

\* kirjan nimellä
\* tekijän nimellä
\* ISBN-numerolla

Haku kohdistuu sillä hetkellä valittuna olevan kirjahyllyn kirjoihin.

Hakukenttä avataan päänäkymän hakukuvakkeesta, jotta kirjahyllylle jää mahdollisimman paljon näkyvää tilaa.

**### Lajittelu**

Kirjat voidaan järjestää seuraavilla tavoilla:

\* Oma järjestys
\* Nimi A–Ö
\* Nimi Ö–A
\* Tekijä A–Ö
\* Tekijä Ö–A
\* Arvosana 5–1
\* Arvosana 1–5

Arvioimattomat kirjat sijoitetaan arvosanalajittelussa listan loppuun.

Kirjojen raahaaminen on käytettävissä vain silloin, kun lajittelutavaksi on valittu **\*\*Oma järjestys\*\*** eikä haku tai suodatus ole aktiivinen.

**### Lukutilat**

Jokaiselle kirjalle voidaan määrittää yksi seuraavista lukutiloista:

\* Lukematta
\* Kesken
\* Luettu

Lukutila:

\* tallennetaan kirjan mukana
\* näkyy kirjan tietosivulla
\* voidaan vaihtaa kirjan tietosivulta
\* voidaan käyttää kirjojen suodattamiseen
\* voidaan näyttää tunnisteena kansikuvassa
\* voidaan näyttää tunnisteena kirjan selkämyksessä

Lukutilatunnisteiden näyttäminen on valinnainen asetus. Valinta säilyy sovelluksen uudelleenkäynnistyksen jälkeen.

**### Arvosanat**

Kirjalle voidaan antaa arvosana yhdestä viiteen tähteä.

Arvosana:

\* tallennetaan kirjan mukana
\* näkyy kirjan tietosivulla
\* voidaan vaihtaa tai poistaa
\* säilyy sovelluksen uudelleenkäynnistyksen jälkeen
\* sisältyy varmuuskopioon
\* voidaan käyttää lajitteluun ja suodattamiseen

Kirja voi olla myös arvioimaton.

**### Muistiinpanot**

Jokaiselle kirjalle voidaan tallentaa henkilökohtainen muistiinpano.

Muistiinpanoa voidaan käyttää esimerkiksi:

\* oman lukukokemuksen kirjaamiseen
\* huomioiden tallentamiseen
\* muistettavien asioiden merkitsemiseen
\* lainassa olevan kirjan tietojen kirjaamiseen

Muistiinpano voidaan lisätä, muokata tai poistaa. Se tallennetaan kirjan mukana ja sisältyy varmuuskopioon.

**### Suodatus**

Kirjoja voidaan suodattaa lukutilan perusteella:

\* Kaikki
\* Lukematta
\* Kesken
\* Luettu

Lisäksi kirjoja voidaan suodattaa sisällön perusteella:

\* Kaikki
\* Arvioidut
\* Arvioimattomat
\* Sisältää muistiinpanon

Tekstihaku, lukutilasuodatus, sisältösuodatus ja lajittelu toimivat yhdessä.

**### Kirjan tietosivu**

Kirjan tietosivu on suunniteltu vastaamaan virtuaalisen kirjahyllyn visuaalista tyyliä.

Tietosivulla voidaan:

\* tarkastella kirjan kantta, nimeä ja tekijää
\* vaihtaa tai poistaa kansikuva
\* palauttaa verkkokansi
\* tarkastella ISBN-numeroa ja sivumäärää
\* vaihtaa lukutilaa
\* antaa, muuttaa tai poistaa arvosana
\* lisätä tai muokata muistiinpanoa
\* muokata kirjan perustietoja
\* poistaa kirja

Lukutilaa, arvosanaa ja muistiinpanoa voidaan muuttaa suoraan niitä vastaavia tietorivejä napauttamalla.

**### Näkymäasetukset**

Käyttäjä voi valita:

\* kansikuvanäkymän
\* selkämyksenäkymän
\* lukutilatunnisteiden näyttämisen

Näkymäasetukset tallennetaan paikallisesti ja palautetaan automaattisesti sovelluksen käynnistyessä.

Kansikuvanäkymä on sovelluksen oletusnäkymä.

**### Varmuuskopiointi ja palautus**

Kirjoista, kirjahyllyistä ja käyttäjän omista kansikuvista voidaan luoda siirrettävä ZIP-varmuuskopio.

ZIP-varmuuskopio sisältää:

\* arkiston rakennetta kuvaavan \`manifest.json\`-tiedoston
\* kirjastotiedot sisältävän \`library.json\`-tiedoston
\* varmuuskopion luontiajankohdan
\* kaikki kirjat ja niiden perustiedot
\* kirjojen verkkokansien osoitteet
\* käyttäjän paikalliset kansikuvat varsinaisina kuvatiedostoina
\* kirjojen lukutilat
\* kirjojen arvosanat
\* kirjojen muistiinpanot
\* kirjojen kirjahyllyt
\* kirjojen järjestyksen
\* kaikki käyttäjän luomat kirjahyllyt

Varmuuskopio voidaan tallentaa tai jakaa käyttöjärjestelmän jakovalikon kautta.

Sovellus tukee palautuksessa kahta tiedostomuotoa:

\* uusi kansikuvat sisältävä ZIP-varmuuskopio
\* aiemmissa versioissa luotu JSON-varmuuskopio

Vanha JSON-varmuuskopio sisältää kirjastotiedot mutta ei varsinaisia paikallisia kansikuvatiedostoja.

Ennen palauttamista sovellus:

\* tunnistaa JSON- ja ZIP-varmuuskopiot
\* tarkistaa varmuuskopion ja arkiston version
\* tarkistaa JSON-rakenteen
\* tarkistaa ZIP-arkiston sallitut tiedostot ja hakemistot
\* estää turvattomat tiedostopolut ja symboliset linkit
\* rajoittaa arkiston ja yksittäisten tiedostojen kokoa
\* tarkistaa kirjojen ja kirjahyllyjen tunnisteet
\* tunnistaa päällekkäiset tunnisteet
\* tarkistaa kirjojen viittaukset kirjahyllyihin
\* tarkistaa paikallisten kansikuvien viittaukset ja kuvatiedostot
\* näyttää palautettavien kirjojen, kirjahyllyjen ja kansikuvien määrän
\* pyytää käyttäjältä vahvistuksen

ZIP-varmuuskopion kansikuvat otetaan käyttöön transaktiona. Vanhoista samannimisistä kuvista tehdään väliaikaiset varakopiot, ja palautus vahvistetaan vasta kirjastotietojen onnistuneen tallennuksen jälkeen.

Jos tallennus epäonnistuu, sovellus yrittää palauttaa sekä aiemmat kirjastotiedot että aiemmat kansikuvat. Onnistuneen palautuksen jälkeen tarpeettomiksi jääneet vanhan kirjaston kansikuvat poistetaan.

Varmuuskopion palauttaminen korvaa sovelluksessa sillä hetkellä olevat kirjat ja kirjahyllyt. ZIP-varmuuskopio palauttaa lisäksi siihen sisältyvät paikalliset kansikuvat.

**## Tietojen tallennus**

Kirjat, kirjahyllyt ja käyttöliittymän näkymäasetukset tallennetaan laitteen paikalliseen tallennustilaan.

Kirjat ja hyllyt muunnetaan JSON-muotoon ennen tallentamista. Käyttäjän omat kansikuvat tallennetaan sovelluksen omaan pysyvään tiedostohakemistoon.

Paikallisesti tallennettavia tietoja ovat esimerkiksi:

\* kirjojen perustiedot
\* ISBN-numero
\* verkkokannen osoite
\* oman kansikuvan tiedostonimi
\* kirjan selkämyksen väri
\* kirjan hylly
\* kirjan lukutila
\* kirjan arvosana
\* kirjan muistiinpano
\* kirjojen oma järjestys
\* käyttäjän luomat kirjahyllyt
\* valittu kirjojen esitystapa
\* lukutilatunnisteiden näkyvyys

Tallennetut tiedot palautetaan automaattisesti sovelluksen käynnistyessä.

ZIP-varmuuskopio tarjoaa erillisen tavan säilyttää ja siirtää kirjaston tiedot sekä käyttäjän omat kansikuvat sovelluksen paikallisen tallennuksen lisäksi. Vanhojen JSON-varmuuskopioiden palautusta tuetaan edelleen.

Nykyinen alpha-versio ei vielä sisällä:

\* automaattista pilvisynkronointia
\* käyttäjätilejä
\* automaattisia varmuuskopioita
\* tietojen automaattista synkronointia useiden laitteiden välillä

**## Käytetyt teknologiat**

\* Flutter
\* Dart
\* Material 3
\* Shared Preferences
\* JSON
\* Google Books API
\* Open Library API
\* Finna API
\* HTTP
\* Mobile Scanner
\* Image Picker
\* Path Provider
\* Path
\* Share Plus
\* File Selector
\* Archive
\* ZIP

**## Projektin rakenne**

Projektin keskeiset hakemistot:

\`\`\`text
lib/
├── dialogs/
│   ├── manual\_book\_dialog.dart
│   └── ...
├── models/
│   ├── book.dart
│   ├── book\_search\_result.dart
│   ├── library\_backup.dart
│   ├── library\_view\_settings.dart
│   ├── portable\_backup\_archive\_data.dart
│   ├── portable\_backup\_manifest.dart
│   ├── shelf.dart
│   └── ...
├── screens/
│   ├── book\_details\_screen.dart
│   └── home\_screen.dart
├── services/
│   ├── backup\_export\_service.dart
│   ├── backup\_import\_service.dart
│   ├── book\_api\_exception.dart
│   ├── book\_api\_service.dart
│   ├── book\_storage\_service.dart
│   ├── custom\_cover\_service.dart
│   ├── finna\_book\_search\_service.dart
│   ├── finna\_cover\_validator.dart
│   ├── library\_backup\_validator.dart
│   ├── library\_view\_settings\_service.dart
│   ├── portable\_backup\_archive\_reader.dart
│   ├── portable\_backup\_archive\_service.dart
│   ├── portable\_cover\_restore\_service.dart
│   ├── shelf\_storage\_service.dart
│   └── ...
├── theme/
│   └── app\_theme.dart
├── utils/
│   ├── book\_query.dart
│   └── isbn\_utils.dart
├── widgets/
│   ├── book\_cover\_card.dart
│   ├── book\_cover\_hero.dart
│   ├── book\_cover\_image.dart
│   ├── book\_cover\_shelf.dart
│   ├── book\_spine.dart
│   ├── bookshelf.dart
│   ├── reading\_status\_badge.dart
│   ├── shelf\_board.dart
│   ├── shelf\_empty\_state.dart
│   ├── shelf\_row\.dart
│   └── ...
└── main.dart

test/
├── models/
│   ├── book\_custom\_cover\_test.dart
│   ├── book\_notes\_test.dart
│   ├── book\_rating\_test.dart
│   ├── library\_backup\_test.dart
│   ├── library\_view\_settings\_test.dart
│   └── ...
├── services/
│   ├── backup\_export\_service\_test.dart
│   ├── backup\_import\_service\_test.dart
│   ├── custom\_cover\_service\_test.dart
│   ├── book\_api\_service\_test.dart
│   ├── finna\_book\_search\_service\_test.dart
│   ├── finna\_cover\_validator\_test.dart
│   ├── portable\_backup\_archive\_reader\_test.dart
│   ├── portable\_backup\_archive\_service\_test.dart
│   ├── portable\_cover\_restore\_service\_test.dart
│   └── ...
├── utils/
│   ├── book\_query\_test.dart
│   └── isbn\_utils\_test.dart
└── ...
\`\`\`

Tiedostorakenne voi muuttua sovelluksen kehityksen aikana.

**## Projektin käynnistäminen**

Varmista ensin, että Flutter on asennettu ja käytettävissä komentoriviltä.

Hae projektin riippuvuudet:

\`\`\`bash
flutter pub get
\`\`\`

Käynnistä sovellus:

\`\`\`bash
flutter run
\`\`\`

**## Tarkistukset ja testit**

Muotoile lähdekoodi:

\`\`\`bash
dart format lib test
\`\`\`

Tarkista lähdekoodi:

\`\`\`bash
flutter analyze
\`\`\`

Suorita testit:

\`\`\`bash
flutter test
\`\`\`

Version \`v0.11.0-alpha\` valmisteluvaiheessa projektissa on **\*\*123 läpäisevää automaattista testiä\*\***.

Testit kattavat muun muassa:

\* kirjamallin JSON-muunnokset
\* arvosanojen validoinnin
\* muistiinpanojen tallennuksen
\* käyttäjän oman kansikuvan tietomallin
\* paikallisten kansikuvatiedostojen hakemisen ja poistamisen
\* varmuuskopion tietomallin
\* siirrettävän varmuuskopion manifestin
\* ZIP-varmuuskopion muodostamisen
\* kansikuvatiedostojen lisäämisen ZIP-arkistoon
\* ZIP-arkiston turvallisen lukemisen
\* JSON- ja ZIP-varmuuskopioiden tunnistamisen
\* varmuuskopion palautuksen validoinnin
\* paikallisten kansikuvien transaktionaalisen palautuksen
\* kansikuvien palautuksen vahvistamisen ja perumisen
\* kirjahaun
\* ISBN-10- ja ISBN-13-tunnusten normalisoinnin ja validoinnin
\* ISBN-10- ja ISBN-13-tunnusten keskinäisen vastaavuuden
\* Finna-hakupalvelun ja täsmällisen ISBN-osuman valinnan
\* Google Books- ja Open Library -tulosten ISBN-varmistuksen
\* useiden kirjatietopalvelujen tulosten yhdistämisen
\* yhden kirjatietopalvelun virheestä palautumisen
\* Finnan kansikuvaosoitteiden muodostamisen
\* Finnan 10 × 10 GIF-paikkamerkin tunnistamisen ja hylkäämisen
\* Open Library -varakannen käyttämisen Finnan kannen puuttuessa
\* kirjahyllyrajauksen
\* lukutilasuodatuksen
\* arvosana- ja muistiinpanosuodatuksen
\* lajittelun
\* eri hakujen ja suodattimien yhdistelmät
\* alkuperäisen kirjalistan järjestyksen säilymisen
\* näkymäasetusten oletusarvot ja tallennettujen arvojen palauttamisen

**## Kehitystilanne**

Version \`v0.11.0-alpha\` pääpaino on ollut suomalaisen ISBN-haun sekä kirjatietojen ja kansikuvien löytymisen parantamisessa.

Toteutettuja kokonaisuuksia ovat:

\* Finna uutena kirjatietolähteenä Google Booksin ja Open Libraryn rinnalla
\* ISBN-10- ja ISBN-13-tunnusten normalisointi ja tarkistusnumeron validointi
\* ISBN-10- ja ISBN-13-muotojen keskinäisen vastaavuuden tunnistaminen
\* täsmällisen ISBN-painoksen tarkistaminen kaikista hakulähteistä
\* Finna- ja Google Books -hakujen rinnakkainen suorittaminen
\* Open Library puuttuvien tietojen ja kansien varalähteenä
\* eri kirjatietopalvelujen tulosten kenttäkohtainen yhdistäminen
\* suomalaisen kirjan nimen ja tekijän ensisijainen valinta Finnasta
\* vanhempien suomalaisten kirjojen kansien hakeminen Finnan \`/Cover/Show\`-palvelulla
\* Finnan kansihaun muodostaminen tietueen tunnisteesta sekä ISBN-, nimi- ja tekijätiedoista
\* Finnan 10 × 10 pikselin läpinäkyvän paikkamerkkikuvan automaattinen hylkääminen
\* käyttökelpoisen varakannen käyttäminen toisesta kirjapalvelusta
\* yhden hakupalvelun teknisestä virheestä palautuminen ilman koko ISBN-haun epäonnistumista
\* suomalaisilla uusilla ja vanhemmilla kirjoilla tehdyt laitetestit
\* 123 läpäisevää automaattista testiä

**## Suunniteltuja ominaisuuksia**

Tulevissa versioissa voidaan toteuttaa esimerkiksi:

\* kirjahyllyjen järjestäminen
\* lajittelu kirjan lisäysajan mukaan
\* lukemisen aloitus- ja lopetuspäivämäärät
\* lukemisen tilastot
\* kirjan lainaustiedot
\* automaattiset varmuuskopiot
\* pilvisynkronointi
\* käyttäjätilit

**## Versiohistoria**

Katso tarkemmat muutokset tiedostosta [CHANGELOG.md]\(CHANGELOG.md).

**## Lisenssi**

Tälle projektille ei ole vielä määritelty erillistä lisenssiä.