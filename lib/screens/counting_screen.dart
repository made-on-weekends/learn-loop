import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/counting_config.dart';
import '../services/pdf_service.dart';
import '../widgets/worksheet_editor_layout.dart';

class CountingScreen extends StatefulWidget {
  const CountingScreen({super.key});

  @override
  State<CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<CountingScreen> {
  late GlobalConfig _globalConfig;
  late CountingConfig _countingConfig;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Count and Write");
      _countingConfig = CountingConfig();
    });
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateCounting(_globalConfig, _countingConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Numbers & Counting",
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
          Slider(
            value: _globalConfig.marginMm,
            min: 5.0,
            max: 30.0,
            divisions: 5,
            label: "Margin: ${_globalConfig.marginMm.toInt()} mm",
            onChanged: (val) {
              setState(() {
                _globalConfig.marginMm = val;
              });
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Page Margin: ${_globalConfig.marginMm.toInt()} mm",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ),
          const Divider(height: 32),

          _sectionHeader("Activity Type"),
          const SizedBox(height: 12),
          SegmentedButton<CountingActivityType>(
            segments: const [
              ButtonSegment(
                value: CountingActivityType.countAndWrite,
                label: Text("Count & Write"),
                icon: Icon(Icons.visibility),
              ),
              ButtonSegment(
                value: CountingActivityType.drawToMatch,
                label: Text("Draw to Match"),
                icon: Icon(Icons.draw),
              ),
            ],
            selected: {_countingConfig.activityType},
            onSelectionChanged: (val) {
              setState(() {
                _countingConfig.activityType = val.first;
                _globalConfig.title = val.first == CountingActivityType.countAndWrite
                    ? "Count and Write"
                    : "Draw to Match";
              });
            },
          ),
          const SizedBox(height: 20),

          _sectionHeader("Number Range"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _countingConfig.minNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Min",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _countingConfig.minNumber = parsed);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: _countingConfig.maxNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Max",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _countingConfig.maxNumber = parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _sectionHeader("Shape Type"),
          const SizedBox(height: 12),
          DropdownButtonFormField<ShapeType>(
            value: _countingConfig.shapeType,
            decoration: const InputDecoration(
              labelText: "Object Shape",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: ShapeType.values.map((e) {
              String label = e.name[0].toUpperCase() + e.name.substring(1);
              return DropdownMenuItem(value: e, child: Text(label));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _countingConfig.shapeType = val);
            },
          ),
          const SizedBox(height: 20),

          _sectionHeader("Questions Per Page"),
          Slider(
            value: _countingConfig.questionsPerPage.toDouble(),
            min: 2,
            max: 12,
            divisions: 5,
            label: "${_countingConfig.questionsPerPage}",
            onChanged: (val) => setState(() => _countingConfig.questionsPerPage = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_countingConfig.questionsPerPage} questions per page",
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
