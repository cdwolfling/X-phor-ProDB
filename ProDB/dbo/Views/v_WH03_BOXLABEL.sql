



/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/

CREATE VIEW [dbo].[v_WH03_BOXLABEL] AS
SELECT 
    /* 基础物料信息 */
    b.Material_PN,  
    b.Description AS [Description],  -- 直接引用Custom_Information的Description字段
    e.pn AS PN,
    e.Customer_Code,  -- 添加客户代码列
    
    /* 新增字段：Carton_ID_Inner */
    e.Carton_ID_Inner,  -- 从Shipping_list表引入
    
    /* 批次标识组合 */
    (e.Lot_ID + e.Wafer_ID + e.Box_ID) AS LOTID_WAFERID_BOXID,
    
    /* 供应链信息 */
    b.Supplier_Code,
    e.PO,
    e.Ship_Qty AS [SHIP_QTY],
    
    /* 日期处理 */
    CONVERT(VARCHAR, e.Ship_date, 23) AS [MFG date],
    CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 3, e.Ship_date)), 23) AS [Exp date],
    
    /* 编码组合字段 */
    (b.Supplier_Code + e.Lot_ID ) AS supplier_code_LOTID,
    --(b.Supplier_Code + e.Lot_ID + e.Wafer_ID + e.Box_ID) AS supplier_code_LOTID,2025-8-4 修改前
    /* 二维码生成逻辑 */
    --(b.Supplier_Code + e.Lot_ID + e.Wafer_ID + e.Box_ID + '_' +   2025-8-4 修改前
	(b.Supplier_Code + e.Lot_ID + '_' + 
     b.Supplier_Code + '_' + 
     REPLACE(CONVERT(VARCHAR, e.Ship_date, 23), '-', '') + '_' + 
     REPLACE(CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 3, e.Ship_date)), 23), '-', '') + '_' + 
     b.Material_PN + '_' +  
     e.PO + '_' + 
     CAST(e.Ship_Qty AS VARCHAR)) AS [QR code]


FROM 
(
    SELECT  
        a.Project,
        COALESCE(CASE WHEN a.PO_End = '/' THEN NULL ELSE a.PO_End END, a.PO) AS PO,
        a.Ship_Qty,
        a.Ship_date,
        a.pn,
        a.Lot_ID,
        a.Wafer_ID,
        a.Box_ID,
        a.Carton_ID_Inner,  -- 新增字段
        a.Carton_ID_outter,
        a.Customer_Code,  -- 客户代码字段
        a.Customer_Code AS Customer_Code_Filter  -- 用于筛选的客户代码
    FROM Shipping_list a 
    WHERE a.Customer_Code LIKE 'WH03%'  -- 筛选客户代码为WH03
    AND a.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天及之后的日期
    AND a.Site = 'SH'
) AS e  

LEFT JOIN Custom_Information b  
    ON e.pn = b.pn  
    AND e.Customer_Code = b.Customer_Code  -- 关联客户代码
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_WH03_BOXLABEL] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_WH03_BOXLABEL] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_WH03_BOXLABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_WH03_BOXLABEL] TO [Production]
    AS [dbo];

