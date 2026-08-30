import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/math_config.dart';
import '../services/pdf_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class MathScreen extends StatefulWidget {
  const MathScreen({super.key});

  @override
  State<MathScreen> createState() => _MathScreenState();
}

class _MathScreenState extends State<MathScreen> {
  late GlobalConfig _globalConfig;
  late MathConfig _mathConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Math Practice");
      _mathConfig = MathConfig();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateMath(_globalConfig, _mathConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Addition & Subtraction",
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

          _sectionHeader("Operation"),
          const SizedBox(height: 12),
          SegmentedButton<MathOperation>(
            segments: const [
              ButtonSegment(
                value: MathOperation.addition,
                label: Text("Addition"),
                icon: Icon(Icons.add),
              ),
              ButtonSegment(
                value: MathOperation.subtraction,
                label: Text("Subtraction"),
                icon: Icon(Icons.remove),
              ),
              ButtonSegment(
                value: MathOperation.mixed,
                label: Text("Mixed"),
                icon: Icon(Icons.shuffle),
              ),
            ],
            selected: {_mathConfig.operation},
            onSelectionChanged: (val) {
              setState(() => _mathConfig.operation = val.first);
            },
          ),
          const SizedBox(height: 20),

          _sectionHeader("Equation Layout"),
          const SizedBox(height: 12),
          SegmentedButton<MathFormat>(
            segments: const [
              ButtonSegment(
                value: MathFormat.vertical,
                label: Text("Vertical"),
                icon: Icon(Icons.view_agenda_outlined),
              ),
              ButtonSegment(
                value: MathFormat.horizontal,
                label: Text("Horizontal"),
                icon: Icon(Icons.view_stream),
              ),
            ],
            selected: {_mathConfig.format},
            onSelectionChanged: (val) {
              setState(() => _mathConfig.format = val.first);
            },
          ),
          const SizedBox(height: 20),

          _sectionHeader("Number Range"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _mathConfig.minNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Min",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _mathConfig.minNumber = parsed);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _mathConfig.maxNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Max",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _mathConfig.maxNumber = parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _sectionHeader("Page Layout"),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text("1 Column")),
              ButtonSegment(value: 2, label: Text("2 Columns")),
            ],
            selected: {_mathConfig.columnsCount},
            onSelectionChanged: (val) {
              setState(() => _mathConfig.columnsCount = val.first);
            },
          ),
          const SizedBox(height: 20),

          _sectionHeader("Questions Count"),
          Slider(
            value: _mathConfig.questionsCount.toDouble(),
            min: 4,
            max: 20,
            divisions: 8,
            label: "${_mathConfig.questionsCount}",
            onChanged: (val) => setState(() => _mathConfig.questionsCount = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_mathConfig.questionsCount} questions",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 12),

          SwitchListTile(
            title: const Text("Show counting workspace", style: TextStyle(fontSize: 14)),
            subtitle: const Text("Dashed box for drawing sticks", style: TextStyle(fontSize: 11)),
            value: _mathConfig.drawWorkspace,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _mathConfig.drawWorkspace = val),
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
