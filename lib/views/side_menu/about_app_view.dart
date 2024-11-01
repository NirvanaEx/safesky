import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:safe_sky/views/pdf_page_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutAppView extends StatelessWidget {
  Future<String> _getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}.${packageInfo.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        centerTitle: true,
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
              color: Color(0xFF323955),
            ),
            Text(
              localizations.aboutApp,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            FutureBuilder<String>(
              future: _getAppVersion(),
              builder: (context, snapshot) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    '${localizations.version}: ${snapshot.data ?? ''}',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              },
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        // Получаем код языка
                        String pdfPath;
                        final locale = Localizations.localeOf(context);
                        if (locale.languageCode == 'ru') {
                          pdfPath = 'assets/docs/user_agreement_ru.pdf';
                        } else if (locale.languageCode == 'uz') {
                          pdfPath = 'assets/docs/user_agreement_uz.pdf';
                        } else {
                          pdfPath = 'assets/docs/user_agreement_en.pdf';
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PdfPageView(
                              pdfPath: pdfPath,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          localizations.userAgreement,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Material(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      onTap: () {
                        // Логика открытия страницы политики конфиденциальности
                      },
                      borderRadius: BorderRadius.circular(15),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          localizations.privacyPolicy,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
