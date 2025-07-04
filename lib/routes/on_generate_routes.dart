import 'package:flutter/material.dart';
import 'package:whatsapp_clone/features/app/const/page_const.dart';
import 'package:whatsapp_clone/features/app/home/contacts_page.dart';
import 'package:whatsapp_clone/features/app/settings/settings_page.dart';
import 'package:whatsapp_clone/features/call/presentation/pages/call_contact_page.dart';
import 'package:whatsapp_clone/features/chat/presentation/pages/single_chat_page.dart';
import 'package:whatsapp_clone/features/status/presentation/pages/my_status_page.dart';
import 'package:whatsapp_clone/features/user/domain/entities/user_entity.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/edit_profile_page.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/edit_status_page.dart';

class OnGenerateRoutes {
  static Route<dynamic>? route(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name;

    switch (name) {
      case PageConst.contactUsersPage:
        {
          if (args is String) {
            return materialPageBuilder(ContactsPage(uid: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.settingsPage:
        {
          if (args is String) {
            return materialPageBuilder(SettingsPage(uid: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.editProfilePage:
        {
          if (args is UserEntity) {
            return materialPageBuilder(EditProfilePage(currentUser: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.editStatusPage:
        {
          if (args is UserEntity) {
            return materialPageBuilder(EditStatusPage(currentUser: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.callContactPage:
        {
          if (args is String) {
            return materialPageBuilder(CallContactPage(uid: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.myStatusPage:
        {
          if (args is String) {
            return materialPageBuilder(MyStatusPage(status: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.callPage:
        {
          if (args is String) {
            // return materialPageBuilder(CallPage(uid: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      case PageConst.singleChatPage:
        {
          if (args is String) {
            return materialPageBuilder(SingleChatPage(uid: args));
          }
          return materialPageBuilder(const ErrorPage());
        }
      default:
        return null;
    }
  }
}

dynamic materialPageBuilder(Widget child) {
  return MaterialPageRoute(
    builder: (context) => child,
  );
}

class ErrorPage extends StatelessWidget {
  const ErrorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(
          "Error: Page not found",
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.red,
              ),
        ),
      ),
    );
  }
}
