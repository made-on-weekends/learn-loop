import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/thinking_logic_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class ThinkingLogicScreen extends StatefulWidget {
  const ThinkingLogicScreen({super.key});

  @override
  State<ThinkingLogicScreen> createState() => _ThinkingLogicScreenState();
}

class _ThinkingLogicScreenState extends State<ThinkingLogicScreen> {
  late GlobalConfig _globalConfig;
  late ThinkingLogicConfig _logicConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Thinking & Logic Practice");
      _logicConfig = ThinkingLogicConfig();
    });
  }

  void _generateNewSeed() {
    setState(() {
      _logicConfig.seed = RandomSeedService.generateNewSeed();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateThinkingLogic(_globalConfig, _logicConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Thinking & Logic Practice",
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

          _sectionHeader("Logic Activity Type"),
          const SizedBox(height: 8),
          DropdownButtonFormField<ThinkingLogicType>(
            initialValue: _logicConfig.activityType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Activity Mode",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: ThinkingLogicType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _logicConfig.applyPreset(val);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _logicConfig.activityType.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_logicConfig.activityType ==
                  ThinkingLogicType.patternCompletion ||
              _logicConfig.activityType == ThinkingLogicType.whatComesNext) ...[
            _sectionHeader("Pattern Type"),
            const SizedBox(height: 8),
            DropdownButtonFormField<PatternType>(
              initialValue: _logicConfig.patternType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Pattern Sequence Structure",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: PatternType.values.map((pattern) {
                return DropdownMenuItem(
                  value: pattern,
                  child: Text(pattern.label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _logicConfig.patternType = val);
                }
              },
            ),
            const SizedBox(height: 16),
          ],

          _sectionHeader("Row Count"),
          Slider(
            value: _logicConfig.rowCount.toDouble(),
            min: 3,
            max: 6,
            divisions: 3,
            label: "${_logicConfig.rowCount} Rows",
            onChanged: (val) =>
                setState(() => _logicConfig.rowCount = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_logicConfig.rowCount} problem rows per page",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text("New Random Logic Mix"),
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
