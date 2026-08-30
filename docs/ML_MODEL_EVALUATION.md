# DiaSense AI — Machine Learning Model Evaluation Report

## 1. Executive Summary & Clinical Assessment
In accordance with Engineering Rules 2, 3, and 13, all metric overrides and synthetic dataset shortcuts have been removed. The XGBoost classifier was trained and evaluated strictly on the authentic 768-sample NIDDK Pima Indians Diabetes Dataset using a stratified 80/20 train-test split and 5-fold cross-validation.

## 2. Performance Metrics (Authentic Held-out Test Set)

| Metric | Value | Clinical Interpretation |
|---|---|---|
| **Accuracy** | **74.03%** | Overall correct classification on unseen real patient data |
| **Precision** | **60.61%** | Positive predictive value for elevated risk |
| **Recall / Sensitivity** | **74.07%** | **High sensitivity** — detects 74.07% of true positive diabetes risk profiles |
| **Specificity** | **74.00%** | True negative rate on healthy individuals |
| **F1-Score** | **0.6667** | Balanced harmonic mean of precision and sensitivity |
| **ROC-AUC Index** | **0.8187** | Strong discrimination ability between risk tiers |
| **5-Fold Cross Validation** | **74.10% ± 2.40%** | Stable generalization across subsets |

## 3. Analysis: Why the 90% Target is Not Honestly Achievable on Real Pima Data
- **Clinical Dataset Limitation**: The authentic Pima dataset contains 768 records with natural physiological noise and unmeasured confounding factors (e.g., HbA1c, fasting duration, diet). In peer-reviewed biomedical literature, single non-invasive models on this dataset typically achieve 72%–78% accuracy.
- **Patient Safety Priority**: High sensitivity (74.07% Recall) is prioritized to minimize false negatives in preventive healthcare screening.
