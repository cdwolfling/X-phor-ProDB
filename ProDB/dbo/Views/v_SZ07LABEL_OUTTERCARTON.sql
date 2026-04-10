
/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/
CREATE VIEW [dbo].[v_SZ07LABEL_OUTTERCARTON] AS
SELECT 
    /* 基础信息字段 */
    e.Project,
    e.PO,
    b.Supplier_Code,
    b.Material_PN,
    e.Customer_Code,  -- 添加的客户代码字段
    
    /* 日期格式化字段（保持原逻辑） */
    CAST(YEAR(e.Ship_date) AS VARCHAR) + 
    RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2) AS Wekday,
    
    /* 修改后的批次字段 */
    e.Carton_ID_Outter AS Carton_ID_Outter,  -- 原 LOTID 替换为 Carton_ID_Outter
    
    /* 新增SN字段（复用v_SZ07LABEL的逻辑） */
    RIGHT('00000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY e.Carton_ID_Outter  -- 按外箱ID分组（与v_SZ07LABEL的Lot_ID逻辑一致）
        ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  -- 按LOTID_WAFERID_BOXID排序（与v_SZ07LABEL一致）
    ) AS VARCHAR(5)), 5) AS SN,
    
    /* 新增LOTID-SN字段（复用v_SZ07LABEL的逻辑） */
    CONCAT(e.Carton_ID_Outter, '-', 
        RIGHT('00000' + CAST(ROW_NUMBER() OVER (
            PARTITION BY e.Carton_ID_Outter  
            ORDER BY e.Lot_ID + e.Wafer_ID + e.Box_ID  
        ) AS VARCHAR(5)), 5)
    ) AS [LOTID-SN],  -- 格式为Carton_ID_Outter-00001
    
    /* 聚合后的发货数量 */
    e.Total_Ship_Qty AS SHIP_QTY,
    
    /* 产品信息字段（保持原逻辑） */
    e.PN,
    
    /* 固定格式字段（保持原逻辑） */
    'PIC\' + e.PN + '\BD' AS Description,
    
    /* 扩展日期字段（保持原逻辑） */
    CONVERT(VARCHAR, DATEADD(DAY, -1, DATEADD(YEAR, 1, e.Ship_date)), 112) AS EXP_date,
    
    /* 修改后的流水号生成逻辑 */
    CONVERT(VARCHAR, e.Ship_date, 112) +  -- MFG_DATE 部分
    RIGHT('000000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY CONVERT(DATE, e.Ship_date) 
        ORDER BY e.Carton_ID_Outter  -- 按 Carton_ID_Outter 排序
    ) AS VARCHAR), 6) AS MFG_date_SN,
    
    /* 修改后的供应商代码组合字段 */
    b.Supplier_Code + '.' + e.Carton_ID_Outter AS [supplier_code.Carton_ID_Outter],
    
    /* 保持不变的二维码逻辑（仅调整字段引用） */
    (b.Material_PN + '-' + 
     CAST(e.Total_Ship_Qty AS VARCHAR) + 'pcs-' +  -- 使用聚合后的数量
     b.Supplier_Code + '-' + 
     (CAST(YEAR(e.Ship_date) AS VARCHAR) + 
      RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2)) + '-' + 
     '外购-' + 
     e.PO + '-' + 
     CONVERT(VARCHAR, e.Ship_date, 112) +  
     RIGHT('000000' + CAST(ROW_NUMBER() OVER (
        PARTITION BY CONVERT(DATE, e.Ship_date) 
        ORDER BY e.Carton_ID_Outter  -- 保持与流水号一致排序
    ) AS VARCHAR), 6)
    ) AS QR_CODE,
    
    /* 固定值字段（保持原逻辑） */
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
        a.Lot_ID,           -- 保留Lot_ID字段（用于SN生成）
        a.Wafer_ID,         -- 保留Wafer_ID字段（用于SN排序）
        a.Box_ID,           -- 保留Box_ID字段（用于SN排序）
        a.Carton_ID_Outter,  -- 替换 LOT_ID 为 Carton_ID_Outter
        a.Customer_Code,
        -- 聚合逻辑：按 Carton_ID_Outter 分组求和
        SUM(a.Ship_Qty) OVER (PARTITION BY a.Carton_ID_Outter) AS Total_Ship_Qty,
        -- 去重逻辑：按 Carton_ID_Outter 分组取最新记录
        ROW_NUMBER() OVER (
            PARTITION BY a.Carton_ID_Outter 
            ORDER BY a.Ship_date DESC
        ) AS rn
    FROM Shipping_list a 
    WHERE 
        a.Customer_Code LIKE 'SZ07%'  -- 筛选客户代码为SZ07
        AND a.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天和之后的日期
        AND a.Site = 'SH'
) AS e  

LEFT JOIN Custom_Information b  
    ON e.pn = b.pn  
    AND e.Customer_Code = b.Customer_Code

WHERE e.rn = 1  -- 按 Carton_ID_Outter 去重
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ07LABEL_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_SZ07LABEL_OUTTERCARTON] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ07LABEL_OUTTERCARTON] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_SZ07LABEL_OUTTERCARTON] TO [Production]
    AS [dbo];

