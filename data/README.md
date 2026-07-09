# Data — Sourcing & Provenance

## Source

This project uses the **IEEE-CIS Fraud Detection** dataset, originally released as part of a
2019 Kaggle competition hosted by the IEEE Computational Intelligence Society and Vesta
Corporation (a real-world payment processing company).

- Competition page: https://www.kaggle.com/c/ieee-fraud-detection
- Files used: `train_transaction.csv`, `train_identity.csv`
- Files **not** used: `test_transaction.csv`, `test_identity.csv` — these lack the `isFraud`
  label (withheld by Kaggle for leaderboard scoring), so they can't support labeled analysis.
  A train/test split was instead created from the labeled training data for this project.

## Why the raw data isn't included in this repository

Kaggle competition datasets are subject to competition-specific terms that generally
restrict redistribution. In addition, the raw files (~683MB combined, 394+ columns) are
impractical to host in a Git repository. For both reasons, raw and intermediate data files
are excluded from version control (see `.gitignore`), and this README documents how to
reproduce them instead.

## How to reproduce this dataset

1. Download `train_transaction.csv` and `train_identity.csv` from the Kaggle competition
   page above (requires a free Kaggle account).
2. Upload both files into a Google BigQuery dataset (via Cloud Storage staging, or direct
   upload for smaller files).
3. Clone the `dbt/` project in this repository and configure `profiles.yml` to point at your
   BigQuery project/dataset.
4. Run the pipeline:
   ```bash
   cd dbt
   dbt run
   dbt test
   ```
   This builds the bronze → silver → gold layers described below.
5. Export the resulting `gold_card_transactions` table to a local Parquet file (see the
   pipeline documentation for the exact query), and place it at `data/gold_card_transactions.parquet`.
   All analysis notebooks in this repo read from that local file.

## Pipeline summary (medallion architecture)

| Layer | Purpose | Materialization |
|---|---|---|
| **Bronze** | Thin pass-through of the two raw Kaggle tables, light type cleanup only | View |
| **Silver** | Narrowed to a working column set, selected via a missingness analysis (columns with excessive nulls and no clear business meaning were dropped) — see `dbt/analyses/column_missingness_check.sql` | View |
| **Gold** | Final joined, analysis-ready table (`silver_transaction` LEFT JOIN `silver_identity` on transaction ID), with columns renamed to clear, business-readable names | Table |

Identity data covers only a subset of transactions (identity collection was optional in the
original data), so identity-derived columns contain a substantial proportion of nulls by
design — this reflects a real operational constraint (not every channel captures the same
signals) rather than a data quality defect.

## Gold layer schema (`gold_card_transactions`)

| Column | Description |
|---|---|
| `is_fraud` | Target label: 1 = confirmed fraud, 0 = legitimate |
| `transaction_id` | Unique transaction identifier |
| `transaction_time_offset` | Time offset from a reference point (not a real timestamp) |
| `transaction_amount` | Transaction value |
| `product_code` | Product/service category code |
| `c1`–`c6` | Anonymized count features (e.g. addresses/devices associated with the card — exact definitions withheld by Vesta) |
| `match_flag_1`–`match_flag_9` | Anonymized match indicators (e.g. name/address/etc. matching between card and purchase — exact definitions withheld by Vesta) |
| `card_id_1`, `card_id_2`, `card_id_5` | Anonymized card identifiers |
| `card_country_code` | Card issuing country code |
| `card_network` | Card network (e.g. Visa, Mastercard) |
| `card_type` | Credit vs. debit |
| `billing_region_code`, `billing_country_code` | Billing address region/country |
| `payer_email_domain`, `recipient_email_domain` | Email domains of purchaser and recipient |
| `identity_score_1`, `identity_score_2` | Anonymized identity-related scores |
| `identity_found_flag`, `identity_category`, `identity_status` | Identity verification indicators |
| `timezone_offset` | Device timezone offset |
| `identity_match_flag`, `identity_record_status`, `identity_record_match` | Additional identity match indicators |
| `identity_flag_35`–`identity_flag_38` | Anonymized binary identity flags |
| `browser_version` | Browser/app version string |
| `device_type` | Desktop vs. mobile |
| `device_info` | Device/model description |

Columns prefixed with anonymized codes (`c*`, `match_flag_*`, `identity_flag_*`, identity
scores) were retained despite unclear individual business meaning because they showed
non-trivial predictive signal in early exploration; they are treated in the analysis as
"engineered risk signals" rather than interpreted individually.

## License note

This dataset is provided under Kaggle's competition rules and is intended for research/
educational use consistent with those terms. Users of this repository must obtain the data
directly from Kaggle and agree to those terms themselves.
