// chắc chắn rằng đã cập nhật phiên bản gói english_words trong pubspec.yaml
// Ví dụ: english_words: ^4.0.0

import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const MyApp());

//Stateless vì nó cố định, không có dữ liệu hay trạng thái cần cập nhật
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Startup Name Generator',
      home: RandomWords(),
    );
  }
}

//Stateful vì nó có thể thay đổi trong quá trình chạy ứng dụng (update data)
class RandomWords extends StatefulWidget {
  const RandomWords({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final List<WordPair> _suggestions = <WordPair>[];
  final Set<WordPair> _saved = <WordPair>{};
  final TextStyle _biggerFont = const TextStyle(fontSize: 20);
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadSavedWords();
  }

  _loadSavedWords() async {
    _prefs = await SharedPreferences.getInstance();
    List<String>? savedWords = _prefs!.getStringList('savedWords');
    if (savedWords != null) {
      _saved.addAll(savedWords.map((word) {
        List<String> pair =
            word.split('::'); // Tách từ 'word' thành List<String>
        return WordPair(
            pair[0], pair[1]); // Sử dụng đủ cặp từ để khởi tạo WordPair
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Name Generator'),
        backgroundColor: Colors.purple,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
          ),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return SavedSuggestions(savedWords: _saved.toList());
        },
      ),
    );
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (BuildContext context, int i) {
        if (i.isOdd) {
          return const Divider();
        }

        final int index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

// đánh dấu cặp từ yêu thích
  Widget _buildRow(WordPair pair) {
    final bool alreadySaved = _saved.contains(pair);
    return ListTile(
      title: Text(
        pair.asPascalCase,
        style: _biggerFont,
      ),
      trailing: Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.purpleAccent : null,
      ),
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _saved.remove(pair);
          } else {
            _saved.add(pair);
          }
          _saveWords();
        });
      },
    );
  }

  _saveWords() async {
    List<String> savedWordsList = _saved
        .map((word) =>
            '${word.first}::${word.second}') // Kết hợp cặp từ thành một chuỗi, phân cách bằng '::'
        .toList();
    await _prefs!.setStringList('savedWords', savedWordsList);
  }
}

class SavedSuggestions extends StatelessWidget {
  final List<WordPair> savedWords;

  const SavedSuggestions({super.key, required this.savedWords});

  @override
  Widget build(BuildContext context) {
    final tiles = savedWords.map((WordPair pair) {
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: const TextStyle(fontSize: 16),
        ),
      );
    });

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Suggestions'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(children: divided),
    );
  }
}
