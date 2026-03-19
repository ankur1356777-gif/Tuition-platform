import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/student_service.dart';
import '../../../core/theme/design_system.dart';
import '../../../core/theme/app_widgets.dart';

class TakeTestScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> test;
  const TakeTestScreen({super.key, required this.test});

  @override
  ConsumerState<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends ConsumerState<TakeTestScreen> {
  late Timer _timer;
  int _secondsRemaining = 0;
  final Map<int, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = (widget.test['duration_minutes'] ?? 60) * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _submitTest();
      }
    });
  }

  Future<void> _submitTest() async {
    if (_isSubmitting) return;
    _timer.cancel();
    setState(() => _isSubmitting = true);

    try {
      await ref.read(studentServiceProvider).submitTest(
        widget.test['id'],
        _selectedAnswers,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test submitted successfully!', style: DesignSystem.bodySmall(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting test: $e', style: DesignSystem.bodySmall(color: Colors.white)),
            backgroundColor: DesignSystem.error,
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.test['questions'] as List? ?? [];
    final minutes = (_secondsRemaining / 60).floor();
    final seconds = _secondsRemaining % 60;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await _showQuitDialog(context, isDark);
        return confirm ?? false;
      },
      child: Scaffold(
        backgroundColor: isDark ? DesignSystem.backgroundDark : const Color(0xFFF8FAFF),
        appBar: AppBar(
          title: Text(widget.test['title'] ?? 'Assessment', style: DesignSystem.heading3(color: null)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : DesignSystem.backgroundDark),
            onPressed: () => Navigator.maybePop(context),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _secondsRemaining < 60 ? DesignSystem.error.withOpacity(0.1) : DesignSystem.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: (_secondsRemaining < 60 ? DesignSystem.error : DesignSystem.primary).withOpacity(0.2)),
              ),
              child: Center(
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined, 
                      size: 16, 
                      color: _secondsRemaining < 60 ? DesignSystem.error : DesignSystem.primary
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$minutes:${seconds.toString().padLeft(2, "0")}',
                      style: DesignSystem.bodyMedium(
                        color: _secondsRemaining < 60 ? DesignSystem.error : DesignSystem.primary
                      ).copyWith(fontWeight: FontWeight.bold, fontFeatures: [const FontFeature.tabularFigures()]),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          child: Column(
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: questions.isEmpty ? 0 : _selectedAnswers.length / questions.length,
                backgroundColor: Colors.grey.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primary),
                minHeight: 4,
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                  itemCount: questions.length,
                  itemBuilder: (context, qIndex) {
                    final q = questions[qIndex];
                    final options = q['options'] as List? ?? [];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: PremiumCard(
                        glass: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${qIndex + 1}.',
                                  style: DesignSystem.bodyLarge(color: DesignSystem.primary).copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    q['text'] ?? 'No Question Content',
                                    style: DesignSystem.bodyLarge(color: null).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ...List.generate(options.length, (oIndex) {
                              final isSelected = _selectedAnswers[qIndex] == oIndex;
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedAnswers[qIndex] = oIndex),
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                        ? DesignSystem.primary.withOpacity(0.1) 
                                        : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.02)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isSelected ? DesignSystem.primary : Colors.transparent,
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected ? DesignSystem.primary : Colors.grey.withOpacity(0.5),
                                              width: 2,
                                            ),
                                          ),
                                          child: isSelected 
                                            ? Center(child: Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: DesignSystem.primary))) 
                                            : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Text(
                                            options[oIndex],
                                            style: DesignSystem.bodyMedium(
                                              color: isSelected ? DesignSystem.primary : null
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? DesignSystem.backgroundDark : Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))
            ],
          ),
          child: GradientButton(
            text: 'FINISH AND SUBMIT',
            onPressed: _isSubmitting ? null : _submitTest,
            loading: _isSubmitting,
            icon: Icons.check_circle_outline_rounded,
          ),
        ),
      ),
    );
  }

  Future<bool?> _showQuitDialog(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2E2E3E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Quit Assessment?', style: DesignSystem.heading3(color: null)),
        content: Text(
          'Your progress will be lost and this attempt will be invalidated. Are you sure you want to exit?',
          style: DesignSystem.bodySmall(color: Colors.grey),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('STAY', style: DesignSystem.bodyMedium(color: Colors.grey).copyWith(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: DesignSystem.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('QUIT TEST'),
          ),
        ],
      ),
    );
  }
}
