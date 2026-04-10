

/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
2025-12-28 JC: use dbo.ufn_YearWeekCode
*/
CREATE VIEW [dbo].[XH_BOXLABEL] AS 
SELECT TOP 100 PERCENT 
    Project,
    PO,
    supplier_code,
    Material_PN,
    weekday,
    Lot_ID, 
    Wafer_ID, 
    Box_ID, 
    SHIP_QTY,
    pn,
    description,
    PO + '-' + Supplier_Code + '-' + Material_PN + '-' + weekday + '-' + Lot_ID + '-' + Wafer_ID + Box_ID + '-' + CAST(Ship_Qty AS VARCHAR(15)) AS QR_code,
    LOTID_WAFERID_BOXID,
    Carton_ID_Inner
FROM (
    SELECT TOP 100 PERCENT
        a.Project,
        COALESCE(CASE WHEN PO_End = '/' THEN NULL ELSE PO_End END, PO) AS PO,
        b.supplier_code,
        b.Material_PN,
        dbo.ufn_YearWeekCode(a.Ship_date) AS weekday,
        Lot_ID, Wafer_ID, Box_ID, A.SHIP_QTY,
        a.pn,
       B.Description,
        Lot_ID + Wafer_ID + Box_ID AS LOTID_WAFERID_BOXID,
        Carton_ID_Inner
    FROM 
        Shipping_list a 
    LEFT JOIN 
        Custom_Information b 
    ON 
        a.PN = b.pn AND a.Customer_Code = b.customer_code
    WHERE 
        a.Ship_date >= CAST(GETDATE() AS DATE  ) -- 筛选今天和今天之后的记录
        AND a.Site = 'SH'
	ORDER BY Carton_ID_Inner ASC
)

AS subquery
ORDER BY  Carton_ID_Inner ;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production]
    WITH GRANT OPTION
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production]
    WITH GRANT OPTION
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[XH_BOXLABEL] TO [Production]
    AS [dbo];

