import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:safe_sky/utils/localization_manager.dart';
import 'package:safe_sky/viewmodels/add_request_viewmodel.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AddRequestViewModel viewModel;
  late BuildContext context;

  setUp(() {
    viewModel = AddRequestViewModel();
  });

  group('submitRequest validation tests', () {
    testWidgets('Invalid radius should return "Некорректное значение радиуса"', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LocalizationManager(),
          child: Builder(
            builder: (BuildContext ctx) {
              context = ctx;
              return MaterialApp(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
              );
            },
          ),
        ),
      );

      viewModel.radiusController.text = 'abc'; // Невалидное значение радиуса
      expect(viewModel.submitRequest(context), 'Некорректное значение радиуса');
    });

    testWidgets('Invalid flight height should return "Некорректное значение высоты полета"', (WidgetTester tester) async {
      viewModel.radiusController.text = '100'; // Валидное значение радиуса
      viewModel.flightHeightController.text = 'abc'; // Невалидное значение высоты полета
      expect(viewModel.submitRequest(context), 'Некорректное значение высоты полета');
    });

    testWidgets('Invalid permit number should return "Некорректное значение номера разрешения"', (WidgetTester tester) async {
      viewModel.flightHeightController.text = '50'; // Валидное значение высоты полета
      viewModel.permitNumberController.text = 'abc'; // Невалидное значение номера разрешения
      expect(viewModel.submitRequest(context), 'Некорректное значение номера разрешения');
    });

    testWidgets('Invalid contract number should return "Некорректное значение номера контракта"', (WidgetTester tester) async {
      viewModel.permitNumberController.text = '12345'; // Валидное значение номера разрешения
      viewModel.contractNumberController.text = 'abc'; // Невалидное значение номера контракта
      expect(viewModel.submitRequest(context), 'Некорректное значение номера контракта');
    });

    testWidgets('Invalid latitude and longitude format should return "Некорректный формат координат"', (WidgetTester tester) async {
      viewModel.contractNumberController.text = '67890'; // Валидное значение номера контракта
      viewModel.latLngController.text = 'abc def'; // Невалидный формат координат
      expect(viewModel.submitRequest(context), "Некорректный формат координат. Используйте формат 'широта долгота'");
    });

    testWidgets('Valid data should return null', (WidgetTester tester) async {
      viewModel.radiusController.text = '100';
      viewModel.flightHeightController.text = '50';
      viewModel.permitNumberController.text = '12345';
      viewModel.contractNumberController.text = '67890';
      viewModel.latLngController.text = '40.7128 -74.0060'; // Валидный формат координат
      viewModel.startDate = DateTime.now();
      viewModel.flightStartDateTime = DateTime.now();
      viewModel.flightEndDateTime = DateTime.now().add(Duration(hours: 1));

      expect(viewModel.submitRequest(context), null); // Ожидается успешное прохождение всех проверок
    });
  });
}
