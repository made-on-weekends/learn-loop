import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class WorksheetEditorLayout extends StatelessWidget {
  final String title;
  final Widget settingsWidget;
  final Future<Uint8List> Function() pdfBuilder;
  final VoidCallback? onReset;

  const WorksheetEditorLayout({
    super.key,
    required this.title,
    required this.settingsWidget,
    required this.pdfBuilder,
    this.onReset,
  });

  Future<void> _launchDonation() async {
    final Uri url = Uri.parse(
      'https://asifiqbal.rocks/donation?utm_source=learn_loop&utm_medium=flutter_app&utm_campaign=app_header&ref=learn-loop-app',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;
    final theme = Theme.of(context);

    Widget buildPreview() {
      return PdfPreview(
        build: (format) => pdfBuilder(),
        allowPrinting: true,
        allowSharing: true,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        dynamicLayout: false,
        initialPageFormat: PdfPageFormat.a4,
        loadingWidget: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text("Generating PDF worksheet..."),
            ],
          ),
        ),
        onError: (context, error) => Center(
          child: Text(
            "Error rendering PDF: $error",
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      );
    }

    final actions = [
      IconButton(
        icon: const Icon(Icons.coffee, color: Color(0xFFF59E0B)),
        tooltip: "Support the Maintainer",
        onPressed: _launchDonation,
      ),
      if (onReset != null)
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: "Reset Config",
          onPressed: onReset,
        ),
    ];

    if (isWide) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: actions,
        ),
        body: Row(
          children: [
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: theme.dividerColor.withValues(alpha: 0.4)),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: settingsWidget,
                ),
              ),
            ),
            Expanded(
              flex: 6,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(16.0),
                child: buildPreview(),
              ),
            ),
          ],
        ),
      );
    } else {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: actions,
            bottom: TabBar(
              tabs: const [
                Tab(
                  icon: Icon(Icons.tune),
                  text: "Customize",
                ),
                Tab(
                  icon: Icon(Icons.picture_as_pdf),
                  text: "Preview & Print",
                ),
              ],
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: settingsWidget,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: buildPreview(),
              ),
            ],
          ),
        ),
      );
    }
  }
}
