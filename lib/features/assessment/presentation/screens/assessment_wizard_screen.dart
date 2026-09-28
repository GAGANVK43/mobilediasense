import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/health_card.dart';
import '../../data/models/assessment_model.dart';
import '../../../dashboard/presentation/providers/dashboard_provider.dart';
import '../../../prediction/presentation/providers/prediction_provider.dart';

class AssessmentWizardScreen extends ConsumerStatefulWidget {
  const AssessmentWizardScreen({super.key});

  @override
  ConsumerState<AssessmentWizardScreen> createState() => _AssessmentWizardScreenState();
}

class _AssessmentWizardScreenState extends ConsumerState<AssessmentWizardScreen> {
  int _currentStep = 1;
  bool _isLoading = false;

  // Step 1: Demographics & Profile
  late TextEditingController _ageCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _incomeCtrl;
  String _gender = 'Male';
  String _patientGroup = 'Urban';
  double _bmi = 24.5;

  // Step 2: Clinical & Metabolic Biomarkers
  late TextEditingController _glucoseCtrl;
  late TextEditingController _hba1cCtrl;
  late TextEditingController _bpCtrl;
  late TextEditingController _bmiCtrl;

  // Step 3: Diet, Activity & Lifestyle
  late TextEditingController _sugarCtrl;
  late TextEditingController _activityCtrl;
  late TextEditingController _fastFoodCtrl;
  late TextEditingController _sleepCtrl;
  String _familyHistory = 'No';

  @override
  void initState() {
    super.initState();
    _ageCtrl = TextEditingController(text: '35');
    _heightCtrl = TextEditingController(text: '170');
    _weightCtrl = TextEditingController(text: '70');
    _incomeCtrl = TextEditingController(text: '45000');

    _glucoseCtrl = TextEditingController(text: '105');
    _hba1cCtrl = TextEditingController(text: '5.7');
    _bpCtrl = TextEditingController(text: '120');
    _bmiCtrl = TextEditingController(text: '24.2');

    _sugarCtrl = TextEditingController(text: '25');
    _activityCtrl = TextEditingController(text: '1.5');
    _fastFoodCtrl = TextEditingController(text: '1');
    _sleepCtrl = TextEditingController(text: '7.5');

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
      final rounded = double.parse(calc.toStringAsFixed(1));
      setState(() {
        _bmi = rounded;
        _bmiCtrl.text = rounded.toString();
      });
    }
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _incomeCtrl.dispose();
    _glucoseCtrl.dispose();
    _hba1cCtrl.dispose();
    _bpCtrl.dispose();
    _bmiCtrl.dispose();
    _sugarCtrl.dispose();
    _activityCtrl.dispose();
    _fastFoodCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  bool _validateStep(int step) {
    if (step == 1) {
      final age = int.tryParse(_ageCtrl.text);
      if (age == null || age <= 0 || age > 120) {
        _showSnackbar('Please enter a valid age (1–120 yrs).', isError: true);
        return false;
      }
      final height = double.tryParse(_heightCtrl.text);
      if (height == null || height < 50 || height > 260) {
        _showSnackbar('Please enter a valid height in cm (50–260 cm).', isError: true);
        return false;
      }
      final weight = double.tryParse(_weightCtrl.text);
      if (weight == null || weight < 20 || weight > 300) {
        _showSnackbar('Please enter a valid weight in kg (20–300 kg).', isError: true);
        return false;
      }
    } else if (step == 2) {
      final glucose = double.tryParse(_glucoseCtrl.text);
      if (glucose == null || glucose < 40 || glucose > 500) {
        _showSnackbar('Please enter a valid Fasting Glucose (40–500 mg/dL).', isError: true);
        return false;
      }
      final hba1c = double.tryParse(_hba1cCtrl.text);
      if (hba1c == null || hba1c < 3.0 || hba1c > 20.0) {
        _showSnackbar('Please enter a valid HbA1c percentage (3.0–20.0%).', isError: true);
        return false;
      }
      final bp = double.tryParse(_bpCtrl.text);
      if (bp == null || bp < 50 || bp > 250) {
        _showSnackbar('Please enter a valid Blood Pressure (50–250 mmHg).', isError: true);
        return false;
      }
    } else if (step == 3) {
      final sugar = double.tryParse(_sugarCtrl.text);
      if (sugar == null || sugar < 0 || sugar > 400) {
        _showSnackbar('Please enter a valid Daily Sugar Intake (0–400 g).', isError: true);
        return false;
      }
      final activity = double.tryParse(_activityCtrl.text);
      if (activity == null || activity < 0 || activity > 24) {
        _showSnackbar('Please enter a valid Physical Activity (0–24 hrs/day).', isError: true);
        return false;
      }
      final sleep = double.tryParse(_sleepCtrl.text);
      if (sleep == null || sleep < 1 || sleep > 24) {
        _showSnackbar('Please enter valid Daily Sleep hours (1–24 hrs).', isError: true);
        return false;
      }
    }
    return true;
  }

