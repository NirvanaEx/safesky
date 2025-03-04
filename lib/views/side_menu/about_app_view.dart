import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/views/pdf_page_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

// Получаем значение суффикса из переменной среды
const String buildSuffix = String.fromEnvironment('BUILD_SUFFIX', defaultValue: '');

class AboutAppView extends StatelessWidget {
  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}.${packageInfo.buildNumber}$buildSuffix';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(localizations.mainView_aboutApp),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            SvgPicture.asset(
              'assets/svg/logo.svg',
              height: 80,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(height: 16),
            Text(
              localizations.mainView_aboutApp,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${localizations.version}: ${snapshot.data ?? ''}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              },
            ),
            Divider(),

          ],
        ),
      ),
    );
  }
}
