
import 'package:flutter/material.dart';

import '../../models/invoice_model.dart';
import '../../models/payment_model.dart';
import '../../shared/invoice_data.dart';
import '../../shared/shared_functions.dart';


class InvoicesTable extends StatelessWidget {
  final List<InvoiceModel> invoices;
  final Color headerColor;
  final void Function(int index) onSelect;

  const InvoicesTable({
    Key? key,
    required this.invoices,
    required this.headerColor,
    required this.onSelect
  }) : super(key: key);



  DataCell _dataCell(String data, int index) => DataCell(
    Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: invoices[index].type == InvoiceTypes.returned? Colors.red: Colors.black
      )
    )
  );


  @override
  Widget build(BuildContext context) {
    List<String> headerRow = ["Inv. num", "Date", "Type", "Original price", "Price after discount"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 1, 15, 15),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,

        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: DataTable(
            border: TableBorder.all(
              borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            headingRowHeight: 50,
            dataRowHeight: 40,
            headingRowColor: MaterialStateProperty.all(headerColor),
            showCheckboxColumn: false,
            columnSpacing: 60,

            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white
            ),

            columns: [
              for (String title in headerRow) DataColumn(label: Text(title)),
            ],

            rows: [
              for (int i = 0; i < invoices.length; i++) DataRow(
                color: MaterialStateProperty.all(
                  i % 2 == 0? Colors.grey[300]: Colors.white
                ),

                onSelectChanged: (bool? selected) => onSelect(i),

                /// ["Inv. number", "Date", "Type", "Price"]
                cells: [
                  _dataCell(invoices[i].invoiceNum, i),
                  _dataCell(Shared.getDate(invoices[i].date), i),
                  _dataCell(invoices[i].type, i),
                  _dataCell(Shared.getPrice(invoices[i].totalPrice), i),
                  _dataCell(Shared.getPrice(invoices[i].priceAfterDiscount), i)
                ]
              ),
            ],
          ),
        ),
      )
    );
  }
}



class PaymentsTable extends StatelessWidget {
  final List<PaymentModel> payments;
  final Color headerColor;
  final bool isSupplier;
  final void Function(int index) onSelect;

  const PaymentsTable({
    Key? key,
    required this.payments,
    required this.headerColor,
    required this.isSupplier,
    required this.onSelect
  }) : super(key: key);



  DataCell _dataCell(String data, int index) => DataCell(
    Text(data,
      style: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 16,
        color: payments[index].isNorm? Colors.black: Colors.red
      )
    )
  );


  String _flowType(bool isNorm) => isSupplier == isNorm? "Outbound": "Inbound";

  String _dueDate(int? dueDate, String paymentMethod) {
    if (paymentMethod == PaymentMethods.check && dueDate != null) {
      return Shared.getDate(dueDate);
    }
    return "No due date";
  }


  @override
  Widget build(BuildContext context) {
    List<String> headerRow = [
      "Date",
      "Flow",
      "Amount",
      "Payment type",
      "Due date"
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 1, 15, 15),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,

        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          child: DataTable(
            border: TableBorder.all(
              borderRadius: const BorderRadius.all(Radius.circular(10))
            ),
            headingRowHeight: 50,
            dataRowHeight: 40,
            headingRowColor: MaterialStateProperty.all(headerColor),
            showCheckboxColumn: false,
            columnSpacing: 60,

            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white
            ),

            columns: [
              for (String title in headerRow) DataColumn(label: Text(title)),
            ],

            rows: [
              for (int i = 0; i < payments.length; i++) DataRow(
                color: MaterialStateProperty.all(
                  i % 2 == 0? Colors.grey[300]: Colors.white
                ),

                onSelectChanged: (bool? selected) => onSelect(i),

                /// ["Date", "Who paid", "Amount", "Payment type", "Due date"]
                cells: [
                  _dataCell(Shared.getDate(payments[i].date), i),
                  _dataCell(_flowType(payments[i].isNorm), i),
                  _dataCell(Shared.getPrice(payments[i].amount), i),
                  _dataCell(payments[i].paymentMethod, i),
                  _dataCell(_dueDate(payments[i].dueDate, payments[i].paymentMethod), i)
                ]
              ),
            ],
          ),
        ),
      )
    );
  }
}

