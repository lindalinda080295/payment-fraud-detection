DECLARE cols ARRAY<STRING>;
DECLARE agg_expr STRING;
DECLARE unpivot_list STRING;

-- Step 1: pull the column list automatically
SET cols = (
  SELECT ARRAY_AGG(column_name)
  FROM `{{ env_var('GCP_PROJECT_ID') }}.fraud_detection.INFORMATION_SCHEMA.COLUMNS`
  WHERE table_name = 'train_transaction'
);

-- Step 2: build one wide query that counts nulls for every column at once
SET agg_expr = (
  SELECT STRING_AGG(FORMAT('COUNTIF(`%s` IS NULL) AS `%s`', col, col), ', ')
  FROM UNNEST(cols) AS col
);

EXECUTE IMMEDIATE FORMAT("""
  CREATE OR REPLACE TEMP TABLE wide_nulls AS
  SELECT %s, COUNT(*) AS total_rows
  FROM `project-41ec398a-5c57-453b-84c.fraud_detection.train_transaction`
""", agg_expr);

-- Step 3: unpivot that single wide row into a readable tall table
SET unpivot_list = (
  SELECT STRING_AGG(FORMAT('`%s`', col), ', ')
  FROM UNNEST(cols) AS col
);

EXECUTE IMMEDIATE FORMAT("""
  SELECT column_name, null_count,
         ROUND(null_count / (SELECT total_rows FROM wide_nulls) * 100, 2) AS pct_missing
  FROM wide_nulls
  UNPIVOT(null_count FOR column_name IN (%s))
  ORDER BY pct_missing DESC
""", unpivot_list);