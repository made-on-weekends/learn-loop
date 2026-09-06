import 'package:flutter/material.dart';
import '../models/kid_profile.dart';
import '../services/settings_service.dart';

class KidProfileCard extends StatelessWidget {
  final ValueChanged<KidProfile>? onChanged;
  final bool compact;

  const KidProfileCard({super.key, this.onChanged, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<KidProfile>(
      valueListenable: SettingsService.kidProfileNotifier,
      builder: (context, profile, _) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          padding: EdgeInsets.all(compact ? 12.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.child_care_rounded,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Kid Profile",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Sets default line spacing & grade level",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.65,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Age Dropdown (Row 1)
              DropdownButtonFormField<int>(
                key: ValueKey('age_${profile.age}'),
                initialValue: profile.age,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Age",
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: List.generate(11, (i) => i + 2).map((age) {
                  return DropdownMenuItem(value: age, child: Text("$age yrs"));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final updated = profile.copyWith(age: val);
                    SettingsService.saveKidProfile(updated);
                    onChanged?.call(updated);
                  }
                },
              ),
              const SizedBox(height: 12),
              // Grade Dropdown (Row 2)
              DropdownButtonFormField<KidGrade>(
                key: ValueKey('grade_${profile.grade.name}'),
                initialValue: profile.grade,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Grade",
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: KidGrade.values.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    final updated = profile.copyWith(grade: val);
                    SettingsService.saveKidProfile(updated);
                    onChanged?.call(updated);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
