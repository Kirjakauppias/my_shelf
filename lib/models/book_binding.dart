enum BookBinding { hardcover, paperback, ebook, audiobook, other, unknown }

extension BookBindingExtension on BookBinding {
  String get label {
    switch (this) {
      case BookBinding.hardcover:
        return 'Sidottu';

      case BookBinding.paperback:
        return 'Nidottu';

      case BookBinding.ebook:
        return 'E-kirja';

      case BookBinding.audiobook:
        return 'Äänikirja';

      case BookBinding.other:
        return 'Muu';

      case BookBinding.unknown:
        return 'Ei tiedossa';
    }
  }
}
