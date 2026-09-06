import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/math_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
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
            key: ValueKey(_globalConfig.title),
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
          const SizedBox(height: 12),
          DropdownButtonFormField<MathActivityMode>(
            initialValue: _mathConfig.activityMode,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Worksheet Style",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: MathActivityMode.standardEquations,
                child: Text(
                  "Standard Equations",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: MathActivityMode.numberLine,
                child: Text(
                  "Number Line Jump Guides",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: MathActivityMode.tenFrame,
                child: Text(
                  "Ten-Frame Grid Visualization",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: MathActivityMode.numberBonds,
                child: Text(
                  "Number Bonds (Part-Part-Whole)",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _mathConfig.activityMode = val;
                  if (val == MathActivityMode.numberLine) {
                    _globalConfig.title = "Number Line Math";
                  } else if (val == MathActivityMode.tenFrame) {
                    _globalConfig.title = "Ten-Frame Math";
                  } else if (val == MathActivityMode.numberBonds) {
                    _globalConfig.title = "Number Bonds Math";
                  } else {
                    _globalConfig.title = "Math Practice";
                  }
                });
              }
            },
          ),
          const SizedBox(height: 20),

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

          if (_mathConfig.activityMode ==
              MathActivityMode.standardEquations) ...[
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
          ],

          SwitchListTile(
            title: const Text(
              "Missing Term Questions",
              style: TextStyle(fontSize: 14),
            ),
            subtitle: const Text(
              "e.g., 3 + ___ = 5 or ___ + 2 = 5",
              style: TextStyle(fontSize: 11),
            ),
            value: _mathConfig.missingTerm,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _mathConfig.missingTerm = val),
          ),
          const SizedBox(height: 16),

          _sectionHeader("Number Range Presets"),
          const SizedBox(height: 8),
          Row(
            children: [
              ActionChip(
                label: const Text("Sums ≤ 5"),
                onPressed: () {
                  setState(() {
                    _mathConfig.minNumber = 1;
                    _mathConfig.maxNumber = 5;
                  });
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text("Sums ≤ 10"),
                onPressed: () {
                  setState(() {
                    _mathConfig.minNumber = 1;
                    _mathConfig.maxNumber = 10;
                  });
                },
              ),
              const SizedBox(width: 8),
              ActionChip(
                label: const Text("Sums ≤ 20"),
                onPressed: () {
                  setState(() {
                    _mathConfig.minNumber = 1;
                    _mathConfig.maxNumber = 20;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey("min_${_mathConfig.minNumber}"),
                  initialValue: _mathConfig.minNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Min",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      setState(() => _mathConfig.minNumber = parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey("max_${_mathConfig.maxNumber}"),
                  initialValue: _mathConfig.maxNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Max",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      setState(() => _mathConfig.maxNumber = parsed);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_mathConfig.activityMode ==
              MathActivityMode.standardEquations) ...[
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
          ],

          _sectionHeader("Questions Count"),
          Slider(
            value: _mathConfig.questionsCount.toDouble(),
            min: 4,
            max: 20,
            divisions: 8,
            label: "${_mathConfig.questionsCount}",
            onChanged: (val) =>
                setState(() => _mathConfig.questionsCount = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_mathConfig.questionsCount} questions",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 12),

          if (_mathConfig.activityMode ==
              MathActivityMode.standardEquations) ...[
            SwitchListTile(
              title: const Text(
                "Show counting workspace",
                style: TextStyle(fontSize: 14),
              ),
              subtitle: const Text(
                "Dashed box for drawing sticks",
                style: TextStyle(fontSize: 11),
              ),
              value: _mathConfig.drawWorkspace,
              contentPadding: EdgeInsets.zero,
              onChanged: (val) =>
                  setState(() => _mathConfig.drawWorkspace = val),
            ),
            const SizedBox(height: 12),
          ],

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: const Text("Shuffle Question Seed"),
              onPressed: () {
                setState(() {
                  _mathConfig.seed = RandomSeedService.generateNewSeed();
                });
              },
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }
}
