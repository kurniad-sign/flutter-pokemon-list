import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Http Response Pokemon Class Type
class PokemonAPIResponse {
  const PokemonAPIResponse({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  factory PokemonAPIResponse.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'url': String url,
        'name': String name,
      } =>
        PokemonAPIResponse(name: name, url: url),
      _ => throw const FormatException('Failed to load album.'),
    };
  }
}

// Make API Request Pokemon
Future<List<PokemonAPIResponse>> fetchPokemonList() async {
  final response = await http
      .get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=10&offset=1'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>;
    print(results);
    return results
        .map(
            (item) => PokemonAPIResponse.fromJson(item as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load pokemon list');
  }
}

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MyAppState();
}

class _MyAppState extends State<MainApp> {
  late Future pokemonList;

  void initialState() {
    super.initState();
    pokemonList = fetchPokemonList();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Pokemon',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Pokemon List'),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
            child: FutureBuilder(
                future: fetchPokemonList(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final pokemons = snapshot.data!;
                    return ListView.builder(
                      itemCount: pokemons.length,
                      itemBuilder: (context, index) {
                        final pokemon = pokemons[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${index + 1}.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pokemon.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pokemon ID: ${index + 1}',
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }

                  return const CircularProgressIndicator();
                })),
      ),
    );
  }
}
