import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonForm extends StatelessWidget {
  const SkeletonForm({Key? key}) : super(key: key);

  // Константы для размеров
  static const double _labelHeight = 20.0;
  static const double _fieldHeight = 50.0;
  static const double _labelFieldSpacing = 8.0;
  static const double _verticalSpacing = 16.0;

  // Ширина лейбла можно задать фиксированно или оставить переменной
  static const double _labelWidth = 150.0;

  // Высота одного skeleton-блока (лейбл + отступ + поле + нижний отступ)
  double get skeletonItemTotalHeight =>
      _labelHeight + _labelFieldSpacing + _fieldHeight + _verticalSpacing;

  @override
  Widget build(BuildContext context) {
    // Определяем яркость текущей темы
    final brightness = Theme.of(context).brightness;
    // Выбираем базовый и выделяющий цвета в зависимости от темы
    final baseColor =
    brightness == Brightness.dark ? Colors.grey[700]! : Colors.grey.shade300;
    final highlightColor =
    brightness == Brightness.dark ? Colors.grey[600]! : Colors.grey.shade100;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Высота экрана
        final availableHeight = constraints.maxHeight;
        // Рассчитываем количество блоков, округляя вверх
        final int count = (availableHeight / skeletonItemTotalHeight).ceil();

        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 15),
                ...List.generate(
                  count,
                      (index) =>
                      _buildSkeletonField(baseColor, highlightColor, brightness),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkeletonField(
      Color baseColor, Color highlightColor, Brightness brightness) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Лейбл (меньше)
        Container(
          width: _labelWidth,
          height: _labelHeight,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        const SizedBox(height: _labelFieldSpacing),
        // Поле (на всю ширину)
        Container(
          width: double.infinity,
          height: _fieldHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [baseColor, highlightColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(brightness == Brightness.dark ? 0.2 : 0.1),
                blurRadius: 4,
                offset: const Offset(2, 2),
              ),
            ],
          ),
        ),
        const SizedBox(height: _verticalSpacing),
      ],
    );
  }
}
