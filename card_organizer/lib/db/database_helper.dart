import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('card_organizer.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Create Folders table
    await db.execute('''
      CREATE TABLE folders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_name TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Create Cards table with foreign key
    await db.execute('''
      CREATE TABLE cards(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name TEXT NOT NULL,
        suit TEXT NOT NULL,
        image_url TEXT,
        folder_id INTEGER,
        FOREIGN KEY (folder_id) REFERENCES folders (id)
          ON DELETE CASCADE
      )
    ''');

    // Prepopulate folders
    await _prepopulateFolders(db);

    // Prepopulate cards
    await _prepopulateCards(db);
  }

  Future _prepopulateFolders(Database db) async {
    final folders = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    for (int i = 0; i < folders.length; i++) {
      await db.insert('folders', {
        'folder_name': folders[i],
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Map card name to its deckofcardsapi code
  static String _cardCode(String cardName) {
    switch (cardName) {
      case 'Ace':
        return 'A';
      case '10':
        return '0';
      case 'Jack':
        return 'J';
      case 'Queen':
        return 'Q';
      case 'King':
        return 'K';
      default:
        return cardName; // 2-9
    }
  }

  // Map suit name to its single-letter code
  static String _suitCode(String suit) {
    return suit[0].toUpperCase(); // Hearts->H, Diamonds->D, Clubs->C, Spades->S
  }

  /// Build the full image URL for a card.
  static String cardImageUrl(String cardName, String suit) {
    return 'https://deckofcardsapi.com/static/img/${_cardCode(cardName)}${_suitCode(suit)}.png';
  }

  Future _prepopulateCards(Database db) async {
    final suits = ['Hearts', 'Diamonds', 'Clubs', 'Spades'];
    final cards = [
      'Ace',
      '2',
      '3',
      '4',
      '5',
      '6',
      '7',
      '8',
      '9',
      '10',
      'Jack',
      'Queen',
      'King',
    ];

    for (int folderId = 1; folderId <= suits.length; folderId++) {
      for (var card in cards) {
        await db.insert('cards', {
          'card_name': card,
          'suit': suits[folderId - 1],
          'image_url': cardImageUrl(card, suits[folderId - 1]),
          'folder_id': folderId,
        });
      }
    }
  }
}
