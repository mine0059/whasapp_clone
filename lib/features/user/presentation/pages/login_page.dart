import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:whatsapp_clone/features/app/const/app_const.dart';
import 'package:whatsapp_clone/features/app/home/home_page.dart';
import 'package:whatsapp_clone/features/app/home/modern_home_page.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/auth/auth_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/credential/credential_cubit.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/initial_profile_submit_page.dart';
import 'package:whatsapp_clone/features/user/presentation/pages/otp_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();

  static Country _selectedFilteredDialogCountry =
      CountryPickerUtils.getCountryByPhoneCode("234");
  String _countryCode = _selectedFilteredDialogCountry.phoneCode;

  String _phoneNumber = "";

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CredentialCubit, CredentialState>(
      listener: (context, credentialListenerstate) {
        if (credentialListenerstate is CredentialSuccess) {
          debugPrint("🎉 Credential success - logging in user");
          BlocProvider.of<AuthCubit>(context).loggedIn();
        }
        if (credentialListenerstate is CredentialFailure) {
          toast("Something went wrong");
        }
      },
      builder: (context, credentialBuilderstate) {
        if (credentialBuilderstate is CredentialLoading) {
          return const Center(
              child: CircularProgressIndicator(
            color: tabColor,
          ));
        }
        if (credentialBuilderstate is CredentialPhoneAuthSmsCodeReceived) {
          return const OtpPage();
        }
        if (credentialBuilderstate is CredentialPhoneAuthProfileInfo) {
          return InitialProfileSubmitPage(phoneNumber: _phoneNumber);
        }
        if (credentialBuilderstate is CredentialSuccess) {
          return BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return ModernHomePage(uid: authState.uid);
                // return HomePage(uid: authState.uid);
              }
              return _buildWidget();
            },
          );
        }
        return _buildWidget();
      },
    );
  }

  _buildWidget() {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Verify your phone number",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: tabColor,
                      ),
                    ),
                  ),
                  const Text(
                    "WhatsApp Clone will send you SMS message (carrier charges may apply) to verify your phone number. Enter the country code and phone number",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 2),
                    onTap: _openFilteredCountryPickerDialog,
                    title: _buildDialogItem(_selectedFilteredDialogCountry),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(width: 1.50, color: tabColor),
                          ),
                        ),
                        width: 80,
                        height: 42,
                        alignment: Alignment.center,
                        child: Text(
                          _selectedFilteredDialogCountry.phoneCode,
                        ),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Expanded(
                        child: Container(
                          height: 40,
                          margin: const EdgeInsets.only(top: 1.5),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: tabColor, width: 1.5),
                            ),
                          ),
                          child: TextField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                                hintText: "Phone Number",
                                border: InputBorder.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: _submitVerifyPhoneNumber,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                width: 120,
                height: 40,
                decoration: BoxDecoration(
                  color: tabColor,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Center(
                  child: Text(
                    "Next",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilteredCountryPickerDialog() {
    showDialog(
      context: context,
      builder: (_) => Theme(
        data: Theme.of(context).copyWith(
          primaryColor: tabColor,
        ),
        child: CountryPickerDialog(
          titlePadding: const EdgeInsets.all(8.0),
          searchCursorColor: tabColor,
          searchInputDecoration: const InputDecoration(
            hintText: "Search",
          ),
          isSearchable: true,
          title: const Text("Select your phone code"),
          onValuePicked: (Country country) {
            setState(() {
              _selectedFilteredDialogCountry = country;
              _countryCode = country.phoneCode;
            });
          },
          itemBuilder: _buildDialogItem,
        ),
      ),
    );
  }

  Widget _buildDialogItem(Country country) {
    return Container(
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: tabColor, width: 1.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CountryPickerUtils.getDefaultFlagImage(country),
          Text(" +${country.phoneCode}"),
          Expanded(
            child: Text(
              " ${country.name}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          const Icon(Icons.arrow_drop_down)
        ],
      ),
    );
  }

  void _submitVerifyPhoneNumber() {
    if (_phoneController.text.isNotEmpty) {
      _phoneNumber = "+$_countryCode${_phoneController.text}";
      debugPrint("PhoneNumber $_phoneNumber");
      BlocProvider.of<CredentialCubit>(context)
          .submitVerifyPhoneNumber(phoneNumber: _phoneNumber);
    } else {
      toast("Enter your phone number");
    }
  }
}
