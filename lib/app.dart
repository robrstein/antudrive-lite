import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/ble_provider.dart';
import 'providers/groups_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';
import 'services/storage_service.dart';

class AntuDriveLiteApp extends StatelessWidget {
  final StorageService storage;
  const AntuDriveLiteApp({super.key, required this.storage});

  static const _themeSeeds = [
    (seed: Color(0xFFFFBF00), dark: true),
    (seed: Color(0xFF1E88E5), dark: true),
    (seed: Color(0xFFFF6D00), dark: false),
  ];

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(create: (_) => GroupsProvider(storage)),
        ChangeNotifierProvider(create: (_) => BleProvider(storage)),
      ],
      child: Consumer<SettingsProvider>(
        builder: (ctx, settings, _) {
          final t = _themeSeeds[settings.themeIndex.clamp(0, 2)];
          return MaterialApp(
            title: 'AntuDrive Lite',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: t.seed,
                  brightness: t.dark ? Brightness.dark : Brightness.light),
              useMaterial3: true,
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
