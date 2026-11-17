Repository: https://github.com/kmnisha979/NoShowGuard-Capstone

# NoShowGuard — Clinic Appointment No-Show Analysis

## Project Overview

NoShowGuard analyses clinic appointment records to understand patient no-shows, identify high-risk appointments, and recommend operational actions to reduce missed visits.

The project combines Python data cleaning, MySQL analysis, machine learning, and Gemini-based classification of patient follow-up notes.

## Key Findings — Four-Part Summary

**Part 1 — Python Foundations:** Cleaned 1,020 raw appointment records into 990 usable appointments, including 218 no-shows (22.02%).

**Part 2 — SQL Analysis:** Appointments booked 31 or more days in advance had a 60.5% no-show rate (26 of 43 appointments).

**Part 3 — Machine Learning:** Logistic Regression was selected based on training cross-validation AUC (0.7737); it achieved test ROC-AUC of 0.7889, with a selected classification threshold of 0.35 and test recall of 57.14%.

**Part 4 — Generative AI:** Analysed 10 patient follow-up notes; 9 non-blank notes passed validation, and both notes classified as `forgot_or_no_reminder` belonged to appointments without a reminder sent.

## Business Recommendation

CareLoop Clinics should prioritise targeted reminder verification and proactive follow-up for appointments with elevated no-show risk, particularly those booked far in advance. Across 990 cleaned appointments, 218 were no-shows (22.02%), while appointments booked 31 or more days ahead had a 60.5% no-show rate. The selected Logistic Regression model achieved a test ROC-AUC of 0.7889; using the 0.35 threshold, it flagged 49 of 198 test appointments and identified 28 of the 49 actual no-shows (57.14% recall). The follow-up note analysis found that 5 of 10 appointments had no reminder sent, including both cases classified as forgotten appointments or missing reminders. A practical next step is to verify reminder delivery and prioritise outreach to higher-risk appointments, while monitoring staff calling capacity and measuring whether these interventions reduce no-shows.

## Selected Model

**Logistic Regression**

- Selection criterion: Highest training cross-validation ROC-AUC among the compared models
- Training cross-validation ROC-AUC: 0.7737
- Test ROC-AUC: 0.7889
- Classification threshold: 0.35
- Test recall: 57.14%
- Test precision: 57.14%
- Test appointments flagged for follow-up: 49 of 198

The threshold of 0.35 was chosen using training data because it provided a better precision-recall balance for identifying potential no-shows than the default threshold of 0.50.

## GenAI Prompt Evaluation

Gemini Flash was used to classify patient follow-up notes into predefined root-cause categories. Outputs were validated using Pydantic.

In a two-note comparison, the basic V1 prompt returned non-standard root-cause labels for both N007 and N009. The CRAFT-based V2 prompt returned allowed categories for both notes.

The CRAFT prompt is recommended for deployment because it better enforces consistent structured classifications. The comparison is illustrative because the N007 V2 result was generated using a different Flash model.

## Limitations

1. **Small qualitative sample:** Only 10 follow-up notes were analysed, so their root-cause distribution cannot be generalised to all clinic appointments.
2. **Potential data leakage:** Some cleaning statistics were calculated using the full dataset before the train/test split, which may make model performance estimates optimistic.
3. **Validation design:** The model was evaluated using one random train/test split rather than a time-based evaluation, so future operational performance remains uncertain.

## Project Files

- `01_ingest_clean.ipynb` — Data ingestion, validation, cleaning, feature engineering and exports
- `rejected_rows.json` — Rejected records
- `appointments_clean.csv` — Cleaned appointment dataset
- `clinics_enriched.csv` — Clinic data enriched with weather information
- `load_data.sql` — MySQL schema and data loading
- `02_queries.sql` — SQL analysis
- `03_model.ipynb` — Machine learning experiments and evaluation
- `test_risk_scores.csv` — Test-set risk predictions
- `04_genai.ipynb` — Gemini API classification and validation
- `notes_analysed.csv` — Structured follow-up note results
- `data/` — Three original source files

## Tools and Technologies

Python, Pandas, NumPy, scikit-learn, Pydantic, Google Gemini API, Google Colab, MySQL and GitHub.

## Data and Security

The repository contains the capstone datasets and generated outputs. The Gemini API key must not be committed to GitHub. API credentials are supplied at runtime rather than stored in source files.
