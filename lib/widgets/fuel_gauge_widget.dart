import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FuelGaugeWidget extends StatelessWidget {
  final String? selectedLevel;
  final Function(String) onLevelSelected;

  const FuelGaugeWidget({
    Key? key,
    this.selectedLevel,
    required this.onLevelSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levels = ['1/4', '2/4', '3/4', 'FULL'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: levels.map((level) {
        bool isSelected = selectedLevel == level;
        return GestureDetector(
          onTap: () => onLevelSelected(level),
          child: Container(
            width: 50,
            height: 70,
            decoration: BoxDecoration(
              color: isSelected ? AppConfig.primaryColor : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppConfig.primaryColor : Colors.grey.shade400,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  level,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}