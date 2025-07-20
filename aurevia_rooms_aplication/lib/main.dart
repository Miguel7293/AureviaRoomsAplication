import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:aureviarooms/data/services/room_rate_repository.dart';
import 'package:aureviarooms/data/services/room_repository.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
import 'package:aureviarooms/data/services/user_model_repository.dart'; // <--- Importa el nuevo repositorio
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:aureviarooms/data/services/local_storage_manager.dart';
import 'package:aureviarooms/app/app.dart';
import 'package:aureviarooms/config/supabase/supabase_config.dart';
import 'package:aureviarooms/provider/auth_provider.dart';
import 'package:aureviarooms/provider/connection_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectionProvider()),
        // Provee LocalStorageManager y UserModelRepository primero si AuthProvider los necesita
        Provider(create: (_) => LocalStorageManager()),
        // UserModelRepository depende de ConnectionProvider y LocalStorageManager
        Provider(
          create: (context) => UserModelRepository(
            context.read<ConnectionProvider>(),
            context.read<LocalStorageManager>(),
          ),
        ),
        ChangeNotifierProxyProvider2<ConnectionProvider, UserModelRepository, AuthProvider>( // <--- Cambia a ProxyProvider2
          create: (context) => AuthProvider(
            context.read<ConnectionProvider>(),
            context.read<UserModelRepository>(), // <--- Pasa el UserModelRepository
          ),
          update: (context, connection, userModelRepo, previous) {
            previous?.updateConnection(connection);
            // Si AuthProvider necesita actualizarse con el nuevo userModelRepo, hazlo aquí.
            // En este caso, el repo no cambia, solo se inyecta al inicio.
            return previous!;
          },
        ),
        Provider(
          create: (context) => BookingRepository(
            context.read<ConnectionProvider>(),
            context.read<LocalStorageManager>(),
          ),
        ),
        Provider(
          create: (context) => StayRepository(
            context.read<ConnectionProvider>(),
            context.read<LocalStorageManager>(),
          ),
        ),
          Provider(
          create: (context) => RoomRepository(
            context.read<ConnectionProvider>(),
            context.read<LocalStorageManager>(),
          ),
        ),
        Provider(
          create: (context) => RoomRateRepository(
            context.read<ConnectionProvider>(),
            context.read<LocalStorageManager>(),
          ),
        ),
      ],
      child: const App(),
    ),
  );
}
