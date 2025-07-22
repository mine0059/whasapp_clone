import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

class ShowDateCard extends StatelessWidget {
  const ShowDateCard({Key? key, required this.date}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: yellowCardBgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          DateFormat('d MMMM y').format(date),
          style: const TextStyle(color: greyColor),
        ),
      ),
    );
  }
}
