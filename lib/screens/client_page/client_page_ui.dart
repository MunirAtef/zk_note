
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/screens/client_page/client_page_cubit.dart';
import 'package:zk_note/screens/client_page/client_page_state.dart';
import 'package:zk_note/screens/client_page/invoices_table.dart';
import 'package:zk_note/screens/client_page/list_item_with_actions.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/client_image.dart';
import 'package:zk_note/shared_widgets/map_table.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';
import 'package:zk_note/shared_widgets/text_button_with_icon.dart';


class ClientPage extends StatelessWidget {
  final ClientModel clientModel;
  const ClientPage({Key? key, required this.clientModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ClientPageCubit cubit = BlocProvider.of<ClientPageCubit>(context);
    cubit.setInitial(context, clientModel);
    const Color subColor = Colors.green;

    return ScreenBackground(
      appBarColor: subColor,
      title: "CLIENT PAGE",
      action: IconButton(
        onPressed: () => cubit.openBottomSheet(),
        icon: const Icon(Icons.settings, color: Colors.white)
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Main data image, name, type, address
            BlocBuilder<ClientPageCubit, ClientPageState>(
              buildWhen: (prevState, currentState) => currentState.updateMainData,
              builder: (context, state) {
                final String? address = cubit.getAddress();

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Hero(
                      tag: clientModel.id,
                      child: ClientSquareImage(
                        imageUrl: clientModel.imageUrl,
                        width: 110,
                        margin: const EdgeInsets.fromLTRB(15, 5, 0, 15),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20)
                        ),
                      ),
                    ),

                    Expanded(
                      child: Container(
                        height: 110,
                        margin: const EdgeInsets.only(right: 15, top: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20)
                          ),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              MainColors.appColorDark,
                              MainColors.clientPage
                            ]
                          )
                        ),

                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 28,
                              child: Text(
                                clientModel.name,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  overflow: TextOverflow.ellipsis
                                ),
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              clientModel.isSupplier? "Supplier": "Client",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(200, 200, 200, 1)
                              ),
                            ),

                            const SizedBox(height: 5),

