
import 'package:flutter/material.dart';
import 'package:zk_note/shared/main_colors.dart';

class PhoneListItem extends StatelessWidget {
  final String phoneNumber;
  final void Function()? onDelete;
  const PhoneListItem({Key? key, required this.phoneNumber, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 2),
      padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: const Border(
          bottom: BorderSide(width: 2, color: MainColors.addClientPage)
        )
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(
              phoneNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ),

          InkWell(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Icon(Icons.delete, color: MainColors.addClientPage),
            ),
          ),
        ],
      ),
    );
  }
}



