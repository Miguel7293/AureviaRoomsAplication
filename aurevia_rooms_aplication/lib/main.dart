import 'package:aureviarooms/data/services/booking_repository.dart';
import 'package:aureviarooms/data/services/stay_repository.dart';
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
        ChangeNotifierProxyProvider<ConnectionProvider, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<ConnectionProvider>(),
          ),
          update: (context, connection, previous) {
            previous?.updateConnection(connection);
            return previous!;
          },
        ),
        Provider(create: (_) => LocalStorageManager()),
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
      ],
      child: const App(),
    ),
  );
}