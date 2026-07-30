-- How much data do we have?
-- How many securities?
-- What is the date range?

-- Data overview
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT symbol) AS total_securities,
    MIN([date]) AS start_date,
    MAX([date]) AS end_date
FROM vw_trade_daily;

-- Any missing trading days?
-- Any abnormal volume spikes?
-- How many stocks trade daily?

-- Trading activity by day

SELECT
    [date],
    COUNT(DISTINCT symbol) AS securities_traded,
    SUM(volume) AS total_volume
FROM vw_trade_daily
GROUP BY [date]
ORDER BY [date];

-- Biggest one day gainers.
-- Any suspicious returns.
-- Understand return distribution.

-- Daily return calculation

WITH returns AS
(
    SELECT
        [date],
        symbol,
        [close],

        LAG([close]) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS prev_close

    FROM vw_trade_daily
)

SELECT TOP 100
    [date],
    symbol,

    ROUND(
        100.0 * ([close] - prev_close)
        / NULLIF(prev_close,0),
        2
    ) AS return_pct

FROM returns

WHERE prev_close IS NOT NULL
ORDER BY return_pct DESC;

-- check bad results
SELECT COUNT(*) AS bad_rows
FROM trade_daily
WHERE
    [open] <= 0
    OR [high] <= 0
    OR [low] <= 0
    OR [close] <= 0;

-- realistic results only
WITH returns AS
(
    SELECT
        [date],
        symbol,
        [close],

        LAG([close]) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS prev_close

    FROM vw_trade_daily
)

SELECT TOP 100
    [date],
    symbol,

    ROUND(
        100.0 * ([close] - prev_close)
        / NULLIF(prev_close,0),
        2
    ) AS return_pct

FROM returns

WHERE prev_close > 5
  AND [close] > 5
  AND ABS(
        100.0 * ([close] - prev_close)
        / NULLIF(prev_close,0)
      ) <= 50

ORDER BY return_pct DESC;

-- how many bad rows ??

SELECT
    COUNT(*) AS bad_rows
FROM trade_daily
WHERE [close] <= 0;

SELECT
    COUNT(DISTINCT symbol) AS bad_symbols
FROM vw_trade_daily
WHERE [close] <= 0;

-- Return distribution

WITH returns AS
(
    SELECT
        symbol,
        [date],

        100.0 *
        (
            [close]
            -
            LAG([close]) OVER
            (
                PARTITION BY symbol
                ORDER BY [date]
            )
        )
        /
        NULLIF(
            LAG([close]) OVER
            (
                PARTITION BY symbol
                ORDER BY [date]
            ),
            0
        ) AS return_pct

    FROM vw_trade_daily

    WHERE
        [close] > 0
        AND volume > 0
)

SELECT
    COUNT(*) AS observations,
    AVG(return_pct) AS avg_return,
    MIN(return_pct) AS min_return,
    MAX(return_pct) AS max_return
FROM returns
WHERE return_pct IS NOT NULL
  AND ABS(return_pct) <= 50;

-- Price distribution

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN [close] < 5 THEN 1
            ELSE 0
        END
    ) AS below_5,

    SUM(
        CASE
            WHEN [close] < 10 THEN 1
            ELSE 0
        END
    ) AS below_10,

    SUM(
        CASE
            WHEN [close] < 20 THEN 1
            ELSE 0
        END
    ) AS below_20

FROM vw_trade_daily

WHERE [close] > 0;

-- Zero volume rows

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN [volume] = 0 THEN 1
            ELSE 0
        END
    ) AS zero_volume_rows

FROM vw_trade_daily;

-- Active securities

SELECT
    COUNT(DISTINCT symbol) AS total_symbols,

    COUNT(
        DISTINCT CASE
            WHEN [volume] > 0
            THEN symbol
        END
    ) AS traded_symbols

FROM vw_trade_daily;

-- Dataset is largely healthy.

-- 7141 symbols available.
-- 7136 symbols have traded at least once.

-- Main data quality issues:
-- 38 symbols contain negative prices.
-- 18.7% rows have zero volume.
-- 40.8% rows have close price below ₹20.

-- Most active securities

SELECT TOP 20
    symbol,
    COUNT(*) AS trading_days
FROM vw_trade_daily
GROUP BY symbol
ORDER BY trading_days DESC;


SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT symbol) AS total_symbols,
    MIN([date]) AS start_date,
    MAX([date]) AS end_date
FROM trade_daily;

-- nse bse contribution
WITH nse_hist AS
(
    SELECT
        COUNT(*) AS rows
    FROM OPENROWSET(
        BULK 'Files/data/raw/nse_trade_hist/*.csv',
        FORMAT='CSV',
        PARSER_VERSION='2.0',
        HEADER_ROW = TRUE
    ) AS x
)
SELECT * FROM nse_hist;



SELECT TOP 20
    symbol,
    COUNT(*) AS trading_days
FROM trade_daily
GROUP BY symbol
ORDER BY trading_days DESC;



SELECT
    symbol,
    [date],
    [open],
    [high],
    [low],
    [close]
FROM [dbo].[trade_daily]
WHERE
    [open] < 0
    OR [high] < 0
    OR [low] < 0
    OR [close] < 0;