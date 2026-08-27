import 'package:flutter/material.dart';

// Tuodaan projektin oma Book-malli.
// Book-luokka kuvaa sovelluksessa yksittäistä kirjaa ja sisältää
// esimerkiksi kirjan nimen, kirjailijan, ISBN:n, sivumäärän,
// selkämyksen värin ja lukutilan.
import '../models/book.dart';

// Tuodaan BookBinding-enum, jolla kuvataan kirjan sidosasua.
import '../models/book_binding.dart';

// Tuodaan ISBN-numeroihin liittyvät apufunktiot.
// IsbnUtils-luokkaa käytetään alempana esim. ISBN:n
// normalisointiin ja oikeellisuuden tarkistamiseen.
import '../utils/isbn_utils.dart';

/// [ManualBookDialog] on dialogi, jonka avulla käyttäjä voi joko:
/// 1. lisätä kirjan käsin
/// 2. muokata olemassa olevaa kirjaa.
///
/// [StatefulWidget] valitaan koska
/// dialogin sisäinen tila voi muuttua käyttäjän toiminnan aikana.
/// Esim:
/// - valittu sidosasu voi vaihtua
/// - valittu selkämyksen väri voi vaihtua.
class ManualBookDialog extends StatefulWidget {
  /// [initialIsbn] sisältää mahdollisen valmiiksi tunnetun ISBN:n.
  /// [String]? = joko String-arvo tai null-arvo.
  /// Tätä voidaan käyttää tilanteessa jossa ISBN on ensin skannattu,
  /// mutta kirjan tietoja ei löytynyt automaattisesti.
  final String? initialIsbn;

  /// [book] sisältää muokattavan kirjan.
  /// Jos [book] == null:
  /// dialogia käytetään uuden kirjan lisäämiseen.
  /// Jos [book] != null:
  /// dialogia käytetään olemassa olevan kirjan muokkaamiseen.
  final Book? book;

  /// [ManualBookDialog]-luokan konstruktori.
  ///
  /// const mahdollistaa widgetin luomisen compile-time-vakiona silloin
  /// kun sille annetut arvot ovat myös vakioita.
  ///
  /// {...} tarkoittaa nimettyjä parametreja.
  ///
  /// super.key välittää mahdollisen Key-arvon statefulWidgetin yläluokalle.
  ///
  /// this.initialIsbn tallentaa parametrin suoraan initialIsbn-kenttään.
  /// this.book tallentaa parametrin suoraan book-kenttään.
  ///
  /// Kumpikaan parametri ei ole required, joten molemmat voivat jäädä
  /// antamatta ja niiden arvoksi tulee silloin null.
  const ManualBookDialog({super.key, this.initialIsbn, this.book});

  /// [StatefulWidget] tarvitsee erillisen [State]-olion.
  ///
  /// [createState] kutsutaan, kun Flutter luo tälle widgetille sen muuttuvaa
  /// tilaa hallitsevan [State]-objektin.
  ///
  /// => on Dartin lyhyt yhden lausekkeen funktiosyntaksi.
  ///
  /// Tämä vastaa käytännössä:
  ///
  /// State[ManualBookDialog] createState() {
  ///   return _ManualBookDialogState();
  /// }
  @override
  State<ManualBookDialog> createState() => _ManualBookDialogState();
}

/// Tämä luokka sisältää [ManualBookDialog]-widgetin varsinaisen
/// muuttuvan tilan ja käyttöliittymälogiikan.
///
/// Alaviiva luokan nimen alussa tekee luokasta Dartissa
/// library-private-luokan eli sitä ei ole tarkoitettu käytettäväksi
/// tämän Dart-kirjaston ulkopuolelta.
class _ManualBookDialogState extends State<ManualBookDialog> {
  /// Luodaan GlobalKey Form-widgettiä varten.
  /// [GlobalKey<FormState>] antaa mahdollisuuden päästä myöhemmin
  /// käsiksi Form-widgetin FormState-olioon.
  ///
  /// Sitä tarvitaan esimerkiksi lomakkeen kaikkien validatorien
  /// suorittamiseen komennolla:
  ///
  /// _formKey.currentState!.validate()
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _isbnController;
  late final TextEditingController _pageCountController;
  late final TextEditingController _publicationYearController;
  late final TextEditingController _publisherController;

  BookBinding _selectedBinding = BookBinding.unknown;

  Color _selectedColor = const Color(0xFF335C67);

  static const List<Color> _spineColors = [
    Color(0xFF8D3B3B),
    Color(0xFF335C67),
    Color(0xFF6B705C),
    Color(0xFF8A5A44),
    Color(0xFF5E548E),
    Color(0xFF9C6644),
    Color(0xFF3D5A80),
    Color(0xFF7F5539),
  ];

