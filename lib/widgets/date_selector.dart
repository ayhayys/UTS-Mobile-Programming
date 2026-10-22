import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/app_theme.dart';
import '../core/json_utils.dart';

/// Baris pemilih tanggal (Today + 4 hari ke depan + tombol kalender).
class DateSelector extends StatelessWidget {
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const DateSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  Future<void> _pickDate(BuildContext context) async {
    final today = dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: selected,
      firstDate: today,
      lastDate: today.add(const Duration(days: 10)),
    );
    if (picked != null) onSelected(dateOnly(picked));
  }

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final days = List.generate(5, (i) => today.add(Duration(days: i)));
    final outsideRow = !days.contains(selected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final d in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _DateChip(
                  label: d == today
                      ? 'TODAY'
                      : DateFormat('EEE').format(d).toUpperCase(),
                  day: d.day.toString(),
                  selected: d == selected,
                  onTap: () => onSelected(d),
                ),
              ),
            ),
          const SizedBox(width: 3),
          InkWell(
            onTap: () => _pickDate(context),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 46,
              height: 62,
              decoration: BoxDecoration(
                color: outsideRow ? AppColors.accent : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: outsideRow ? AppColors.accent : AppColors.border,
                ),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: outsideRow ? Colors.white : AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final String day;
  final bool selected;
  final VoidCallback onTap;

  const _DateChip({
    required this.label,
    required this.day,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 62,
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white70 : AppColors.muted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              day,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: selected ? Colors.white : AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
