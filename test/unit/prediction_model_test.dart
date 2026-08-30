import 'package:flutter_test/flutter_test.dart';
import 'package:diasense_mobile/features/prediction/data/models/prediction_model.dart';

void main() {
  group('Prediction Models Unit Tests', () {
    test('PredictionResultModel parses risk and contributing factors', () {
      final json = {
        'id': 10,
        'assessment_id': 5,
        'prediction': 'Diabetic',
        'risk_percentage': 78.4,
        'confidence': 0.92,
        'recommendation': 'Consult an endocrinologist for clinical confirmation.',
        'contributing_factors': [
          {
            'feature': 'Glucose',
            'score': 0.85,
            'impact': 'High Impact',
            'description': 'Elevated plasma glucose reading.',
          },
          {
            'feature': 'BMI',
            'score': 0.60,
            'impact': 'Moderate Impact',
            'description': 'Elevated body mass index.',
          }
        ],
      };

      final result = PredictionResultModel.fromJson(json);
      expect(result.prediction, 'Diabetic');
      expect(result.riskPercentage, 78.4);
      expect(result.contributingFactors.length, 2);
      expect(result.contributingFactors.first.feature, 'Glucose');
      expect(result.contributingFactors.first.impact, 'High Impact');
    });
  });
}
