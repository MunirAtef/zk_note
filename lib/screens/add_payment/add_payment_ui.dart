
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/screens/add_payment/add_payment_cubit.dart';
import 'package:zk_note/screens/add_payment/add_payment_state.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/client_image.dart';
import 'package:zk_note/shared_widgets/custom_button.dart';
import 'package:zk_note/shared_widgets/custom_drop_down_menu.dart';
import 'package:zk_note/shared_widgets/custom_text_field.dart';
import 'package:zk_note/shared_widgets/date_picker.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';

class AddPayment extends StatelessWidget {
  final ClientModel clientModel;

  const AddPayment({
    Key? key,
    required this.clientModel
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color subColor = MainColors.paymentsPage;
    final AddPaymentCubit cubit = AddPaymentCubit.getInstance(context);
    cubit.setInitial(clientModel.isSupplier);

    return WillPopScope(
      onWillPop: () async => cubit.clearPage(),
      child: ScreenBackground(
        title: "ADD PAYMENT",
        appBarColor: subColor,
        onBackIconPressed: () => cubit.clearPage(),
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

              BlocBuilder<AddPaymentCubit, AddPaymentState>(
                buildWhen: (ps, cs) => cs.updateFlowType,

                builder: (context, state) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: OutlinedButton(
                          onPressed: cubit.expandOrCollapseWhoPaid,
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
                              Text(cubit.currentFlow),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_drop_down_circle_sharp, size: 22)
                            ],
                          ),
                        ),
                      ),

                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: cubit.showFlowType? 40: 0,
                        child: TextButton(
                          onPressed: cubit.changeFlowType,
                          style: TextButton.styleFrom(
                            foregroundColor: subColor,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16
                            ),
                          ),
                          child: Text(cubit.anotherFlow),
                        )
                      ),
                    ],
                  );
                }
              ),

              const SizedBox(height: 5),

              BlocBuilder<AddPaymentCubit, AddPaymentState>(
                buildWhen: (ps, cs) => cs.updateDate,
                builder: (context, state) => DatePicker(
                  dateTime: cubit.paymentDate,
                  subColor: subColor,
                  onChange: cubit.onDateChange,
                )
              ),

              /// paid amount
              CustomTextField(
                controller: cubit.paidAmountController,
                hint: "Paid amount",
                prefix: const Icon(Icons.money),
                keyboardType: TextInputType.number,
                margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),

              /// payment
              BlocBuilder<AddPaymentCubit, AddPaymentState>(
                buildWhen: (ps, cs) => cs.updatePaymentMethod,
                builder: (context, state) => Column(
                  children: [
                    CustomDropDownMenu(
                      hintText: "Payment",
                      placeholder: "Payment",
                      items: cubit.paymentMethods,
                      selectedItem: cubit.selectedPaymentMethod,
                      subColor: subColor,
                      margin: const EdgeInsets.fromLTRB(30, 10, 30, 0),
                      onChange: cubit.onPaymentMethodChanged,
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: cubit.isPaymentByCheck()? 45: 0,
                      child: DatePicker(
                        dateTime: cubit.dueDateForCheck,
                        dateTitle: "Due date",
                        margin: const EdgeInsets.fromLTRB(30, 2, 30, 0),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        subColor: MainColors.appColorDark,
                        size: 15,
                        onChange: cubit.onCheckDueDateChange,
                      ),
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      height: cubit.addNotifier()? 45: 0,
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (cubit.notifyMe) IconButton(
                            onPressed: () => cubit.changeNotifyAfter(false),
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: MainColors.appColorDark,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: const Icon(Icons.exposure_minus_1, color: Colors.white)
                            )
                          ),

                          if (cubit.addNotifier()) TextButton(
                            onPressed: cubit.changeNotifyMe,
                            style: TextButton.styleFrom(
                              foregroundColor: subColor,
                              textStyle: const TextStyle(fontWeight: FontWeight.w600),
                              padding: const EdgeInsets.symmetric(horizontal: 3)
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cubit.notifyMe?
                                    Icons.notifications
                                    : Icons.notifications_off
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  cubit.notifyMe?
                                    "NOTIFY ME BEFORE ${cubit.notifyBefore} DAYS"
                                    : "NOTIFY OFF"
                                )
                              ],
                            )
                          ),

                          if (cubit.notifyMe) IconButton(
                            onPressed: () => cubit.changeNotifyAfter(true),
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: MainColors.appColorDark,
                                borderRadius: BorderRadius.all(Radius.circular(5))
                              ),
                              child: const Icon(Icons.plus_one, color: Colors.white)
                            )
                          ),
                        ],
                      )
                    )
                  ],
                )
              ),

              const SizedBox(height: 10),
              const Divider(thickness: 2),

              BlocBuilder<AddPaymentCubit, AddPaymentState>(
                buildWhen: (ps, cs) => cs.updateLoading,
                builder: (context, state) => CustomButton(
                  onPressed: () async => await cubit.addPayment(context, clientModel),
                  color: subColor,
                  text: "ADD PAYMENT",
                  isLoading: cubit.isLoading,
                  leading: const Icon(Icons.payment, color: Colors.white)
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}


