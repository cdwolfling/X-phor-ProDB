

/*

Change Log:
2026-02-07 JC: add Site='SH' filter for SH site label printing
*/
 
CREATE VIEW [dbo].[v_HS01LABEL] AS
SELECT 
    /* 基础信息字段 */
    e.Project,                          -- 直接取自Shipping_list
    e.PO,                               -- 处理后的采购订单号
    b.Supplier_Code,                    -- 供应商代码
    b.Material_PN,                      -- 物料编号
    e.Customer_Code,                    -- 添加的客户代码字段
    -- 修改后的年周格式，去除了'W'字符
    CAST(YEAR(e.Ship_date) AS VARCHAR) + 
    RIGHT('0' + CAST(DATEPART(WEEK, e.Ship_date) AS VARCHAR), 2) AS Wekday,  -- 年周格式日期（YYYYXX）
    
    /* 批次相关字段 */
    e.Lot_ID AS LOTID,                  -- 批次ID
    e.Wafer_ID + e.Box_ID AS WAFERID_BOXID,  -- 修改点：去掉下划线直接拼接
    e.Ship_Qty AS SHIP_QTY,             -- 发货数量
    e.LOTID_WAFERID_BOXID,              -- 复合批次标识
    e.Carton_ID_Inner,                  -- 新增的Carton_ID_Inner字段
    
    /* 产品信息字段 */
    b.PN,                               -- 产品编号
    e.Description,                      -- 固定格式描述
    
    /* 复合标识字段 */
    b.Supplier_Code + '.' + e.LOTID_WAFERID_BOXID AS [supplier_code.LOTID_WAFERID_BOXID],  -- 供应商+批次组合码
    
    /* 日期字段 */
    CONVERT(VARCHAR, e.Ship_date, 23) AS [MFG date],  -- 生产日期（YYYY-MM-DD）
    
    /* 二维码生成字段 */
    (b.Supplier_Code + '$' + 
     b.Material_PN + '$' + 
     (b.Supplier_Code + '.' + e.LOTID_WAFERID_BOXID) + '$' + 
     CAST(e.Ship_Qty AS VARCHAR) + '$' + 
     CONVERT(VARCHAR, e.Ship_date, 23)  -- 修改点：移除REPLACE函数保留日期分隔符
    ) AS [QR code]  -- 二维码字符串
 
FROM 
(
    /* 子查询e：基础数据准备 */
    SELECT  
        a.Project,
        -- PO号处理逻辑：优先使用PO_End，若为'/'则回退到PO字段
        COALESCE(NULLIF(a.PO_End, '/'), a.PO) AS PO,
        a.Ship_Qty,
        a.Ship_date,
        a.pn,
        a.Lot_ID,
        a.Wafer_ID,
        a.Box_ID,
        a.Customer_Code,
        a.Carton_ID_Inner,                -- 新增的Carton_ID_Inner字段
        
        -- 复合批次标识（LOTID+WAFFERID+BOXID）
        a.Lot_ID + a.Wafer_ID + a.Box_ID AS LOTID_WAFERID_BOXID,
        
        -- 固定描述格式（PIC\PN\BD）
        'PIC\' + a.PN + '\BD' AS Description
        
    FROM Shipping_list a 
    WHERE a.Customer_Code LIKE 'HS01%'  -- 筛选客户代码为HS01
    AND a.Ship_date >= CAST(GETDATE() AS DATE)  -- 筛选今天及之后的日期
    AND a.Site = 'SH'
) AS e  -- 别名为e的子查询
 
LEFT JOIN Custom_Information b  -- 左连接供应商信息表
    ON e.pn = b.pn  -- 连接条件：产品编号匹配
    AND e.Customer_Code = b.Customer_Code
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[v_HS01LABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_HS01LABEL] TO [Production1]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[v_HS01LABEL] TO [Production]
    AS [dbo];

