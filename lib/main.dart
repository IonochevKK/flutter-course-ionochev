import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/config/app_config.dart';
import 'data/index.dart' as data;
import 'domain/index.dart' as domain;
import 'ui/screens/index.dart' as screens;

void main() {
  AppConfig.validate();

  final api = data.SpaceApi(
    baseUri: AppConfig.apiBaseUri,
    client: http.Client(),
  );
  runApp(CatalogApp(repository: data.SpaceRepositoryImpl(api)));
}

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key, required this.repository});

  final domain.SpaceRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Космос',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: screens.CatalogScreen(repository: repository),
    );
  }
}
