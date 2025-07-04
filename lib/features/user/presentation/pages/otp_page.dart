import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:whatsapp_clone/features/app/theme/styles.dart';
import 'package:whatsapp_clone/features/user/presentation/cubit/credential/credential_cubit.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String _otpCode = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      "Verify your OTP",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: tabColor),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Enter your Otp for the whatsApp Clone Verification (so that you will be moved for further step to complete)",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 30),
                  _pinCodeWidget(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
            GestureDetector(
              onTap: _submitSmsCode,
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
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _submitSmsCode() {
    if (_otpCode.isNotEmpty) {
      BlocProvider.of<CredentialCubit>(context)
          .submitSmsCode(smsCode: _otpCode);
    }
  }

  Widget _pinCodeWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: <Widget>[
          PinCodeTextField(
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            appContext: context,
            autoFocus: true,
            length: 6,
            dialogConfig: DialogConfig(
              dialogContent: 'Do you want to paste?',
              dialogTitle: 'paste OTP',
            ),
            onChanged: (value) => _otpCode = value,
            onCompleted: (value) => _otpCode = value,
            beforeTextPaste: (value) {
              return value != null &&
                  value.isNotEmpty &&
                  value.length == 6 &&
                  int.tryParse(value) != null;
            },
          ),
          const Text("Enter your 6 digit code")
        ],
      ),
    );
  }
}
