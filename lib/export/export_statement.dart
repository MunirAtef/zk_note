
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/shared/invoice_data.dart';
import 'package:zk_note/shared/user_data.dart';

import '../models/client_model.dart';
import '../models/invoice_model.dart';
import '../models/trans_payments_model.dart';
import '../shared/shared_functions.dart';
import 'custom_pdf_widgets.dart';
import 'export_document.dart';


class ExportStatement extends ExportDocument {
  List<InvoiceModel> invoices;
  List<PaymentModel> payments;
  ClientModel client;

  ExportStatement(this.invoices, this.payments, this.client);

  StatementStrings strings = StatementStrings();

  double pageHeight() => (invoices.length + payments.length) * 30 + 800;

  String invoiceTypeByAr(String type) {
    if (type == InvoiceTypes.purchase) return strings.purchase;
    if (type == InvoiceTypes.sales) return strings.sales;
    return strings.returnInvoice;
  }

  String paymentMethodByAr(String method) {
    if (method == PaymentMethods.cash) return strings.cash;
    if (method == PaymentMethods.bankTransfer) return strings.bankTransfer;
    return strings.check;
  }

  String getPaymentFlow(bool isNorm) {
    return (isNorm ^ client.isSupplier)? strings.inbound: strings.outbound;
  }

  pw.Table invoicesTable(int start, int end) {
    return customPdfDataTable(
      headers: [
        strings.invoiceType,
        strings.totalPrice,
        strings.date,
        strings.invoiceNum,
      ],
      data: [
        for (InvoiceModel invoice in invoices.sublist(start, end)) [
          invoiceTypeByAr(invoice.type),
          invoice.priceAfterDiscount.toStringAsFixed(1),
          dateFormatter(invoice.date),
          invoice.invoiceNum
        ]
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      font: ttf
    );
  }

  pw.Table paymentsTable(int start, int end) {
    return customPdfDataTable(
      headers: [
        strings.paymentMethod,
        strings.paymentFlow,
        strings.paidAmount,
        strings.date
      ],
      data: [
        for (PaymentModel payment in payments.sublist(start, end)) [
          paymentMethodByAr(payment.paymentMethod),
          getPaymentFlow(payment.isNorm),
          payment.amount.toStringAsFixed(1),
          dateFormatter(payment.date)
        ]
      ],
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      font: ttf
    );
  }


  summaryTable() {
    bool addRetPay = client.transPayments.totalRetPay > 0.01;

    List<String> keys = [
      strings.purchasesTotal,
      strings.returnsTotal,
      client.isSupplier? strings.inboundTotal: strings.outboundTotal,
      if (addRetPay) client.isSupplier? strings.outboundTotal: strings.inboundTotal
    ];

    List<String> values = [
      Shared.getPrice(client.transPayments.totalNorTrans),
      Shared.getPrice(client.transPayments.totalRetTrans),
      Shared.getPrice(client.transPayments.totalNorPay),
      if (addRetPay) Shared.getPrice(client.transPayments.totalRetPay)
    ];

    return pw.Container(
      child: pw.Table(
        tableWidth: pw.TableWidth.max,
        columnWidths: {
          0: const pw.FlexColumnWidth(4),
          1: const pw.FlexColumnWidth(3),
        },
        children: [
          for (int i = 0; i < keys.length; i++) pw.TableRow(
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
                margin: const pw.EdgeInsets.all(2),
                alignment: pw.Alignment.centerRight,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  border: pw.Border.all(color: PdfColors.grey)
                ),
                child: pw.ConstrainedBox(
                  constraints: const pw.BoxConstraints(minWidth: 40, maxWidth: 200),
                  child: pw.Text(
                    values[i],
                    maxLines: 1,
                    textDirection: pw.TextDirection.rtl,
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 16
                    )
                  )
                )
              ),

              pw.Container(
                padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
                margin: const pw.EdgeInsets.all(1),
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
                  border: pw.Border.all(color: PdfColors.grey)
                ),
                child: pw.Text(
                  keys[i],
                  textDirection: pw.TextDirection.rtl,
                  maxLines: 1,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    font: ttf
                  )
                )
              ),
            ]
          )
        ]
      )
    );
  }

  String amountOwed() {
    TransPaymentsModel payments = client.transPayments;

    double totalPrice = payments.totalNorTrans - payments.totalRetTrans
      - payments.totalNorPay + payments.totalRetPay;

    double absAmount = totalPrice > 0? totalPrice: -totalPrice;
    String price = Shared.getPrice(absAmount);


    ///   supplier     pos      you
    ///     1           1        1
    ///     1           0        0
    ///     0           1        0
    ///     0           0        1
    if (absAmount < 0.01) return strings.noAmountOwed;

    return (client.isSupplier == totalPrice > 0)?
      "${strings.amountOwedToYou}: $price"
      : "${strings.amountOwedToHim}: $price";
  }

  Future<pw.Document> generateInvoice() async {
    await super.getFont();

    String clientTitle = client.isSupplier? strings.supplierName:
    strings.clientName;

    Uint8List? marketplaceLogo = await getMarketplaceLogo();


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
                      strings.statement,
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
                        strings.date
                      ],
                      values: [
                        UserData.mpName!,
                        client.name,
                        dateFormatter(DateTime.now().millisecondsSinceEpoch)
                      ],
                      font: ttf
                    ),
                  ]
                ),

                pw.SizedBox(height: 10),

                subTitle(strings.statementSummary, ttf),

                summaryTable(),

                pw.SizedBox(height: 10),
                pw.Divider(indent: 20, endIndent: 20, color: PdfColors.grey),
                pw.SizedBox(height: 10),

                pw.SizedBox(
                  width: double.infinity,
                  child: pw.Text(
                    amountOwed(),
                    textDirection: pw.TextDirection.rtl,
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      font: ttf
                    )
                  ),
                ),

                if (invoices.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  subTitle(strings.invoices, ttf),
                  invoicesTable(0, invoices.length)
                ],

                if (payments.isNotEmpty) ...[
                  pw.SizedBox(height: 10),
                  pw.Divider(),
                  subTitle(strings.payments, ttf),
                  paymentsTable(0, payments.length)
                ]
              ],
            ),
          );
        },
      ),
    );


    // addInvoices();
    // addPayments();

    return pdf;
  }

  void addInvoices() {
    int pageItems = 20;
    int invoicesLen = invoices.length;

    for (int i = 0; i < invoicesLen; i += pageItems) {
      int end = i + pageItems <= invoicesLen? i + pageItems: invoicesLen;

      if (invoices.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageTheme: pageTheme(700),
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  subTitle(i == 0? strings.invoices: strings.invoicesContinue, ttf),

                  invoicesTable(i, end),
                ]
              );
            }
          )
        );
      }
    }
  }

  void addPayments() {
    int pageItems = 20;
    int paymentsLen = payments.length;

    for (int i = 0; i < paymentsLen; i += pageItems) {
      int end = i + pageItems <= paymentsLen? i + pageItems: paymentsLen;

      if (payments.isNotEmpty) {
        pdf.addPage(
          pw.Page(
            pageTheme: pageTheme(700),
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  subTitle(i == 0? strings.payments: strings.paymentsContinue, ttf),

                  paymentsTable(i, end),
                ]
              );
            }
          )
        );
      }
    }

  }
}


