import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/coloring_config.dart';
import '../models/global_config.dart';
import '../models/kid_profile.dart';
import '../services/asset_catalog_service.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class ColoringScreen extends StatefulWidget {
  const ColoringScreen({super.key});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> {
  late GlobalConfig _globalConfig;
  late ColoringConfig _coloringConfig;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Coloring Practice");
      _coloringConfig = ColoringConfig();
      _selectedCategory = 'All';
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateColoring(_globalConfig, _coloringConfig);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...AssetCatalogService.getCategories()];
    final availableAssets = _selectedCategory == 'All'
        ? AssetCatalogService.getAll()
        : AssetCatalogService.getByCategory(_selectedCategory);

    return ValueListenableBuilder<KidProfile>(
      valueListenable: SettingsService.kidProfileNotifier,
      builder: (context, profile, _) {
        return WorksheetEditorLayout(
          title: "Coloring Generator",
          onReset: _resetConfig,
          pdfBuilder: _buildPdf,
          settingsWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Category & Asset Selector
              _buildSectionHeader("Select Coloring Page"),
              const SizedBox(height: 10),

              // Category Filter Dropdown
              DropdownButtonFormField<String>(
                key: const ValueKey('coloring_category_dropdown'),
                initialValue: _selectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Category Filter",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem<String>(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedCategory = val;
                      final newAvailable = val == 'All'
                          ? AssetCatalogService.getAll()
                          : AssetCatalogService.getByCategory(val);
                      if (newAvailable.isNotEmpty) {
                        _coloringConfig.assetId = newAvailable.first.id;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // Asset Dropdown
              DropdownButtonFormField<String>(
                key: const ValueKey('coloring_asset_dropdown'),
                initialValue: _coloringConfig.assetId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Coloring Illustration",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: availableAssets.map((asset) {
                  return DropdownMenuItem<String>(
                    value: asset.id,
                    child: Text("${asset.title} (${asset.category})"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _coloringConfig.assetId = val;
                    });
                  }
                },
              ),

              const Divider(height: 32),

              // 2. Line Thickness & Style Settings
              _buildSectionHeader("Line Thickness"),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ColoringLineThickness>(
                  key: const ValueKey('line_thickness_segmented'),
                  segments: const [
                    ButtonSegment(
                      value: ColoringLineThickness.thick,
                      label: Text("Thick"),
                      icon: Icon(Icons.line_weight),
                    ),
                    ButtonSegment(
                      value: ColoringLineThickness.medium,
                      label: Text("Medium"),
                      icon: Icon(Icons.show_chart),
                    ),
                    ButtonSegment(
                      value: ColoringLineThickness.thin,
                      label: Text("Thin"),
                      icon: Icon(Icons.timeline),
                    ),
                  ],
                  selected: {_coloringConfig.lineThickness},
                  onSelectionChanged: (val) {
                    setState(() {
                      _coloringConfig.lineThickness = val.first;
                    });
                  },
                ),
              ),

              const Divider(height: 32),

              // 3. Worksheet Layout Options
              _buildSectionHeader("Worksheet Layout & Features"),
              const SizedBox(height: 10),

              SwitchListTile(
                key: const ValueKey('word_tracing_switch'),
                title: const Text(
                  "Dashed Name Tracing at Top",
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  "Includes large dashed text for toddlers to trace",
                  style: TextStyle(fontSize: 12),
                ),
                value: _coloringConfig.showWordTracing,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _coloringConfig.showWordTracing = val;
                  });
                },
              ),

              SwitchListTile(
                key: const ValueKey('decorative_border_switch'),
                title: const Text(
                  "Decorative Outer Border",
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  "Frame border surrounding the coloring page",
                  style: TextStyle(fontSize: 12),
                ),
                value: _coloringConfig.showDecorativeBorder,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _coloringConfig.showDecorativeBorder = val;
                  });
                },
              ),

              SwitchListTile(
                key: const ValueKey('coloring_prompts_switch'),
                title: const Text(
                  "Coloring Guidance Banner",
                  style: TextStyle(fontSize: 14),
                ),
                subtitle: const Text(
                  "Footnote tip encouraging coloring inside the lines",
                  style: TextStyle(fontSize: 12),
                ),
                value: _coloringConfig.showColoringPrompts,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) {
                  setState(() {
                    _coloringConfig.showColoringPrompts = val;
                  });
                },
              ),

              const Divider(height: 32),

              // 4. Global Page Settings Section
              _buildSectionHeader("Page & Header Settings"),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _globalConfig.title,
                decoration: const InputDecoration(
                  labelText: "Worksheet Title",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (val) {
                  setState(() {
                    _globalConfig.title = val;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text(
                        "Name Line",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _globalConfig.showNameLine,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          _globalConfig.showNameLine = val ?? true;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: CheckboxListTile(
                      title: const Text(
                        "Date Line",
                        style: TextStyle(fontSize: 13),
                      ),
                      value: _globalConfig.showDateLine,
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (val) {
                        setState(() {
                          _globalConfig.showDateLine = val ?? true;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PageMarginDropdown(
                value: _globalConfig.marginMm,
                onChanged: (val) {
                  setState(() {
                    _globalConfig.marginMm = val;
                  });
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }
}