                            if (address != null) Text(
                              address,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color.fromRGBO(200, 200, 200, 1),
                                overflow: TextOverflow.ellipsis
                              )
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
            ),

            const Divider(thickness: 2, height: 2),
            const SizedBox(height: 15),

            /// Summary report
            const SizedBox(
              width: double.infinity,
              height: 30,
              child: Text(
                "SUMMARY REPORT",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MainColors.appColorDark
                )
              ),
            ),

            /// Totals and amount owed
            BlocBuilder<ClientPageCubit, ClientPageState>(
              buildWhen: (ps, cs) => cs.updateInvoices || cs.updatePayments,

              builder: (context, state) {
                return Column(
                  children: [
                    MapTable(
                      data: cubit.totalAmountsData(),
                      darkColor: subColor,
                      lightColor: subColor.withAlpha(220),
                      keyColumnWidth: 160
                    ),

                    /// Amount owned
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(15),
                      margin: const EdgeInsets.fromLTRB(15, 10, 15, 5),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        gradient: LinearGradient(
                          colors: [
                            MainColors.appColorDark,
                            subColor
                          ]
                        )
                      ),
                      child: Text(
                        cubit.amountOwed(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white
                        )
                      )
                    )
                  ]
                );
              }
            ),

            Center(
              child: TextButtonWithIcon(
                text: "SHARE STATEMENT",
                subColor: subColor,
                icon: const Icon(Icons.share),
                onPressed: () => cubit.statementPreview(context),
              ),
            ),


            /// Phone numbers section
            PageSection(
              title: "PHONE NUMBERS",
              buttonText: "ADD NUMBER",
              iconData: Icons.add_call,
              onPressed: cubit.addPhoneNumber,
              child: BlocBuilder<ClientPageCubit, ClientPageState>(
                buildWhen: (prevState, currentState) => currentState.updatePhonesList,
                builder: (context, state) {
                  return Column(
                    children: [
                      for (String phone in clientModel.phones) ListItemWithActions(
                        title: phone,
                        actions: [
                          IconButton(
                            onPressed: () => cubit.chatWhatsapp(phone),
                            icon: const Icon(Icons.whatsapp, color: Colors.white)
                          ),
                          IconButton(
                            onPressed: () => cubit.makeCall(phone),
                            icon: const Icon(Icons.contact_phone, color: Colors.white)
                          ),
                          IconButton(
                            onPressed: () => cubit.deletePhoneNumber(phone),
                            icon: const Icon(Icons.delete, color: Colors.white)
                          )
                        ],
                      ),

                      if (clientModel.phones.isNotEmpty) const SizedBox(height: 10),
                    ],
                  );
                }
              ),
            ),

            /// Categories section
            PageSection(
              title: "CATEGORIES",
              buttonText: "ADD CATEGORIES",
              iconData: Icons.category,
              onPressed: cubit.addCategories,
              child: BlocBuilder<ClientPageCubit, ClientPageState>(
                buildWhen: (prevState, currentState) => currentState.updateCategoriesList,
                builder: (context, state) => Column(
                  children: [
                    for (int categoryId in clientModel.categories) ListItemWithActions(
                      title: UserData.categoriesMap[categoryId].toString(),
                      actions: [
                        IconButton(
                          onPressed: () => cubit.deleteCategory(categoryId),
                          icon: const Icon(Icons.delete, color: Colors.white)
                        )
                      ],
                    ),

                    if (clientModel.categories.isNotEmpty) const SizedBox(height: 10),
                  ],
                )
              ),
            ),

            /// Invoices section
            PageSection(
              title: "INVOICES",
              buttonText: "ADD INVOICE",
              iconData: Icons.receipt_long,
              onPressed: cubit.addTransaction,
              child: BlocBuilder<ClientPageCubit, ClientPageState>(
                buildWhen: (ps, cs) => cs.updateInvoices,
                builder: (context, state) {
                  if (cubit.clientInvoices == null) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
                      child: LinearProgressIndicator(
                        color: subColor,
                        backgroundColor: Colors.white,
                      ),
                    );
                  }

                  if (cubit.clientInvoices!.isEmpty) return const SizedBox();

                  return InvoicesTable(
                    invoices: cubit.clientInvoices ?? [],
                    headerColor: subColor,
                    onSelect: cubit.openInvoiceDetails,
                  );
                }
              ),
            ),

            /// Payments section
            PageSection(
              title: "PAYMENTS",
              buttonText: "ADD PAYMENT",
              iconData: Icons.payment,
              onPressed: cubit.addPayment,

              child: BlocBuilder<ClientPageCubit, ClientPageState>(
                buildWhen: (ps, cs) => cs.updatePayments,
                builder: (context, state) {
                  if (cubit.payments == null) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 20),
                      child: LinearProgressIndicator(
                        color: subColor,
                        backgroundColor: Colors.white,
                      ),
                    );
                  }

                  if (cubit.payments!.isEmpty) return const SizedBox();

                  return PaymentsTable(
                    payments: cubit.payments ?? [],
                    headerColor: subColor,
                    isSupplier: clientModel.isSupplier,
                    onSelect: cubit.onSelectPayment,
                  );
                }
              ),
            ),

            const SizedBox(height: 20)
          ],
        ),
      ),
    );
  }
}


class PageSection extends StatelessWidget {
  final String title;
  final String buttonText;
  final IconData iconData;
  final void Function()? onPressed;
  final Widget? child;

  const PageSection({
    Key? key,
    required this.title,
    required this.buttonText,
    required this.iconData,
    required this.onPressed,
    this.child
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool expanded = true;
    Widget? switcherWidget = child;
    void Function(void Function())? setChildState;

    return Column(
      children: [
        const Divider(thickness: 2, height: 2),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: MainColors.appColorDark
                )
              ),

              const Spacer(),

              TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: MainColors.clientPage,
                  textStyle: const TextStyle(fontWeight: FontWeight.w600)
                ),
                child: Row(
                  children: [
                    Icon(iconData),
                    const SizedBox(width: 5),
                    Text(buttonText)
                  ],
                )
              ),

              StatefulBuilder(
                builder: (context, setInternalState) {
                  return IconButton(
                    onPressed: () {
                      expanded = !expanded;
                      switcherWidget = expanded? child: const SizedBox(key: Key("0"));
                      setInternalState(() {});
                      if (setChildState != null) setChildState!(() {});
                    },
                    icon: AnimatedRotation(
                      turns: expanded? -0.25: 0.25,
                      duration: const Duration(milliseconds: 500),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        size: 20,
                        color: MainColors.appColorDark
                      )
                    )
                  );
                }
              )
            ],
          ),
        ),

        StatefulBuilder(
          builder: (context, setInternalState) {
            setChildState = setInternalState;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, animation) =>
                ScaleTransition(scale: animation, child: child),
              child: switcherWidget,
            );
          }
        )
      ],
    );
  }
}

