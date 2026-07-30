-- OHLC CONSISTENCY
SELECT COUNT(*) AS bad_rows
FROM trade_daily
WHERE
    [high] < [open]
    OR [high] < [close]
    OR [low] > [open]
    OR [low] > [close]
    OR [high] < [low];



-- check flat OHLC + volume
SELECT
    COUNT(*) AS flat_rows
FROM trade_daily
WHERE
    [high]=[close]
    AND [close]=[open]
    AND [open]=[low]
    AND [volume] > 0;


-- inspect the 46,978 problematic rows.
SELECT TOP 100
    symbol,
    [date],
    [open],
    [high],
    [low],
    [close],
    [volume]
FROM trade_daily
WHERE
    [high] < [open]
    OR [high] < [close]
    OR [low] > [open]
    OR [low] > [close]
    OR [high] < [low];



SELECT TOP 50
    symbol,
    [date],
    [open],
    [high],
    [low],
    [close],
    [volume]
FROM trade_daily
WHERE
    [high] + 0.01 < [open]
    OR [high] + 0.01 < [close]
    OR [low] - 0.01 > [open]
    OR [low] - 0.01 > [close]
    OR [high] + 0.01 < [low];





-- -99% returns

WITH returns AS
(
    SELECT
        symbol,
        [date],

        [close],

        LAG([close]) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS prev_close,

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

    FROM trade_daily

    WHERE
        [close] > 0
        AND [volume] > 0
)

SELECT TOP 100
    symbol,
    [date],
    prev_close,
    [close],
    return_pct
FROM returns
WHERE return_pct <= -90
ORDER BY return_pct;



-- checking extreme positive returns
WITH returns AS
(
    SELECT
        symbol,
        [date],

        [close],

        LAG([close]) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS prev_close,

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

    FROM trade_daily

    WHERE
        [close] > 0
        AND [volume] > 0
)

SELECT TOP 100
    symbol,
    [date],
    prev_close,
    [close],
    return_pct
FROM returns
WHERE return_pct >= 500
ORDER BY return_pct DESC;







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

    FROM trade_daily

    WHERE
        [close] > 0
        AND [volume] > 0
)

SELECT
    COUNT(*) AS total_rows,

    SUM(
        CASE
            WHEN ABS(return_pct) > 50
            THEN 1
            ELSE 0
        END
    ) AS bad_rows

FROM returns;



-- Data Validation Summary

-- 1. Removed rows with non-positive OHLC values.
-- 2. Identified a small number of OHLC consistency violations.
-- 3. Investigated extreme returns (>50%).
-- 4. Found Yahoo Finance adjustment artifacts causing temporary prices such as 0.001, 0.01 etc.
-- 5. Affected rows: 8,764 (~0.06% of dataset).
-- 6. All EDA analyses will use ABS(return_pct) <= 50.
-- 7. Dataset considered suitable for momentum and volume research.