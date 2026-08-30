import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/prewriting_config.dart';
import '../services/pdf_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class PrewritingScreen extends StatefulWidget {
  const PrewritingScreen({super.key});

  @override
  State<PrewritingScreen> createState() => _PrewritingScreenState();
}

class _PrewritingScreenState extends State<PrewritingScreen> {
  late GlobalConfig _globalConfig;
  late PrewritingConfig _prewritingConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Pre-Writing Practice");
      _prewritingConfig = PrewritingConfig();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generatePrewriting(_globalConfig, _prewritingConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Pre-Writing Lines",
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
                  title: const Text("Name Line", style: TextStyle(fontSize: 13)),
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
                  title: const Text("Date Line", style: TextStyle(fontSize: 13)),
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

          _sectionHeader("Line Pattern"),
          const SizedBox(height: 12),
          SegmentedButton<LinePattern>(
            segments: const [
              ButtonSegment(
                value: LinePattern.straight,
                label: Text("Straight"),
              ),
              ButtonSegment(
                value: LinePattern.wave,
                label: Text("Waves"),
              ),
              ButtonSegment(
                value: LinePattern.zigzag,
                label: Text("Zigzag"),
              ),
              ButtonSegment(
                value: LinePattern.castle,
                label: Text("Castle"),
              ),
            ],
            selected: {_prewritingConfig.pattern},
            onSelectionChanged: (val) {
              setState(() => _prewritingConfig.pattern = val.first);
            },
          ),
          const SizedBox(height: 20),

          SwitchListTile(
            title: const Text("Dotted Lines (for tracing)", style: TextStyle(fontSize: 14)),
            value: _prewritingConfig.isDotted,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _prewritingConfig.isDotted = val),
          ),
          const SizedBox(height: 12),

          _sectionHeader("Number of Lines"),
          Slider(
            value: _prewritingConfig.lineCount.toDouble(),
            min: 3,
            max: 10,
            divisions: 7,
            label: "${_prewritingConfig.lineCount}",
            onChanged: (val) => setState(() => _prewritingConfig.lineCount = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_prewritingConfig.lineCount} lines per page",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 20),

          _sectionHeader("Stroke Width"),
          Slider(
            value: _prewritingConfig.strokeWidth,
            min: 1.0,
            max: 4.0,
            divisions: 6,
            label: "${_prewritingConfig.strokeWidth.toStringAsFixed(1)} pt",
            onChanged: (val) => setState(() => _prewritingConfig.strokeWidth = val),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "Line thickness: ${_prewritingConfig.strokeWidth.toStringAsFixed(1)} pt",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: -0.2),
    );
  }
}
