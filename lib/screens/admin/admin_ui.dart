

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zk_note/screens/admin/admin_cubit.dart';
import 'package:zk_note/screens/home_page/home_page_ui.dart';
import 'package:zk_note/shared/user_data.dart';
import 'package:zk_note/shared_widgets/custom_container.dart';
import 'package:zk_note/shared_widgets/loading.dart';
import 'package:zk_note/shared_widgets/screen_background.dart';

import '../../shared/assets.dart';

class Admin extends StatelessWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AdminCubit cubit = AdminCubit();
    cubit.getUsers();

    return BlocProvider<AdminCubit>(
      create: (context) => cubit,
      child: ScreenBackground(
        title: "USERS",
        addBackIcon: false,
        action: IconButton(
          onPressed: cubit.cancel,
          icon: const Icon(Icons.cancel, color: Colors.white)
        ),

        body: BlocBuilder<AdminCubit, int>(
          builder: (context, state) {
            if (cubit.users == null) return const Loading();

            return ListView.builder(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              itemCount: cubit.users!.length,
              itemBuilder: (context, index) => UserCard(
                user: cubit.users![index],
                onTap: () => cubit.onTap(context, index),
              )
            );
          }
        ),
      ),
    );
  }
}


class UserCard extends StatelessWidget {
  final Marketplace user;
  final void Function()? onTap;
  const UserCard({Key? key, required this.user, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CustomContainer(
        shadowColor: Colors.grey[600]!,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),

        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: user.mpLogo == null? Container(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(
                    AssetImages.marketplace,
                    width: 40,
                    height: 40,
                  ),
                ),
              ): CachedNetworkImage(
                imageUrl: user.mpLogo!,
                placeholder: (context, url) {
                  return Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.asset(AssetImages.hourglass),
                  );
                },
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 10),

            Text(
              user.mpName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600
              ),
            )
          ],
        ),
      ),
    );
  }
}
