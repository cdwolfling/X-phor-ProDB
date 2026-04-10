
/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/
CREATE VIEW [dbo].[v_SZ07LABEL] AS
SELECT 
    /* 基础信息字段 */
    e.Project,                          
    e.PO,                               
    b.Supplier_Code,                    
    b.Material_PN,                      
    e.Customer_Code,  -- 添加的客户代码字段
    e.Carton_ID_Inner,  -- 新增的Carton_ID_Inner字段
    
    /* 日期格式化字段 */
    CAST(YEAR(e.Ship_date) AS VARCHAR) + 
    RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2) AS Wekday,  
    
    /* 批次相关字段 */
    e.Lot_ID AS LOTID,                  
    e.Wafer_ID + e.Box_ID AS WAFERID_BOXID,  
    e.Ship_Qty AS SHIP_QTY,             
    
    /* 新增客户20250911需求的LOTID-SN拼接字段 */
    CONCAT(e.Lot_ID, '-', 
        RIGHT('00000' + CAST(ROW_NUMBER() OVER (
            PARTITION BY e.Lot_ID  
            ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  
        ) AS VARCHAR(5)), 5)
    ) AS [LOTID-SN],  -- 格式为LOTID-00001
    
    /* 产品信息字段 */
    e.PN,                               
    
    /* 固定格式字段 */
    'PIC\' + e.PN + '\BD' AS Description,  
    
    /* 扩展日期字段（修改点：日期改为无分隔符格式） */
    CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 1, e.Ship_date)), 112) AS EXP_date,  
    
    /* 新增SN字段（完全复用v_SZ02NT02的逻辑） */
    RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY e.Lot_ID  -- 按LOTID分组
        ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  -- 按LOTID_WAFERID_BOXID排序
    ) AS VARCHAR(5)), 5) AS SN,
    
    /* 流水号生成字段（保持原逻辑） */
    CONVERT(VARCHAR, e.Ship_date, 112) +  
    RIGHT('000000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY CONVERT(DATE, e.Ship_date) 
        ORDER BY e.Ship_Qty DESC  
    ) AS VARCHAR), 6) AS MFG_date_SN,

    /* 二维码生成字段（保持原逻辑） */
    (b.Material_PN + '-' + 
     CAST(e.Ship_Qty AS VARCHAR) + 'pcs-' +  
     b.Supplier_Code + '-' + 
     (CAST(YEAR(e.Ship_date) AS VARCHAR) + 
      RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2)) + '-' + 
     '外购-' + 
     e.PO + '-' + 
     CONVERT(VARCHAR, e.Ship_date, 112) +  
     RIGHT('000000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY CONVERT(DATE, e.Ship_date) 
        ORDER BY e.Ship_Qty DESC
    ) AS VARCHAR), 6)
    ) AS QR_CODE,
    
    /* 固定值字段 */
    '外购' AS [交易代码],
    'pcs' AS [数量单位]

FROM 
(
    SELECT  
        a.Project,
        a.PO,                            
        a.Ship_Qty,
        a.Ship_date,
        a.pn,
        a.Lot_ID,
        a.Wafer_ID,
        a.Box_ID,
        a.Customer_Code,
        a.Carton_ID_Inner  -- 从Shipping_list表中添加Carton_ID_Inner字段
    FROM Shipping_list a 
    WHERE 
        a.Customer_Code LIKE 'SZ07%'  -- 筛选客户代码为SZ07
        AND a.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天和之后的日期
        AND a.Site = 'SH'
) AS e  

LEFT JOIN Custom_Information b  
    ON e.pn = b.pn  
    AND e.Customer_Code = b.Customer_Code
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ07LABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ07LABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ07LABEL] TO [Production]
    AS [dbo];

