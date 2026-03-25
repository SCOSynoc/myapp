import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:myapp/models/user.dart';
import 'package:myapp/presentation/auth/login_screen.dart';
import 'package:myapp/presentation/home_screen.dart';
import 'package:myapp/providers/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Hive.initFlutter();
  await Hive.openBox<User>('userBox');
  runApp(ProviderScope(child: const MyApp()));
}



class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);

    return MaterialApp(
      title: 'Business News',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: user != null ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}


