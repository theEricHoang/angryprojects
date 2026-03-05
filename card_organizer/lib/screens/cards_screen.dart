import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../models/card.dart';
import '../repositories/card_repository.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'add_edit_card_screen.dart';

class CardsScreen extends StatefulWidget {
  final Folder folder;

  const CardsScreen({super.key, required this.folder});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  final CardRepository _cardRepo = CardRepository();

  List<PlayingCard> _cards = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoading = true);
    try {
      final cards = await _cardRepo.getCardsByFolderId(widget.folder.id!);
      setState(() {
        _cards = cards;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load cards: $e')));
      }
    }
  }

  Future<void> _deleteCard(PlayingCard card) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      itemName: '${card.cardName} of ${card.suit}',
      cascade: false,
    );

    if (confirmed == true) {
      try {
        await _cardRepo.deleteCard(card.id!);
        _loadCards();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${card.cardName} of ${card.suit} deleted.'),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to delete card: $e')));
        }
      }
    }
  }

  void _addCard() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddEditCardScreen(
              folderId: widget.folder.id!,
              folderName: widget.folder.folderName,
            ),
          ),
        )
        .then((_) => _loadCards());
  }

  void _editCard(PlayingCard card) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddEditCardScreen(
              folderId: widget.folder.id!,
              folderName: widget.folder.folderName,
              existingCard: card,
            ),
          ),
        )
        .then((_) => _loadCards());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folder.folderName} Cards'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cards.isEmpty
          ? const Center(child: Text('No cards in this folder.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _cards.length,
              itemBuilder: (context, index) {
                final card = _cards[index];
                return _CardListItem(
                  card: card,
                  onEdit: () => _editCard(card),
                  onDelete: () => _deleteCard(card),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  final PlayingCard card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CardListItem({
    required this.card,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: _buildCardImage(),
        title: Text(
          card.cardName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(card.suit),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey),
              tooltip: 'Edit card',
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Delete card',
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardImage() {
    if (card.imageUrl != null && card.imageUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.network(
          card.imageUrl!,
          width: 48,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 48,
      height: 64,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Center(
        child: Text(
          card.cardName.isNotEmpty ? card.cardName[0] : '?',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: (card.suit == 'Hearts' || card.suit == 'Diamonds')
                ? Colors.red
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
