import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfliq_app/provider/timer.dart';
import 'package:myfliq_app/services/auth_services.dart';
import 'package:myfliq_app/view/chat_home.page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:shared_preferences/shared_preferences.dart';

final otpLoaderProvider = StateProvider<bool>((ref) => false);

class OTPVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String testOtp;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.testOtp,
  });

  @override
  ConsumerState<OTPVerificationPage> createState() =>
      _OTPVerificationPageState();
}

class _OTPVerificationPageState extends ConsumerState<OTPVerificationPage> {
  final TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(otpLoaderProvider);
    final resendSecondsLeft = ref.watch(otpResendTimerProvider);
    final isResendAvailable = resendSecondsLeft == 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back, size: 24),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your verification\ncode',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jost',
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    // Logic to edit phone number
                    Navigator.pop(context);
                  },

                  child: RichText(
                    text: TextSpan(
                      text: widget.phoneNumber,
                      style: const TextStyle(color: Colors.black87),
                      children: const [
                        TextSpan(
                          text: '  Edit',
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              PinCodeTextField(
                appContext: context,
                length: 6,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(13),
                  fieldHeight: 50,
                  fieldWidth: 50,
                  activeFillColor: Colors.white,
                  selectedColor: Colors.pink,
                  inactiveColor: Colors.grey.shade300,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.white,
                enableActiveFill: false,
                onChanged: (value) => otpController.text = value,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: const Text(
                  "Didn't get anything? No worries, let’s try again.",
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: isResendAvailable
                      ? () async {
                          final success = await AuthService.sendOtp(
                            widget.phoneNumber,
                          );

                          if (success != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('OTP resent successfully!'),
                              ),
                            );
                            ref
                                .read(otpResendTimerProvider.notifier)
                                .startTimer();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to resend OTP'),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Text(
                    isResendAvailable
                        ? "Resend"
                        : "Resend in ${resendSecondsLeft}s",
                    style: TextStyle(
                      color: isResendAvailable ? Colors.blue : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),

              // 🔄 Button or Loader
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          final otp = otpController.text.trim();
                          if (otp.length != 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter valid 6-digit OTP'),
                              ),
                            );
                            return;
                          }

                          ref.read(otpLoaderProvider.notifier).state = true;

                          final result = await AuthService.verifyOtp(
                            phone: widget.phoneNumber,
                            otp: otp,
                          );

                          ref.read(otpLoaderProvider.notifier).state = false;

                          if (result != null) {
                            final accessToken =
                                result['auth_status']['access_token'];
                            final userId = result['id'];
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('access_token', accessToken);
                            await prefs.setString('user_id', userId);
                            print(accessToken);
                            print(userId);
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChatHomePage(),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Invalid OTP or verification failed',
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF96C9A), Color(0xFFF85A8F)],
                      ),
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: Center(
                      child: isLoading
                          ? const CupertinoActivityIndicator(
                              color: Colors.white,
                            )
                          : const Text(
                              "Verify",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
