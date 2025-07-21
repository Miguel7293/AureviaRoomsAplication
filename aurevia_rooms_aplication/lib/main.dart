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
import 'package:aureviarooms/config/supabase/supabase_config.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/provider/connection_provider.dart';
import 'package:aureviarooms/provider/theme_provider.dart'; // ¡Importa el nuevo ThemeProvider!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        // Añade el ThemeProvider aquí
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
      child: const App(), // Aquí es donde tu widget App consume los temas
    ),
  );
}