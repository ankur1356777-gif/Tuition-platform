import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/teacher_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class CreateTestScreen extends ConsumerStatefulWidget {
  const CreateTestScreen({super.key});

  @override
  ConsumerState<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends ConsumerState<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();
  final _marksController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedTuitionId;
  String _testMode = 'offline';
  final List<Map<String, dynamic>> _questions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    _marksController.dispose();
    super.dispose();
  }

  void _addQuestion() {
    setState(() {
      _questions.add({
        'text': '',
        'options': ['', '', '', ''],
        'correct_option': 0,
        'marks': 1,
      });
    });
  }

  Future<void> _submitTest() async {
    if (!_formKey.currentState!.validate() || _selectedDate == null || _selectedTuitionId == null) {
      String msg = _selectedDate == null ? 'Please select a date' : 'Please select a student';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: DesignSystem.error));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(teacherServiceProvider).createTest({
        'tuition_id': _selectedTuitionId,
        'title': _titleController.text,
        'subject': _subjectController.text,
        'scheduled_date': DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDate!),
        'total_marks': int.parse(_marksController.text),
        'test_mode': _testMode,
        'questions': _testMode == 'online' ? _questions : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Test created!'), backgroundColor: Colors.green));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: DesignSystem.error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tuitionsAsync = ref.watch(activeTuitionsTeacherProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text('Design Assessment', style: DesignSystem.heading3(color: null)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : DesignSystem.backgroundDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [DesignSystem.backgroundDark, const Color(0xFF1E1E2E)]
              : [const Color(0xFFF0F4FF), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: tuitionsAsync.when(
          data: (tuitions) => _buildForm(context, tuitions, isDark),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Error: $err', style: DesignSystem.bodySmall(color: Colors.grey))),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, List<dynamic> tuitions, bool isDark) {
    if (tuitions.isEmpty) return Center(child: Text('No active tuitions found.', style: DesignSystem.bodySmall(color: Colors.grey)));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BASIC DETAILS', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            PremiumCard(
              glass: true,
              child: Column(
                children: [
                  DropdownButtonFormField<int>(
                    value: _selectedTuitionId,
                    items: tuitions.map<DropdownMenuItem<int>>((t) {
                      final studentName = t['student']?['user']?['name'] ?? t['student']?['name'] ?? 'Student';
                      return DropdownMenuItem(value: t['id'], child: Text('$studentName - ${t['lead']?['tuition_request']?['subjects']?[0] ?? 'Tuition'}'));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedTuitionId = val),
                    decoration: DesignSystem.inputDecoration('Select Student', Icons.person_rounded),
                    style: DesignSystem.bodyMedium(color: null),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: DesignSystem.inputDecoration('Test Title', Icons.title_rounded),
                    style: DesignSystem.bodyMedium(color: null),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: DesignSystem.inputDecoration('Subject', Icons.subject_rounded),
                    style: DesignSystem.bodyMedium(color: null),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('CONFIGURATION', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 16),
            PremiumCard(
              glass: true,
              child: Column(
                children: [
                  Row(
                    children: [
                      _ModeChip(label: 'OFFLINE', isSelected: _testMode == 'offline', onSelected: () => setState(() => _testMode = 'offline')),
                      const SizedBox(width: 12),
                      _ModeChip(label: 'ONLINE (MCQ)', isSelected: _testMode == 'online', onSelected: () => setState(() => _testMode = 'online')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _marksController,
                    decoration: DesignSystem.inputDecoration('Total Marks', Icons.grade_rounded),
                    style: DesignSystem.bodyMedium(color: null),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today_rounded, size: 20, color: DesignSystem.primary),
                    title: Text(_selectedDate == null ? 'Set Date & Time' : DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDate!), 
                      style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: _selectedDate == null ? FontWeight.normal : FontWeight.bold, color: _selectedDate == null ? Colors.grey : null)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () async {
                      final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)), initialDate: DateTime.now());
                      if (date != null && context.mounted) {
                        final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (time != null) setState(() => _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute));
                      }
                    },
                  ),
                ],
              ),
            ),
            if (_testMode == 'online') ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('QUESTIONS', style: DesignSystem.bodySmall(color: Colors.grey).copyWith(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  TextButton.icon(onPressed: _addQuestion, icon: const Icon(Icons.add_circle_rounded, size: 16), label: Text('ADD QUESTION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                ],
              ),
              const SizedBox(height: 12),
              ...List.generate(_questions.length, (index) => _buildQuestionCard(index)),
            ],
            const SizedBox(height: 48),
            GradientButton(
              text: 'CREATE ASSESSMENT',
              onPressed: _isLoading ? null : _submitTest,
              loading: _isLoading,
              icon: Icons.assignment_turned_in_rounded,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(int index) {
    return PremiumCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: DesignSystem.primary.withOpacity(0.1), child: Text('${index + 1}', style: TextStyle(fontSize: 10, color: DesignSystem.primary, fontWeight: FontWeight.bold))),
              const SizedBox(width: 8),
              Expanded(child: TextFormField(decoration: const InputDecoration(hintText: 'Type question here...', border: InputBorder.none), style: DesignSystem.bodyMedium(color: null).copyWith(fontWeight: FontWeight.bold), onChanged: (v) => _questions[index]['text'] = v)),
            ],
          ),
          const Divider(),
          ...List.generate(4, (oIndex) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Radio<int>(value: oIndex, groupValue: _questions[index]['correct_option'], onChanged: (v) => setState(() => _questions[index]['correct_option'] = v), activeColor: Colors.green),
                Expanded(child: TextFormField(decoration: InputDecoration(hintText: 'Option ${oIndex + 1}', hintStyle: TextStyle(fontSize: 12, color: Colors.grey), border: InputBorder.none), style: DesignSystem.bodyMedium(color: null), onChanged: (v) => _questions[index]['options'][oIndex] = v)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  const _ModeChip({required this.label, required this.isSelected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? DesignSystem.primary : Colors.grey.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? DesignSystem.primary : Colors.transparent)),
        child: Text(label, style: DesignSystem.bodySmall(color: isSelected ? Colors.white : Colors.grey).copyWith(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5)),
      ),
    );
  }
}
