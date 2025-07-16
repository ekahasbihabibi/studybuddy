import 'package:flutter/material.dart';
import '../models/module.dart';
import '../services/module_service.dart';
import '../services/favorite_service.dart';
import 'module_detail_screen.dart';

class ModuleScreen extends StatefulWidget {
  final String? searchQuery;

  const ModuleScreen({super.key, this.searchQuery});

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  List<Module> _modules = [];
  List<Module> _filteredModules = [];
  bool _loading = true;
  final TextEditingController _searchController = TextEditingController();
  Map<String, bool> _favorites = {};

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final modules = await loadModules();
    _modules = modules;

    if (widget.searchQuery != null) {
      _searchController.text = widget.searchQuery!;
      _filterModules(widget.searchQuery!);
    } else {
      _filteredModules = modules;
    }

    await _loadFavorites();

    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadFavorites() async {
    final ids = await FavoriteService.getFavoriteModuleIds();
    setState(() {
      _favorites = {
        for (var m in _modules) m.id: ids.contains(m.id),
      };
    });
  }

  void _filterModules(String query) {
    setState(() {
      _filteredModules = _modules
          .where((m) =>
      m.title.toLowerCase().contains(query.toLowerCase()) ||
          m.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Color(0xFF121212) : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          "Modul Belajar",
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Cari modul...",
                filled: true,
                fillColor:
                isDark ? Colors.grey[800] : Colors.white,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filterModules,
            ),
          ),
          Expanded(
            child: _filteredModules.isEmpty
                ? Center(child: Text("Modul tidak ditemukan"))
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredModules.length,
              itemBuilder: (context, index) {
                final module = _filteredModules[index];
                return _buildModuleCard(context, module, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, Module module, bool isDark) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ModuleDetailScreen(module: module),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
              isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blueAccent.withOpacity(0.15),
              child: Icon(Icons.menu_book, color: Colors.blueAccent),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    module.description,
                    style: TextStyle(
                      fontSize: 13,
                      color:
                      isDark ? Colors.white70 : Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _favorites[module.id] == true
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: _favorites[module.id] == true
                    ? Colors.red
                    : Colors.grey,
              ),
              onPressed: () async {
                await FavoriteService.toggleFavorite(module.id);
                await _loadFavorites();
              },
            ),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: isDark ? Colors.white54 : Colors.grey),
          ],
        ),
      ),
    );
  }
}