  @override
  void initState() {
    super.initState();

    final existingBook = widget.book;

    _titleController = TextEditingController(text: existingBook?.title ?? '');

    _authorController = TextEditingController(text: existingBook?.author ?? '');

    _isbnController = TextEditingController(
      text: existingBook?.isbn ?? widget.initialIsbn ?? '',
    );

    _pageCountController = TextEditingController(
      text: existingBook?.pageCount.toString() ?? '',
    );

    _publicationYearController = TextEditingController(
      text: existingBook?.publicationYear?.toString() ?? '',
    );

    _publisherController = TextEditingController(
      text: existingBook?.publisher ?? '',
    );

    _selectedBinding = existingBook?.binding ?? BookBinding.unknown;

    if (existingBook != null) {
      _selectedColor = existingBook.spineColor;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _isbnController.dispose();
    _pageCountController.dispose();
    _publicationYearController.dispose();
    _publisherController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final isbn = IsbnUtils.normalize(_isbnController.text.trim());

    final pageCount = int.parse(_pageCountController.text.trim());

    final publicationYearText = _publicationYearController.text.trim();

    final publicationYear = publicationYearText.isEmpty
        ? null
        : int.parse(publicationYearText);

    final publisherText = _publisherController.text.trim();

    final publisher = publisherText.isEmpty ? null : publisherText;

    final id =
        widget.book?.id ??
        (isbn.isNotEmpty
            ? isbn
            : DateTime.now().microsecondsSinceEpoch.toString());

    final book = Book(
      id: id,
      shelfId: widget.book?.shelfId ?? 'default-shelf',
      isbn: isbn.isEmpty ? null : isbn,
      title: title,
      author: author,
      pageCount: pageCount,

      // Bibliografiset tiedot säilytetään muokkauksessa.
      // Niille lisätään omat muokkauskentät myöhemmin v0.12:ssa.
      publicationYear: publicationYear,
      publisher: publisher,
      binding: _selectedBinding,

      // Myös kirjan muut jo olemassa olevat tiedot täytyy säilyttää.
      coverUrl: widget.book?.coverUrl,
      customCoverFileName: widget.book?.customCoverFileName,
      spineColor: _selectedColor,
      readingStatus: widget.book?.readingStatus ?? ReadingStatus.unread,
      rating: widget.book?.rating,
      notes: widget.book?.notes ?? '',
    );

    Navigator.of(context).pop(book);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.book == null ? 'Lisää kirja käsin' : 'Muokkaa kirjaa'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kirjan nimi',
                    prefixIcon: Icon(Icons.menu_book),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Syötä kirjan nimi.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _authorController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Kirjailija',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Syötä kirjailijan nimi.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _isbnController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'ISBN (valinnainen)',
                    prefixIcon: Icon(Icons.numbers),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final normalized = IsbnUtils.normalize(value?.trim() ?? '');

                    if (normalized.isEmpty) {
                      return null;
                    }

                    if (!IsbnUtils.isValid(normalized)) {
                      return 'Syötä kelvollinen ISBN-10 tai ISBN-13.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _pageCountController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  //onFieldSubmitted: (_) => _submit(),
                  decoration: const InputDecoration(
                    labelText: 'Sivumäärä',
                    prefixIcon: Icon(Icons.format_list_numbered),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final pageCount = int.tryParse(value?.trim() ?? '');

                    if (pageCount == null || pageCount <= 0) {
                      return 'Syötä kelvollinen sivumäärä.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),
                TextFormField(
                  controller: _publicationYearController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Julkaisuvuosi (valinnainen)',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';

                    if (text.isEmpty) {
                      return null;
                    }

                    final year = int.tryParse(text);

                    if (year == null || year < 1 || year > 9999) {
                      return 'Syötä kelvollinen julkaisuvuosi.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 14),
                TextFormField(
                  controller: _publisherController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Kustantaja (valinnainen)',
                    prefixIcon: Icon(Icons.business_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 14),
                DropdownButtonFormField<BookBinding>(
                  initialValue: _selectedBinding,
                  decoration: const InputDecoration(
                    labelText: 'Sidosasu',
                    prefixIcon: Icon(Icons.auto_stories_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: BookBinding.values.map((binding) {
                    return DropdownMenuItem<BookBinding>(
                      value: binding,
                      child: Text(binding.label),
                    );
                  }).toList(),
                  onChanged: (binding) {
                    if (binding == null) {
                      return;
                    }

                    setState(() {
                      _selectedBinding = binding;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Selkämyksen väri',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final color in _spineColors)
                      _ColorChoice(
                        color: color,
                        isSelected: color == _selectedColor,
                        onSelected: () {
                          setState(() {
                            _selectedColor = color;
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Peruuta'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(
            widget.book == null ? 'Lisää hyllyyn' : 'Tallenna muutokset',
          ),
        ),
      ],
    );
  }
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onSelected;

  const _ColorChoice({
    required this.color,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onSelected,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 4,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
