import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/disclaimer_card.dart';
import '../../../../core/widgets/health_card.dart';

class DietScreen extends ConsumerStatefulWidget {
  const DietScreen({super.key});

  @override
  ConsumerState<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends ConsumerState<DietScreen> {
  final List<String> _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String _selectedDay = 'Monday';
  bool _isVegetarian = true;

  // Daily Streak Habit Tracker
  int _streakCount = 3;
  bool _streakClaimed = false;
  bool _waterGoal = true;
  bool _stepGoal = true;
  bool _fiberGoal = false;
  bool _glucoseGoal = false;

  final Map<String, Map<String, String>> _weeklyMealsVeg = {
    'Monday': {
      'breakfast': 'Oats & Ragi Dosa (2 pcs) with Mint Chutney & Paneer Bhurji (GI < 45).',
      'lunch': 'Brown Rice/Quinoa (1 cup), Palak Dal, Cucumber & Tomato Salad, Plain Curd.',
      'dinner': 'Methi Roti (2 pcs), Grilled Tofu/Paneer with sautéed broccoli and clear vegetable soup.',
      'snacks': 'Roasted Makhana (Foxnuts) + Handful of Walnuts & Almonds + Green Tea.',
      'exercise': '45 minutes brisk walking + 15 min light yoga/pranayama.',
    },
    'Tuesday': {
      'breakfast': 'Sprouted Moong & Vegetable Cheela with flaxseed chutney & boiled chickpeas.',
      'lunch': 'Millet Roti (2 pcs), Bhindi Masala, Mixed Sprouts Salad, Buttermilk with roasted jeera.',
      'dinner': 'Quinoa vegetable khichdi with roasted papad and steamed beans.',
      'snacks': 'Guava slices / Green Apple with a spoon of peanut butter.',
      'exercise': '30 minutes cycling / stationary bike + 15 min core stretches.',
    },
    'Wednesday': {
      'breakfast': 'Vegetable Oats Upma loaded with peas, carrots, beans & chia seeds.',
      'lunch': 'Whole Wheat Roti (2), Lauki (Bottle Gourd) Curry, Yellow Moong Dal, Beetroot Salad.',
      'dinner': 'Paneer Tikka with bell peppers, onions, mint dip and a bowl of tomato soup.',
      'snacks': 'Boiled Kala Chana chaat with lemon, coriander & green chili.',
      'exercise': '40 minutes brisk walking + 10 min stair climbing.',
    },
    'Thursday': {
      'breakfast': 'Multi-grain bread avocado toast with crushed sesame seeds & sprouts.',
      'lunch': 'Barley / Brown Rice Bowl with Rajma, cabbage salad and curd.',
      'dinner': 'Mixed vegetable soup with steamed soya chunks and 1 bajra roti.',
      'snacks': 'Chia seed pudding with unsweetened almond milk and cinnamon.',
      'exercise': '30 minutes resistance training (dumbbells/bands) + 15 min stretch.',
    },
    'Friday': {
      'breakfast': 'Besan & Methi Cheela with curd and green coriander chutney.',
      'lunch': 'Jowar Roti (2), Baingan Bharta, Chana Dal, Cucumber Raita.',
      'dinner': 'Stir-fried tofu, broccoli, bell peppers with garlic ginger dressing.',
      'snacks': 'Pumpkin and sunflower seeds with cinnamon herbal tea.',
      'exercise': '45 minutes brisk walk in morning/evening outdoors.',
    },
    'Saturday': {
      'breakfast': 'Idli (2 pcs) with Sambar loaded with drumsticks & coconut mint chutney.',
      'lunch': 'Brown Rice Pulao with soya chunks, cucumber raita and sprouted salad.',
      'dinner': 'Vegetable Dal Dalia with roasted cumin seeds and green salad.',
      'snacks': 'Handful of roasted peanuts and roasted chana.',
      'exercise': '50 minutes outdoor jogging or recreational badminton.',
    },
    'Sunday': {
      'breakfast': 'Vegetable stuffed Roti (Paneer/Gobhi without butter) with curd.',
      'lunch': 'Quinoa Biryani with mixed vegetables, Dal Makhani (low butter), Beetroot Raita.',
      'dinner': 'Light Moong Dal Khichdi with kadhi and green beans.',
      'snacks': 'Berries (Blueberries/Strawberries) with unsalted mixed nuts.',
      'exercise': '60 minutes gentle yoga, breathing exercises, and meditation.',
    },
  };

  final Map<String, Map<String, String>> _weeklyMealsNonVeg = {
    'Monday': {
      'breakfast': '3 Egg White Omelet with spinach, mushrooms & 1 slice multigrain toast.',
      'lunch': 'Grilled Chicken Breast with quinoa, steamed broccoli, and avocado salad.',
      'dinner': 'Baked Salmon / Steamed Fish with asparagus and cauliflower mash.',
      'snacks': 'Boiled egg + Green Tea + Handful of raw almonds.',
      'exercise': '45 minutes brisk walking + 15 min upper body resistance training.',
    },
    'Tuesday': {
      'breakfast': 'Poached eggs on sautéed spinach with chia seeds and unsweetened tea.',
      'lunch': 'Chicken and Vegetable Stew with brown rice and leafy greens.',
      'dinner': 'Pan-seared Tilapia/Rohu fish with stir-fry zucchini and bell peppers.',
      'snacks': 'Walnuts and roasted pumpkin seeds + Black Coffee without sugar.',
      'exercise': '30 minutes cycling + 15 min core workouts.',
    },
    'Wednesday': {
      'breakfast': 'Egg Bhurji (2 eggs) with 1 whole wheat roti and sliced tomatoes.',
      'lunch': 'Grilled Fish Fillet with lemon butter garlic herbs, green salad and lentil soup.',
      'dinner': 'Chicken breast tikka with mint chutney and a bowl of clear chicken soup.',
      'snacks': 'Boiled chickpeas chaat with shredded chicken.',
      'exercise': '40 minutes brisk walking + 15 min bodyweight squats and lunges.',
    },
    'Thursday': {
      'breakfast': 'Oats cooked with unsweetened milk, topped with 2 boiled egg whites.',
      'lunch': 'Chicken and vegetable curry (low oil) with 2 multi-grain rotis and salad.',
      'dinner': 'Steamed Fish with sautéed green beans, broccoli, and clear mushroom soup.',
      'snacks': 'Handful of cashews and almonds + green tea.',
      'exercise': '30 minutes resistance band training + 15 min brisk walk.',
    },
    'Friday': {
      'breakfast': 'Scrambled eggs with bell peppers, onions, avocado and 1 bajra roti.',
      'lunch': 'Brown Rice (1 cup) with Fish Curry and steamed leafy salad.',
      'dinner': 'Tandoori Chicken breast (skinless) with raw cucumber salad and soup.',
      'snacks': 'Roasted sunflower seeds + Cinnamon tea.',
      'exercise': '45 minutes moderate jogging or brisk walking.',
    },
    'Saturday': {
      'breakfast': 'Omelet (1 whole, 2 whites) with mushroom, tomatoes and chia seeds.',
      'lunch': 'Grilled Chicken and Quinoa Salad with olive oil and lemon vinaigrette.',
      'dinner': 'Baked Salmon with steamed broccoli, lemon and pepper.',
      'snacks': 'Greek yogurt (unsweetened) with walnuts.',
      'exercise': '50 minutes swimming, cycling, or brisk outdoor walking.',
    },
    'Sunday': {
      'breakfast': 'Boiled eggs (2) with sliced avocado, cucumber and 1 slice rye toast.',
      'lunch': 'Chicken Biryani (made with Brown Rice & minimal oil) with cucumber raita.',
      'dinner': 'Light Chicken and Vegetable soup with 1 whole wheat phulka.',
      'snacks': 'Mixed berries with roasted flaxseeds.',
      'exercise': '60 minutes yoga, mobility stretching, and meditation.',
    },
  };

  void _claimStreak() {
    if (_streakClaimed) return;
    setState(() {
      _streakCount++;
      _streakClaimed = true;
      _waterGoal = true;
      _stepGoal = true;
      _fiberGoal = true;
      _glucoseGoal = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('🔥 Streak Upgraded to $_streakCount Days! Daily tasks completed! 🎉'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealMap = _isVegetarian ? _weeklyMealsVeg : _weeklyMealsNonVeg;
    final todayMeal = mealMap[_selectedDay] ?? mealMap['Monday']!;

    final completedCount = (_waterGoal ? 1 : 0) + (_stepGoal ? 1 : 0) + (_fiberGoal ? 1 : 0) + (_glucoseGoal ? 1 : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Diet & Lifestyle'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // 1. Streak Tracker Header Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 24)),
                          const SizedBox(width: 8),
                          Text(
                            '$_streakCount Day Health Streak',
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          '$completedCount/4 Done',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Complete your daily habits to maintain optimal glycemic control.',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // 4 Habit Checkboxes
                  _buildHabitRow('💧 3L Daily Water Intake', _waterGoal, (v) => setState(() => _waterGoal = v ?? false)),
                  _buildHabitRow('🚶 8,000 Steps Physical Activity', _stepGoal, (v) => setState(() => _stepGoal = v ?? false)),
                  _buildHabitRow('🥗 High-Fiber Leafy Greens', _fiberGoal, (v) => setState(() => _fiberGoal = v ?? false)),
                  _buildHabitRow('🩸 Blood Glucose Logged', _glucoseGoal, (v) => setState(() => _glucoseGoal = v ?? false)),

                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _streakClaimed ? null : _claimStreak,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF0F766E),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        _streakClaimed ? '✅ Today\'s Streak Claimed' : '🔥 Claim Daily Streak & Level Up',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Day Selector Tabs & Veg/Non-Veg Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Meal Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                Row(
                  children: [
                    Text(_isVegetarian ? '🥬 Veg' : '🍗 Non-Veg', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    Switch(
                      value: !_isVegetarian,
                      activeColor: const Color(0xFFE11D48),
                      inactiveThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _isVegetarian = !v),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),

            // Horizontal Day Pills
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _days.length,
                itemBuilder: (context, idx) {
                  final day = _days[idx];
                  final isSelected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.borderLight),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Meal Cards for Selected Day
            _buildMealCard('🌅 Breakfast (GI < 45)', todayMeal['breakfast']!, const Color(0xFFF59E0B), Icons.wb_sunny_outlined),
            const SizedBox(height: AppSpacing.sm),
            _buildMealCard('☀️ Lunch (Balanced Macros)', todayMeal['lunch']!, const Color(0xFF10B981), Icons.restaurant_rounded),
            const SizedBox(height: AppSpacing.sm),
            _buildMealCard('🌙 Dinner (Light & Low-Carb)', todayMeal['dinner']!, const Color(0xFF6366F1), Icons.nights_stay_outlined),
            const SizedBox(height: AppSpacing.sm),
            _buildMealCard('🍎 Healthy Snacks', todayMeal['snacks']!, const Color(0xFF0D9488), Icons.eco_outlined),
            const SizedBox(height: AppSpacing.sm),
            _buildMealCard('🏃 Exercise Target', todayMeal['exercise']!, const Color(0xFFEC4899), Icons.directions_run_rounded),
            const SizedBox(height: AppSpacing.lg),

            // 4. Macro Breakdown Card
            HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Optimal Macronutrient Distribution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _buildMacroBar('Carbs (Complex)', '45%', AppColors.primary, 0.45),
                      const SizedBox(width: 10),
                      _buildMacroBar('Protein', '25%', const Color(0xFF10B981), 0.25),
                      const SizedBox(width: 10),
                      _buildMacroBar('Healthy Fats', '30%', const Color(0xFFF59E0B), 0.30),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // 5. Foods to Eat & Foods to Avoid
            HealthCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Clinical Dietary Guidelines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: AppSpacing.sm),
                  _buildGuidelineItem(Icons.check_circle, Colors.green, 'Foods to Eat', 'Leafy greens, bitter gourd (karela), whole millets, chia seeds, walnuts, lean protein, Greek yogurt, cinnamon.'),
                  const SizedBox(height: AppSpacing.xs),
                  _buildGuidelineItem(Icons.cancel, Colors.red, 'Foods to Avoid', 'Refined sugar, white flour (maida), sweetened beverages, deep-fried snacks, processed meats, sweetened desserts.'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const DisclaimerCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitRow(String text, bool isChecked, ValueChanged<bool?> onChanged) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          activeColor: Colors.white,
          checkColor: const Color(0xFF0F766E),
          side: const BorderSide(color: Colors.white, width: 1.5),
          onChanged: _streakClaimed ? null : onChanged,
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              decoration: isChecked ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(String title, String content, Color accent, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent)),
                const SizedBox(height: 3),
                Text(content, style: const TextStyle(fontSize: 13, height: 1.4, color: AppColors.textPrimaryLight)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(String label, String pct, Color color, double val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              Text(pct, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: val,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidelineItem(IconData icon, Color color, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12.5, height: 1.4, color: AppColors.textPrimaryLight),
              children: [
                TextSpan(text: title + ': ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
