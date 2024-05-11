
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/invoice_model.dart';
import 'package:zk_note/screens/add_transaction/add_transaction_cubit.dart';
import 'package:zk_note/screens/add_transaction/add_transaction_state.dart';
import 'package:zk_note/screens/invoice_details/invoice_details_cubit.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared_widgets/date_picker.dart';
import 'package:zk_note/shared_widgets/invoice_items_table.dart';
import 'package:zk_note/shared/assets.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/client_image.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_drop_down_menu.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';



class AddTransaction extends StatelessWidget {
  final ClientModel clientModel;
  final InvoiceModel? initialInvoice;

  const AddTransaction({
    Key? key,
    required this.clientModel,
    this.initialInvoice
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color subColor = MainColors.addTransactionPage;
    final AddTransactionCubit cubit = AddTransactionCubit.getInstance(context);
    cubit.setInitial(clientModel, initialInvoice);

    return WillPopScope(
      onWillPop: () async {
        cubit.clearPage();
        return true;
      },
      child: ScreenBackground(
        appBarColor: subColor,
        title: "ADD INVOICE",
        action: InvoiceDetailsCubit.copiedInvoice == null? null: IconButton(
          onPressed: cubit.pasteInvoice,
          icon: const Icon(Icons.paste, color: Colors.white)
        ),

        onBackIconPressed: () {
          cubit.clearPage();
          return true;
        },
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /// Client
              Container(
                margin: const EdgeInsets.fromLTRB(30, 20, 30, 15),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all()
                ),
                child: Row(
                  children: [
                    Hero(
                      tag: clientModel.id,
                      child: ClientSquareImage(
                        imageUrl: clientModel.imageUrl,
                        width: 40,
                        margin: const EdgeInsets.only(right: 10),
                        borderRadius: const BorderRadius.all(Radius.circular(5)),
                      ),
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 22,
                          child: Text(
                            clientModel.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        Text(
                          clientModel.isSupplier? "Supplier": "Client",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: MainColors.appColorDark
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) => currentState.updateInvoiceType,

                builder: (context, state) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: OutlinedButton(
                          onPressed: cubit.showAnotherInvoiceType,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: subColor,
                            backgroundColor: Colors.grey[100],
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            side: const BorderSide(width: 2, color: Colors.grey),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10))
                            )
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${cubit.invoiceType} INVOICE"),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_drop_down_circle_sharp, size: 22)
                            ],
                          ),
                        ),
                      ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: cubit.showSwitchInvoice? 40: 0,
                        child: TextButton(
                          onPressed: cubit.switchInvoiceType,
                          style: TextButton.styleFrom(
                            foregroundColor: subColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                          child: Text("${cubit.anotherInvoiceType} INVOICE"),
                        )
                      ),
                    ],
                  );
                }
              ),

              const SizedBox(height: 5),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) =>
                  currentState.updateInvoiceDate,
                builder: (context, state) {
                  return DatePicker(
                    dateTime: cubit.invoiceDate,
                    subColor: subColor,
                    onChange: (newDate) => cubit.onDateChange(newDate),
                  );
                }
              ),

              CustomTextField(
                controller: cubit.invoiceNumController,
                hint: "Invoice number",
                keyboardType: TextInputType.number,
                prefix: const Icon(Icons.onetwothree, size: 24),
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              CustomTextField(
                controller: cubit.commentController,
                hint: "Write a comment...",
                maxLines: 3,
                maxHeight: 200,
                prefix: const Icon(Icons.comment, size: 24),
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              const Divider(thickness: 2),
              const SizedBox(height: 10),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) => currentState.updateAddItemSection,

                builder: (context, state) {
                  bool useUpdate = cubit.itemToBeUpdated != null;

                  return Text(
                    useUpdate? "UPDATE ITEM": "ADD ITEM",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600
                    ),
                  );
                }
              ),

              CustomTextField(
                controller: cubit.itemNameController,
                hint: "Item name",
                prefix: const Padding(
                  padding: EdgeInsets.all(5),
                  child: ImageIcon(AssetImage(AssetImages.productIcon))
                ),
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              /// item count and price
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: cubit.itemCountController,
                      hint: "Item count",
                      keyboardType: TextInputType.number,
                      margin: const EdgeInsets.fromLTRB(30, 10, 10, 10),
                      prefix: const Padding(
                        padding: EdgeInsets.all(8),
                        child: ImageIcon(AssetImage(AssetImages.tallyIcon))
                      ),

                      onChanged: (_) => cubit.updateCurrentTotalPrice(),
                    ),
                  ),

                  Expanded(
                    child: CustomTextField(
                      controller: cubit.unitPriceController,
                      hint: "Unit price",
                      keyboardType: TextInputType.number,
                      margin: const EdgeInsets.fromLTRB(10, 10, 30, 10),
                      prefix: const Icon(Icons.monetization_on),
                      onChanged: (_) => cubit.updateCurrentTotalPrice(),
                    ),
                  ),
                ],
              ),

              /// unit drop down menu and add unit button
              Row(
                children: [
                  Expanded(
                    child: BlocBuilder<AddTransactionCubit, AddTransactionState>(
                      buildWhen: (prevState, currentState) {
                        return currentState.updateItemUnit
                          || currentState.updateAddItemSection;
                      },

                      builder: (context, state) {
                        return CustomDropDownMenu(
                          hintText: "Unit",
                          placeholder: "Unit",
                          subColor: subColor,
                          selectedItem: cubit.selectedUnit,
                          items: UserData.units,
                          margin: const EdgeInsets.fromLTRB(30, 10, 5, 10),
                          onChange: (String? newValue) => cubit.updateUnit(newValue),
                        );
                      }
                    ),
                  ),

                  TextButton(
                    onPressed: () => cubit.addNewUnit(context),
                    style: TextButton.styleFrom(
                      foregroundColor: subColor,
                      textStyle: const TextStyle(fontWeight: FontWeight.w600)
                    ),
                    child: const Text("ADD UNIT"),
                  ),

                  const SizedBox(width: 30),
                ],
              ),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) {
                  return currentState.updateCurrentPrice
                    || currentState.updateAddItemSection;
                },

                builder: (context, state) {
                  if (cubit.currentItemPrice == null) return const SizedBox();

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                    child: Text(
                      "Price: ${Shared.getPrice(cubit.currentItemPrice!)}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  );
                }
              ),


              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) => currentState.updateAddItemSection,

                builder: (context, state) {
                  bool useUpdate = cubit.itemToBeUpdated != null;

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: cubit.addOrUpdateItem,
                        style: TextButton.styleFrom(
                          foregroundColor: subColor,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_box),
                            const SizedBox(width: 5),
                            Text(useUpdate? "UPDATE THE ITEM" :"ADD THE ITEM")
                          ],
                        )
                      ),

                      if (useUpdate) TextButton(
                        onPressed: cubit.onCancelUpdate,
                        style: TextButton.styleFrom(
                          foregroundColor: subColor,
                          textStyle: const TextStyle(fontWeight: FontWeight.w600)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.cancel),
                            SizedBox(width: 5),
                            Text("CANCEL")
                          ],
                        )
                      ),
                    ],
                  );
                }
              ),

              const Divider(thickness: 2),
              const SizedBox(height: 10),

              const Text(
                "INVOICE ITEMS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600
                ),
              ),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) => currentState.updateItemsTable,

                builder: (context, state) {
                  bool showDelete = cubit.selectedTableItems.isNotEmpty;
                  bool showEdit = cubit.selectedTableItems.length == 1;

                  if (cubit.invoiceItems.isEmpty) return const SizedBox();

                  return Column(
                    children: [
                      InvoiceItemsTable(
                        itemsModel: cubit.invoiceItems,
                        headerColor: subColor,
                        selectedItems: cubit.selectedTableItems,
                        onSelect: cubit.onSelectTableItems,
                      ),

                      if (showDelete) Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: cubit.deleteTableRows,
                            style: TextButton.styleFrom(
                              foregroundColor: subColor,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600)
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.delete),
                                SizedBox(width: 5),
                                Text("DELETE")
                              ],
                            )
                          ),

                          if (showEdit) TextButton(
                            onPressed: cubit.updateTableRow,
                            style: TextButton.styleFrom(
                              foregroundColor: subColor,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600)
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.edit),
                                SizedBox(width: 5),
                                Text("EDIT")
                              ],
                            )
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (ps, cs) =>
                  cs.updateInvoicePrice || cs.updateItemsTable,

                builder: (context, state) {
                  String? priceAfterDiscount = cubit.getPriceAfterDiscount();

                  return Column(
                    children: [
                      const SizedBox(height: 5),

                      if (cubit.totalPrice != null) Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "Total price: ${Shared.getPrice(cubit.totalPrice!)}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),

                      const Divider(thickness: 2),

                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "DISCOUNT",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),

                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 30),

                          const Text(
                            "By amount",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),

                          Checkbox(
                            value: cubit.useDiscountAmount,
                            fillColor: MaterialStateProperty.all(subColor),
                            onChanged: cubit.updateDiscountType
                          ),

                          Expanded(
                            child: CustomTextField(
                              controller: cubit.discountController,
                              hint: cubit.useDiscountAmount? "Amount": "Percentage",
                              prefix: const Icon(Icons.discount),
                              keyboardType: TextInputType.number,
                              margin: const EdgeInsets.fromLTRB(0, 10, 30, 10),
                              suffix: cubit.useDiscountAmount?
                                const Icon(Icons.monetization_on)
                                : const Icon(Icons.percent),
                              onChanged: cubit.updatePriceAfterDiscount,
                            ),
                          ),
                        ],
                      ),

                      if (priceAfterDiscount != null) Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          priceAfterDiscount,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                      ),
                    ],
                  );
                }
              ),

              const Divider(thickness: 2),
              const SizedBox(height: 10),

              BlocBuilder<AddTransactionCubit, AddTransactionState>(
                buildWhen: (prevState, currentState) => currentState.updateLoading,

                builder: (context, state) {
                  return CustomButton(
                    text: "ADD INVOICE",
                    color: subColor,
                    leading: const Icon(Icons.add_box, color: Colors.white),
                    isLoading: cubit.isLoading,
                    onPressed: () => cubit.addTransaction(context)
                  );
                }
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

