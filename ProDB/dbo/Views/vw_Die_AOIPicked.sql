

/*
==========================================================================
视图名称：vw_Die_AOIPicked
业务用途：用于X_phor_TravelerHandlingService相关程序（Console/Service）
          筛选符合(被挑粒)条件的Die，找出效果图, 之后可用于找原图用于训图
SELECT * FROM dbo.vw_Die_AOIPicked

Change Log:
    2026-04-10 JC: ProductModel改为取'_'之前的值， 例如 CORAL3P1-A3_LExxxxx-W24-V12 AOI.xlsm
    2026-01-23 JC: 输出ProductModel为varchar(8)
    2026-01-19 JC: 排除已包装的数据
    2025-12-24 JC: 查(Traveler有变动的)3天内 的 AOI Defect
    2025-12-22 JC: 初始创建，优化SQL结构、性能及可读性
==========================================================================
*/
CREATE VIEW [dbo].[vw_Die_AOIPicked]
AS
SELECT CONVERT
    (
        varchar(20),
        LEFT
        (
            w.SourceName,
            CASE
                WHEN CHARINDEX('_', w.SourceName) > 0
                    THEN
                        CASE
                            WHEN CHARINDEX('_', w.SourceName) - 1 > 20 THEN 20
                            ELSE CHARINDEX('_', w.SourceName) - 1
                        END
                ELSE 20
            END
        )
    ) AS ProductModel, w.Wafer号, d.BoxNo, d.AOI_name, d.Cbin, d.Seqid
    FROM
    dbo.Wafer w
    INNER JOIN dbo.Die d ON w.Wafer号 = d.LotWafer
    INNER JOIN dbo.Die_AOIPicked p ON d.DieID = p.DieID
    WHERE w.FileModifiedTime >= DATEADD(DAY, -3, GETDATE())
    AND p.jpgPath IS NULL
    AND p.Udt <= DATEADD(hh, -1, GETDATE()) --为了不长期占用文件服务器I/O， 对同一个Die 1小时内不重复处理
    AND (
        w.包装开始时间 IS NULL
        OR w.包装开始时间 = '1899-12-31'
        --OR w.包装开始时间 >= DATEADD(DAY, -1, GETDATE()) --排除包装的热数据-->排除已包装的数据
    );