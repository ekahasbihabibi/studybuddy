import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:studybuddy/services/auth_service.dart';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  String? _email;
  String? _currentImageUrl;
  File? _selectedImage;
  bool _isLoading = false;

  final String baseUrl = "http://192.168.100.109/studybuddy";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _email = await AuthService.getCurrentUserEmail();
    if (_email != null) {
      final profile = await AuthService.getUserProfile(_email!);
      setState(() {
        _nameController.text = profile['name'] ?? '';
        _currentImageUrl = profile['profile_picture'];
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<bool> _uploadImageIfNeeded() async {
    if (_selectedImage == null || _email == null) return true;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload_profile.php'),
    );
    request.fields['email'] = _email!;
    request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

    final response = await request.send();
    final result = json.decode(await response.stream.bytesToString());

    if (result['success']) {
      setState(() {
        _currentImageUrl = "$baseUrl/uploads/${result['filename']}";
        _selectedImage = null;
      });
      return true;
    }
    return false;
  }

  Future<void> _saveProfile() async {
    if (_email == null) return;

    setState(() => _isLoading = true);
    final uploadSuccess = await _uploadImageIfNeeded();
    final updateSuccess = await AuthService.updateUserName(_email!, _nameController.text.trim());
    setState(() => _isLoading = false);

    final success = uploadSuccess && updateSuccess;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success ? 'Profil berhasil diperbarui' : 'Gagal memperbarui profil'),
    ));

    if (success) Navigator.pop(context);
  }

  Future<void> _deleteProfilePicture() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin ingin menghapus foto profil?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );

    if (confirm == true && _email != null) {
      final success = await AuthService.deleteProfilePicture(_email!);
      if (success) {
        setState(() {
          _currentImageUrl = null;
          _selectedImage = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Foto profil berhasil dihapus")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus foto")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: _email == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : (_currentImageUrl != null
                        ? NetworkImage(_currentImageUrl!)
                        : null) as ImageProvider?,
                    child: (_selectedImage == null && _currentImageUrl == null)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_currentImageUrl != null && _selectedImage == null)
              TextButton.icon(
                onPressed: _deleteProfilePicture,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text("Hapus Foto", style: TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: const Icon(Icons.person),
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveProfile,
              icon: const Icon(Icons.save),
              label: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
