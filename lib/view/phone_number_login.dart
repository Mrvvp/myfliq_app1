import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfliq_app/services/auth_services.dart';
import 'package:myfliq_app/view/otp_verification.dart';

final isOtpLoadingProvider = StateProvider<bool>((ref) => false);

class PhoneNumberInputPage extends ConsumerStatefulWidget {
  const PhoneNumberInputPage({super.key});

  @override
  ConsumerState<PhoneNumberInputPage> createState() =>
      _PhoneNumberInputPageState();
}

class _PhoneNumberInputPageState extends ConsumerState<PhoneNumberInputPage> {
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(isOtpLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, size: 24),
              ),
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'Enter your phone\nnumber',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Jost',
                    color: Color(0xFF2D0C0C),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_android_outlined,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    const Text('+91', style: TextStyle(fontSize: 16)),
                    const Icon(Icons.keyboard_arrow_down),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '974568 1203',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(
                  'Fliq will send you a text with a verification code.',
                  style: TextStyle(fontSize: 12, color: Colors.black),
                ),
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF96C9A), Color(0xFFF85A8F)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          ref.read(isOtpLoadingProvider.notifier).state = true;

                          final phone = '+91${phoneController.text.trim()}';
                          final otp = await AuthService.sendOtp(phone);

                          ref.read(isOtpLoadingProvider.notifier).state = false;

                          if (otp != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OTPVerificationPage(
                                  phoneNumber: phone,
                                  testOtp: otp.toString(),
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to send OTP'),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    elevation: 4,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                  ),
                  child: isLoading
                      ? const CupertinoActivityIndicator(color: Colors.white)
                      : const Text(
                          'Next',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
