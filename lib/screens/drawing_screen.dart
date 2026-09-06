import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/drawing_config.dart';
import '../models/global_config.dart';
import '../models/kid_profile.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  late GlobalConfig _globalConfig;
  late DrawingConfig _drawingConfig;
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _resetConfig();
  }

  void _resetConfig() {
    setState(() {
      _globalConfig = GlobalConfig(title: "Drawing & Creativity");
      _drawingConfig = DrawingConfig();
      _promptController = TextEditingController(
        text: _drawingConfig.storyPromptText,
      );
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildPdf() {
    return PdfService.generateDrawing(_globalConfig, _drawingConfig);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<KidProfile>(
      valueListenable: SettingsService.kidProfileNotifier,
      builder: (context, profile, _) {
        return WorksheetEditorLayout(
          title: "Drawing & Creativity Generator",
          onReset: _resetConfig,
          pdfBuilder: _buildPdf,
          settingsWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Activity Mode Selector
              _buildSectionHeader("Worksheet Activity Mode"),
              const SizedBox(height: 10),
              DropdownButtonFormField<DrawingActivityMode>(
                key: const ValueKey('drawing_mode_dropdown'),
                initialValue: _drawingConfig.activityMode,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Activity Mode",
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: DrawingActivityMode.values.map((mode) {
                  return DropdownMenuItem<DrawingActivityMode>(
                    value: mode,
                    child: Text(mode.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _drawingConfig.activityMode = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              // 2. Dynamic Activity Controls
              if (_drawingConfig.activityMode ==
                  DrawingActivityMode.finishSymmetry) ...[
                DropdownButtonFormField<int>(
                  key: const ValueKey('symmetry_grid_dropdown'),
                  initialValue: _drawingConfig.gridSize,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Grid Dimensions",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 6,
                      child: Text("6 x 6 Grid (Easier)"),
                    ),
                    DropdownMenuItem(
                      value: 8,
                      child: Text("8 x 8 Grid (Standard)"),
                    ),
                    DropdownMenuItem(
                      value: 10,
                      child: Text("10 x 10 Grid (Advanced)"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _drawingConfig.gridSize = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_drawingConfig.activityMode ==
                  DrawingActivityMode.stepByStep) ...[
                DropdownButtonFormField<String>(
                  key: const ValueKey('step_subject_dropdown'),
                  initialValue: _drawingConfig.stepSubject,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: "Drawing Subject",
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cat', child: Text("Cute Cat")),
                    DropdownMenuItem(value: 'car', child: Text("Race Car")),
                    DropdownMenuItem(value: 'house', child: Text("Cozy House")),
                    DropdownMenuItem(
                      value: 'rocket',
                      child: Text("Space Rocket"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _drawingConfig.stepSubject = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_drawingConfig.activityMode ==
                  DrawingActivityMode.storyPrompt) ...[
                TextFormField(
                  key: const ValueKey('story_prompt_field'),
                  controller: _promptController,
                  decoration: const InputDecoration(
                    labelText: "Story Prompt Text",
                    border: OutlineInputBorder(),
                    helperText: "Appears at the top of the draw & write page",
                  ),
                  maxLines: 2,
                  onChanged: (val) {
                    setState(() {
                      _drawingConfig.storyPromptText = val;
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_drawingConfig.activityMode ==
                  DrawingActivityMode.dotToDot) ...[
                Text(
                  "Number of Dots: ${_drawingConfig.dotCount}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Slider(
                  key: const ValueKey('dot_count_slider'),
                  value: _drawingConfig.dotCount.toDouble(),
                  min: 10,
                  max: 25,
                  divisions: 15,
                  label: "${_drawingConfig.dotCount} Dots",
                  onChanged: (val) {
                    setState(() {
                      _drawingConfig.dotCount = val.toInt();
                    });
                  },
                ),
                const SizedBox(height: 12),
              ],

              // Seed Shuffle Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const ValueKey('shuffle_drawing_seed_btn'),
                  icon: const Icon(Icons.shuffle, size: 18),
                  label: const Text("Shuffle Prompt / Variant"),
                  onPressed: () {
                    setState(() {
                      _drawingConfig.seed = math.Random().nextInt(1000000);
                    });
                  },
                ),
              ),

              const Divider(height: 32),

              // 3. Global Page Settings Section
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
              const SizedBox(height: 24),
            ],
          ),
        );
      },
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
