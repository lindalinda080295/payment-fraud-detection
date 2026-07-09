# dbt Project — Card Fraud Detection Pipeline

This dbt project transforms raw IEEE-CIS card transaction data into an analysis-ready table using a bronze → silver → gold (medallion) architecture in BigQuery.

## Architecture

```
sources (raw_ieee)
  ├── train_transaction ─┐
  └── train_identity ────┤
                          ▼
            bronze_transaction, bronze_identity   (raw passthrough, 1:1 with source)
                          ▼
            silver_transaction, silver_identity    (narrowed column set — see below)
                          ▼
              gold_card_transactions                (joined, renamed, analytics-ready)
```

| Model | Materialization | Purpose |
|---|---|---|
| `bronze_transaction` | view | Raw passthrough of `train_transaction` |
| `bronze_identity` | view | Raw passthrough of `train_identity` |
| `silver_transaction` | view | Narrowed transaction columns (see methodology) |
| `silver_identity` | view | Narrowed identity columns (see methodology) |
| `gold_card_transactions` | table | Left join of silver layers on `TransactionID`, with all columns renamed to business-readable names |

## Column-narrowing methodology (silver layer)

The raw tables are wide — several hundred columns combined, many of them anonymized (`V1`...`V339`, `id_01`...`id_38`) with no public documentation of what they represent. Rather than carrying all of them forward, columns were narrowed using three rules:

1. **Dropped** any column with more than 10% missing values (see `analyses/transactions_column_missingness_check.sql` and `analyses/identity_column_missingness_check.sql` — these dynamically compute null rates across every column in each source table).
2. **Kept** the columns the Kaggle IEEE-CIS competition community has consistently identified as the most predictive and interpretable (e.g. `TransactionAmt`, `ProductCD`, `card1–card6`, `addr1–addr2`, `P_emaildomain`/`R_emaildomain`, `C1–C6`, `M1–M9`), since these have documented real-world meaning even where Kaggle didn't disclose exact definitions.
3. **Sampled** a small number of additional low-null-rate columns from the remaining anonymized fields (e.g. select `id_*` identity flags) to preserve some exploratory coverage beyond the "obvious" columns, in case they carry signal in later modeling phases.

This keeps the gold table wide enough to be useful for both EDA and modeling, without carrying forward columns that are mostly empty or undocumented noise.

## Tests

Defined in `models/gold/schema.yml`:
- `transaction_id`: `unique`, `not_null`
- `is_fraud`: `accepted_values` (`0`, `1`)

## Analyses

`analyses/` contains two dynamic missingness-check scripts (BigQuery scripting — `DECLARE`/`EXECUTE IMMEDIATE`) that pull the full column list from `INFORMATION_SCHEMA` and compute null rates for every column at once, rather than hardcoding column names. These were the basis for the silver-layer column decisions above. They aren't run automatically as part of `dbt run` — compile and run manually when re-evaluating column choices:

```bash
dbt compile --select transactions_column_missingness_check
# copy the compiled SQL from target/compiled/.../ and run in the BigQuery console
# or, if supported by your dbt version:
dbt show --select transactions_column_missingness_check
```

## Running the project

Requires a `GCP_PROJECT_ID` environment variable set locally (see the project root README for setup) and a `profiles.yml` with a valid BigQuery connection — neither is committed to this repo.

```bash
dbt run                                 # builds bronze → silver → gold in BigQuery
dbt test                                # runs schema tests
dbt docs generate && dbt docs serve     # generates and serves the lineage diagram
```
