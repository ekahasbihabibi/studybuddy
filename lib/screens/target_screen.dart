import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TargetScreen extends StatefulWidget {
  const TargetScreen({super.key});

  @override
  State<TargetScreen> createState() => _TargetScreenState();
}

class _TargetScreenState extends State<TargetScreen> {
  List<String> goals = [];
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      goals = prefs.getStringList('learning_goals') ?? [];
    });
  }

  Future<void> _saveGoals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('learning_goals', goals);
  }

  void _addGoal() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        goals.add(_controller.text.trim());
        _controller.clear();
      });
      _saveGoals();
    }
  }

  void _removeGoal(int index) {
    setState(() {
      goals.removeAt(index);
    });
    _saveGoals();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Target Belajar'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Tambah Target Baru',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addGoal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: goals.isEmpty
                  ? Center(child: Text('Belum ada target. Tambahkan sekarang!'))
                  : ListView.builder(
                itemCount: goals.length,
                itemBuilder: (context, index) => Card(
                  child: ListTile(
                    leading: Icon(Icons.flag),
                    title: Text(goals[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeGoal(index),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
