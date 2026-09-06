import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/counting_config.dart';
import '../services/pdf_service.dart';
import '../services/random_seed_service.dart';
import '../widgets/page_margin_dropdown.dart';
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

          _sectionHeader("Activity Type"),
          const SizedBox(height: 12),
          DropdownButtonFormField<CountingActivityType>(
            initialValue: _countingConfig.activityType,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: "Worksheet Activity",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: CountingActivityType.countAndWrite,
                child: Text("Count and Write", overflow: TextOverflow.ellipsis),
              ),
              DropdownMenuItem(
                value: CountingActivityType.drawToMatch,
                child: Text(
                  "Draw to Match Number",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: CountingActivityType.numberTracing,
                child: Text(
                  "Number Tracing 1-20",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: CountingActivityType.moreVsLess,
                child: Text(
                  "Compare Groups (More vs Less)",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownMenuItem(
                value: CountingActivityType.numberSequence,
                child: Text(
                  "Fill in Missing Sequence",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _countingConfig.activityType = val;
                  switch (val) {
                    case CountingActivityType.countAndWrite:
                      _globalConfig.title = "Count and Write";
                      break;
                    case CountingActivityType.drawToMatch:
                      _globalConfig.title = "Draw to Match";
                      break;
                    case CountingActivityType.numberTracing:
                      _globalConfig.title = "Number Tracing Practice";
                      break;
                    case CountingActivityType.moreVsLess:
                      _globalConfig.title = _countingConfig.compareMore
                          ? "Circle the Group with MORE"
                          : "Circle the Group with FEWER";
                      break;
                    case CountingActivityType.numberSequence:
                      _globalConfig.title = "Fill in Missing Numbers";
                      break;
                  }
                });
              }
            },
          ),
          const SizedBox(height: 20),

          if (_countingConfig.activityType ==
              CountingActivityType.moreVsLess) ...[
            _sectionHeader("Comparison Target"),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text("Circle MORE")),
                ButtonSegment(value: false, label: Text("Circle FEWER")),
              ],
              selected: {_countingConfig.compareMore},
              onSelectionChanged: (val) {
                setState(() {
                  _countingConfig.compareMore = val.first;
                  _globalConfig.title = val.first
                      ? "Circle the Group with MORE"
                      : "Circle the Group with FEWER";
                });
              },
            ),
            const SizedBox(height: 20),
          ],

          if (_countingConfig.activityType ==
              CountingActivityType.numberSequence) ...[
            _sectionHeader("Sequence Length"),
            Slider(
              value: _countingConfig.sequenceLength.toDouble(),
              min: 3,
              max: 6,
              divisions: 3,
              label: "${_countingConfig.sequenceLength}",
              onChanged: (val) =>
                  setState(() => _countingConfig.sequenceLength = val.toInt()),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                "${_countingConfig.sequenceLength} numbers per sequence",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
            const SizedBox(height: 20),
          ],

          _sectionHeader("Number Range"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey("min_${_countingConfig.minNumber}"),
                  initialValue: _countingConfig.minNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Min",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      setState(() => _countingConfig.minNumber = parsed);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  key: ValueKey("max_${_countingConfig.maxNumber}"),
                  initialValue: _countingConfig.maxNumber.toString(),
                  decoration: const InputDecoration(
                    labelText: "Max",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) {
                      setState(() => _countingConfig.maxNumber = parsed);
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_countingConfig.activityType !=
                  CountingActivityType.numberTracing &&
              _countingConfig.activityType !=
                  CountingActivityType.numberSequence) ...[
            _sectionHeader("Shape Type"),
            const SizedBox(height: 12),
            DropdownButtonFormField<ShapeType>(
              initialValue: _countingConfig.shapeType,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: "Object Shape",
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: ShapeType.values.map((e) {
                String label = e.name[0].toUpperCase() + e.name.substring(1);
                return DropdownMenuItem(
                  value: e,
                  child: Text(label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _countingConfig.shapeType = val);
                }
              },
            ),
            const SizedBox(height: 20),
          ],

          _sectionHeader("Items / Questions Count"),
          Slider(
            value: _countingConfig.questionsPerPage.toDouble(),
            min: 2,
            max: 12,
            divisions: 10,
            label: "${_countingConfig.questionsPerPage}",
            onChanged: (val) =>
                setState(() => _countingConfig.questionsPerPage = val.toInt()),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              "${_countingConfig.questionsPerPage} items per page",
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.shuffle),
              label: const Text("Shuffle Random Seed"),
              onPressed: () {
                setState(() {
                  _countingConfig.seed = RandomSeedService.generateNewSeed();
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
