/*
Create by Jackiech on 2026-04-01

-- 单颗查询
SELECT dbo.ufn_GetChipBin_FromCPData_Coral6p0('LN41477-W01', 'E07-403') AS Bin

-- 整片 Wafer 批量出 Bin 结果
SELECT
    ChipSN,
    dbo.ufn_GetChipBin_FromCPData_Coral6p0(LotWafer, ChipSN) AS Bin
FROM dbo.vw_CPTestData_Coral6p0
WHERE LotWafer = 'LN41477-W01'
ORDER BY ChipSN

-- 统计各 Bin 数量与良率
SELECT
    Bin,
    COUNT(*) AS cnt,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS pct
FROM (
    SELECT dbo.ufn_GetChipBin_FromCPData_Coral6p0(LotWafer, ChipSN) AS Bin
    FROM dbo.vw_CPTestData_Coral6p0
    WHERE LotWafer = 'LN41477-W01'
) t
GROUP BY Bin
ORDER BY Bin

TODO: Coral6p0以外产品是适配， 测试

Change Log:
2026-04-09 JC: 无测试结果， 返回0； 无部分测试项， 返回2
2026-04-02 JC: 使用dbo.LotWafer_UEC_Mean_Std 取代 ufn_GetUEC_Bounds/ufn_GetUEC_Mean_Std/dbo.LotWafer_UEC_Data
2026-04-01 JC: (临时)使用dbo.LotWafer_UEC_Data 取代 ufn_GetUEC_Bounds
*/
CREATE   FUNCTION [dbo].[ufn_GetChipBin_FromCPData_Coral6p0]
(
    @LotWafer  NVARCHAR(50),
    @ChipSN    NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @Bin INT = 2  -- 默认 Bin2（兜底）

    -- =============================================
    -- 1. Spec 参数（替换为从配置表动态读取）
    -- =============================================
    DECLARE @ProductFamily      NVARCHAR(50)

    select @ProductFamily=left(w.SourceName,8) from dbo.Wafer w where w.Wafer号=@LotWafer

    DECLARE @uec_low            FLOAT
    DECLARE @uec_high           FLOAT
    DECLARE @std_multiplier     FLOAT
    DECLARE @loss_low           FLOAT
    DECLARE @loss_high          FLOAT
    DECLARE @loss_range_high    FLOAT
    DECLARE @ompd_range_high    FLOAT
    DECLARE @mpdm_mpds_dev      FLOAT
    DECLARE @er_low             FLOAT
    DECLARE @ppi_low            FLOAT
    DECLARE @ppi_high           FLOAT
    DECLARE @ht_low             FLOAT
    DECLARE @ht_high            FLOAT
    DECLARE @dc_low             FLOAT
    DECLARE @dc_high            FLOAT
    DECLARE @mpd_loss_low       FLOAT
    DECLARE @mpd_loss_high      FLOAT
    DECLARE @mpd_loss_range     FLOAT

    SELECT
        @uec_low         = MAX(CASE WHEN v.ParameterKey = 'uec_onchip_low'          THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @uec_high        = MAX(CASE WHEN v.ParameterKey = 'uec_conchip_high'        THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @std_multiplier  = MAX(CASE WHEN v.ParameterKey = 'uec_onchip_std'          THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @loss_low        = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_optical_low' THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @loss_high       = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_optical_high'THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @loss_range_high = MAX(CASE WHEN v.ParameterKey = 'loss_range_high'         THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @ompd_range_high = MAX(CASE WHEN v.ParameterKey = 'ompd_range_high'         THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @mpdm_mpds_dev   = MAX(CASE WHEN v.ParameterKey = 'mpdm_mpds_dev'           THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @er_low          = MAX(CASE WHEN v.ParameterKey = 'ER_low'                  THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @ppi_low         = MAX(CASE WHEN v.ParameterKey = 'ppi_low'                 THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @ppi_high        = MAX(CASE WHEN v.ParameterKey = 'ppi_high'                THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @ht_low          = MAX(CASE WHEN v.ParameterKey = 'heater_resistance_low'   THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @ht_high         = MAX(CASE WHEN v.ParameterKey = 'heater_resistance_high'  THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @dc_low          = MAX(CASE WHEN v.ParameterKey = 'dark_current_low'        THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @dc_high         = MAX(CASE WHEN v.ParameterKey = 'dark_current_high'       THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @mpd_loss_low    = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_mpd_low'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @mpd_loss_high   = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_mpd_high'    THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @mpd_loss_range  = MAX(CASE WHEN v.ParameterKey = 'mpd_loss_range_high'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END)
    FROM spec.vw_ProductFamilySpec v
    WHERE v.ProductFamily = @ProductFamily
      AND v.IsActive = 1

    -- =============================================
    -- 2. 取芯片数据到临时表
    -- =============================================
    DECLARE @v TABLE (
        UEC_Onchip           FLOAT,
        CH01 FLOAT, CH02 FLOAT, CH03 FLOAT, CH04 FLOAT,
        CH05 FLOAT, CH06 FLOAT, CH07 FLOAT, CH08 FLOAT,
        Loss_range           FLOAT,
        ER_CH01 FLOAT, ER_CH02 FLOAT, ER_CH03 FLOAT, ER_CH04 FLOAT,
        ER_CH05 FLOAT, ER_CH06 FLOAT, ER_CH07 FLOAT, ER_CH08 FLOAT,
        PPI_CH01 FLOAT, PPI_CH02 FLOAT, PPI_CH03 FLOAT, PPI_CH04 FLOAT,
        PPI_CH05 FLOAT, PPI_CH06 FLOAT, PPI_CH07 FLOAT, PPI_CH08 FLOAT,
        HTU_CH01 FLOAT, HTU_CH02 FLOAT, HTU_CH03 FLOAT, HTU_CH04 FLOAT,
        HTU_CH05 FLOAT, HTU_CH06 FLOAT, HTU_CH07 FLOAT, HTU_CH08 FLOAT,
        OMPDM_CH01_OC FLOAT, OMPDM_CH02_OC FLOAT,
        OMPDM_CH03_OC FLOAT, OMPDM_CH04_OC FLOAT,
        OMPDM_CH05_OC FLOAT, OMPDM_CH06_OC FLOAT,
        OMPDM_CH07_OC FLOAT, OMPDM_CH08_OC FLOAT,
        OMPDS_CH01_OC FLOAT, OMPDS_CH02_OC FLOAT,
        OMPDS_CH03_OC FLOAT, OMPDS_CH04_OC FLOAT,
        OMPDS_CH05_OC FLOAT, OMPDS_CH06_OC FLOAT,
        OMPDS_CH07_OC FLOAT, OMPDS_CH08_OC FLOAT,
        OMPDM_CH01_C  FLOAT, OMPDM_CH02_C  FLOAT,
        OMPDM_CH03_C  FLOAT, OMPDM_CH04_C  FLOAT,
        OMPDM_CH05_C  FLOAT, OMPDM_CH06_C  FLOAT,
        OMPDM_CH07_C  FLOAT, OMPDM_CH08_C  FLOAT,
        OMPDS_CH01_C  FLOAT, OMPDS_CH02_C  FLOAT,
        OMPDS_CH03_C  FLOAT, OMPDS_CH04_C  FLOAT,
        OMPDS_CH05_C  FLOAT, OMPDS_CH06_C  FLOAT,
        OMPDS_CH07_C  FLOAT, OMPDS_CH08_C  FLOAT,
        IMPD_CH01_C   FLOAT, IMPD_CH02_C   FLOAT,  -- impdNum=2
        Onchip_loss_CH01_MPD FLOAT, Onchip_loss_CH02_MPD FLOAT,
        Onchip_loss_CH03_MPD FLOAT, Onchip_loss_CH04_MPD FLOAT,
        Onchip_loss_CH05_MPD FLOAT, Onchip_loss_CH06_MPD FLOAT,
        Onchip_loss_CH07_MPD FLOAT, Onchip_loss_CH08_MPD FLOAT,
        MPD_Loss_range FLOAT
    )

    INSERT INTO @v
    SELECT
        UEC_Onchip,
        CH01,CH02,CH03,CH04,CH05,CH06,CH07,CH08,
        Loss_range,
        ER_CH01,ER_CH02,ER_CH03,ER_CH04,ER_CH05,ER_CH06,ER_CH07,ER_CH08,
        PPI_CH01,PPI_CH02,PPI_CH03,PPI_CH04,PPI_CH05,PPI_CH06,PPI_CH07,PPI_CH08,
        HTU_CH01,HTU_CH02,HTU_CH03,HTU_CH04,HTU_CH05,HTU_CH06,HTU_CH07,HTU_CH08,
        OMPDM_CH01_OC,OMPDM_CH02_OC,OMPDM_CH03_OC,OMPDM_CH04_OC,
        OMPDM_CH05_OC,OMPDM_CH06_OC,OMPDM_CH07_OC,OMPDM_CH08_OC,
        OMPDS_CH01_OC,OMPDS_CH02_OC,OMPDS_CH03_OC,OMPDS_CH04_OC,
        OMPDS_CH05_OC,OMPDS_CH06_OC,OMPDS_CH07_OC,OMPDS_CH08_OC,
        OMPDM_CH01_C,OMPDM_CH02_C,OMPDM_CH03_C,OMPDM_CH04_C,
        OMPDM_CH05_C,OMPDM_CH06_C,OMPDM_CH07_C,OMPDM_CH08_C,
        OMPDS_CH01_C,OMPDS_CH02_C,OMPDS_CH03_C,OMPDS_CH04_C,
        OMPDS_CH05_C,OMPDS_CH06_C,OMPDS_CH07_C,OMPDS_CH08_C,
        IMPD_CH01_C,IMPD_CH02_C,
        Onchip_loss_CH01_MPD,Onchip_loss_CH02_MPD,
        Onchip_loss_CH03_MPD,Onchip_loss_CH04_MPD,
        Onchip_loss_CH05_MPD,Onchip_loss_CH06_MPD,
        Onchip_loss_CH07_MPD,Onchip_loss_CH08_MPD,
        MPD_Loss_range
    FROM dbo.vw_CPTestData_Coral6p0 v
    WHERE LotWafer = @LotWafer and v.isRecent=1
      AND ChipSN   = @ChipSN

    IF NOT EXISTS (SELECT 1 FROM @v)
    BEGIN
        RETURN 0
    END

    -- =============================================
    -- Step 1：非数值检查 → Bin 2
    -- 任一判定列为 NULL 则直接返回 Bin 2
    -- =============================================
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            UEC_Onchip IS NULL OR
            CH01 IS NULL OR CH02 IS NULL OR CH03 IS NULL OR CH04 IS NULL OR
            CH05 IS NULL OR CH06 IS NULL OR CH07 IS NULL OR CH08 IS NULL OR
            Loss_range IS NULL OR
            ER_CH01 IS NULL OR ER_CH02 IS NULL OR ER_CH03 IS NULL OR ER_CH04 IS NULL OR
            ER_CH05 IS NULL OR ER_CH06 IS NULL OR ER_CH07 IS NULL OR ER_CH08 IS NULL OR
            PPI_CH01 IS NULL OR PPI_CH02 IS NULL OR PPI_CH03 IS NULL OR PPI_CH04 IS NULL OR
            PPI_CH05 IS NULL OR PPI_CH06 IS NULL OR PPI_CH07 IS NULL OR PPI_CH08 IS NULL OR
            HTU_CH01 IS NULL OR HTU_CH02 IS NULL OR HTU_CH03 IS NULL OR HTU_CH04 IS NULL OR
            HTU_CH05 IS NULL OR HTU_CH06 IS NULL OR HTU_CH07 IS NULL OR HTU_CH08 IS NULL OR
            OMPDM_CH01_OC IS NULL OR OMPDM_CH02_OC IS NULL OR
            OMPDM_CH03_OC IS NULL OR OMPDM_CH04_OC IS NULL OR
            OMPDM_CH05_OC IS NULL OR OMPDM_CH06_OC IS NULL OR
            OMPDM_CH07_OC IS NULL OR OMPDM_CH08_OC IS NULL OR
            OMPDS_CH01_OC IS NULL OR OMPDS_CH02_OC IS NULL OR
            OMPDS_CH03_OC IS NULL OR OMPDS_CH04_OC IS NULL OR
            OMPDS_CH05_OC IS NULL OR OMPDS_CH06_OC IS NULL OR
            OMPDS_CH07_OC IS NULL OR OMPDS_CH08_OC IS NULL OR
            OMPDM_CH01_C IS NULL OR OMPDM_CH02_C IS NULL OR
            OMPDM_CH03_C IS NULL OR OMPDM_CH04_C IS NULL OR
            OMPDM_CH05_C IS NULL OR OMPDM_CH06_C IS NULL OR
            OMPDM_CH07_C IS NULL OR OMPDM_CH08_C IS NULL OR
            OMPDS_CH01_C IS NULL OR OMPDS_CH02_C IS NULL OR
            OMPDS_CH03_C IS NULL OR OMPDS_CH04_C IS NULL OR
            OMPDS_CH05_C IS NULL OR OMPDS_CH06_C IS NULL OR
            OMPDS_CH07_C IS NULL OR OMPDS_CH08_C IS NULL OR
            IMPD_CH01_C IS NULL OR IMPD_CH02_C IS NULL OR
            Onchip_loss_CH01_MPD IS NULL OR Onchip_loss_CH02_MPD IS NULL OR
            Onchip_loss_CH03_MPD IS NULL OR Onchip_loss_CH04_MPD IS NULL OR
            Onchip_loss_CH05_MPD IS NULL OR Onchip_loss_CH06_MPD IS NULL OR
            Onchip_loss_CH07_MPD IS NULL OR Onchip_loss_CH08_MPD IS NULL
            --OR MPD_Loss_range IS NULL
    )
    BEGIN
        RETURN 2  -- 非数值 → Bin 2，终止
    END
    UPDATE v
        SET v.MPD_Loss_range = ca.max_loss - ca.min_loss
        FROM @v v
        CROSS APPLY (
            SELECT
                MAX(x.loss) AS max_loss,
                MIN(x.loss) AS min_loss
            FROM (VALUES
                (v.Onchip_loss_CH01_MPD),
                (v.Onchip_loss_CH02_MPD),
                (v.Onchip_loss_CH03_MPD),
                (v.Onchip_loss_CH04_MPD),
                (v.Onchip_loss_CH05_MPD),
                (v.Onchip_loss_CH06_MPD),
                (v.Onchip_loss_CH07_MPD),
                (v.Onchip_loss_CH08_MPD)
            ) AS x(loss)
        ) ca
        WHERE v.MPD_Loss_range IS NULL;

    -- =============================================
    -- 中间变量
    -- =============================================
    DECLARE @mean    FLOAT
    DECLARE @std    FLOAT
    DECLARE @uec_upper    FLOAT
    DECLARE @uec_lower    FLOAT
    DECLARE @fail_nonER   INT = 0
    DECLARE @fail_ER      INT = 0
    DECLARE @min_ER       FLOAT

    -- UEC 动态上下限（对应 uec_onchip_std 乘子）
    SELECT @mean = Mean,
           @std = Std
        FROM dbo.LotWafer_UEC_Mean_Std l
        JOIN dbo.CPTest_File f on l.LotWafer = f.LotWafer and f.isRecent = 1
        WHERE l.LotWafer = @LotWafer AND L.Cdt >= f.FileModifiedTime
    SELECT @uec_upper=@mean+@std_multiplier*@std
    SELECT @uec_lower=@mean-@std_multiplier*@std
    IF @uec_upper IS NULL OR @uec_lower IS NULL
    BEGIN
        RETURN -1  -- 未能找到mean/std/@std_multiplier, 提前中止
    END
    SET @uec_upper = CASE WHEN @uec_upper < @uec_high THEN @uec_upper ELSE @uec_high END
    SET @uec_lower = CASE WHEN @uec_lower > @uec_low  THEN @uec_lower ELSE @uec_low  END

    -- =============================================
    -- Step 2 准备：各项 Fail 判定（不含ER）
    -- =============================================
    -- UEC
    IF EXISTS (
        SELECT 1 FROM @v
        WHERE UEC_Onchip < @uec_lower OR UEC_Onchip > @uec_upper
    ) SET @fail_nonER = 1

    -- Link Loss CH01~CH08
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            CH01<@loss_low OR CH01>@loss_high OR
            CH02<@loss_low OR CH02>@loss_high OR
            CH03<@loss_low OR CH03>@loss_high OR
            CH04<@loss_low OR CH04>@loss_high OR
            CH05<@loss_low OR CH05>@loss_high OR
            CH06<@loss_low OR CH06>@loss_high OR
            CH07<@loss_low OR CH07>@loss_high OR
            CH08<@loss_low OR CH08>@loss_high
    ) SET @fail_nonER = 1

    -- Link Loss Range
    IF EXISTS (SELECT 1 FROM @v WHERE Loss_range > @loss_range_high)
        SET @fail_nonER = 1

    -- OMPD 一致性
    IF EXISTS (
        SELECT 1 FROM @v
        WHERE (
            SELECT MAX(roc) FROM (VALUES
                (OMPDM_CH01_OC-OMPDM_CH01_C/1000),(OMPDM_CH02_OC-OMPDM_CH02_C/1000),
                (OMPDM_CH03_OC-OMPDM_CH03_C/1000),(OMPDM_CH04_OC-OMPDM_CH04_C/1000),
                (OMPDM_CH05_OC-OMPDM_CH05_C/1000),(OMPDM_CH06_OC-OMPDM_CH06_C/1000),
                (OMPDM_CH07_OC-OMPDM_CH07_C/1000),(OMPDM_CH08_OC-OMPDM_CH08_C/1000),
                (OMPDS_CH01_OC-OMPDS_CH01_C/1000),(OMPDS_CH02_OC-OMPDS_CH02_C/1000),
                (OMPDS_CH03_OC-OMPDS_CH03_C/1000),(OMPDS_CH04_OC-OMPDS_CH04_C/1000),
                (OMPDS_CH05_OC-OMPDS_CH05_C/1000),(OMPDS_CH06_OC-OMPDS_CH06_C/1000),
                (OMPDS_CH07_OC-OMPDS_CH07_C/1000),(OMPDS_CH08_OC-OMPDS_CH08_C/1000)
            ) AS t(roc)
        )
        / NULLIF((
            SELECT MIN(roc) FROM (VALUES
                (OMPDM_CH01_OC-OMPDM_CH01_C/1000),(OMPDM_CH02_OC-OMPDM_CH02_C/1000),
                (OMPDM_CH03_OC-OMPDM_CH03_C/1000),(OMPDM_CH04_OC-OMPDM_CH04_C/1000),
                (OMPDM_CH05_OC-OMPDM_CH05_C/1000),(OMPDM_CH06_OC-OMPDM_CH06_C/1000),
                (OMPDM_CH07_OC-OMPDM_CH07_C/1000),(OMPDM_CH08_OC-OMPDM_CH08_C/1000),
                (OMPDS_CH01_OC-OMPDS_CH01_C/1000),(OMPDS_CH02_OC-OMPDS_CH02_C/1000),
                (OMPDS_CH03_OC-OMPDS_CH03_C/1000),(OMPDS_CH04_OC-OMPDS_CH04_C/1000),
                (OMPDS_CH05_OC-OMPDS_CH05_C/1000),(OMPDS_CH06_OC-OMPDS_CH06_C/1000),
                (OMPDS_CH07_OC-OMPDS_CH07_C/1000),(OMPDS_CH08_OC-OMPDS_CH08_C/1000)
            ) AS t(roc)
        ), 0)
        > POWER(10.0, @ompd_range_high / 10.0)
    ) SET @fail_nonER = 1

    -- MPDM vs MPDS 逐对偏差（前8 vs 后8，roc 已扣除暗电流）
    IF EXISTS (
        SELECT 1 FROM @v WHERE
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH01_OC-OMPDM_CH01_C/1000),0)/NULLIF(ABS(OMPDS_CH01_OC-OMPDS_CH01_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH02_OC-OMPDM_CH02_C/1000),0)/NULLIF(ABS(OMPDS_CH02_OC-OMPDS_CH02_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH03_OC-OMPDM_CH03_C/1000),0)/NULLIF(ABS(OMPDS_CH03_OC-OMPDS_CH03_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH04_OC-OMPDM_CH04_C/1000),0)/NULLIF(ABS(OMPDS_CH04_OC-OMPDS_CH04_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH05_OC-OMPDM_CH05_C/1000),0)/NULLIF(ABS(OMPDS_CH05_OC-OMPDS_CH05_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH06_OC-OMPDM_CH06_C/1000),0)/NULLIF(ABS(OMPDS_CH06_OC-OMPDS_CH06_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH07_OC-OMPDM_CH07_C/1000),0)/NULLIF(ABS(OMPDS_CH07_OC-OMPDS_CH07_C/1000),0)))>@mpdm_mpds_dev OR
        ABS(10*LOG10(NULLIF(ABS(OMPDM_CH08_OC-OMPDM_CH08_C/1000),0)/NULLIF(ABS(OMPDS_CH08_OC-OMPDS_CH08_C/1000),0)))>@mpdm_mpds_dev
    ) SET @fail_nonER = 1

    -- PPI
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            PPI_CH01<@ppi_low OR PPI_CH01>@ppi_high OR
            PPI_CH02<@ppi_low OR PPI_CH02>@ppi_high OR
            PPI_CH03<@ppi_low OR PPI_CH03>@ppi_high OR
            PPI_CH04<@ppi_low OR PPI_CH04>@ppi_high OR
            PPI_CH05<@ppi_low OR PPI_CH05>@ppi_high OR
            PPI_CH06<@ppi_low OR PPI_CH06>@ppi_high OR
            PPI_CH07<@ppi_low OR PPI_CH07>@ppi_high OR
            PPI_CH08<@ppi_low OR PPI_CH08>@ppi_high
    ) SET @fail_nonER = 1

    -- Heater
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            HTU_CH01<@ht_low OR HTU_CH01>@ht_high OR
            HTU_CH02<@ht_low OR HTU_CH02>@ht_high OR
            HTU_CH03<@ht_low OR HTU_CH03>@ht_high OR
            HTU_CH04<@ht_low OR HTU_CH04>@ht_high OR
            HTU_CH05<@ht_low OR HTU_CH05>@ht_high OR
            HTU_CH06<@ht_low OR HTU_CH06>@ht_high OR
            HTU_CH07<@ht_low OR HTU_CH07>@ht_high OR
            HTU_CH08<@ht_low OR HTU_CH08>@ht_high
    ) SET @fail_nonER = 1

    -- MPD Dark Current（impdNum=2，共 2+8+8=18 列，修复 OMPDS_CH08_C 漏检）
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            IMPD_CH01_C<@dc_low  OR IMPD_CH01_C>@dc_high  OR
            IMPD_CH02_C<@dc_low  OR IMPD_CH02_C>@dc_high  OR
            OMPDM_CH01_C<@dc_low OR OMPDM_CH01_C>@dc_high OR
            OMPDM_CH02_C<@dc_low OR OMPDM_CH02_C>@dc_high OR
            OMPDM_CH03_C<@dc_low OR OMPDM_CH03_C>@dc_high OR
            OMPDM_CH04_C<@dc_low OR OMPDM_CH04_C>@dc_high OR
            OMPDM_CH05_C<@dc_low OR OMPDM_CH05_C>@dc_high OR
            OMPDM_CH06_C<@dc_low OR OMPDM_CH06_C>@dc_high OR
            OMPDM_CH07_C<@dc_low OR OMPDM_CH07_C>@dc_high OR
            OMPDM_CH08_C<@dc_low OR OMPDM_CH08_C>@dc_high OR
            OMPDS_CH01_C<@dc_low OR OMPDS_CH01_C>@dc_high OR
            OMPDS_CH02_C<@dc_low OR OMPDS_CH02_C>@dc_high OR
            OMPDS_CH03_C<@dc_low OR OMPDS_CH03_C>@dc_high OR
            OMPDS_CH04_C<@dc_low OR OMPDS_CH04_C>@dc_high OR
            OMPDS_CH05_C<@dc_low OR OMPDS_CH05_C>@dc_high OR
            OMPDS_CH06_C<@dc_low OR OMPDS_CH06_C>@dc_high OR
            OMPDS_CH07_C<@dc_low OR OMPDS_CH07_C>@dc_high OR
            OMPDS_CH08_C<@dc_low OR OMPDS_CH08_C>@dc_high   -- 补齐第18列
    ) SET @fail_nonER = 1

    -- MPD Loss
    IF EXISTS (
        SELECT 1 FROM @v WHERE
            Onchip_loss_CH01_MPD<@mpd_loss_low OR Onchip_loss_CH01_MPD>@mpd_loss_high OR
            Onchip_loss_CH02_MPD<@mpd_loss_low OR Onchip_loss_CH02_MPD>@mpd_loss_high OR
            Onchip_loss_CH03_MPD<@mpd_loss_low OR Onchip_loss_CH03_MPD>@mpd_loss_high OR
            Onchip_loss_CH04_MPD<@mpd_loss_low OR Onchip_loss_CH04_MPD>@mpd_loss_high OR
            Onchip_loss_CH05_MPD<@mpd_loss_low OR Onchip_loss_CH05_MPD>@mpd_loss_high OR
            Onchip_loss_CH06_MPD<@mpd_loss_low OR Onchip_loss_CH06_MPD>@mpd_loss_high OR
            Onchip_loss_CH07_MPD<@mpd_loss_low OR Onchip_loss_CH07_MPD>@mpd_loss_high OR
            Onchip_loss_CH08_MPD<@mpd_loss_low OR Onchip_loss_CH08_MPD>@mpd_loss_high
    ) SET @fail_nonER = 1

    -- MPD Loss Range
    IF EXISTS (SELECT 1 FROM @v WHERE MPD_Loss_range > @mpd_loss_range)
        SET @fail_nonER = 1

    -- ER 单独判定
    SELECT @min_ER = (
        SELECT MIN(er) FROM (VALUES
            (ER_CH01),(ER_CH02),(ER_CH03),(ER_CH04),
            (ER_CH05),(ER_CH06),(ER_CH07),(ER_CH08)
        ) AS t(er)
    ) FROM @v

    IF EXISTS (
        SELECT 1 FROM @v WHERE
            ER_CH01<@er_low OR ER_CH02<@er_low OR
            ER_CH03<@er_low OR ER_CH04<@er_low OR
            ER_CH05<@er_low OR ER_CH06<@er_low OR
            ER_CH07<@er_low OR ER_CH08<@er_low
    ) SET @fail_ER = 1

    -- =============================================
    -- Step 2：不在 failed device 内（全部 Pass）→ Bin 1
    -- =============================================
    IF @fail_nonER = 0 AND @fail_ER = 0
    BEGIN
        RETURN 1  -- Pass → Bin 1，终止
    END

    -- =============================================
    -- Step 3：非ER全Pass 且命中 ER Bin7 → Bin 7
    -- =============================================
    IF @fail_nonER = 0 AND @min_ER > 23 AND @min_ER <= 24
    BEGIN
        RETURN 7  -- Bin 7，终止
    END

    -- =============================================
    -- Step 4：非ER全Pass 且命中 ER Bin8 → Bin 8
    -- =============================================
    IF @fail_nonER = 0 AND @min_ER > 24 AND @min_ER <= @er_low
    BEGIN
        RETURN 8  -- Bin 8，终止
    END

    -- =============================================
    -- Step 5：其余情况 → Bin 2
    -- =============================================
    RETURN 2

END