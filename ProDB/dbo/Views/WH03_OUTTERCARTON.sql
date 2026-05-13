


/*

Change Log:
2026-05-13 JC: add configurable Ship_date filter by view; use maintained ship date when available, otherwise keep today-and-after filter.
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/
CREATE   VIEW [dbo].[WH03_OUTTERCARTON] AS
SELECT 
    b.Material_PN, 
    b.Description AS [Description],
    e.pn AS PN,
    e.Customer_Code,  -- 添加客户代码列
    e.Carton_ID_Outter,
    --(b.Supplier_Code + e.Carton_ID_Outter) AS Supplier_Coder_Carton_ID_Outter,2025-8-4修改前
	(b.Supplier_Code + e.Lot_ID) AS Supplier_Coder_Carton_ID_Outter,
    (b.Supplier_Code + e.Lot_ID + '_' + 
     b.Supplier_Code + '_' + 
     REPLACE(CONVERT(VARCHAR, e.Ship_date, 23), '-', '') + '_' + 
     REPLACE(CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 3, e.Ship_date)), 23), '-', '') + '_' + 
     b.Material_PN + '_' +  
     e.PO + '_' + 
     CAST(f.Sumqty AS VARCHAR)) AS [QR code],
    e.PO,
    f.Sumqty AS [SHIP_QTY],
    CONVERT(VARCHAR, e.Ship_date, 23) AS [MFG date],
    CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 3, e.Ship_date)), 23) AS [Exp date],
    b.Supplier_Code
FROM 
(
    SELECT  
        a.Project,
        COALESCE(CASE WHEN a.PO_End = '/' THEN NULL ELSE a.PO_End END, a.PO) AS PO,
        a.Ship_Qty,
        a.Ship_date,
        a.pn,  -- 仅保留一次
        a.Lot_ID,
        a.Wafer_ID,
        a.Box_ID,
        a.Carton_ID_Outter,
        a.Customer_Code,
        ROW_NUMBER() OVER (
            PARTITION BY a.Carton_ID_Outter 
            ORDER BY a.Ship_date DESC
        ) AS rn
    FROM Shipping_list a 
    CROSS APPLY dbo.ufn_GetLabelViewShipDate('WH03_OUTTERCARTON') cfg
    WHERE a.Customer_Code LIKE 'WH03%'  -- 筛选客户代码为WH03
    AND (
        (cfg.ConfigShipDate IS NOT NULL AND a.Ship_date = cfg.ConfigShipDate)
        OR
        (cfg.ConfigShipDate IS NULL AND a.Ship_date >= CAST(GETDATE() AS DATE))
    )
    AND a.Site = 'SH'
) AS e
LEFT JOIN Custom_Information b 
    ON e.pn = b.pn 
    AND e.Customer_Code = b.Customer_Code
LEFT JOIN 
(
    SELECT  
        SUM(ship_qty) AS Sumqty,
        Carton_ID_Outter
    FROM Shipping_list
    CROSS APPLY dbo.ufn_GetLabelViewShipDate('WH03_OUTTERCARTON') cfg
    WHERE Customer_Code LIKE 'WH03%'  -- 筛选客户代码为WH03
    AND (
        (cfg.ConfigShipDate IS NOT NULL AND Ship_date = cfg.ConfigShipDate)
        OR
        (cfg.ConfigShipDate IS NULL AND Ship_date >= CAST(GETDATE() AS DATE))
    )
    AND Site = 'SH'
    GROUP BY Carton_ID_Outter
) AS f
    ON e.Carton_ID_Outter = f.Carton_ID_Outter
WHERE e.rn = 1;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[WH03_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[WH03_OUTTERCARTON] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[WH03_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[WH03_OUTTERCARTON] TO [Production]
    AS [dbo];

