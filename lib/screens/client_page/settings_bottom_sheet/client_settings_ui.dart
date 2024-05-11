
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/client_page/client_page_cubit.dart';
import 'package:zk_note/screens/client_page/settings_bottom_sheet/settings_button.dart';
import 'package:zk_note/shared/main_colors.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';


class ClientSettings extends StatelessWidget {
  const ClientSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ClientPageCubit cubit = BlocProvider.of<ClientPageCubit>(context);
    const Color subColor = MainColors.clientSettingsPage;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30)
      ),
      child: ScreenBackground(
        title: "SETTINGS",
        appBarColor: subColor,
        addBackIcon: false,
        body: Column(
          children: [
            const SizedBox(height: 20),

            SettingsButton(
              onPressed: () async => cubit.updateImage(),
              text: "UPDATE CLIENT IMAGE",
              leading: const Icon(Icons.add_a_photo),
            ),

            SettingsButton(
              onPressed: () async => cubit.updateName(),
              text: "UPDATE CLIENT NAME",
              leading: const Icon(Icons.person),
            ),

            SettingsButton(
              onPressed: () async => cubit.updateAddress(),
              text: "UPDATE ADDRESS",
              leading: const Icon(Icons.location_city),
            ),

            const Divider(thickness: 2),

            SettingsButton(
              onPressed: () async => cubit.deleteClient(),
              text: "DELETE",
              leading: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}

