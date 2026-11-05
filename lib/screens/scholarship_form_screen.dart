import 'package:flutter/material.dart';

class ScholarshipFormScreen extends StatefulWidget {
  const ScholarshipFormScreen({super.key});

  @override
  State<ScholarshipFormScreen> createState() => _ScholarshipFormScreenState();
}

class _ScholarshipFormScreenState extends State<ScholarshipFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String school = '';
  String motivation = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text("Form Pengajuan Beasiswa")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                label: "Nama Lengkap",
                onSaved: (val) => name = val!,
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: "Email",
                keyboardType: TextInputType.emailAddress,
                onSaved: (val) => email = val!,
                validator: (val) =>
                    val!.contains('@') ? null : "Format email salah",
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: "Asal Sekolah / Universitas",
                onSaved: (val) => school = val!,
                validator: (val) => val!.isEmpty ? "Wajib diisi" : null,
              ),
              SizedBox(height: 16),
              _buildTextField(
                label: "Motivasi Mengikuti Beasiswa",
                maxLines: 4,
                onSaved: (val) => motivation = val!,
                validator: (val) =>
                    val!.length < 10 ? "Minimal 10 karakter" : null,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: Icon(Icons.send),
                label: Text("Kirim Pengajuan"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Berhasil Diajukan"),
          content: Text("Terima kasih, pengajuan kamu telah kami terima."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tutup"),
            ),
          ],
        ),
      );
    }
  }
}
