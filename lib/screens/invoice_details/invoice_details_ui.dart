
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/invoice_model.dart';
import 'package:zk_note/screens/invoice_details/invoice_details_cubit.dart';
import 'package:zk_note/screens/invoice_details/invoice_details_state.dart';
import 'package:zk_note/shared_widgets/invoice_items_table.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/map_table.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';

class InvoiceDetails extends StatelessWidget {
  final ClientModel clientModel;
  final InvoiceModel invoiceModel;

  const InvoiceDetails({
    Key? key,
    required this.clientModel,
    required this.invoiceModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const subColor = MainColors.invoiceDetailsPage;
    InvoiceDetailsCubit cubit = InvoiceDetailsCubit.getInstance(context);
    cubit.setInitial(clientModel, invoiceModel);

    return ScreenBackground(
      title: "INVOICE DETAILS",
      appBarColor: subColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MapTable(
              data: cubit.getMetaData(),
              keyColumnWidth: 180,
              darkColor: subColor,
              lightColor: subColor.withAlpha(180),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(20),
                topLeft: Radius.circular(20),
                bottomRight: Radius.circular(10),
                bottomLeft: Radius.circular(10)
              )
            ),

            BlocBuilder<InvoiceDetailsCubit, InvoiceDetailsState>(
              buildWhen: (prevState, currentState) => currentState.updateTable,
              builder: (context, state) {
                if (cubit.isLoading) {
                  return const Padding(
                    padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                    child: LinearProgressIndicator(
                      color: subColor,
                      backgroundColor: Colors.white
                    ),
                  );
                }

                return InvoiceItemsTable(
                  itemsModel: invoiceModel.invoiceItems ?? [],
                  headerColor: subColor,
                  selectedItems: cubit.selectedTableItems,
                  onSelect: cubit.updateItemsTable,
                );
              }
            ),

            BlocBuilder<InvoiceDetailsCubit, InvoiceDetailsState>(
              buildWhen: (prevState, currentState) => currentState.updateComment,
              builder: (context, state) {
                if (cubit.isLoading) return const SizedBox();
                return CommentSection(comment: invoiceModel.comment);
              }
            ),

            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => cubit.deleteInvoice(context),
                  style: TextButton.styleFrom(
                    foregroundColor: subColor,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    )
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.delete, size: 28),
                      SizedBox(width: 5),
                      Text("DELETE INVOICE"),
                    ],
                  )
                ),

                TextButton(
                  onPressed: () => cubit.copyInvoice(context),
                  style: TextButton.styleFrom(
                    foregroundColor: subColor,
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    )
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.copy, size: 28),
                      SizedBox(width: 5),
                      Text("COPY INVOICE"),
                    ],
                  )
                ),
              ]
            ),

            Center(
              child: TextButton(
                onPressed: () => cubit.pdfPreview(context),
                style: TextButton.styleFrom(
                  foregroundColor: subColor,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16
                  )
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.picture_as_pdf, size: 28),
                    SizedBox(width: 5),
                    Text("OPEN PDF"),
                  ],
                )
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


class CommentSection extends StatelessWidget {
  final String? comment;

  const CommentSection({
    Key? key,
    required this.comment
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    InvoiceDetailsCubit cubit = InvoiceDetailsCubit.getInstance(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MainColors.appColorDark,
            MainColors.invoiceDetailsPage,
          ]
        ),
        borderRadius: BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        children: [
          const Text(
            "Comment",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child:Text(
              comment ?? "NO COMMENT",
              textAlign: TextAlign.start,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: comment != null? Colors.white: Colors.grey
              ),
            )
          ),

          const SizedBox(height: 10),
          const Divider(thickness: 2, height: 2, color: Colors.white),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => cubit.editComment(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white
                ),
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    SizedBox(width: 5),
                    Text("EDIT"),
                  ],
                )
              ),

              if (comment != null) TextButton(
                onPressed: () => cubit.deleteComment(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white
                ),
                child: Row(
                  children: const [
                    Icon(Icons.delete),
                    SizedBox(width: 5),
                    Text("DELETE"),
                  ],
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}


