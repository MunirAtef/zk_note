
import 'package:flutter/material.dart';
import 'package:zk_note/models/invoice_item_model.dart';
import 'package:zk_note/shared/shared_functions.dart';

class InvoiceItemsTable extends StatelessWidget {
  final List<InvoiceItemModel> itemsModel;
  final Color headerColor;
  final List<int> selectedItems;
  final void Function()? onSelect;

  const InvoiceItemsTable({
    Key? key,
    required this.itemsModel,
    required this.headerColor,
    required this.selectedItems,
    this.onSelect
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> headerRow = ["Name", "Count", "Unit price", "Price"];

    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 10),
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
            checkboxHorizontalMargin: 15,
            columnSpacing: 60,

            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white
            ),

            dataTextStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: Colors.black
            ),

            columns: [
              for (String title in headerRow) DataColumn(label: Text(title)),
            ],

            rows: [
              for (int i = 0; i < itemsModel.length; i++) DataRow(
                selected: selectedItems.contains(i),

                color: MaterialStateProperty.all(
                  i % 2 == 0? Colors.grey[300]: Colors.white
                ),

                onSelectChanged: (bool? selected) {
                  selected == true? selectedItems.add(i): selectedItems.remove(i);
                  if (onSelect != null) onSelect!();
                },

                cells: [
                  DataCell(Text(itemsModel[i].name)),
                  DataCell(Text("${itemsModel[i].count} ${itemsModel[i].unit}")),
                  DataCell(Text(Shared.getPrice(itemsModel[i].price))),
                  DataCell(Text(Shared.getPrice(itemsModel[i].price * itemsModel[i].count))),
                ]
              ),
            ],
          ),
        ),
      )
    );
  }
}


