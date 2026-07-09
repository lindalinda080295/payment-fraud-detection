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