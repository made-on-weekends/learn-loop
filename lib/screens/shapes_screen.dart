import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/shapes_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  late GlobalConfig _globalConfig;
  late ShapesConfig _shapesConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Shapes & Visual-Motor Practice");
      _shapesConfig = ShapesConfig();
    });
  }

  void _generateNewSeed() {
    setState(() {
      _shapesConfig.seed = RandomSeedService.generateNewSeed();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateShapes(_globalConfig, _shapesConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Shapes Learning & Visual-Motor",
      onReset: _resetConfig,
      pdfBuilder: _buildPdf,
      settingsWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader("Page & Header"),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _globalConfig.title,
            decoration: const InputDecoration(
              labelText: "Worksheet Title",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (val) => setState(() => _globalConfig.title = val),
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
          const Divider(height: 32),

          _sectionHeader("Activity Mode"),
          const SizedBox(height: 8),
          DropdownButtonFormField<ShapeActivityMode>(
            initialValue: _shapesConfig.activityMode,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Shape Learning Mode",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: ShapeActivityMode.values.map((mode) {
              return DropdownMenuItem(
                value: mode,
                child: Text(mode.label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => _shapesConfig.activityMode = val);
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _shapesConfig.activityMode.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_shapesConfig.activityMode ==
              ShapeActivityMode.identification) ...[
            _sectionHeader("Target Search Shape"),
            const SizedBox(height: 8),
            DropdownButtonFormField<ShapeDesign>(
              initialValue: _shapesConfig.targetShape,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Target Shape to Search",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ShapeDesign.values.map((shape) {
                return DropdownMenuItem(value: shape, child: Text(shape.label));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _shapesConfig.targetShape = val);
                }
              },
            ),
            const SizedBox(height: 16),
          ],

          _sectionHeader("Select Shapes"),
          const SizedBox(height: 8),
          const Text(
            "Choose which shapes to include in the worksheet activity.",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          ...ShapeDesign.values.map((shape) {
            final bool isSelected = _shapesConfig.selectedShapes.contains(
              shape,
            );
            final String label = shape.label;
            final IconData icon = _iconForShape(shape);

            return CheckboxListTile(
              title: Row(
                children: [
                  Icon(
                    icon,
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 10),
                  Text(label, style: const TextStyle(fontSize: 14)),
                ],
              ),
              value: isSelected,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) {
                setState(() {
                  if (val == true) {
                    if (!_shapesConfig.selectedShapes.contains(shape)) {
                      _shapesConfig.selectedShapes.add(shape);
                    }
                  } else {
                    if (_shapesConfig.selectedShapes.length > 1) {
                      _shapesConfig.selectedShapes.remove(shape);
                    }
                  }
                });
              },
            );
          }),
          const Divider(height: 32),

          if (_shapesConfig.activityMode == ShapeActivityMode.tracing) ...[
            _sectionHeader("Tracing Options"),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text(
                "Dotted outline (for tracing)",
                style: TextStyle(fontSize: 14),
              ),
              value: _shapesConfig.isDotted,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) => setState(() => _shapesConfig.isDotted = val),
            ),
            SwitchListTile(
              title: const Text(
                "Show stroke direction guides",
                style: TextStyle(fontSize: 14),
              ),
              value: _shapesConfig.showTracingGuides,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) =>
                  setState(() => _shapesConfig.showTracingGuides = val),
            ),
            const SizedBox(height: 16),
          ],

          OutlinedButton.icon(
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text("New Random Grid Mix"),
            onPressed: _generateNewSeed,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  IconData _iconForShape(ShapeDesign shape) {
    switch (shape) {
      case ShapeDesign.circle:
        return Icons.circle_outlined;
      case ShapeDesign.square:
        return Icons.square_outlined;
      case ShapeDesign.triangle:
        return Icons.change_history;
      case ShapeDesign.rectangle:
        return Icons.rectangle_outlined;
      case ShapeDesign.oval:
        return Icons.egg_outlined;
      case ShapeDesign.diamond:
        return Icons.details;
      case ShapeDesign.star:
        return Icons.star_border;
      case ShapeDesign.heart:
        return Icons.favorite_border;
    }
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }
}
