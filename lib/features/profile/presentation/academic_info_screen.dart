import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/profile_provider.dart';

class AcademicInfoScreen extends ConsumerStatefulWidget {
  const AcademicInfoScreen({super.key});

  @override
  ConsumerState<AcademicInfoScreen> createState() => _AcademicInfoScreenState();
}

class _AcademicInfoScreenState extends ConsumerState<AcademicInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _instController;
  String? _board;
  String? _passingYear;
  String? _examType;
  String? _groupType;
  bool _isLoading = false;

  final List<String> _boards = [
    'Dhaka',
    'Rajshahi',
    'Comilla',
    'Jessore',
    'Chittagong',
    'Barisal',
    'Sylhet',
    'Dinajpur',
    'Mymensingh',
    'Madrasah',
    'Technical',
  ];
  final List<String> _years = ['2023', '2024', '2025', '2026', '2027'];
  final List<String> _exams = ['HSC', 'SSC', 'Admission'];
  final List<String> _groups = ['Science', 'Arts', 'Commerce'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).value;
    _instController = TextEditingController(text: profile?.institution ?? '');
    _board = _boards.contains(profile?.board) ? profile?.board : null;
    _passingYear = _years.contains(profile?.passingYear)
        ? profile?.passingYear
        : null;
    _examType = _exams.contains(profile?.examType) ? profile?.examType : null;
    _groupType = _groups.contains(profile?.groupType)
        ? profile?.groupType
        : null;
  }

  @override
  void dispose() {
    _instController.dispose();
    super.dispose();
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(profileProvider.notifier)
          .updateProfile(
            institution: _instController.text.trim(),
            board: _board,
            passingYear: _passingYear,
            examType: _examType,
            groupType: _groupType,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Academic Info updated successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating info: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Academic Information',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _instController,
              decoration: _buildInputDecoration('Institution Name'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _board,
              decoration: _buildInputDecoration('Board'),
              items: _boards
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (val) => setState(() => _board = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _passingYear,
              decoration: _buildInputDecoration('Passing Year'),
              items: _years
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (val) => setState(() => _passingYear = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _examType,
              decoration: _buildInputDecoration('Exam Type'),
              items: _exams
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _examType = val),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _groupType,
              decoration: _buildInputDecoration('Group'),
              items: _groups
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (val) => setState(() => _groupType = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Academic Info',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
