// main.dart

import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:aureviarooms/data/services/promotion_repository.dart';
import 'package:aureviarooms/data/services/review_repository.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/data/services/user_model_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/app/app.dart'; // Tu widget principal MaterialApp
import 'package:aureviarooms/app/app_theme.dart'; // <--- THIS IS CORRECT
import 'package:aureviarooms/config/supabase/supabase_config.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:aureviarooms/provider/theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        Provider(create: (_) => LocalStorageManager()),
        Provider(
          create: (context) => UserModelRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        ChangeNotifierProxyProvider2<ConnectionProvider, UserModelRepository, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ConnectionProvider>(),
            context.read<UserModelRepository>(),
          ),
          update: (context, connection, userModelRepo, previous) {
            previous?.updateConnection(connection);
            return previous!;
          },
        ),
        Provider(
          create: (context) => BookingRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        Provider(
          create: (context) => PromotionRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        Provider(
          create: (context) => ReviewRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        Provider(
          create: (context) => StayRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        Provider(
          create: (context) => RoomRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
        Provider(
          create: (context) => RoomRateRepository(
            context.read<ConnectionProvider>(),
          ),
        ),
      ],
      child: const MyAppWrapper(),
    ),
  );
}

class MyAppWrapper extends StatelessWidget {
  const MyAppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'AureviaRooms',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      // Aquí usamos la clase AppTheme que importamos
      theme: AppTheme.lightTheme, // Usa tu tema claro
      darkTheme: AppTheme.darkFuturisticTheme, // Usa tu tema oscuro futurista
      home: const App(),
    );
  }
}