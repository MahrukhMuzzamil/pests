import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pests247/client/widgets/custom_button.dart';
import 'package:pests247/shared/screens/auth/account_type_screen.dart';
import 'package:pests247/shared/screens/auth/first_account_selection_screen.dart';
import '../../models/others/pest_model.dart';
import '../auth/login/login_page.dart';
import '../auth/sign_up/sign_up_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  List<ServiceCategory> services = allCategories.where((c) => c.isActive).toList();

  int selectedService = 4;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        selectedService = Random().nextInt(services.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const Center(child: Text('No services found.'));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: services.length,
                  itemBuilder: (BuildContext context, int index) {
                    if (index >= services.length) return const SizedBox();
                    return _serviceContainer(
                      services[index].imageURL,
                      services[index].name,
                      index,
                    );
                  },
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Welcome to a Pest-Free Environment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'We provide expert pest control services to keep your home safe and comfortable. Let our professionals handle all your pest concerns with care and precision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'L O G I N',
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    isLoading: false,
                    tag: 'ButtonL O G I N',
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    text: 'S I G N U P',
                    backgroundColor: Colors.white70,
                    textColor: Colors.black,
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const AccountSelectScreen(),
                        ),
                      );
                    },
                    isLoading: false,
                    tag: 'ButtonS I G N U P',
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) =>
                                const FirstAccountSelectionScreen(),
                          ),
                        );
                      },
                      child: const Text('Skip for now')),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _serviceContainer(String image, String name, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedService = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: selectedService == index ? Colors.white : Colors.grey.shade100,
          border: Border.all(
            color: selectedService == index
                ? Colors.blue.shade100
                : Colors.transparent,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Image.asset(
            image,
            height: MediaQuery.of(context).size.width * 0.1,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
