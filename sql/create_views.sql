-- =====================================
-- vw_trade_daily
-- =====================================

CREATE OR ALTER VIEW vw_trade_daily AS
SELECT
    [date],
    symbol,
    [open],
    high,
    low,
    [close],
    volume
FROM trade_daily;

-- =====================================
-- vw_bulk_daily
-- =====================================

CREATE OR ALTER VIEW vw_bulk_daily AS
SELECT
    [date],
    symbol,
    security_name,
    client_name,
    deal_type,
    quantity,
    price,
    source
FROM bulk_daily;

-- =====================================
-- vw_block_daily
-- =====================================

CREATE OR ALTER VIEW vw_block_daily AS
SELECT
    [date],
    symbol,
    security_name,
    client_name,
    deal_type,
    quantity,
    price,
    source
FROM block_daily;

-- =====================================
-- vw_sec_master
-- =====================================

CREATE OR ALTER VIEW vw_sec_master AS
SELECT
    isin,
    symbol,
    company_name,
    bse_security_code,
    cmp,
    market_cap,
    sector,
    industry,
    face_value
FROM sec_master;

-- =====================================
-- vw_deals_daily
-- =====================================

CREATE OR ALTER VIEW vw_deals_daily AS

SELECT
    [date],
    symbol,
    security_name,
    client_name,
    deal_type,
    quantity,
    price,
    source,
    'BULK' AS deal_category
FROM bulk_daily

UNION ALL

SELECT
    [date],
    symbol,
    security_name,
    client_name,
    deal_type,
    quantity,
    price,
    source,
    'BLOCK' AS deal_category
FROM block_daily;