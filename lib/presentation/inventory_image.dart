import 'package:flutter/material.dart';
import 'package:url_launcher/link.dart';

import '../core/models.dart';

class ItemIllustration {
  const ItemIllustration({
    required this.asset,
    required this.title,
    required this.author,
    required this.license,
    required this.source,
    required this.licenseUrl,
  });

  final String asset;
  final String title;
  final String author;
  final String license;
  final String source;
  final String licenseUrl;

  static const projector = ItemIllustration(
    asset: 'assets/images/inventory/projector.jpg',
    title: 'Epson EB-U04',
    author: 'Raimond Spekking',
    license: 'CC BY-SA 4.0',
    source: 'https://commons.wikimedia.org/wiki/File:Epson_EB-U04-5358.jpg',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
  );
  static const laptop = ItemIllustration(
    asset: 'assets/images/inventory/laptop.jpg',
    title: 'Lenovo G500s laptop',
    author: 'Raimond Spekking',
    license: 'CC BY-SA 4.0',
    source:
        'https://commons.wikimedia.org/wiki/File:Lenovo_G500s_laptop-2905.jpg',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
  );
  static const hdmi = ItemIllustration(
    asset: 'assets/images/inventory/hdmi.jpg',
    title: 'HDMI Cable',
    author: 'Kannan shanmugam, shanmugam studio, Kollam',
    license: 'CC BY-SA 4.0',
    source: 'https://commons.wikimedia.org/wiki/File:HDMI_Cable.JPG',
    licenseUrl: 'https://creativecommons.org/licenses/by-sa/4.0/',
  );
  static const speaker = ItemIllustration(
    asset: 'assets/images/inventory/speaker.jpg',
    title: 'JBL EON 1500',
    author: 'Blurred Ren',
    license: 'CC BY 2.0',
    source: 'https://commons.wikimedia.org/wiki/File:JBL_EON_1500.jpg',
    licenseUrl: 'https://creativecommons.org/licenses/by/2.0/',
  );

  // Match the equipment name, not just its broad category: an arbitrary
  // electronic device should not be represented by a projector photograph.
  static ItemIllustration? forItem(InventoryItem item) {
    final name = item.name.toLowerCase();
    if (name.contains('proyektor') || name.contains('projector')) {
      return projector;
    }
    if (name.contains('laptop') || name.contains('notebook')) return laptop;
    if (name.contains('hdmi')) return hdmi;
    if (name.contains('speaker') || name.contains('pengeras suara')) {
      return speaker;
    }
    return null;
  }
}

class InventoryImage extends StatelessWidget {
  const InventoryImage({
    super.key,
    required this.item,
    this.height = 215,
    this.compact = false,
  });

  final InventoryItem item;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final illustration = ItemIllustration.forItem(item);
    Widget placeholder() => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: compact ? 30 : 56,
            color: Colors.blueGrey,
          ),
          if (!compact) ...[
            const SizedBox(height: 8),
            const Text('Foto barang belum tersedia'),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(compact ? 8 : 12),
          ),
          child: illustration == null
              ? placeholder()
              : Padding(
                  padding: EdgeInsets.all(compact ? 4 : 12),
                  child: Image.asset(
                    illustration.asset,
                    fit: BoxFit.contain,
                    semanticLabel: 'Ilustrasi ${item.name}',
                    excludeFromSemantics: compact,
                    errorBuilder: (_, _, _) => placeholder(),
                  ),
                ),
        ),
        if (!compact && illustration != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  'Foto ilustrasi jenis barang',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              TextButton(
                onPressed: () => _showCredit(context, illustration),
                child: const Text('Kredit foto'),
              ),
            ],
          ),
      ],
    );
  }

  void _showCredit(BuildContext context, ItemIllustration illustration) {
    showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (context) => AlertDialog(
        title: const Text('Kredit foto'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                illustration.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '© ${illustration.author} / ${illustration.license} '
                '(via Wikimedia Commons)',
              ),
              const SizedBox(height: 12),
              const Text(
                'Foto ini menunjukkan contoh jenis barang. Model '
                'dan kondisi unit laboratorium dapat berbeda. Foto '
                'menggunakan thumbnail sumber, tanpa suntingan tambahan.',
              ),
              const SizedBox(height: 12),
              Link(
                uri: Uri.parse(illustration.source),
                target: LinkTarget.blank,
                builder: (context, followLink) => TextButton.icon(
                  onPressed: followLink,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: const Text('Sumber foto'),
                ),
              ),
              Link(
                uri: Uri.parse(illustration.licenseUrl),
                target: LinkTarget.blank,
                builder: (context, followLink) => TextButton.icon(
                  onPressed: followLink,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(illustration.license),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
