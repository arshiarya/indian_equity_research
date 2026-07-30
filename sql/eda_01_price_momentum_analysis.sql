-- When a stock gains more than 5% today,
-- what happens next?

-- Count momentum events
WITH base_data AS
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

        LEAD([close],1) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS close_1d

    FROM trade_daily

    WHERE
        [close] > 10
        AND [volume] > 0
),

events AS
(
    SELECT
        symbol,
        [date],

        100.0 *
        ([close] - prev_close)
        / NULLIF(prev_close,0)
        AS return_pct,

        100.0 *
        (close_1d - [close])
        / NULLIF([close],0)
        AS future_1d_return

    FROM base_data
)

SELECT
    COUNT(*) AS events,

    AVG(future_1d_return)
        AS avg_future_1d_return,

    MIN(future_1d_return)
        AS min_future_1d_return,

    MAX(future_1d_return)
        AS max_future_1d_return

FROM events

WHERE
    return_pct >= 5
    AND ABS(return_pct) <= 50
    AND ABS(future_1d_return) <= 50
    AND future_1d_return IS NOT NULL;






WITH base_data AS
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

        LEAD([close],5) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS close_5d

    FROM trade_daily

    WHERE
        [close] > 10
        AND [volume] > 0
),

events AS
(
    SELECT
        symbol,
        [date],

        100.0 *
        ([close] - prev_close)
        / NULLIF(prev_close,0)
        AS return_pct,

        100.0 *
        (close_5d - [close])
        / NULLIF([close],0)
        AS future_5d_return

    FROM base_data
)

SELECT
    COUNT(*) AS events,

    AVG(future_5d_return)
        AS avg_future_5d_return,

    MIN(future_5d_return)
        AS min_future_5d_return,

    MAX(future_5d_return)
        AS max_future_5d_return

FROM events

WHERE
    return_pct >= 5
    AND ABS(return_pct) <= 50
    AND ABS(future_5d_return) <= 50
    AND future_5d_return IS NOT NULL;








WITH base_data AS
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

        LEAD([close],10) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS close_10d

    FROM trade_daily

    WHERE
        [close] > 10
        AND [volume] > 0
),

events AS
(
    SELECT
        symbol,
        [date],

        100.0 *
        ([close] - prev_close)
        / NULLIF(prev_close,0)
        AS return_pct,

        100.0 *
        (close_10d - [close])
        / NULLIF([close],0)
        AS future_10d_return

    FROM base_data
)

SELECT
    COUNT(*) AS events,

    AVG(future_10d_return)
        AS avg_future_10d_return,

    MIN(future_10d_return)
        AS min_future_10d_return,

    MAX(future_10d_return)
        AS max_future_10d_return

FROM events

WHERE
    return_pct >= 5
    AND ABS(return_pct) <= 50
    AND ABS(future_10d_return) <= 50
    AND future_10d_return IS NOT NULL;








WITH base_data AS
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

        LEAD([close],20) OVER
        (
            PARTITION BY symbol
            ORDER BY [date]
        ) AS close_20d

    FROM trade_daily

    WHERE
        [close] > 10
        AND [volume] > 0
),

events AS
(
    SELECT
        symbol,
        [date],

        100.0 *
        ([close] - prev_close)
        / NULLIF(prev_close,0)
        AS return_pct,

        100.0 *
        (close_20d - [close])
        / NULLIF([close],0)
        AS future_20d_return

    FROM base_data
)

SELECT
    COUNT(*) AS events,

    AVG(future_20d_return)
        AS avg_future_20d_return,

    MIN(future_20d_return)
        AS min_future_20d_return,

    MAX(future_20d_return)
        AS max_future_20d_return

FROM events

WHERE
    return_pct >= 5
    AND ABS(return_pct) <= 50
    AND ABS(future_20d_return) <= 50
    AND future_20d_return IS NOT NULL;