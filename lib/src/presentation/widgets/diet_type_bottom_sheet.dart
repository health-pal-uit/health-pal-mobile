import 'package:da1/src/config/theme/app_colors.dart';
import 'package:da1/src/config/theme/typography.dart';
import 'package:da1/src/domain/entities/diet_type.dart';
import 'package:flutter/material.dart';

class DietTypeBottomSheet extends StatefulWidget {
  final List<DietType> dietTypes;
  final String? currentDietTypeId;
  final int totalKcal;

  const DietTypeBottomSheet({
    super.key,
    required this.dietTypes,
    this.currentDietTypeId,
    required this.totalKcal,
  });

  @override
  State<DietTypeBottomSheet> createState() => _DietTypeBottomSheetState();
}

class _DietTypeBottomSheetState extends State<DietTypeBottomSheet> {
  String? _selectedDietTypeId;

  @override
  void initState() {
    super.initState();
    _selectedDietTypeId = widget.currentDietTypeId;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose your Diet Type',
                  style: AppTypography.headline.copyWith(fontSize: 22),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.dietTypes.length,
              itemBuilder: (context, index) {
                final dietType = widget.dietTypes[index];
                final isSelected = _selectedDietTypeId == dietType.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDietTypeId = dietType.id;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          isSelected
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.backgroundLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              dietType.name,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color:
                                  isSelected ? AppColors.primary : Colors.grey,
                              size: 26,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            _buildMacroChip(
                              'Carbs',
                              dietType.carbsPercentages,
                              const Color.fromARGB(255, 50, 228, 107),
                            ),
                            const SizedBox(width: 10),
                            _buildMacroChip(
                              'Proteins',
                              dietType.proteinPercentages,
                              Colors.red,
                            ),
                            const SizedBox(width: 10),
                            _buildMacroChip(
                              'Fats',
                              dietType.fatPercentages,
                              Colors.amber,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _selectedDietTypeId != null
                        ? () {
                          Navigator.pop(
                            context,
                            widget.dietTypes.firstWhere(
                              (dt) => dt.id == _selectedDietTypeId,
                            ),
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  'Lưu chế độ ăn',
                  style: AppTypography.body.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroChip(String label, int percentage, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$percentage%',
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
