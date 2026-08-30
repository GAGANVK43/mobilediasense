import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';
import '../../data/models/assessment_model.dart';
import '../providers/assessment_wizard_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';

class AssessmentWizardScreen extends ConsumerStatefulWidget {
  const AssessmentWizardScreen({super.key});

  @override
  ConsumerState<AssessmentWizardScreen> createState() => _AssessmentWizardScreenState();
}

class _AssessmentWizardScreenState extends ConsumerState<AssessmentWizardScreen> {
  int _currentStep = 1;
  bool _isLoading = false;

  late TextEditingController _fullNameCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _glucoseCtrl;
  late TextEditingController _bpCtrl;
  late TextEditingController _insulinCtrl;
  late TextEditingController _skinCtrl;
  late TextEditingController _sleepCtrl;

  String _gender = 'Male';
  String _familyHistory = 'No';
  String _exerciseLevel = 'Regular';
  String _smoking = 'No';
  String _alcohol = 'No';
  double _bmi = 24.2;

  @override
  void initState() {
    super.initState();
    _fullNameCtrl = TextEditingController(text: '');
    _ageCtrl = TextEditingController(text: '35');
    _heightCtrl = TextEditingController(text: '170');
    _weightCtrl = TextEditingController(text: '70');
    _glucoseCtrl = TextEditingController(text: '115');
    _bpCtrl = TextEditingController(text: '75');
    _insulinCtrl = TextEditingController(text: '80');
    _skinCtrl = TextEditingController(text: '20');
    _sleepCtrl = TextEditingController(text: '7');

    _heightCtrl.addListener(_calculateBMI);
    _weightCtrl.addListener(_calculateBMI);
    _calculateBMI();
  }

