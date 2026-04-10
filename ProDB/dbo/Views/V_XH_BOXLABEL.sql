


/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
2025-12-28 JC: use dbo.ufn_YearWeekCode
*/
CREATE VIEW [dbo].[V_XH_BOXLABEL] AS 
SELECT 
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
    SELECT 
        a.Project,
        COALESCE(CASE WHEN PO_End = '/' THEN NULL ELSE PO_End END, PO) AS PO,
        b.supplier_code,
        Material_PN,
        dbo.ufn_YearWeekCode(a.Ship_date) AS weekday,
        Lot_ID, Wafer_ID, Box_ID, A.SHIP_QTY,
        a.pn,
        'PIC\' + a.PN + '\BD' AS description,
        Lot_ID + Wafer_ID + Box_ID AS LOTID_WAFERID_BOXID,
        Carton_ID_Inner
    FROM 
        Shipping_list a 
    LEFT JOIN 
        Custom_Information b 
    ON 
        a.PN = b.pn AND a.Customer_Code = b.customer_code
    WHERE 
        a.Ship_date >= CAST(GETDATE() AS DATE) -- 筛选今天和今天之后的记录
        AND a.Site = 'SH'
) AS subquery;