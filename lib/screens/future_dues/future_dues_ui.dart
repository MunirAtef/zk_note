
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/screens/future_dues/future_dues_cubit.dart';
import 'package:zk_note/screens/future_dues/future_dues_state.dart';
import 'package:zk_note/shared_widgets/custom_drop_down_menu.dart';
import 'package:zk_note/shared_widgets/loading.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';

import '../../shared/main_colors.dart';
import 'future_due_card.dart';

class FutureDues extends StatelessWidget {
  const FutureDues({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FutureDuesCubit cubit = FutureDuesCubit.getInstance(context);
    cubit.setInitial();
    const Color subColor = MainColors.futureDuesPage;

    return ScreenBackground(
      title: "FUTURE DUES",
      appBarColor: subColor,
      action: IconButton(
        onPressed: () async {},
        icon: const Icon(Icons.notifications, color: Colors.white)
      ),
      body: BlocBuilder<FutureDuesCubit, FutureDuesState>(
        builder: (context, state) {
          if (cubit.notifications == null) return const Loading(subColor: subColor);


          return Column(
            children: [
              CustomDropDownMenu(
                hintText: "Payment Flow",
                placeholder: "All",
                subColor: subColor,
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                widthForHint: 120,
                selectedItem: cubit.selectedFlow,
                items: cubit.flows,
                onChange: cubit.onFlowChange,
              ),

              Expanded(
                child: ListView.builder(
                  itemCount: cubit.notifications!.length,
                  padding: EdgeInsets.zero,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    PaymentModel payment = cubit.notifications![index];
                    ClientModel client = cubit.getUserById(context, payment.clientId);

                    return NotificationCard(
                      payment: payment,
                      client: client,
                      flow: cubit.selectedFlow
                    );
                  }
                ),
              )
            ],
          );
        }
      ),
    );
  }
}