  void _calculateBMI() {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    if (h > 0 && w > 0) {
      final hMeter = h / 100.0;
      final calc = w / (hMeter * hMeter);
      setState(() {
        _bmi = double.parse(calc.toStringAsFixed(1));
      });
    }
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _glucoseCtrl.dispose();
    _bpCtrl.dispose();
    _insulinCtrl.dispose();
    _skinCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    if (step == 1) {
      final age = int.tryParse(_ageCtrl.text);
      if (age == null || age <= 0 || age > 120) {
        _showSnackbar('Please enter a valid age (1-120 yrs).', isError: true);
        return false;
      }
      final height = double.tryParse(_heightCtrl.text);
      if (height == null || height <= 0) {
        _showSnackbar('Please enter a valid height in cm.', isError: true);
        return false;
      }
      final weight = double.tryParse(_weightCtrl.text);
      if (weight == null || weight <= 0) {
        _showSnackbar('Please enter a valid weight in kg.', isError: true);
        return false;
      }
    } else if (step == 2) {
      final glucose = double.tryParse(_glucoseCtrl.text);
      if (glucose == null || glucose <= 0) {
        _showSnackbar('Please enter a valid blood glucose level.', isError: true);
        return false;
      }
      final bp = double.tryParse(_bpCtrl.text);
      if (bp == null || bp <= 0) {
        _showSnackbar('Please enter a valid diastolic blood pressure.', isError: true);
        return false;
      }
    }
    return true;
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.riskHigh : AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleExecutePrediction() async {
    if (!_validateStep(3)) return;

    setState(() => _isLoading = true);
    _showSnackbar('🧠 Executing XGBoost ML Inference...');

    try {
      final dpf = _familyHistory == 'Yes' ? 0.85 : 0.15;
      final pregnancies = _gender == 'Female' ? 1 : 0;
      final glucose = double.tryParse(_glucoseCtrl.text) ?? 120.0;
      final bp = double.tryParse(_bpCtrl.text) ?? 70.0;
      final skin = double.tryParse(_skinCtrl.text) ?? 20.0;
      final insulin = double.tryParse(_insulinCtrl.text) ?? 80.0;
      final age = int.tryParse(_ageCtrl.text) ?? 30;

      final assessment = AssessmentModel(
        pregnancies: pregnancies,
        glucose: glucose,
        bloodPressure: bp,
        skinThickness: skin,
        insulin: insulin,
        bmi: _bmi,
        diabetesPedigreeFunction: dpf,
        age: age,
      );

      final repo = ref.read(assessmentRepositoryProvider);
      final result = await repo.createAssessment(assessment);

      if (mounted) {
        ref.invalidate(dashboardDataProvider);
        _showSnackbar('✅ AI Risk Assessment Complete!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pushReplacement('/prediction/result', extra: result);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Assessment'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              color: Colors.white,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepIndicator(1, 'Profile'),
                      _buildStepConnector(_currentStep >= 2),
                      _buildStepIndicator(2, 'Vitals'),
                      _buildStepConnector(_currentStep >= 3),
                      _buildStepIndicator(3, 'Lifestyle & Predict'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: _currentStep / 3.0,
                      minHeight: 5,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == 1) _buildStep1(),
                    if (_currentStep == 2) _buildStep2(),
                    if (_currentStep == 3) _buildStep3(),
                    const SizedBox(height: AppSpacing.lg),
                    const DisclaimerCard(),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 1)
                    Expanded(
                      flex: 1,
                      child: AppButton(
                        text: 'Back',
                        isOutlined: true,
                        onPressed: () => setState(() => _currentStep--),
                      ),
                    ),
                  if (_currentStep > 1) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _currentStep == 3 ? '🧠 Execute ML Inference' : 'Next Step →',
                      isLoading: _isLoading,
                      onPressed: () {
                        if (_currentStep < 3) {
                          if (_validateStep(_currentStep)) {
                            setState(() => _currentStep++);
                          }
                        } else {
                          _handleExecutePrediction();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int stepNum, String title) {
    final isActive = _currentStep == stepNum;
    final isDone = _currentStep > stepNum;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? AppColors.primary
                : isActive
                    ? AppColors.primaryLight
                    : AppColors.surfaceLight,
            border: Border.all(
              color: isActive || isDone ? AppColors.primary : AppColors.borderLight,
              width: 1.5,
            ),
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    stepNum.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppColors.textSecondaryLight,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppColors.textPrimaryLight : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: isActive ? AppColors.primary : AppColors.borderLight,
      ),
    );
  }

  Widget _buildStep1() {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Step 1: Personal Profile', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Demographics and physical metrics for BMI calculation.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Full Name',
            controller: _fullNameCtrl,
            hint: 'e.g. John Doe',
            prefixIcon: const Icon(Icons.badge_outlined),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Age (years) *',
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gender', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _gender,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Height (cm) *',
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.height_rounded),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Weight (kg) *',
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_weight_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calculate_outlined, color: AppColors.primary, size: 22),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Auto-Calculated BMI', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          _bmi < 18.5
                              ? 'Underweight'
                              : _bmi < 25.0
                                  ? 'Normal weight'
                                  : _bmi < 30.0
                                      ? 'Overweight'
                                      : 'Obese',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _bmi < 25.0 ? AppColors.riskLow : AppColors.riskModerate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  ' kg/m²',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.favorite_border_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Step 2: Medical Vitals', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Clinical laboratory values and vital measurements.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Blood Glucose (mg/dL) *',
            controller: _glucoseCtrl,
            keyboardType: TextInputType.number,
            hint: 'Fasting: 70-125, Post-meal: 120-180',
            prefixIcon: const Icon(Icons.bloodtype_outlined),
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Diastolic Blood Pressure (mmHg) *',
            controller: _bpCtrl,
            keyboardType: TextInputType.number,
            hint: 'Normal: 60-85 mmHg',
            prefixIcon: const Icon(Icons.speed_rounded),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Insulin (µU/mL)',
                  controller: _insulinCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'Normal: 15-276',
                  prefixIcon: const Icon(Icons.medication_liquid_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Skin Thickness (mm)',
                  controller: _skinCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'Triceps: 10-50',
                  prefixIcon: const Icon(Icons.straighten_outlined),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return HealthCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_run_rounded, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('Step 3: Lifestyle & Predict', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Family genetic background and daily lifestyle habits.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Family History of Diabetes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip('No', _familyHistory == 'No', () => setState(() => _familyHistory = 'No')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildChoiceChip('Yes', _familyHistory == 'Yes', () => setState(() => _familyHistory = 'Yes')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          const Text('Physical Activity Level', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.borderLight),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _exerciseLevel,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'None', child: Text('None (Sedentary)')),
                  DropdownMenuItem(value: 'Light', child: Text('Light (1-2 days/week)')),
                  DropdownMenuItem(value: 'Moderate', child: Text('Moderate (3-4 days/week)')),
                  DropdownMenuItem(value: 'Regular', child: Text('Regular (5+ days/week)')),
                  DropdownMenuItem(value: 'Athletic', child: Text('Athletic (Daily intense)')),
                ],
                onChanged: (v) => setState(() => _exerciseLevel = v ?? 'Regular'),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Smoking', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceChip('No', _smoking == 'No', () => setState(() => _smoking = 'No')),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildChoiceChip('Yes', _smoking == 'Yes', () => setState(() => _smoking = 'Yes')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alcohol', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceChip('No', _alcohol == 'No', () => setState(() => _alcohol = 'No')),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _buildChoiceChip('Yes', _alcohol == 'Yes', () => setState(() => _alcohol = 'Yes')),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'Daily Sleep (Hours)',
            controller: _sleepCtrl,
            keyboardType: TextInputType.number,
            hint: 'Recommended: 7-9 hours',
            prefixIcon: const Icon(Icons.bedtime_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }
}
