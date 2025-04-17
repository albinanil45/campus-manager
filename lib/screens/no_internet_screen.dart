import 'package:campus_manager/helpers/get_initial_screen.dart';
import 'package:campus_manager/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:page_transition/page_transition.dart';

class NoInternetScreen extends StatelessWidget {
  NoInternetScreen({super.key});

  final ValueNotifier<bool> isLoading = ValueNotifier(false);

  Future<void> fetchInitialScreen(BuildContext context) async {
    isLoading.value = true;
    Widget screen = await GetInitialScreen.getInitialScreen();
    if (screen is NoInternetScreen) {
      isLoading.value = false;
    } else {
      await Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.rightToLeftJoined,
          childCurrent: this,
          child: screen,
        ),
      );
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    // Breakpoints
    bool isDesktop = size.width > 1000;
    bool isTablet = size.width > 600 && size.width <= 1000;

    double fontSize = isDesktop
        ? 20
        : isTablet
            ? 18
            : 16;

    double buttonWidth = isDesktop
        ? 200
        : isTablet
            ? 180
            : 160;

    double lottieHeight = isDesktop
        ? size.height * 0.4
        : size.height * 0.35;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Lottie.asset(
                      'assets/no_internet.json',
                      height: lottieHeight,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No internet available, check your connection',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: blackColor,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ValueListenableBuilder(
                      valueListenable: isLoading,
                      builder: (context, value, child) {
                        return SizedBox(
                          width: buttonWidth,
                          height: 45,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                            ),
                            icon: isLoading.value
                                ? const SizedBox(
                                    height: 16,
                                    width: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: whiteColor,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    color: whiteColor,
                                  ),
                            label: Text(
                              'Retry',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: fontSize,
                              ),
                            ),
                            onPressed: () async {
                              if (!isLoading.value) {
                                await fetchInitialScreen(context);
                              }
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
