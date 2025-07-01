import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/global/widgets/profile_widget.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, required this.uid});

  final String uid;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Contacts"),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              width: 50,
              height: 50,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: profileWidget(),
              ),
            ),
            title: const Text(
              "Contact Name",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text("Hey there! I'm using WhatsApp"),
            // trailing: const Wrap(
            //   children: [
            //     Icon(Icons.call, color: Colors.green, size: 22),
            //     SizedBox(width: 15),
            //     Icon(Icons.video_call, color: Colors.blue, size: 25),
            //   ],
            // ),
          );
        },
      ),
    );
  }
}
