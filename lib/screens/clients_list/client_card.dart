
import 'package:flutter/material.dart';
import 'package:zk_note/models/client_model.dart';
import 'package:zk_note/screens/client_page/client_page_ui.dart';
import 'package:zk_note/screens/clients_list/clients_list_cubit.dart';
import 'package:zk_note/shared/shared_functions.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/client_image.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';
import 'package:zk_note/shared_widgets/custom_snake_bar.dart';

import '../../shared/main_colors.dart';

class ClientCard extends StatelessWidget {
  final ClientModel clientModel;
  static late ClientsListCubit cubit;

  const ClientCard({Key? key, required this.clientModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String? address;
    if (clientModel.governorate != null) {
      address = clientModel.governorate!.name;
      if (clientModel.city != null) address += " / ${clientModel.city!.name}";
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientPage(clientModel: clientModel)
          )
        );
      },
      
      onLongPress: () {
        CustomSnackBar(
          context: context,
          subColor: MainColors.clientsListPage
        ).show(
          Shared.amountOwed(clientModel.transPayments, clientModel.isSupplier)
        );
      },
      
      child: CustomContainer(
        shadowColor: Colors.grey[600]!,
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
        child: Row(
          children: [
            Hero(
              tag: clientModel.id,
              child: ClientSquareImage(
                imageUrl: clientModel.imageUrl,
                width: 64,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8)
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 22,
                    child: Text(
                      clientModel.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF000070)
                      ),
                    ),
                  ),

                  const SizedBox(height: 2),

                  Row(
                    children: [
                      Text(
                        clientModel.isSupplier? "Supplier": "Client",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF880000)
                        ),
                      ),

                      if (address != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          child: Icon(Icons.circle, size: 5),
                        ),

                        SizedBox(
                          height: 18,
                          child: Text(
                            address,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                            ),
                          )
                        ),
                      ],
                    ],
                  ),

                  if (clientModel.categories.isNotEmpty) SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      height: 22,
                      child: Text.rich(
                        TextSpan(
                          text: "",
                          children: [
                            for (int categoryKey in clientModel.categories) ...[
                              const TextSpan(
                                text: "<",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000077)
                                )
                              ),
                              TextSpan(
                                text: UserData.categoriesMap[categoryKey].toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF770000)
                                )
                              ),
                              const TextSpan(
                                text: "> ",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF000077)
                                )
                              ),
                            ]
                          ]
                        )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

