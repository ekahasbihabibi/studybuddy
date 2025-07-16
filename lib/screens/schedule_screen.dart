import 'package:flutter/material.dart';
import '../models/study_schedule.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final List<StudySchedule> _schedules = [];

  final _subjectController = TextEditingController();
  String _selectedDay = 'Senin';
  TimeOfDay _selectedTime = TimeOfDay(hour: 08, minute: 00);

  void _addSchedule() {
    final subject = _subjectController.text.trim();
    if (subject.isEmpty) return;

    setState(() {
      _schedules.add(StudySchedule(
        subject: subject,
        day: _selectedDay,
        time: _selectedTime.format(context),
      ));
      _subjectController.clear();
    });
  }

  void _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Jadwal Belajar')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(labelText: 'Mata Pelajaran'),
            ),
            DropdownButton<String>(
              value: _selectedDay,
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
              items: [
                'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
              ].map((day) {
                return DropdownMenuItem(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
            ),
            Row(
              children: [
                Text('Jam: ${_selectedTime.format(context)}'),
                TextButton(
                  onPressed: _pickTime,
                  child: Text('Pilih Jam'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: _addSchedule,
              child: Text('Tambah Jadwal'),
            ),
            Divider(),
            Expanded(
              child: _schedules.isEmpty
                  ? Center(child: Text('Belum ada jadwal.'))
                  : ListView.builder(
                itemCount: _schedules.length,
                itemBuilder: (context, index) {
                  final schedule = _schedules[index];
                  return ListTile(
                    title: Text(schedule.subject),
                    subtitle: Text('${schedule.day}, ${schedule.time}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _schedules.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
