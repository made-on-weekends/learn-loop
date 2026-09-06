import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/focus_attention_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class FocusAttentionScreen extends StatefulWidget {
  const FocusAttentionScreen({super.key});

  @override
  State<FocusAttentionScreen> createState() => _FocusAttentionScreenState();
}

class _FocusAttentionScreenState extends State<FocusAttentionScreen> {
  late GlobalConfig _globalConfig;
  late FocusAttentionConfig _focusConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Focus & Visual Attention");
      _focusConfig = FocusAttentionConfig();
    });
  }

  void _generateNewSeed() {
    setState(() {
      _focusConfig.seed = RandomSeedService.generateNewSeed();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateFocusAttention(_globalConfig, _focusConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Focus & Visual Attention",
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

          _sectionHeader("Activity Type"),
          const SizedBox(height: 8),
          DropdownButtonFormField<FocusActivityType>(
            initialValue: _focusConfig.activityType,
            decoration: const InputDecoration(
              labelText: "Activity Mode",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: FocusActivityType.values.map((type) {
              return DropdownMenuItem(value: type, child: Text(type.label));
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _focusConfig.applyActivityPreset(val);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _focusConfig.activityType.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),

          _sectionHeader("Target Character / Object"),
          const SizedBox(height: 8),
          TextFormField(
            key: ValueKey(_focusConfig.targetItem),
            initialValue: _focusConfig.targetItem,
            decoration: const InputDecoration(
              labelText: "Target Item (e.g. star, B, 5, apple)",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (val) {
              if (val.trim().isNotEmpty) {
                setState(() => _focusConfig.targetItem = val.trim());
              }
            },
          ),
          const SizedBox(height: 16),

          if (_focusConfig.activityType != FocusActivityType.oddOneOut) ...[
            _sectionHeader("Target Count"),
            Slider(
              value: _focusConfig.targetCount.toDouble(),
              min: 2,
              max: 15,
              divisions: 13,
              label: "${_focusConfig.targetCount}",
              onChanged: (val) =>
                  setState(() => _focusConfig.targetCount = val.toInt()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "Find and circle ${_focusConfig.targetCount} targets",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),
          ],

          _sectionHeader("Grid Layout Dimensions"),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rows: ${_focusConfig.gridRows}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    Slider(
                      value: _focusConfig.gridRows.toDouble(),
                      min: 3,
                      max: 8,
                      divisions: 5,
                      onChanged: (val) =>
                          setState(() => _focusConfig.gridRows = val.toInt()),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Columns: ${_focusConfig.gridCols}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    Slider(
                      value: _focusConfig.gridCols.toDouble(),
                      min: 3,
                      max: 8,
                      divisions: 5,
                      onChanged: (val) =>
                          setState(() => _focusConfig.gridCols = val.toInt()),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
