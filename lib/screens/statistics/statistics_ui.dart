
import 'package:flutter/material.dart';
import 'package:zk_note/screens/statistics/statistics_cubit.dart';
import 'package:zk_note/shared_widgets/map_table.dart';

import '../../shared/main_colors.dart';
import '../../shared_widgets/screen_background.dart';

class Statistics extends StatelessWidget {
  const Statistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const subColor = MainColors.statisticsPage;
    StatisticsCubit cubit = StatisticsCubit.getInstance(context);
    cubit.calcTotalAmounts(context);

    return ScreenBackground(
      appBarColor: subColor,
      title: "STATISTICS",
      addBackIcon: false,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
              width: double.infinity,

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [MainColors.appColorDark, subColor]
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
                )
              ),
              child: const Text(
                "TOTAL INVOICES",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),

            MapTable(
              data: cubit.invoicesData(),
              keyColumnWidth: 160,
              darkColor: subColor,
              lightColor: subColor.withAlpha(200),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              ),
            ),

            const SizedBox(height: 5),
            const Divider(thickness: 2),

            Container(
              margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
              padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
              width: double.infinity,

              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [MainColors.appColorDark, subColor]
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10)
                )
              ),
              child: const Text(
                "TOTAL PAYMENTS",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white
                ),
              ),
            ),

            MapTable(
              data: cubit.paymentsData(),
              keyColumnWidth: 160,
              darkColor: subColor,
              lightColor: subColor.withAlpha(200),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)
              ),
            ),

            const SizedBox(height: 5),
            const Divider(thickness: 2),

            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
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
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

