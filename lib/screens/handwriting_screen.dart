import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/handwriting_config.dart';
import '../services/pdf_service.dart';
import '../widgets/worksheet_editor_layout.dart';

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  late GlobalConfig _globalConfig;
  late HandwritingConfig _handwritingConfig;
  late TextEditingController _customTextController;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Handwriting Practice");
      _handwritingConfig = HandwritingConfig();
      _customTextController = TextEditingController(text: _handwritingConfig.customText);
    });
  }

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateHandwriting(_globalConfig, _handwritingConfig);
  }

  @override
  Widget build(BuildContext context) {
    return WorksheetEditorLayout(
      title: "Handwriting Generator",
      onReset: _resetConfig,
      pdfBuilder: _buildPdf,
      settingsWidget: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Global Page Settings Section
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

          // 2. Practice Content Options
          _buildSectionHeader("Worksheet Content"),
          const SizedBox(height: 12),
          DropdownButtonFormField<HandwritingSource>(
            value: _handwritingConfig.source,
            decoration: const InputDecoration(
              labelText: "Generate Source",
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: HandwritingSource.alphabetUpper,
                child: Text("A-Z (Uppercase)"),
              ),
              DropdownMenuItem(
                value: HandwritingSource.alphabetLower,
                child: Text("a-z (Lowercase)"),
              ),
              DropdownMenuItem(
                value: HandwritingSource.numbers,
                child: Text("Numbers (Range)"),
              ),
              DropdownMenuItem(
                value: HandwritingSource.customText,
                child: Text("Custom Spelling Text"),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _handwritingConfig.source = val;
                  if (val == HandwritingSource.alphabetUpper) {
                    _handwritingConfig.alphabetStart = _handwritingConfig.alphabetStart.toUpperCase();
                    _handwritingConfig.alphabetEnd = _handwritingConfig.alphabetEnd.toUpperCase();
                  } else if (val == HandwritingSource.alphabetLower) {
                    _handwritingConfig.alphabetStart = _handwritingConfig.alphabetStart.toLowerCase();
                    _handwritingConfig.alphabetEnd = _handwritingConfig.alphabetEnd.toLowerCase();
                  }
                });
              }
            },
          ),
          const SizedBox(height: 12),

          // Alphabet range inputs
          if (_handwritingConfig.source == HandwritingSource.alphabetUpper ||
              _handwritingConfig.source == HandwritingSource.alphabetLower) ...[
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _handwritingConfig.alphabetStart.toUpperCase(),
                    decoration: const InputDecoration(
                      labelText: "Start Letter",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: List.generate(26, (index) => String.fromCharCode(65 + index))
                        .map((char) => DropdownMenuItem(
                              value: char,
                              child: Text(
                                _handwritingConfig.source == HandwritingSource.alphabetUpper
                                    ? char
                                    : char.toLowerCase(),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _handwritingConfig.alphabetStart =
                              _handwritingConfig.source == HandwritingSource.alphabetUpper
                                  ? val
                                  : val.toLowerCase();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _handwritingConfig.alphabetEnd.toUpperCase(),
                    decoration: const InputDecoration(
                      labelText: "End Letter",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: List.generate(26, (index) => String.fromCharCode(65 + index))
                        .map((char) => DropdownMenuItem(
                              value: char,
                              child: Text(
                                _handwritingConfig.source == HandwritingSource.alphabetUpper
                                    ? char
                                    : char.toLowerCase(),
                              ),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _handwritingConfig.alphabetEnd =
                              _handwritingConfig.source == HandwritingSource.alphabetUpper
                                  ? val
                                  : val.toLowerCase();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Number range inputs
          if (_handwritingConfig.source == HandwritingSource.numbers) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _handwritingConfig.numberStart.toString(),
                    decoration: const InputDecoration(
                      labelText: "Start Number",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) {
                        setState(() {
                          _handwritingConfig.numberStart = parsed;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    initialValue: _handwritingConfig.numberEnd.toString(),
                    decoration: const InputDecoration(
                      labelText: "End Number",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final parsed = int.tryParse(val);
                      if (parsed != null) {
                        setState(() {
                          _handwritingConfig.numberEnd = parsed;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Textarea custom input
          if (_handwritingConfig.source == HandwritingSource.customText) ...[
            TextFormField(
              controller: _customTextController,
              decoration: const InputDecoration(
                labelText: "Spelling Words (one item per line)",
                hintText: "Enter spelling text or name...\ne.g.\nALEX\nCAT\nDOG",
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
              onChanged: (val) {
                setState(() {
                  _handwritingConfig.customText = val;
                });
              },
            ),
            const SizedBox(height: 12),
          ],

          const Divider(height: 32),

          // 3. Layout and Tracing settings
          _buildSectionHeader("Practice Mode & Direction"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<PracticeMode>(
                  value: _handwritingConfig.mode,
                  decoration: const InputDecoration(
                    labelText: "Mode",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PracticeMode.tracing,
                      child: Text("Trace Letters"),
                    ),
                    DropdownMenuItem(
                      value: PracticeMode.copy,
                      child: Text("Copy Example"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _handwritingConfig.mode = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<PracticeDirection>(
                  value: _handwritingConfig.direction,
                  decoration: const InputDecoration(
                    labelText: "Direction",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PracticeDirection.row,
                      child: Text("Row"),
                    ),
                    DropdownMenuItem(
                      value: PracticeDirection.column,
                      child: Text("Column"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _handwritingConfig.direction = val;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text("Use Dotted Font for Tracing", style: TextStyle(fontSize: 14)),
            value: _handwritingConfig.dottedFont,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _handwritingConfig.dottedFont = val;
              });
            },
          ),
          Slider(
            value: _handwritingConfig.fontSize,
            min: 24.0,
            max: 56.0,
            divisions: 8,
            label: "Size: ${_handwritingConfig.fontSize.toInt()} pt",
            onChanged: (val) {
              setState(() {
                _handwritingConfig.fontSize = val;
              });
            },
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                "Letter Font Size: ${_handwritingConfig.fontSize.toInt()} pt",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
          ),
          const Divider(height: 32),

          // 4. Guideline Toggles
          _buildSectionHeader("Line Guidelines"),
          const SizedBox(height: 8),
          const Text(
            "Toggle individual lines on the 4-line grid. Colors are shades of grey for ink-efficient printing.",
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            title: const Text("Top Line (Grey)", style: TextStyle(fontSize: 13)),
            value: _handwritingConfig.showTopLine,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _handwritingConfig.showTopLine = val ?? true;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Mid Line (Dashed Light Grey)", style: TextStyle(fontSize: 13)),
            value: _handwritingConfig.showMidLine,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _handwritingConfig.showMidLine = val ?? true;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Base Line (Solid Dark Grey)", style: TextStyle(fontSize: 13)),
            value: _handwritingConfig.showBaseLine,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _handwritingConfig.showBaseLine = val ?? true;
              });
            },
          ),
          CheckboxListTile(
            title: const Text("Bottom Line (Grey)", style: TextStyle(fontSize: 13)),
            value: _handwritingConfig.showBottomLine,
            dense: true,
            contentPadding: EdgeInsets.zero,
            onChanged: (val) {
              setState(() {
                _handwritingConfig.showBottomLine = val ?? true;
              });
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
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
