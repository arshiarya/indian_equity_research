SELECT TOP 10 *
FROM bulk_daily;



SELECT
    SUM(CASE WHEN date IS NULL THEN 1 ELSE 0 END) AS missing_date,
    SUM(CASE WHEN symbol IS NULL THEN 1 ELSE 0 END) AS missing_symbol,
    SUM(CASE WHEN client_name IS NULL THEN 1 ELSE 0 END) AS missing_client,
    SUM(CASE WHEN deal_type IS NULL THEN 1 ELSE 0 END) AS missing_type,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS missing_price
FROM bulk_daily;



SELECT
    source,
    COUNT(*) AS missing_price
FROM bulk_daily
WHERE price IS NULL AND [date]>'2020-1-1'
GROUP BY source;



SELECT
    deal_type,
    COUNT(*) AS deals
FROM bulk_daily
GROUP BY deal_type;



-- price 0
SELECT
    COUNT(*) AS invalid_price
FROM bulk_daily
WHERE price = 0;




-- dulplicates
SELECT
    date,
    symbol,
    client_name,
    deal_type,
    quantity,
    price,
    source,
    COUNT(*) AS cnt
FROM bulk_daily
GROUP BY
    date,
    symbol,
    client_name,
    deal_type,
    quantity,
    price,
    source
HAVING COUNT(*) > 1;

-- ////////////////////////////////////////////////////////////////////////
SELECT
    source,
    COUNT(*) AS missing_price
FROM bulk_daily
WHERE price IS NULL
GROUP BY source;