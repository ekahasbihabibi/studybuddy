import 'package:flutter/material.dart';
import '../models/module.dart';
import '../screens/module_detail_screen.dart';

class ModuleCard extends StatelessWidget {
  final Module module;

  const ModuleCard({super.key, required this.module});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: ListTile(
        title: Text(
          module.title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(module.description),
        trailing: Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ModuleDetailScreen(module: module),
            ),
          );
        },
      ),
    );
  }
}
