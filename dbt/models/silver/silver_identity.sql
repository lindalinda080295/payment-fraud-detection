-- Column selection rationale:
-- 1. Dropped any column with >10% nulls (see analyses/transactions_column_missingness_check.sql)
-- 2. Kept columns identified by the Kaggle IEEE-CIS community as most predictive
--    (TransactionAmt, ProductCD, card1-6, addr1-2, email domains, C1-C6, M1-M9)
-- 3. No additional low-null anonymized columns sampled from this table

SELECT
    TransactionID,
    id_01,id_02,
    id_12,id_13,id_14,id_15,id_16,id_17,id_18,id_19,id_28,id_29,id_35,
    id_36,id_37,id_38,
    id_31,
    DeviceType,
    DeviceInfo
    -- my kept identity columns
FROM {{ ref('bronze_identity') }}