import 'package:flutter/material.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultiSelectDropdown<T> extends StatelessWidget {
  final List<T> items;
  final List<T> selectedValues;
  final ValueChanged<List<T>> onChanged;
  final String title;
  final String hint;
  final String buttonText;
  final String Function(T) itemLabel;

  const MultiSelectDropdown({
    Key? key,
    required this.items,
    required this.selectedValues,
    required this.onChanged,
    required this.itemLabel,
    this.title = 'Select Items',
    this.hint = 'Select one or more items',
    this.buttonText = 'Choose Items',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiSelectDialogField<T>(
      items: items
          .map((item) => MultiSelectItem<T>(item, itemLabel(item)))
          .toList(),
      initialValue: selectedValues,
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      cancelText: Text(
        'Cancel',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      confirmText: Text(
        'OK',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      buttonText: Text(
        '   $buttonText',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).inputDecorationTheme.fillColor,
        borderRadius: BorderRadius.circular(30),
      ),
      itemsTextStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      checkColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : Colors.white,
      selectedColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.blue
          : Colors.blue,
      selectedItemsTextStyle: TextStyle(
        color: Colors.blue,
        fontSize: 16,
      ),
      onConfirm: onChanged,
      chipDisplay: MultiSelectChipDisplay(
        chipColor: Theme.of(context).brightness == Brightness.light
            ? Colors.blue.shade100
            : Colors.blueAccent.shade100,
        textStyle: Theme.of(context).textTheme.bodyLarge,
        onTap: (item) {
          selectedValues.remove(item);
          onChanged(List.from(selectedValues));
        },
      ),
    );
  }
}