  void _showSnackbar(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                msg,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.riskHigh : AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 90, left: 16, right: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleExecutePrediction() async {
    if (!_validateStep(3)) return;

    setState(() => _isLoading = true);
    _showSnackbar('🧠 Executing Indian Diabetes ML Inference...');

    try {
      final age = int.tryParse(_ageCtrl.text) ?? 35;
      final glucose = double.tryParse(_glucoseCtrl.text) ?? 105.0;
      final hba1c = double.tryParse(_hba1cCtrl.text) ?? 5.7;
      final bp = double.tryParse(_bpCtrl.text) ?? 120.0;
      final sugar = double.tryParse(_sugarCtrl.text) ?? 25.0;
      final activity = double.tryParse(_activityCtrl.text) ?? 1.5;
      final fastFood = double.tryParse(_fastFoodCtrl.text) ?? 1.0;
      final sleep = double.tryParse(_sleepCtrl.text) ?? 7.5;
      final income = double.tryParse(_incomeCtrl.text) ?? 45000.0;
      final familyHistoryVal = _familyHistory == 'Yes' ? 1.0 : 0.0;
      final currentMonth = DateTime.now().month.toDouble();

      final payload = {
        'patient_group': _patientGroup,
        'gender': _gender,
        'age': age,
        'bmi': _bmi,
        'blood_pressure': bp,
        'hba1c': hba1c,
        'fasting_glucose': glucose,
        'physical_activity_hours': activity,
        'daily_sugar_intake': sugar,
        'fast_food_frequency': fastFood,
        'sleep_hours': sleep,
        'family_history': familyHistoryVal,
        'monthly_income': income,
        'month': currentMonth,
        // Legacy compatibility
        'glucose': glucose,
        'pregnancies': _gender == 'Female' ? 1 : 0,
        'skin_thickness': 20.0,
        'insulin': 80.0,
        'diabetes_pedigree_function': _familyHistory == 'Yes' ? 0.85 : 0.15,
      };

      final predRepo = ref.read(predictionRepositoryProvider);
      final predResult = await predRepo.createPrediction(payload);

      if (mounted) {
        ref.invalidate(dashboardDataProvider);
        ref.invalidate(predictionHistoryProvider);
        _showSnackbar('✅ AI Risk Assessment Complete!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          context.pushReplacement('/prediction/result', extra: {
            'id': predResult.id,
            'assessment_id': predResult.assessmentId,
            'prediction': predResult.prediction,
            'risk_percentage': predResult.riskPercentage,
            'confidence': predResult.confidence,
            'recommendation': predResult.recommendation,
            'contributing_factors': predResult.contributingFactors.map((f) => {
              'factor': f.feature,
              'value': f.value,
              'impact': f.impact,
              'description': f.description,
            }).toList(),
          });
        }
      }
    } catch (e) {
      if (mounted) {
        String errMsg = e.toString().replaceAll('Exception: ', '').replaceAll('ApiException: ', '');
        if (errMsg.toLowerCase().contains('internal server error') || errMsg.toLowerCase().contains('500')) {
          errMsg = 'Health assessment service is temporarily unavailable. Please try again.';
        } else if (errMsg.toLowerCase().contains('socket') || errMsg.toLowerCase().contains('connection')) {
          errMsg = 'Unable to connect to server. Please check your network connection.';
        }
        _showSnackbar(errMsg, isError: true);
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
        title: const Text('AI Diabetes Health Screening'),
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
                      _buildStepIndicator(3, 'Habits & Predict'),
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
              Text('Step 1: Patient Demographics', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Regional demographics and physical metrics for BMI assessment.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Age (years) *',
                  controller: _ageCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 35',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Region / Setting', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderLight),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _patientGroup,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Urban', child: Text('Urban')),
                            DropdownMenuItem(value: 'Semi-Urban', child: Text('Semi-Urban')),
                            DropdownMenuItem(value: 'Rural', child: Text('Rural')),
                          ],
                          onChanged: (v) => setState(() => _patientGroup = v ?? 'Urban'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Monthly Income (₹)',
                  controller: _incomeCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 45000',
                  prefixIcon: const Icon(Icons.currency_rupee_rounded),
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
                  hint: 'e.g. 170',
                  prefixIcon: const Icon(Icons.height_rounded),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Weight (kg) *',
                  controller: _weightCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 70',
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
                        const Text('Body Mass Index (BMI)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(
                          _bmi < 18.5
                              ? 'Underweight (<18.5)'
                              : _bmi < 25.0
                                  ? 'Normal (18.5–24.9)'
                                  : _bmi < 30.0
                                      ? 'Overweight (25–29.9)'
                                      : 'Obese (>=30)',
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
                  '$_bmi kg/m²',
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primaryDark),
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
              Text('Step 2: Clinical Vitals & Lab Tests', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Core blood glucose and laboratory biomarkers.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'Fasting Blood Glucose (mg/dL) *',
            controller: _glucoseCtrl,
            keyboardType: TextInputType.number,
            hint: 'Normal: 70–99, Pre-diabetic: 100–125, Diabetic: >=126',
            prefixIcon: const Icon(Icons.bloodtype_outlined),
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'HbA1c Level (%) *',
                  controller: _hba1cCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: 'Normal: <5.7%, Diabetic: >=6.5%',
                  prefixIcon: const Icon(Icons.biotech_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Blood Pressure (mmHg) *',
                  controller: _bpCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 120 (Systolic)',
                  prefixIcon: const Icon(Icons.speed_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          AppTextField(
            label: 'BMI (kg/m²)',
            controller: _bmiCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hint: 'Normal: 18.5–24.9',
            prefixIcon: const Icon(Icons.accessibility_new_rounded),
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
              Text('Step 3: Lifestyle & Diet Habits', style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Daily dietary sugar, exercise, sleep, and genetic history.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondaryLight),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text('Family History of Diabetes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip('No Family History', _familyHistory == 'No', () => setState(() => _familyHistory = 'No')),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _buildChoiceChip('Positive (Yes)', _familyHistory == 'Yes', () => setState(() => _familyHistory = 'Yes')),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Daily Sugar Intake (grams) *',
                  controller: _sugarCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'WHO limit: <=25g/day',
                  prefixIcon: const Icon(Icons.cookie_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Physical Activity (hrs/day) *',
                  controller: _activityCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: 'e.g. 1.0 (Walk/Gym)',
                  prefixIcon: const Icon(Icons.fitness_center_outlined),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Fast Food (meals/week)',
                  controller: _fastFoodCtrl,
                  keyboardType: TextInputType.number,
                  hint: 'e.g. 1 or 2',
                  prefixIcon: const Icon(Icons.fastfood_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppTextField(
                  label: 'Daily Sleep (hours/night)',
                  controller: _sleepCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  hint: 'Optimal: 7–9 hrs',
                  prefixIcon: const Icon(Icons.bedtime_outlined),
                ),
              ),
            ],
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
