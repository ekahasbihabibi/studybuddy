import 'package:flutter/material.dart';
import '../models/module.dart';
import '../services/favorite_service.dart';
import '../services/module_service.dart';
import 'module_detail_screen.dart';

class FavoriteScreen extends StatefulWidget {
  final String? subject; // boleh null, berarti semua

  const FavoriteScreen({super.key, this.subject});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<Module> _favoriteModules = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.getFavoriteModuleIds();
    final allModules = await loadModules();
    setState(() {
      _favoriteModules = allModules.where((m) {
        final isFavorite = ids.contains(m.id);
        final matchesSubject = widget.subject == null || m.subject == widget.subject;
        return isFavorite && matchesSubject;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Modul Favorit${widget.subject != null ? ' – ${widget.subject}' : ''}")),
      body: _favoriteModules.isEmpty
          ? Center(child: Text("Belum ada modul favorit."))
          : ListView.builder(
        itemCount: _favoriteModules.length,
        itemBuilder: (context, index) {
          final module = _favoriteModules[index];
          return ListTile(
            title: Text(module.title),
            subtitle: Text(module.description),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ModuleDetailScreen(module: module)),
              );
            },
          );
        },
      ),
    );
  }
}
