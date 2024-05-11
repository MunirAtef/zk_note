
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';


Table customPdfDataTable({
  Context? context,
  required List<List<String>> data,
  required List<String> headers,
  Map<int, TableColumnWidth>? columnWidths,
  Font? font
}) {
  final rows = <TableRow>[];
  final tableRow = <Widget>[];

  for (String cell in headers) {
    tableRow.add(
      Container(
        alignment: Alignment.center,
        color: PdfColors.grey900,
        height: 25,
        child: Text(
          cell,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: PdfColors.white,
            font: font
          ),
        ),
      ),
    );
  }

  rows.add(TableRow(children: tableRow));


  for (int i = 0; i < data.length; i++) {
    List<String> dataRow = data[i];

    final tableRow = <Widget>[];
    final isOdd = i % 2 != 0;

    for (String cell in dataRow) {
      tableRow.add(
        Container(
          alignment: Alignment.centerRight,
          height: 30,
          color: isOdd? PdfColors.grey200: PdfColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            cell.toString(),
            maxLines: 1,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              font: font
            )
          ),
        ),
      );
    }

    rows.add(TableRow(children: tableRow));
  }
  return Table(
    border: TableBorder.all(),
    children: rows,
    columnWidths: columnWidths,
    defaultVerticalAlignment: TableCellVerticalAlignment.full,
  );
}



Container pdfMapTable({
  required List<String> keys,
  required List<String> values,
  Font? font
}) {
  assert (keys.length == values.length);

  return Container(
    child: Table(
      tableWidth: TableWidth.min,
      children: [
        for (int i = 0; i < keys.length; i++) TableRow(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.all(1),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: PdfColors.white,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                border: Border.all(color: PdfColors.grey)
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 40, maxWidth: 200),
                child: Text(
                  values[i],
                  maxLines: 1,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    font: font,
                    fontSize: 10
                  )
                )
              )
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              margin: const EdgeInsets.all(1),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: PdfColors.grey300,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
                border: Border.all(color: PdfColors.grey)
              ),
              child: Text(
                keys[i],
                textDirection: TextDirection.rtl,
                maxLines: 1,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                  font: font
                )
              )
            ),
          ]
        )
      ]
    )
  );
}


Padding subTitle(String subTitle, Font font) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Center(
      child: Text(
        subTitle,
        style: TextStyle(
          font: font,
          fontSize: 18
        )
      )
    )
  );
}