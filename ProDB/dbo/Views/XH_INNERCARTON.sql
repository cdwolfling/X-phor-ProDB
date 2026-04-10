

/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
2025-12-28 JC: use dbo.ufn_YearWeekCode
*/
CREATE VIEW [dbo].[XH_INNERCARTON]
AS 
SELECT 
   DISTINCT f.Carton_ID_Inner,
   f.Sumqty,
   e.Project,
   e.PO,
   e.Supplier_Code,
   e.Material_PN,
   e.wekday,
   e.Lot_ID,
   e.pn,
   e.description1,
   e.PO + '-' + e.Supplier_Code + '-' + e.Material_PN + '-' + e.wekday + '-' + e.Lot_ID + '-' + e.Carton_ID_Inner + '-' + CAST(f.Sumqty AS VARCHAR(15)) AS QR_code
FROM 
(
    SELECT  
        a.Project,
        COALESCE(CASE WHEN a.PO_End = '/' THEN NULL ELSE a.PO_End END, a.PO) AS PO,
        b.Supplier_Code,
        b.Material_PN,
        dbo.ufn_YearWeekCode(a.Ship_date) AS wekday,
        a.Lot_ID,
        a.Wafer_ID,
        a.Box_ID,
        a.SHIP_QTY,
        a.pn,
        B.Description AS description1,
        a.Lot_ID + a.Wafer_ID + a.Box_ID AS LOTID_WAFERID_BOXID,
        a.Carton_ID_Inner
    FROM 
        Shipping_list a 
    LEFT JOIN 
        Custom_Information b 
        ON a.PN = b.pn 
        AND a.Customer_Code = b.customer_code
    WHERE 
        a.Ship_date >= CAST(GETDATE() AS DATE) -- 筛选今天和今天之后的记录
        AND a.Site = 'SH'
) AS e
LEFT JOIN 
(
    SELECT  
        SUM(ship_qty) AS Sumqty,
        Carton_ID_Inner
    FROM 
        Shipping_list a 
    LEFT JOIN 
        Custom_Information b 
        ON a.PN = b.pn 
        AND a.Customer_Code = b.customer_code 
    WHERE 
        a.Ship_date >= CAST(GETDATE() AS DATE) -- 筛选今天和今天之后的记录
        AND a.Site = 'SH'
    GROUP BY 
        Carton_ID_Inner 
) AS f
    ON e.Carton_ID_Inner = f.Carton_ID_Inner
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production]
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[XH_INNERCARTON] TO [Production]
    AS [dbo];

