
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zk_note/screens/admin/admin_ui.dart';
import 'package:zk_note/screens/home_page/home_page_state.dart';
import 'package:zk_note/shared/font_family.dart';
import 'package:zk_note/shared/user_data.dart';

import '../../shared/assets.dart';
import '../../shared/main_colors.dart';
import '../future_dues/future_dues_ui.dart';
import 'home_page_cubit.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomePageCubit cubit = HomePageCubit.getInstance(context);
    const Color subColor =  MainColors.drawer;

    return Drawer(
      child: Container(
        padding: const EdgeInsets.all(20),

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              MainColors.appColorDark,
              subColor
            ]
          )
        ),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),

            /// Marketplace logo
            Center(
              child: Stack(
                children: [
                  BlocBuilder<HomePageCubit, HomePageState>(
                    buildWhen: (ps, cs) => cs.updateMpLogo,
                    builder: (context, state) {
                      return ClipOval(
                        child: UserData.mpLogo == null? CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 60,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Image.asset(
                              AssetImages.marketplace,
                              width: 100,
                            ),
                          ),
                        ): CachedNetworkImage(
                          imageUrl: UserData.mpLogo!,
                          placeholder: (context, url) {
                            return Padding(
                              padding: const EdgeInsets.all(5),
                              child: Image.asset(AssetImages.hourglass),
                            );
                          },
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      );
                    }
                  ),

                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        onPressed: () => cubit.updateMarketplaceLogo(context),
                        icon: const Icon(Icons.add_a_photo, color: subColor, size: 20)
                      ),
                    ),
                  )
                ],
              ),
            ),

            /// Marketplace name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BlocBuilder<HomePageCubit, HomePageState>(
                  buildWhen: (ps, cs) => cs.updateMpName,
                  builder: (context, state) {
                    return Text(
                      UserData.mpName!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white
                      ),
                    );
                  }
                ),

                IconButton(
                  onPressed: () => cubit.updateMarketplaceName(context),
                  icon: const Icon(Icons.edit, color: Colors.white)
                )
              ]
            ),

            const Divider(thickness: 2, height: 2, color: Colors.grey),

            /// Payment notifications
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FutureDues()
                  )
                );
              },
              child: Row(
                children: const [
                  ImageIcon(
                    AssetImage(AssetImages.futureIcon),
                    color: Colors.white
                  ),

                  SizedBox(width: 20),

                  Text(
                    "FUTURE DUES",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              )
            ),

            /// Logout
            TextButton(
              onPressed: () async => cubit.signOut(context),
              child: Row(
                children: const [
                  Icon(Icons.logout, color: Colors.white),

                  SizedBox(width: 20),

                  Text(
                    "LOGOUT",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              )
            ),

            /// Admin
            if (UserData.isAdmin) TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const Admin())
                );
              },
              child: Row(
                children: const [
                  Icon(Icons.admin_panel_settings, color: Colors.white),

                  SizedBox(width: 20),

                  Text(
                    "ADMIN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              )
            ),

            const Spacer(),

            /// About developer section
            const Divider(thickness: 2, color: Colors.grey),

            const Text(
              "ABOUT DEVELOPER",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                fontFamily: FontFamily.handWriting
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  child: Image.asset(
                    AssetImages.munir,
                    width: 100,
                    height: 100
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Munir M. Atef",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white
                      ),
                    ),

                    SizedBox(height: 10),

                    SizedBox(
                      width: 130,
                      child: Text(
                        "Faculty of Computers & Artificial Intelligence",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                        ),
                      ),
                    ),

                    SizedBox(height: 10),

                    SizedBox(
                      width: 130,
                      child: Text(
                        "Flutter & Native Android Developer",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 15),

            const Text(
              "CONTACT ME",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: cubit.contactLinkedin,
                  icon: const ImageIcon(
                    AssetImage(AssetImages.linkedinIcon),
                    color: Colors.white, size: 30
                  )
                ),
                IconButton(
                  onPressed: cubit.contactWhatsapp,
                  icon: const Icon(Icons.whatsapp, color: Colors.white, size: 35)
                ),
                IconButton(
                  onPressed: cubit.contactFacebook,
                  icon: const Icon(Icons.facebook, color: Colors.white, size: 35)
                ),
                IconButton(
                  onPressed: cubit.contactGmail,
                  icon: const Icon(Icons.email_outlined, color: Colors.white, size: 35)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

