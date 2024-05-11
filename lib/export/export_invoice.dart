
import 'package:flutter/services.dart';
import 'package:zk_note/export/export_document.dart';
import 'package:zk_note/models/invoice_item_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zk_note/shared/invoice_data.dart';
import 'package:zk_note/shared/user_data.dart';

import '../models/client_model.dart';
import '../models/invoice_model.dart';
import 'custom_pdf_widgets.dart';
import '../shared/shared_functions.dart';


class ExportInvoice extends ExportDocument {
  InvoiceModel invoice;
  ClientModel client;

  ExportInvoice(this.invoice, this.client);

  InvoiceStrings strings = InvoiceStrings();

  double pageHeight() => (invoice.invoiceItems!.length * 30) + 500;

  pw.Table itemsTable(int start, int end) {
    return customPdfDataTable(
      headers: [
        strings.totalPrice,
        strings.unitPrice,
        strings.quantity,
        strings.itemName
      ],
      data: [
        for (InvoiceItemModel item in invoice.invoiceItems!.sublist(start, end)) [
          (item.price * item.count).toStringAsFixed(1),
          item.price.toStringAsFixed(1),
          "${item.count} ${item.unit}",
          item.name
        ]
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(0.4),
        1: const pw.FlexColumnWidth(0.4),
        2: const pw.FlexColumnWidth(0.4),
        3: const pw.FlexColumnWidth(1),
      },
      font: ttf
    );
  }

  pw.Column totalAmountSection() {
    bool hasDiscount = invoice.priceAfterDiscount < invoice.totalPrice;

    return pw.Column(
      children: [
        pw.SizedBox(height: 10),
        pw.Divider(),

        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              Shared.getPrice(invoice.totalPrice),
              style: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                fontSize: 18,
                // decoration: hasDiscount?
                // pw.TextDecoration.lineThrough
                // : pw.TextDecoration.none
              )
            ),

            pw.Text(
              strings.totalPriceForInvoice,
              style: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                fontSize: 18
              )
            ),
          ],
        ),

        pw.Divider(),

        if (hasDiscount) pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              Shared.getPrice(invoice.priceAfterDiscount),
              style: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                fontSize: 18
              )
            ),

            pw.Text(
              strings.priceAfterDiscount,
              style: pw.TextStyle(
                font: ttf,
                fontWeight: pw.FontWeight.bold,
                fontSize: 18
              )
            ),
          ],
        ),
      ]
    );
  }


  String invoiceName() {
    if (invoice.type == InvoiceTypes.purchase) return strings.purchaseInvoice;
    if (invoice.type == InvoiceTypes.sales) return strings.salesInvoice;

    return strings.returnInvoice;
  }

  Future<pw.Document> generateInvoice() async {
    await super.getFont();

    ByteData font = await rootBundle.load("assets/fonts/Janna LT Bold.ttf");
    ttf = pw.Font.ttf(font);

    String clientTitle = client.isSupplier? strings.supplierName:
      strings.clientName;

    Uint8List? marketplaceLogo = await getMarketplaceLogo();

    int itemsLen = invoice.invoiceItems!.length;

    // int firstPageItems = 15;
    // int pageItems = 20;
    // int firstPageSize = itemsLen <= firstPageItems? itemsLen: firstPageItems;
    // bool singlePage = itemsLen < firstPageItems - 2;
    //
    // int restPages = (itemsLen - firstPageItems) ~/ pageItems;
    // int startOfEnd = firstPageItems + restPages * pageItems;

    pdf.addPage(
      pw.Page(
        pageTheme: pageTheme(pageHeight()),
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(15),

            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Container(
                  width: double.infinity,
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.black,
                    borderRadius: pw.BorderRadius.all(
                      pw.Radius.circular(5)
                    )
                  ),
                  child: pw.Center(
                    child: pw.Text(
                      invoiceName(),
                      style: pw.TextStyle(
                        font: ttf,
                        fontSize: 20,
                        color: PdfColors.white
                      )
                    ),
                  )
                ),

                pw.SizedBox(height: 10),

                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                  children: [
                    marketplaceLogo != null? pw.ClipRRect(
                      horizontalRadius: 10,
                      verticalRadius: 10,

                      child: pw.Image(
                        pw.MemoryImage(marketplaceLogo),
                        height: 70,
                        width: 70,
                        alignment: pw.Alignment.center,
                        fit: pw.BoxFit.cover
                      ),
                    ): pw.SizedBox(),


                    pdfMapTable(
                      keys: [
                        strings.organizationName,
                        clientTitle,
                        strings.invoiceNumber,
                        strings.invoiceDate
                      ],
                      values: [
                        UserData.mpName!,
                        client.name,
                        invoice.invoiceNum,
                        dateFormatter(invoice.date)
                      ],
                      font: ttf
                    ),
                  ]
                ),

                subTitle(strings.invoiceItems, ttf),

                // itemsTable(0, firstPageSize),
                //
                // if (singlePage) totalAmountSection()

                itemsTable(0, itemsLen),
                totalAmountSection()
              ],
            ),
          );
        },
      ),
    );


    // for (int i = 0; i < restPages; i++) {
    //   pdf.addPage(
    //     pw.Page(
    //       pageTheme: pageTheme(700),
    //       build: (pw.Context context) {
    //         int start = firstPageItems + pageItems * i;
    //         int end = start + pageItems;
    //
    //         return pw.Column(
    //           children: [
    //             subTitle(strings.invoiceItemsContinue, ttf),
    //
    //             itemsTable(start, end)
    //           ]
    //         );
    //       }
    //     )
    //   );
    // }
    //
    //
    // if (!singlePage) {
    //   pdf.addPage(
    //     pw.Page(
    //       pageTheme: pageTheme(700),
    //       build: (pw.Context context) {
    //         return pw.Column(
    //           children: [
    //             if (startOfEnd < itemsLen) ...[
    //               subTitle(strings.invoiceItemsContinue, ttf),
    //               itemsTable(startOfEnd, itemsLen)
    //             ],
    //
    //             totalAmountSection()
    //           ]
    //         );
    //       }
    //     )
    //   );
    // }

    return pdf;
  }
}



class InvoiceStrings extends DocumentStrings {
  final String purchaseInvoice = "فاتورة شراء";
  final String invoiceNumber = "رقم الفاتورة";
  final String salesInvoice = "فاتورة بيع";
  final String returnInvoice = "فاتورة مرتجع";
  final String invoiceDate = "تاريخ الفاتورة";
  final String invoiceItems = "أصناف الفاتورة";
  final String invoiceItemsContinue = "تابع أصناف الفاتورة";

  final String organizationName = "اسم المؤسسة";
  final String supplierName = "اسم المورد";
  final String clientName = "اسم العميل";
  final String totalPriceForInvoice = "المبلغ الكلي للفاتورة";
  final String priceAfterDiscount = "المبلغ بعد الخصم";

  final String itemName = "اسم الصنف";
  final String quantity = "الكمية";
  final String unitPrice = "سعر الوحدة";
  final String totalPrice = "القيمة";
}


