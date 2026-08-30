import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../models/global_config.dart';
import '../models/handwriting_config.dart';
import '../models/kid_profile.dart';
import '../services/handwriting_defaults_resolver.dart';
import '../services/pdf_service.dart';
import '../services/settings_service.dart';
import '../widgets/line_style_selector.dart';
import '../widgets/page_margin_dropdown.dart';
import '../widgets/worksheet_editor_layout.dart';

class RowHeightPreset {
  final double mm;
  final String label;

  const RowHeightPreset({required this.mm, required this.label});
}

class HandwritingScreen extends StatefulWidget {
  const HandwritingScreen({super.key});

  @override
  State<HandwritingScreen> createState() => _HandwritingScreenState();
}

class _HandwritingScreenState extends State<HandwritingScreen> {
  late GlobalConfig _globalConfig;
  late HandwritingConfig _handwritingConfig;
  late TextEditingController _customTextController;

  static const List<RowHeightPreset> _rowHeightPresets = [
    RowHeightPreset(mm: 20.0, label: '20 mm (0.79")'),
    RowHeightPreset(mm: 17.0, label: '17 mm (0.67")'),
    RowHeightPreset(mm: 14.0, label: '14 mm (0.55")'),
    RowHeightPreset(mm: 12.0, label: '12 mm (0.47")'),
    RowHeightPreset(mm: 10.5, label: '10.5 mm (0.41")'),
    RowHeightPreset(mm: 9.0, label: '9 mm (0.35")'),
  ];

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
    final kidProfile = SettingsService.currentKidProfile;
    return PdfService.generateHandwriting(_globalConfig, _handwritingConfig, kidProfile: kidProfile);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<KidProfile>(
      valueListenable: SettingsService.kidProfileNotifier,
      builder: (context, kidProfile, _) {
        final defaults = HandwritingDefaultsResolver.resolve(kidProfile: kidProfile);
        final effectiveStyle = _handwritingConfig.getEffectiveLineStyle(kidProfile);
        final effectiveRowHeightMm = _handwritingConfig.getEffectiveRowHeightMm(kidProfile);

        final isStyleOverridden = _handwritingConfig.lineStyleOverride != null;
        final isRowHeightOverridden = _handwritingConfig.rowHeightMmOverride != null;
        final isAnyOverridden = isStyleOverridden || isRowHeightOverridden;

        // Determine matching row height preset
        double selectedRowHeight = _rowHeightPresets.first.mm;
        double minHeightDiff = (effectiveRowHeightMm - _rowHeightPresets.first.mm).abs();
        for (final preset in _rowHeightPresets) {
          final diff = (effectiveRowHeightMm - preset.mm).abs();
          if (diff < minHeightDiff) {
            minHeightDiff = diff;
            selectedRowHeight = preset.mm;
          }
        }

        return WorksheetEditorLayout(
          title: "Handwriting Generator",
          onReset: _resetConfig,
          pdfBuilder: _buildPdf,
          settingsWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Writing Line Style & Height Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionHeader("Writing Guidelines"),
                  if (isAnyOverridden)
                    Flexible(
                      child: TextButton.icon(
                        icon: const Icon(Icons.restart_alt, size: 16),
                        label: Text(
                          "Reset to ${kidProfile.grade.shortName} default",
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            _handwritingConfig.resetOverrides();
                          });
                        },
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // Line Style Visual Selector (Expandable)
              Row(
                children: [
                  Text(
                    "Line Style",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isStyleOverridden
                          ? theme.colorScheme.tertiaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isStyleOverridden
                          ? "Custom Override"
                          : "Default for ${kidProfile.grade.shortName}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isStyleOverridden
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LineStyleSelector(
                selectedStyle: effectiveStyle,
                onStyleSelected: (newStyle) {
                  setState(() {
                    if (newStyle == defaults.lineStyle) {
                      _handwritingConfig.lineStyleOverride = null;
                    } else {
                      _handwritingConfig.lineStyleOverride = newStyle;
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // Row Height Presets Dropdown
              Row(
                children: [
                  Text(
                    "Row Height",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isRowHeightOverridden
                          ? theme.colorScheme.tertiaryContainer
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isRowHeightOverridden
                          ? "Custom Override"
                          : "Default for ${kidProfile.grade.shortName}",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isRowHeightOverridden
                            ? theme.colorScheme.onTertiaryContainer
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<double>(
                key: ValueKey('row_height_$selectedRowHeight'),
                initialValue: selectedRowHeight,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Row Height Preset",
                  helperText: "Guideline height based on kid's profile",
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: _rowHeightPresets.map((preset) {
                  final isDefault = (preset.mm - defaults.rowHeightMm).abs() < 0.1;
                  return DropdownMenuItem<double>(
                    value: preset.mm,
                    child: Text(
                      isDefault ? "${preset.label} (Default)" : preset.label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isDefault ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      if ((val - defaults.rowHeightMm).abs() < 0.1) {
                        _handwritingConfig.rowHeightMmOverride = null;
                      } else {
                        _handwritingConfig.rowHeightMmOverride = val;
                      }
                    });
                  }
                },
              ),

              const Divider(height: 32),

              // 2. Guideline Styling & Colors
              _buildSectionHeader("Line Color Scheme"),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<GuidelineColorScheme>(
                  segments: const [
                    ButtonSegment(
                      value: GuidelineColorScheme.zanerBloser,
                      label: Text("Color"),
                      icon: Icon(Icons.palette_outlined),
                    ),
                    ButtonSegment(
                      value: GuidelineColorScheme.monochrome,
                      label: Text("Black & White"),
                      icon: Icon(Icons.print_outlined),
                    ),
                  ],
                  selected: {_handwritingConfig.colorScheme},
                  onSelectionChanged: (val) {
                    setState(() {
                      _handwritingConfig.colorScheme = val.first;
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

              // 4. Practice Content Options
              _buildSectionHeader("Worksheet Content"),
              const SizedBox(height: 12),
              DropdownButtonFormField<HandwritingSource>(
                initialValue: _handwritingConfig.source,
                isExpanded: true,
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
                        initialValue: _handwritingConfig.alphabetStart.toUpperCase(),
                        isExpanded: true,
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
                        initialValue: _handwritingConfig.alphabetEnd.toUpperCase(),
                        isExpanded: true,
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

              // 5. Practice Mode & Direction
              _buildSectionHeader("Practice Mode & Direction"),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<PracticeMode>(
                      initialValue: _handwritingConfig.mode,
                      isExpanded: true,
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
                      initialValue: _handwritingConfig.direction,
                      isExpanded: true,
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
              // Conditional Dotted Font Switch (Only show when tracing is chosen)
              if (_handwritingConfig.mode == PracticeMode.tracing) ...[
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
              ],
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
