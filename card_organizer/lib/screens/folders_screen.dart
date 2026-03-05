import 'package:flutter/material.dart';

import '../models/folder.dart';
import '../repositories/folder_repository.dart';
import '../repositories/card_repository.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'cards_screen.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final FolderRepository _folderRepo = FolderRepository();
  final CardRepository _cardRepo = CardRepository();

  List<Folder> _folders = [];
  Map<int, int> _cardCounts = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    setState(() => _isLoading = true);
    try {
      final folders = await _folderRepo.getAllFolders();
      final Map<int, int> counts = {};
      for (final folder in folders) {
        if (folder.id != null) {
          counts[folder.id!] = await _cardRepo.getCardCountByFolder(folder.id!);
        }
      }
      setState(() {
        _folders = folders;
        _cardCounts = counts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load folders: $e')));
      }
    }
  }

  IconData _suitIcon(String folderName) {
    switch (folderName.toLowerCase()) {
      case 'hearts':
        return Icons.favorite;
      case 'diamonds':
        return Icons.diamond;
      case 'clubs':
        return Icons.eco;
      case 'spades':
        return Icons.spa;
      default:
        return Icons.folder;
    }
  }

  Color _suitColor(String folderName) {
    switch (folderName.toLowerCase()) {
      case 'hearts':
        return Colors.red;
      case 'diamonds':
        return Colors.red.shade700;
      case 'clubs':
        return Colors.black87;
      case 'spades':
        return Colors.blueGrey.shade900;
      default:
        return Colors.deepPurple;
    }
  }

  Future<void> _deleteFolder(Folder folder) async {
    final confirmed = await showDeleteConfirmationDialog(
      context,
      itemName: '${folder.folderName} folder',
      cascade: true,
    );

    if (confirmed == true) {
      try {
        await _folderRepo.deleteFolder(folder.id!);
        _loadFolders();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${folder.folderName} folder and all its cards deleted.',
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete folder: $e')),
          );
        }
      }
    }
  }

  void _openFolder(Folder folder) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => CardsScreen(folder: folder)))
        .then((_) => _loadFolders()); // refresh counts on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Organizer'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _folders.isEmpty
          ? const Center(child: Text('No folders found.'))
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                itemCount: _folders.length,
                itemBuilder: (context, index) {
                  final folder = _folders[index];
                  final count = _cardCounts[folder.id] ?? 0;
                  return _FolderCard(
                    folder: folder,
                    cardCount: count,
                    suitIcon: _suitIcon(folder.folderName),
                    suitColor: _suitColor(folder.folderName),
                    onTap: () => _openFolder(folder),
                    onDelete: () => _deleteFolder(folder),
                  );
                },
              ),
            ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  final Folder folder;
  final int cardCount;
  final IconData suitIcon;
  final Color suitColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _FolderCard({
    required this.folder,
    required this.cardCount,
    required this.suitIcon,
    required this.suitColor,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(suitIcon, size: 48, color: suitColor),
              const SizedBox(height: 8),
              Text(
                folder.folderName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$cardCount card${cardCount == 1 ? '' : 's'}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  height: 28,
                  width: 28,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    tooltip: 'Delete folder',
                    onPressed: onDelete,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
