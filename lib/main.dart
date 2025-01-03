import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FirebaseAuth auth;
  final String _email = 'suleymansurucu95@gmail.com';
  final String _password = 'newPassword';

  @override
  void initState() {
    super.initState();
    auth = FirebaseAuth.instance;
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print(
            'User is signed in! -- ${user.email}, email verified: ${user.emailVerified}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: createEmailAndPassword,
              child: const Text('Create Account'),
            ),
            ElevatedButton(
              onPressed: loginEmailAndPassword,
              child: const Text('Login'),
            ),
            ElevatedButton(
              onPressed: signOutEmailAndPassword,
              child: const Text('Logout'),
            ),
            ElevatedButton(
              onPressed: deleteEmailAndPassword,
              child: const Text('Delete User'),
            ),
            ElevatedButton(
              onPressed: changePassword,
              child: const Text('Change the Password'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> createEmailAndPassword() async {
    try {
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      var myUser = userCredential.user;
      if (!myUser!.emailVerified) {
        await myUser.sendEmailVerification();
      } else {
        print('Your email verified, Thank You');
      }
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Account created: ${userCredential.user?.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating account: $e')),
      );
    }
  }

  Future<void> loginEmailAndPassword() async {
    try {
      final userCredential = await auth.signInWithEmailAndPassword(
        email: _email,
        password: _password,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged in as: ${userCredential.user?.email}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging in: $e')),
      );
    }
  }

  Future<void> signOutEmailAndPassword() async {
    try {
      await auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  void deleteEmailAndPassword() async {
    if (auth.currentUser != null) {
      await auth.currentUser!.delete();
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please Enter to Log in')));
    }
  }

  void changePassword() async {
    try {
      await auth.currentUser!.updatePassword('password');
      auth.signOut();
    }on FirebaseAuthException catch (e){

      if (e.code=='requires-recent-login') {
        print('Re authenceire olacak');

        var credential=EmailAuthProvider.credential(email: _email, password: _password);
        await auth.currentUser!.reauthenticateWithCredential(credential);
        await auth.currentUser!.updatePassword('newPassword');
        await auth.signOut();
        print('Updated Password');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
