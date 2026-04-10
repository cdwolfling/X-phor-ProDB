

/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
2025-12-10 JC: Update datetime format
2025-11-27 JC: Fix QR_CODE
*/
CREATE VIEW [dbo].[v_SZ02NT02] AS
SELECT 
    /* 基础信息字段 */
    e.Project,                          
    e.PO,                               
    b.Supplier_Code,                    
    b.Material_PN,                      
    e.Customer_Code,  -- 添加的客户代码字段
    e.Carton_ID_Inner,  -- 新增的Carton_ID_Inner字段
    
    /* 新增字段：LOTID + Wafer_ID + Box_ID 直接拼接 */
    e.Lot_ID + e.Wafer_ID + e.Box_ID AS LOTID_WAFERID_BOXID,
    
    /* 日期格式化字段 */
    CAST(YEAR(e.Ship_date) AS VARCHAR(4)) + RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR(2)), 2) AS Weekday, 
    
    /* 原有字段保持不变 */
    e.Lot_ID AS LOTID,
    e.Wafer_ID + e.Box_ID AS WAFERID_BOXID,  
    e.Ship_Qty AS SHIP_QTY,             
    
    /* 固定产品名称 */
    'SiP' AS 产品名称,                           
    
    /* 描述字段 */
    b.Description AS Description,  
    
    /* 扩展日期字段 */
    --e.Ship_date AS MFG_date,  
    CONVERT(VARCHAR(MAX),e.Ship_date,112) AS MFG_date,
    
    /* 修改后流水号生成字段 - 按LOTID分组，从00001开始递增 */
    RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY e.Lot_ID  -- 按LOTID分组
        ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  -- 按LOTID_WAFERID_BOXID排序
    ) AS VARCHAR(5)), 5) AS SN,  

    /* 修改后二维码生成字段 */
    (b.Material_PN + '&' + 
     CAST(e.Ship_Qty AS VARCHAR) + '&' + 
     (e.Lot_ID + e.Wafer_ID + e.Box_ID) + '&' + 
     CONVERT(VARCHAR(8), e.Ship_date, 112) + '&' + 
     --CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(YEAR, 1, e.Ship_date)), 112) + '&' + 
     RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY e.Lot_ID  -- 按LOTID分组
        ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  -- 按LOTID_WAFERID_BOXID排序
    ) AS VARCHAR(5)), 5)  
    ) AS QR_CODE

FROM 
    Shipping_list e  
LEFT JOIN Custom_Information b  
    ON e.pn = b.pn  
    AND e.Customer_Code = b.Customer_Code
WHERE 
    e.Customer_Code LIKE 'SZ02%' OR  e.Customer_Code LIKE 'NT02%' -- 筛选客户代码为SZ02 或者 NT02
    AND e.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天和之后的日期
    AND e.Site = 'SH'
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ02NT02] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ02NT02] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ02NT02] TO [Production]
    AS [dbo];

