SELECT TOP 5
    symbol,
    [date],
    [close]
FROM trade_daily
WHERE symbol = 'TCS'
ORDER BY [date] DESC;


-- ============================================
-- VIEW : Investment Opportunities
-- ============================================

CREATE OR ALTER VIEW vw_investment_opportunities
AS

WITH latest_price AS
(
    SELECT
        symbol,
        [date],
        [close],
        ROW_NUMBER() OVER
        (
            PARTITION BY symbol
            ORDER BY [date] DESC
        ) AS rn
    FROM trade_daily
),

opportunities AS
(
    SELECT

        sm.symbol AS symbol,

        b.client_name,

        b.[date] AS deal_date,

        t.win_rate,

        b.price AS buy_price,

        lp.[close] AS current_price,

        ROUND(
            ((lp.[close] - b.price) * 100.0) / b.price,
            2
        ) AS difference_pct,

        sm.market_cap,

        sm.sector

    FROM bulk_daily b

    INNER JOIN vw_top_investors t
        ON b.client_name = t.client_name

    LEFT JOIN sec_master sm
        ON
        (
            TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
        )
        OR
        (
            TRY_CAST(b.symbol AS BIGINT) IS NULL
            AND b.symbol = sm.symbol
        )

    LEFT JOIN latest_price lp
        ON sm.symbol = lp.symbol
       AND lp.rn = 1

    WHERE
        b.deal_type = 'BUY'
        AND b.price IS NOT NULL
        AND b.price > 0
        AND t.total_deals >= 10
        AND t.win_rate >= 50
        AND b.[date] >= DATEADD(YEAR, -2, GETDATE())
)

SELECT
    symbol,
    client_name,
    deal_date,
    win_rate,
    buy_price,
    current_price,
    difference_pct,
    market_cap,
    sector
FROM opportunities
WHERE
    difference_pct BETWEEN -100 AND 300;



SELECT TOP 20 *
FROM vw_investment_opportunities;

SELECT
    COUNT(*) AS total_rows,
    COUNT(symbol) AS symbol_available,
    COUNT(current_price) AS current_price_available,
    COUNT(market_cap) AS market_cap_available
FROM vw_investment_opportunities;




SELECT
    COUNT(*) AS total_rows,
    COUNT(bse_security_code) AS bse_code_present
FROM sec_master;

SELECT
    COUNT(*) AS total_rows,
    COUNT(market_cap) AS market_cap_present
FROM sec_master;

SELECT
    COUNT(*) AS bulk_buy_rows,
    COUNT(sm.symbol) AS matched_symbol
FROM bulk_daily b
LEFT JOIN sec_master sm
    ON TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
WHERE b.deal_type = 'BUY';







SELECT
    SUM(CASE WHEN TRY_CAST(symbol AS BIGINT) IS NULL THEN 1 ELSE 0 END) AS non_numeric_symbols,
    SUM(CASE WHEN TRY_CAST(symbol AS BIGINT) IS NOT NULL THEN 1 ELSE 0 END) AS numeric_symbols
FROM bulk_daily
WHERE deal_type = 'BUY';



SELECT TOP 100
    symbol,
    COUNT(*) AS deals
FROM bulk_daily
WHERE deal_type = 'BUY'
GROUP BY symbol
ORDER BY deals DESC;



-- CHECK BULK DAILY

SELECT
    COUNT(*) AS matched_rows
FROM bulk_daily b

LEFT JOIN sec_master sm
ON
(
    TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
)
OR
(
    TRY_CAST(b.symbol AS BIGINT) IS NULL
    AND b.symbol = sm.symbol
)

WHERE b.deal_type='BUY';




-- anomalies detection in vw investment opportunities (null values)

SELECT DISTINCT
    b.symbol
FROM bulk_daily b
LEFT JOIN sec_master sm
ON
(
    TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
)
OR
(
    TRY_CAST(b.symbol AS BIGINT) IS NULL
    AND b.symbol = sm.symbol
)
WHERE
    sm.symbol IS NULL
    AND b.deal_type='BUY'
    AND b.date >= DATEADD(year,-1,GETDATE());


