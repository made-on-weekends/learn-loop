import 'package:flutter/material.dart';

class MarginPreset {
  final double mm;
  final String label;

  const MarginPreset({required this.mm, required this.label});
}

class PageMarginDropdown extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  static const List<MarginPreset> presets = [
    MarginPreset(mm: 10.0, label: 'Narrow (10 mm / 0.4")'),
    MarginPreset(mm: 15.0, label: 'Moderate (15 mm / 0.6")'),
    MarginPreset(mm: 19.05, label: 'Normal (19 mm / 0.75")'),
    MarginPreset(mm: 25.4, label: 'Wide (25.4 mm / 1.0")'),
  ];

  const PageMarginDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Find closest matching preset value if not an exact match
    double selectedValue = presets.first.mm;
    double minDiff = (value - presets.first.mm).abs();

    for (final preset in presets) {
      final diff = (value - preset.mm).abs();
      if (diff < minDiff) {
        minDiff = diff;
        selectedValue = preset.mm;
      }
    }

    return DropdownButtonFormField<double>(
      key: ValueKey(selectedValue),
      initialValue: selectedValue,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: "Page Margin",
        helperText: "Page margin padding around worksheet content",
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: presets.map((preset) {
        return DropdownMenuItem<double>(
          value: preset.mm,
          child: Text(
            preset.label,
            style: const TextStyle(fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) {
          onChanged(val);
        }
      },
    );
  }
}
