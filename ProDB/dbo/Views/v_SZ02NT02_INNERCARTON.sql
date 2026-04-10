

/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
2025-12-10 JC: Update datetime format
*/
CREATE VIEW [dbo].[v_SZ02NT02_INNERCARTON] AS
WITH RankedData AS (
    SELECT 
        /* 基础信息字段 */
        e.Project,                          
        e.PO,                               
        b.Supplier_Code,                    
        b.Material_PN,                      
        e.Customer_Code,  -- 添加的客户代码字段
        
        /* 修改为Carton_ID_Inner */
        e.Carton_ID_Inner,
        
        /* 日期格式化字段 */
        CAST(YEAR(e.Ship_date) AS VARCHAR(4)) + 
        RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR(2)), 2) AS Weekday,  
        
        /* 原有字段保持不变 */
        e.Lot_ID AS LOTID,
        e.Wafer_ID + e.Box_ID AS WAFERID_BOXID,  
        
        /* 修改为按Carton_ID_Inner聚合的发货数量 */
        SUM(e.Ship_Qty) OVER (PARTITION BY e.Carton_ID_Inner) AS SHIP_QTY,             
        
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
         CAST(SUM(e.Ship_Qty) OVER (PARTITION BY e.Carton_ID_Inner) AS VARCHAR) + '&' + 
         (e.Lot_ID + e.Wafer_ID + e.Box_ID) + '&' + 
         CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(YEAR, 1, e.Ship_date)), 112) + '&' + 
         RIGHT('00000' + CAST(ROW_NUMBER() OVER (
            PARTITION BY e.Lot_ID  -- 按LOTID分组
            ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  -- 按LOTID_WAFERID_BOXID排序
         ) AS VARCHAR(5)), 5)  
        ) AS QR_CODE,
        
        /* 供应商代码和Carton_ID_Inner的组合 */
        b.Supplier_Code + '.' + e.Carton_ID_Inner AS Supplier_Code_Carton_ID_Inner,
        
        /* 用于去重的行号 */
        ROW_NUMBER() OVER (
            PARTITION BY e.Carton_ID_Inner 
            ORDER BY e.Ship_date DESC
        ) AS rn,
        
        /* 原始LOTID_WAFERID_BOXID */
        e.Lot_ID + e.Wafer_ID + e.Box_ID AS LOTID_WAFERID_BOXID_Original
        
    FROM 
        Shipping_list e  
    LEFT JOIN Custom_Information b  
        ON e.pn = b.pn  
        AND e.Customer_Code = b.Customer_Code
    WHERE 
    

		e.Customer_Code LIKE 'SZ02%' OR  e.Customer_Code LIKE 'NT02%' -- 筛选客户代码为SZ02 或者 NT02
        AND e.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天和之后的日期
        AND e.Site = 'SH'
)

SELECT 
    /* 基础信息字段 */
    Project,
    PO,
    Supplier_Code,
    Material_PN,
    Customer_Code,  -- 包含客户代码列
    
    /* 使用Carton_ID_Inner */
    Carton_ID_Inner,
    
    /* 日期字段 */
    Weekday,
    
    /* 原始LOTID */
    LOTID,
    
    /* 原始WAFERID_BOXID */
    WAFERID_BOXID,
    
    /* 聚合后的SHIP_QTY */
    SHIP_QTY,
    
    /* 产品名称 */
    产品名称,
    
    /* 描述 */
    Description,
    
    /* MFG日期 - 保持为日期类型 */
    MFG_date,
    
    /* 修改后的SN - 按LOTID分组重新排序 */
    RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY LOTID 
        ORDER BY LOTID_WAFERID_BOXID_Original
    ) AS VARCHAR(5)), 5) AS SN,
    
    /* 修改后的二维码 - 确保所有部分都是字符串 */
    (Material_PN + '&' + 
     CAST(SHIP_QTY AS VARCHAR) + '&' + 
     LOTID_WAFERID_BOXID_Original + '&' + 
     CONVERT(VARCHAR(8), DATEADD(DAY, -1, DATEADD(YEAR, 1, MFG_date)), 112) + '&' + 
     RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY LOTID 
        ORDER BY LOTID_WAFERID_BOXID_Original
     ) AS VARCHAR(5)), 5)  
    ) AS QR_CODE,
    
    /* 供应商代码和Carton_ID_Inner的组合 */
    Supplier_Code_Carton_ID_Inner,
    
    /* 原始LOTID_WAFERID_BOXID */
    LOTID_WAFERID_BOXID_Original
    
FROM RankedData
WHERE rn = 1  -- 去重，只保留每个Carton_ID_Inner的最新记录
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ02NT02_INNERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ02NT02_INNERCARTON] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ02NT02_INNERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ02NT02_INNERCARTON] TO [Production]
    AS [dbo];