class StatementStrings extends DocumentStrings {
  final String statement = "كشف حساب";
  final String date = "التاريخ";

  final String invoiceType = "نوع الفاتورة";
  final String invoiceNum = "رقم الفاتورة";

  final String statementSummary = "ملخص كشف الحساب";
  final String purchasesTotal = "اجمالي المشتريات";
  final String salesTotal = "اجمالي المبيعات";
  final String returnsTotal = "اجمالي المرتجعات";
  final String inboundTotal = "اجمالي الدفع الوارد لك";
  final String outboundTotal = "اجمالي الدفع الصادر منك";

  final String noAmountOwed = "تم تصفية الحساب";
  final String amountOwedToYou = "المبلغ المتبقي لك";
  final String amountOwedToHim = "المبلغ المتبقي عليك";

  final String sales = "بيع";
  final String purchase = "شراء";
  final String returnInvoice = "مرتجع";

  final String invoices = "الفواتير";
  final String invoicesContinue = "تابع الفواتير";
  final String payments = "عمليات الدفع";
  final String paymentsContinue = "تابع عمليات الدفع";

  final String paymentFlow = "اتجاه الدفع";
  final String paidAmount = "المبلغ المدفوع";
  final String paymentMethod = "طريقة الدفع";

  final String inbound = "وارد";
  final String outbound = "صادر";

  final String cash = "كاش";
  final String bankTransfer = "تحويل بنكي";
  final String check = "شيك";

  final String organizationName = "اسم المؤسسة";
  final String supplierName = "اسم المورد";
  final String clientName = "اسم العميل";
  final String totalPriceForInvoice = "المبلغ الكلي";

  final String totalPrice = "القيمة";
}

