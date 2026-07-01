import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 800;
    final theme = Theme.of(context);

    // Common PDF Preview Config
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

    if (isWide) {
      // Split Screen Layout
      return Scaffold(
        appBar: AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            if (onReset != null)
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: "Reset Config",
                onPressed: onReset,
              ),
          ],
        ),
        body: Row(
          children: [
            // Settings Panel (Left side)
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: theme.dividerColor.withOpacity(0.4)),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: settingsWidget,
                ),
              ),
            ),
            // Live PDF Preview Panel (Right side)
            Expanded(
              flex: 6,
              child: Container(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                padding: const EdgeInsets.all(16.0),
                child: buildPreview(),
              ),
            ),
          ],
        ),
      );
    } else {
      // Mobile Tabbed Layout
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              if (onReset != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onReset,
                ),
            ],
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
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          body: TabBarView(
            physics: const NeverScrollableScrollPhysics(), // Prevent swipe conflicts with PDF zoom
            children: [
              // Tab 1: Settings Form
              SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: settingsWidget,
              ),
              // Tab 2: PDF Preview
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
