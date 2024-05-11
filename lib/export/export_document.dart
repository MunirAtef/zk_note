
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../shared/user_data.dart';


class DocumentStrings {
  final String footer = "تم الارسال من برنامج ZK Invoicement (طور بواسطة منير محمد عاطف)";
  final String contactDev = "تواصل مع المبرمج";

  List<String> months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
    'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
}

abstract class ExportDocument {
  pw.Document pdf = pw.Document();
  late pw.Font ttf;

  DocumentStrings documentStrings = DocumentStrings();

  Future<void> getFont() async {
    ByteData font = await rootBundle.load("assets/fonts/Janna LT Bold.ttf");
    ttf = pw.Font.ttf(font);
  }

  pw.Padding link(String text, String url) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(right: 10),

      child: pw.UrlLink(
        child: pw.DecoratedBox(
          decoration: const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900))
          ),
          child: pw.Text(
            text,
            style: pw.TextStyle(
              color: PdfColors.blue900,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            )
          )
        ),
        destination: url,
      )
    );
  }

  pw.PageTheme pageTheme(double height) {
    return pw.PageTheme(
      textDirection: pw.TextDirection.rtl,
      pageFormat: PdfPageFormat(650, height, marginBottom: 50, marginLeft: 30, marginRight: 30, marginTop: 40),
      buildBackground: (context) {
        return pw.Container(
          alignment: pw.Alignment.bottomCenter,
          padding: const pw.EdgeInsets.only(bottom: -25),

          child: pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Divider(height: 2),

              pw.Text(
                documentStrings.footer,
                style: pw.TextStyle(
                  font: ttf,
                  fontSize: 9,
                  color: const PdfColor(0.35, 0.35, 0.35)
                ),
              ),

              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                children: [
                  // link('Facebook', 'https://www.facebook.com/munir-atef.52'),
                  link('Gmail: munir.atef1729@gmail.com', 'mailto:munir.atef1729@gmail.com?to=&subject=&body=Hi Munir, '),
                  link('Whats: +201146721499', 'https://wa.me/+201146721499'),

                  pw.Text(
                    documentStrings.contactDev,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 9,
                      color: const PdfColor(0.35, 0.35, 0.35)
                    ),
                  ),
                ]
              )
            ]
          )
        );
      },
    );
  }

  Future<Uint8List?> getMarketplaceLogo() async {
    if (UserData.mpLogo == null) return null;
    return (await http.get(Uri.parse(UserData.mpLogo!))).bodyBytes;
  }

  dateFormatter(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

    return "${date.day} ${documentStrings.months[date.month - 1]} ${date.year}";
  }
}
