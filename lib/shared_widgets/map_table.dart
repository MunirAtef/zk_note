
import 'package:flutter/material.dart';

class MapTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final double keyColumnWidth;
  final Color? darkColor;
  final Color? lightColor;
  final BorderRadiusGeometry? borderRadius;

  const MapTable({
    Key? key,
    required this.data,
    this.keyColumnWidth = 130,
    this.darkColor,
    this.lightColor,
    this.borderRadius
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> keys = data.keys.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(10))
      ),
      child: Column(
        children: [
          for (int i = 0; i < keys.length; i++) Row(
            children: [
              Container(
                alignment: Alignment.center,
                color: i % 2 == 0? darkColor: lightColor,
                width: keyColumnWidth,
                height: 40,
                child: Text(
                  keys[i],
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),

              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  color: i % 2 == 0? Colors.grey[400]: Colors.grey[200],
                  padding: const EdgeInsets.symmetric(horizontal: 15),

                  height: 40,
                  child: Text(
                    data[keys[i]].toString(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
