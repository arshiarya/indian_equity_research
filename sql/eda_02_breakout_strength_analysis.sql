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
    CASE
        WHEN return_pct >= 5  AND return_pct < 7  THEN '5%-7%'
        WHEN return_pct >= 7  AND return_pct < 10 THEN '7%-10%'
        WHEN return_pct >= 10 AND return_pct < 15 THEN '10%-15%'
        WHEN return_pct >= 15 THEN '15%+'
    END AS breakout_group,

    COUNT(*) AS events,

    AVG(future_5d_return)
        AS avg_future_5d_return

FROM events

WHERE
    return_pct >= 5
    AND ABS(return_pct) <= 50
    AND ABS(future_5d_return) <= 50
    AND future_5d_return IS NOT NULL

GROUP BY
    CASE
        WHEN return_pct >= 5  AND return_pct < 7  THEN '5%-7%'
        WHEN return_pct >= 7  AND return_pct < 10 THEN '7%-10%'
        WHEN return_pct >= 10 AND return_pct < 15 THEN '10%-15%'
        WHEN return_pct >= 15 THEN '15%+'
    END

ORDER BY
    MIN(return_pct);



SELECT
    symbol,
    [date],
    [open],
    [high],
    [low],
    [close]
FROM trade_daily
WHERE
    [open] < 0
    OR [high] < 0
    OR [low] < 0
    OR [close] < 0;