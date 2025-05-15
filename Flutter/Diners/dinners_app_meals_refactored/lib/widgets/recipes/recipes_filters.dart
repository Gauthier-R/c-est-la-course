import 'package:flutter/material.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/app_colors.dart';

class RecipesFilters extends StatelessWidget {
  final String selectedSeason;
  final String selectedTime;
  final String selectedType;
  final Function(String) onSeasonChanged;
  final Function(String) onTimeChanged;
  final Function(String) onTypeChanged;

  const RecipesFilters({
    super.key,
    required this.selectedSeason,
    required this.selectedTime,
    required this.selectedType,
    required this.onSeasonChanged,
    required this.onTimeChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: ResponsiveHelper.heightPercent(context, 0.16),
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.widthPercent(context, 0.04),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.widthPercent(context, 0.04),
          vertical: ResponsiveHelper.heightPercent(context, 0.02),
        ),
        decoration: BoxDecoration(
          color: AppColors.darkOrange,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabeledDropdown(
              label: 'Saison',
              items: ['Tous', '☀️', '❄️', '🌞❄️'],
              selected: selectedSeason,
              onChanged: onSeasonChanged,
            ),
            const SizedBox(width: 8),
            _buildLabeledDropdown(
              label: 'Temps',
              items: ['Tous', '15min', '1h', '+1h'],
              selected: selectedTime,
              onChanged: onTimeChanged,
            ),
            const SizedBox(width: 8),
            _buildLabeledDropdown(
              label: 'Type',
              items: ['Tous', '🥗', '🍗', '🍰'],
              selected: selectedType,
              onChanged: onTypeChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabeledDropdown({
    required String label,
    required List<String> items,
    required String selected,
    required Function(String) onChanged,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, bottom: 4),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selected,
                isExpanded: true,
                items: items
                    .map((val) => DropdownMenuItem(
                          value: val,
                          child: Center(child: Text(val)),
                        ))
                    .toList(),
                onChanged: (val) => onChanged(val!),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
