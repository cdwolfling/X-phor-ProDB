
/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/
 CREATE VIEW [dbo].[v_HS01LABEL_OUTTERCARTON] AS
SELECT 
    /* 基础信息字段 */
    e.Project,
    e.PO,
    b.Supplier_Code,
    b.Material_PN,
    e.Customer_Code,  -- 添加的客户代码字段
    
    /* 修正后的年周格式 */
    CAST(YEAR(e.Ship_date) AS VARCHAR) + 
    RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2) AS Weekday,
    
    /* 批次相关字段 */
    e.Carton_ID_Outter AS LOTID_WAFERID_BOXID,
    
    /* 发货数量（聚合逻辑优化）*/
    e.Total_Ship_Qty AS SHIP_QTY,
    
    /* 产品信息字段 */
    b.PN,
    e.Description,
    
    /* 复合标识字段 */
    b.Supplier_Code + '.' + e.Carton_ID_Outter AS [supplier_code.LOTID_WAFERID_BOXID],
    
    /* 日期字段 */
    CONVERT(VARCHAR, e.Ship_date, 23) AS [MFG date],
    
    /* 二维码生成字段 */
    (b.Supplier_Code + '$' + 
     b.Material_PN + '$' + 
     (b.Supplier_Code + '.' + e.Carton_ID_Outter) + '$' + 
     CAST(e.Total_Ship_Qty AS VARCHAR) + '$' + 
     CONVERT(VARCHAR, e.Ship_date, 23)
    ) AS [QR code]

FROM 
(
    SELECT  
        a.Project,
        COALESCE(NULLIF(a.PO_End, '/'), a.PO) AS PO,
        a.Carton_ID_Outter,
        a.Ship_Qty,
        a.Ship_date,
        a.pn,
        a.Customer_Code,
        'PIC\' + a.PN + '\BD' AS Description,
        a.Carton_ID_Outter AS GroupKey,
        ROW_NUMBER() OVER (
            PARTITION BY a.Carton_ID_Outter 
            ORDER BY a.Ship_date DESC
        ) AS rn,
        -- 预计算每个Carton_ID_Outter的总发货量
        SUM(a.Ship_Qty) OVER (PARTITION BY a.Carton_ID_Outter) AS Total_Ship_Qty
    FROM Shipping_list a 
    WHERE a.Customer_Code LIKE 'HS01%'  -- 筛选客户代码为HS01
      AND a.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天和之后的日期
      AND a.Site = 'SH'
) AS e

LEFT JOIN Custom_Information b
    ON e.pn = b.pn
    AND e.Customer_Code = b.Customer_Code

WHERE e.rn = 1  -- 保持最新记录过滤逻辑
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_HS01LABEL_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_HS01LABEL_OUTTERCARTON] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_HS01LABEL_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_HS01LABEL_OUTTERCARTON] TO [Production]
    AS [dbo];

