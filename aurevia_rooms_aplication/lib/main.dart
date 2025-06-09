import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/app/app.dart';
import 'package:aureviarooms/config/supabase_config.dart';
import '/provider/auth_provider.dart';
import 'provider/connection_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProxyProvider<ConnectionProvider, AuthProvider>(
          create: (context) =>
              AuthProvider(context.read<ConnectionProvider>()),
          update: (context, connection, previous) =>
              AuthProvider(connection),
        ),
      ],
      child: const App(),
    ),
  );
}
