import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return _bodyWidget();
  }

  _bodyWidget() {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      width: 55,
                      height: 55,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: profileWidget(),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 8,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                              color: tabColor,
                              borderRadius: BorderRadius.circular(15),
                              border:
                                  Border.all(width: 2, color: backgroundColor)),
                          child: const Icon(
                            Icons.add,
                            size: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My status",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      GestureDetector(
                        onTap: () {},
                        child: const Text(
                          "Tap to add status update",
                          style: TextStyle(fontSize: 14, color: greyColor),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, PageConst.myStatusPage,
                        arguments: '');
                  },
                  child: Icon(
                    Icons.more_horiz,
                    color: greyColor.withOpacity(.5),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: Text(
                "Recent updates",
                style: TextStyle(
                    fontSize: 15,
                    color: greyColor,
                    fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 10),
            ListView.builder(
                itemCount: 10,
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: SizedBox(
                      width: 55,
                      height: 55,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: profileWidget(),
                      ),
                    ),
                    title: const Text(
                      "User Name",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    subtitle: const Text(
                      "Today, 10:30 AM",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
