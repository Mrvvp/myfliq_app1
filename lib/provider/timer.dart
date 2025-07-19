import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpResendTimerProvider = StateNotifierProvider<OtpTimerNotifier, int>(
  (ref) => OtpTimerNotifier(),
);

class OtpTimerNotifier extends StateNotifier<int> {
  OtpTimerNotifier() : super(0);

  void startTimer() {
    state = 60;
    _tick();
  }

  void _tick() async {
    while (state > 0) {
      await Future.delayed(const Duration(seconds: 1));
      state--;
    }
  }
}
