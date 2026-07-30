SELECT
    COUNT(*) AS buy_deals
FROM bulk_daily
WHERE
    deal_type = 'BUY'
    AND price IS NOT NULL
    AND date >= '2015-01-01';



SELECT TOP 100
    b.[date] AS deal_date,
    b.[symbol],
    b.[client_name],
    b.[price] AS buy_price,

    t.[date] AS future_date,
    t.[close] AS future_close

FROM [bulk_daily] b

CROSS APPLY
(
    SELECT TOP 1
        [date],
        [close]
    FROM [trade_daily] t
    WHERE
        t.[symbol] = b.[symbol]
        AND t.[date] >= DATEADD(DAY, 30, b.[date])
    ORDER BY t.[date]
) t

WHERE
    b.[deal_type] = 'BUY'
    AND b.[price] IS NOT NULL
    AND b.[date] >= '2015-01-01';



SELECT
    [date],
    [close]
FROM [trade_daily]
WHERE [symbol] = 'MITCON'
ORDER BY [date];




SELECT
    MIN([date]) AS min_date,
    MAX([date]) AS max_date,
    COUNT(*) AS rows
FROM [trade_daily]
WHERE [symbol] = 'MITCON';




SELECT
    MIN([date]) AS min_date,
    MAX([date]) AS max_date,
    COUNT(*) AS rows
FROM [trade_daily];



SELECT
    YEAR([date]) AS year,
    COUNT(*) AS rows
FROM [trade_daily]
GROUP BY YEAR([date])
ORDER BY year;



SELECT
    [symbol],
    MIN([date]) AS first_date,
    MAX([date]) AS last_date,
    COUNT(*) AS trading_days
FROM [trade_daily]
WHERE [symbol] = 'MITCON'
GROUP BY [symbol];




SELECT TOP 5 *
FROM [sec_master];

SELECT COUNT(*)
FROM sec_master
WHERE bse_security_code IS NOT NULL;





CREATE OR ALTER VIEW vw_investor_trade_performance
AS

WITH deals AS
(
    SELECT
        b.[date] AS deal_date,
        COALESCE(sm.[symbol], b.[symbol]) AS symbol,
        b.[client_name],
        b.[price] AS buy_price
    FROM bulk_daily b

    LEFT JOIN sec_master sm
        ON TRY_CAST(b.symbol AS BIGINT) = sm.bse_security_code

    WHERE
        b.[date] >= '2015-01-01'
        AND b.deal_type = 'BUY'
        AND b.price > 0
)

SELECT
    d.deal_date,
    d.symbol,
    d.client_name,
    d.buy_price,

    t.[date] AS future_date,
    t.[close] AS future_close,

    ROUND(
        ((t.[close]-d.buy_price)*100.0)/d.buy_price,
        2
    ) AS monthly_return_pct

FROM deals d

OUTER APPLY
(
    SELECT TOP (1)
        [date],
        [close]
    FROM trade_daily t
    WHERE
        t.symbol = d.symbol
        AND t.[date] >= DATEADD(day,30,d.deal_date)
        AND t.[date] <= DATEADD(day,45,d.deal_date)
    ORDER BY t.[date]
) t;




SELECT TOP 100 *
FROM vw_investor_trade_performance;



SELECT
    COUNT(*) AS total_rows,
    SUM(
        CASE
            WHEN monthly_return_pct BETWEEN -80 AND 300
            THEN 1
            ELSE 0
        END
    ) AS usable_rows
FROM vw_investor_trade_performance;




CREATE OR ALTER VIEW vw_investor_summary
AS

SELECT

    [client_name],

    COUNT(*) AS total_deals,

    ROUND(AVG(monthly_return_pct),2) AS avg_return_pct,

    SUM(
        CASE
            WHEN monthly_return_pct > 0
            THEN 1
            ELSE 0
        END
    ) AS profitable_deals,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN monthly_return_pct > 0
                THEN 1
                ELSE 0
            END
        )
        /
        COUNT(*),
        2
    ) AS win_rate,

    MIN(monthly_return_pct) AS worst_return,

    MAX(monthly_return_pct) AS best_return

FROM vw_investor_trade_performance

WHERE
    monthly_return_pct BETWEEN -80 AND 300

GROUP BY
    [client_name];





SELECT TOP 20 *
FROM vw_investor_summary
ORDER BY win_rate DESC;



SELECT
    CASE
        WHEN total_deals = 1 THEN '1'
        WHEN total_deals BETWEEN 2 AND 5 THEN '2-5'
        WHEN total_deals BETWEEN 6 AND 10 THEN '6-10'
        WHEN total_deals BETWEEN 11 AND 20 THEN '11-20'
        WHEN total_deals BETWEEN 21 AND 50 THEN '21-50'
        ELSE '50+'
    END AS deal_bucket,

    COUNT(*) AS investors



SELECT TOP 20
    client_name,
    total_deals,
    profitable_deals,
    win_rate,
    avg_return_pct
FROM vw_investor_summary
WHERE total_deals >= 20
ORDER BY
    win_rate DESC,
    avg_return_pct DESC;




SELECT TOP 5 *
FROM vw_investor_summary;



CREATE OR ALTER VIEW vw_top_investors
AS

WITH investor_returns AS
(
    SELECT
        client_name,
        monthly_return_pct
    FROM vw_investor_trade_performance
    WHERE
        monthly_return_pct IS NOT NULL
        AND monthly_return_pct BETWEEN -80 AND 300
)

SELECT
    client_name,

    COUNT(*) AS total_deals,

    SUM(
        CASE
            WHEN monthly_return_pct > 0 THEN 1
            ELSE 0
        END
    ) AS profitable_deals,

    ROUND(
        100.0 *
        SUM(
            CASE
                WHEN monthly_return_pct > 0 THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS win_rate,

    ROUND(AVG(monthly_return_pct),2) AS avg_return_pct,

    ROUND(
        AVG(
            CASE
                WHEN monthly_return_pct > 0
                THEN monthly_return_pct
            END
        ),
        2
    ) AS avg_gain,

    ROUND(
        AVG(
            CASE
                WHEN monthly_return_pct < 0
                THEN monthly_return_pct
            END
        ),
        2
    ) AS avg_loss,

    ROUND(MAX(monthly_return_pct),2) AS best_return,

    ROUND(MIN(monthly_return_pct),2) AS worst_return

FROM investor_returns

GROUP BY client_name

HAVING COUNT(*) >= 20;




SELECT TOP 20 *
FROM vw_top_investors
ORDER BY
    win_rate DESC,
    avg_return_pct DESC;_deals