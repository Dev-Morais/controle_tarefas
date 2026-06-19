import 'package:flutter/material.dart';
import 'db_helper.dart'; // Certifique-se de importar o seu helper
import 'login_screen.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'perfil_screen.dart';
import 'alterar_senha_screen.dart';

void main() async { // 1. Adicionado async
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Garante que o usuário admin exista antes do app iniciar
  await DBHelper.seedDatabase(); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Controle de Tarefas',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, 
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/alterar_senha': (context) => const AlterarSenhaScreen(),
      },
    );
  }
}

// Sua classe de alertas permanece igual
class AppAlertas {
  static void mostrar(BuildContext context, String mensagem, {bool isErro = true}) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          mensagem,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isErro ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}