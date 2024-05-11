
import 'package:flutter/material.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/models/payment_model.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared_widgets/client_image.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';

import '../../shared/main_colors.dart';

class NotificationCard extends StatelessWidget {
  final PaymentModel payment;
  final ClientModel client;
  final String? flow;


  const NotificationCard({
    Key? key,
    required this.payment,
    required this.client,
    this.flow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOutbound = !(client.isSupplier ^ payment.isNorm);

    if (isOutbound && flow == "Inbound" || !isOutbound && flow == "Outbound") {
      return const SizedBox();
    }

    return CustomContainer(
      padding: const EdgeInsets.fromLTRB(10, 15, 10, 10),
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      shadowColor: Colors.grey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Amount: ${Shared.getPrice(payment.amount)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                ),
              ),

              Text(
                "Due Date: ${Shared.getDate(payment.dueDate ?? 0)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600
                ),
              ),
            ],
          ),

          const Divider(thickness: 1),

          Row(
            children: [
              ClientSquareImage(
                imageUrl: client.imageUrl,
                width: 25,
                borderRadius: const BorderRadius.all(Radius.circular(3)),
              ),

              const SizedBox(width: 5),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                    child: Text(
                      client.name,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),

                  Text(
                    client.isSupplier? "Supplier": "Client",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: MainColors.appColorDark
                    ),
                  ),
                ],
              ),

              const Spacer(),

              Text(
                isOutbound? "Outbound": "Inbound",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isOutbound? Colors.red: Colors.green
                )
              ),
            ],
          )
        ],
      ),
    );
  }
}

