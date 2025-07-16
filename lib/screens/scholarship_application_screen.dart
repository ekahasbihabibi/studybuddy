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
  String reason = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Form Pengajuan Beasiswa")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Isi data berikut dengan lengkap:"),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                onSaved: (value) => name = value ?? '',
                validator: (value) => value == null || value.isEmpty ? "Nama wajib diisi" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Email Aktif"),
                onSaved: (value) => email = value ?? '',
                validator: (value) => value == null || !value.contains('@') ? "Email tidak valid" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: "Alasan Mengajukan Beasiswa"),
                onSaved: (value) => reason = value ?? '',
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Pengajuan beasiswa berhasil dikirim!")),
                    );

                    Navigator.pop(context);
                  }
                },
                child: const Text("Kirim Pengajuan"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
