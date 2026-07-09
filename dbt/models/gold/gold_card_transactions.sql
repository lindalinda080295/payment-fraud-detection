SELECT
    -- Target
    t.isFraud AS is_fraud,

    -- Transaction
    t.TransactionID AS transaction_id,
    t.TransactionDT AS transaction_time_offset,
    t.TransactionAmt AS transaction_amount,
    t.ProductCD AS product_code,

    -- Anonymous C Features
    t.C1 AS c1,
    t.C2 AS c2,
    t.C3 AS c3,
    t.C4 AS c4,
    t.C5 AS c5,
    t.C6 AS c6,

    -- Match Flags
    t.M1 AS match_flag_1,
    t.M2 AS match_flag_2,
    t.M3 AS match_flag_3,
    t.M4 AS match_flag_4,
    t.M5 AS match_flag_5,
    t.M6 AS match_flag_6,
    t.M7 AS match_flag_7,
    t.M8 AS match_flag_8,
    t.M9 AS match_flag_9,

    -- Card Information
    t.card1 AS card_id_1,
    t.card2 AS card_id_2,
    t.card3 AS card_country_code,
    t.card4 AS card_network,
    t.card5 AS card_id_5,
    t.card6 AS card_type,

    -- Billing Address
    t.addr1 AS billing_region_code,
    t.addr2 AS billing_country_code,

    -- Email
    t.P_emaildomain AS payer_email_domain,
    t.R_emaildomain AS recipient_email_domain,

    -- Identity Features
    i.id_01 AS identity_score_1,
    i.id_02 AS identity_score_2,
    i.id_12 AS identity_found_flag,
    i.id_13 AS identity_category,
    i.id_14 AS timezone_offset,
    i.id_15 AS identity_status,
    i.id_16 AS identity_match_flag,
    i.id_17 AS device_code_1,
    i.id_18 AS device_code_2,
    i.id_19 AS device_code_3,
    i.id_28 AS identity_record_status,
    i.id_29 AS identity_record_match,
    i.id_35 AS identity_flag_35,
    i.id_36 AS identity_flag_36,
    i.id_37 AS identity_flag_37,
    i.id_38 AS identity_flag_38,
    i.id_31 AS browser_version,

    -- Device
    i.DeviceType AS device_type,
    i.DeviceInfo AS device_info

FROM {{ ref('silver_transaction') }} t
LEFT JOIN {{ ref('silver_identity') }} i
    ON t.TransactionID = i.TransactionID