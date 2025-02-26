import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelectDropdown<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedValues;
  final ValueChanged<List<T>> onChanged;
  final String title;
  final String hint;
  final String buttonText;
  final String Function(T) itemLabel;  // Функция для получения названия элемента

  MultiSelectDropdown({
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    required this.itemLabel,
    this.title = 'Select Items',
    this.hint = 'Select one or more items',
    this.buttonText = 'Choose Items',
  });

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<T>(
      items: items.map((item) => MultiSelectItem<T>(item, itemLabel(item))).toList(),
      initialValue: selectedValues,
      title: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      buttonText: Text(
        '   $buttonText',
        style: TextStyle(fontSize: 16),
      ),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      onConfirm: onChanged,
      chipDisplay: MultiSelectChipDisplay(
        textStyle: TextStyle(fontSize: 16),
        onTap: (item) {
          selectedValues.remove(item);
          onChanged(List.from(selectedValues));
        },
      ),
    );
  }
}
