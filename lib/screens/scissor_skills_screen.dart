import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/scissor_skills_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class ScissorSkillsScreen extends StatefulWidget {
  const ScissorSkillsScreen({super.key});

  @override
  State<ScissorSkillsScreen> createState() => _ScissorSkillsScreenState();
}

class _ScissorSkillsScreenState extends State<ScissorSkillsScreen> {
  late GlobalConfig _globalConfig;
  late ScissorSkillsConfig _scissorConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Scissor Skills & Fine Motor");
      _scissorConfig = ScissorSkillsConfig();
    });
  }

  void _generateNewSeed() {
    setState(() {
      _scissorConfig.seed = RandomSeedService.generateNewSeed();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateScissorSkills(_globalConfig, _scissorConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Scissor Skills & Cutting",
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

          _sectionHeader("Cutting Activity Mode"),
          const SizedBox(height: 8),
          DropdownButtonFormField<ScissorLineType>(
            initialValue: _scissorConfig.lineType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Scissor Cutting Mode",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: ScissorLineType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.label, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _scissorConfig.applyPreset(val);
                });
              }
            },
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              _scissorConfig.lineType.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_scissorConfig.lineType == ScissorLineType.straight ||
              _scissorConfig.lineType == ScissorLineType.curved ||
              _scissorConfig.lineType == ScissorLineType.zigzag) ...[
            _sectionHeader("Cutting Lines Count"),
            Slider(
              value: _scissorConfig.lineCount.toDouble(),
              min: 3,
              max: 6,
              divisions: 3,
              label: "${_scissorConfig.lineCount} Lines",
              onChanged: (val) =>
                  setState(() => _scissorConfig.lineCount = val.toInt()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "${_scissorConfig.lineCount} cutting practice lines per page",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 16),

            SwitchListTile(
              title: const Text(
                "Show scissor guide icon at start",
                style: TextStyle(fontSize: 14),
              ),
              value: _scissorConfig.showScissorIcons,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) =>
                  setState(() => _scissorConfig.showScissorIcons = val),
            ),
            const SizedBox(height: 16),
          ],

          OutlinedButton.icon(
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text("New Random Cut & Paste Mix"),
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
