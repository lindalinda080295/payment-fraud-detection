SELECT *
FROM {{ source('raw_ieee', 'train_identity') }}