-- 1. Rights Entitlements (-RE, -RE1, -RE2)
SELECT
    COUNT(*) AS rights_issue_rows
FROM vw_investment_opportunities
WHERE symbol LIKE '%-RE%';



SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN symbol IS NULL THEN 1 ELSE 0 END) AS null_symbol,
    SUM(CASE WHEN current_price IS NULL THEN 1 ELSE 0 END) AS null_current_price,
    SUM(CASE WHEN market_cap IS NULL THEN 1 ELSE 0 END) AS null_market_cap,
    SUM(CASE WHEN sector IS NULL THEN 1 ELSE 0 END) AS null_sector,
    SUM(CASE WHEN symbol LIKE '%-RE%' THEN 1 ELSE 0 END) AS rights_issue_rows
FROM vw_investment_opportunities;



SELECT
    COUNT(*) AS completely_unmapped_rows
FROM vw_investment_opportunities
WHERE symbol IS NULL
  AND current_price IS NULL
  AND market_cap IS NULL;





SELECT
    client_name,
    deal_date,
    buy_price,
    symbol
FROM vw_investment_opportunities
WHERE symbol IS NULL
ORDER BY deal_date DESC;






SELECT DISTINCT
    b.symbol AS bulk_symbol,
    b.client_name,
    b.date,
    b.price
FROM bulk_daily b
LEFT JOIN sec_master sm
ON (
        TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
    )
    OR (
        TRY_CAST(b.symbol AS BIGINT) IS NULL
        AND b.symbol = sm.symbol
    )
WHERE
    sm.symbol IS NULL
    AND b.deal_type = 'BUY'
    AND b.price IS NOT NULL
    AND b.price > 0
    AND b.date >= DATEADD(year, -1, GETDATE())
ORDER BY b.date DESC;




SELECT
    b.symbol,
    COUNT(*) AS deals,
    MAX(sm.symbol) AS found_in_sec_master
FROM bulk_daily b
LEFT JOIN sec_master sm
ON (
        TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code
    )
    OR (
        TRY_CAST(b.symbol AS BIGINT) IS NULL
        AND b.symbol = sm.symbol
    )
WHERE
    b.deal_type = 'BUY'
    AND b.date >= DATEADD(year,-1,GETDATE())
GROUP BY b.symbol
HAVING MAX(sm.symbol) IS NULL
ORDER BY deals DESC;


SELECT *
FROM bulk_daily
WHERE client_name = 'VIVEK KANDA'
  AND [date] = '2026-05-25'
  AND price = 11.10;


SELECT *
FROM bulk_daily
WHERE client_name LIKE '%ICICI PRUDENTIAL MUTUAL FUND%';



SELECT *
FROM sec_master
WHERE bse_security_code = 538897;


SELECT
    client_name,
    deal_date,
    symbol,
    buy_price
FROM vw_investment_opportunities
WHERE client_name IN (
    -- 'ACME CAPITAL MARKET LIMITED',
    -- 'ALTIZEN VENTURES LLP',
    'GOLDMAN SACHS FUNDS - GOLDMAN SACHS INDIA EQUITY PORTFOLIO'
    -- 'ICICI PRUDENTIAL MUTUAL FUND',
    -- 'PASHUPATI CAPITA SER PVT LTD',
    -- 'UDAY R SHAH HUF',
    -- 'VISHAL MAHESH WAGHELA',
    -- 'VIVEK KANDA'
)
ORDER BY deal_date DESC;



SELECT TOP 20
    date,
    symbol,
    client_name,
    price
FROM bulk_daily
WHERE client_name = 'ACME CAPITAL MARKET LIMITED'
ORDER BY date DESC;



SELECT *
FROM sec_master
WHERE symbol = 'VOLERCAR';

SELECT
    symbol,
    market_cap
FROM sec_master
WHERE symbol = 'SHRINIWAS';