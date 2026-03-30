import 'package:flutter/material.dart';
import 'package:my_app/main.dart';
import 'package:my_app/ptpage/user_loginandsignup_page/loginandsignup.dart';
import 'package:my_app/userInterfacepage/userinterface.dart';

class PtSignUp extends StatefulWidget {
  const PtSignUp({super.key});

  @override
  State<PtSignUp> createState() => _PtSignUpState();
}

class _PtSignUpState extends State<PtSignUp>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {

    final email = TextEditingController();
    final password = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Antrenör Giriş Sayfası"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
           Navigator.pushReplacement(context, 
           MaterialPageRoute(builder:   (_) => const RoleSelectPage()));
          },
        ),
      ),
      body: Stack(
        children: [

          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Container(color: Colors.black.withOpacity(0.5)),

          FadeTransition(
            opacity: fadeAnimation,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Hero(
                        tag: "logo",
                        child: const Icon(
                          Icons.fitness_center,
                          size: 70,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Giriş Yap",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 30),

                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          hintText: "Email",
                        ),
                      ),

                      const SizedBox(height: 15),

                      TextField(
                        controller: password,
                        obscureText: true,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "Şifre",
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(builder: (_) => const PersonalTrainer()));
                          },
                          child: const Text("Giriş Yap"),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}