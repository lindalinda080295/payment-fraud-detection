-- Column selection rationale:
-- 1. Dropped any column with >10% nulls (see analyses/transactions_column_missingness_check.sql)
-- 2. Kept columns identified by the Kaggle IEEE-CIS community as most predictive
--    (TransactionAmt, ProductCD, card1-6, addr1-2, email domains, C1-C6, M1-M9)
-- 3. No additional low-null anonymized columns sampled from this table


SELECT
    TransactionID,
    isFraud,
    TransactionDT,
    TransactionAmt,
    ProductCD,
    C1,C2,C3,C4,C5,C6,
    M1,M2,M3,M4,M5,M6,M7,M8,M9,
    card1,card2,card3, card4,card5,card6,
    addr1, addr2,
    P_emaildomain, R_emaildomain
    -- finalized kept-column list from the missingness check
FROM {{ ref('bronze_transaction') }}