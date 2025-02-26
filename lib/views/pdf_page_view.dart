import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PdfPageView extends StatelessWidget {
  final String pdfPath;

  PdfPageView({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          localizations.userAgreement,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SfPdfViewer.asset(pdfPath),
    );
  }
}
