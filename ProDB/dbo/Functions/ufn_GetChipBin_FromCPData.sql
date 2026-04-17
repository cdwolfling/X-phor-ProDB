/*
Create by Jackiech on 2026-04-01
SELECT dbo.ufn_GetChipBin_FromCPData('LN41477-W01', 'E07-403') AS Bin
--Coral3p1
select w.Wafer号,d.Cbin,d.Bin, dbo.ufn_GetChipBin_FromCPData(d.LotWafer, d.Cbin) as MES_Bin
    from dbo.Die d
    join dbo.Wafer w on d.LotWafer=w.Wafer号
    where w.测试结束时间 between '2026-03-01' and  '2026-03-01 8:00' and d.Bin not in (0,3) and w.SourceName like 'Coral3p1%'
    and case when d.Bin in (4,5) then 1 else d.Bin end<>dbo.ufn_GetChipBin_FromCPData(d.LotWafer, d.Cbin)
--Coral6p0
select *, dbo.ufn_GetChipBin_FromCPData(w82.LotWafer,w82.Cbin) as MES_Bin from dbo.Die_WrongBin7_82Wafer w82
    where w82.Bin=7 and w82.Bin_V3<>dbo.ufn_GetChipBin_FromCPData(w82.LotWafer,w82.Cbin)

Change Log:
2026-04-17 JC: 优化Debug方式
2026-04-10 JC: bugfix, 修正取@mean @std的逻辑
2026-04-09 JC: 改用[dbo].[ufn_GetChipBin_FromCPData_Coral3p1]的判断方式; 增加Debug信息
2026-04-09 JC: 无测试结果， 返回0； 无部分测试项， 返回2
2026-04-02 JC: 使用dbo.LotWafer_UEC_Mean_Std 取代 ufn_GetUEC_Bounds/ufn_GetUEC_Mean_Std/dbo.LotWafer_UEC_Data
2026-04-01 JC: (临时)使用dbo.LotWafer_UEC_Data 取代 ufn_GetUEC_Bounds
*/
CREATE FUNCTION [dbo].[ufn_GetChipBin_FromCPData]
(
    @LotWafer VARCHAR(50),
    @ChipSN   VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    --declare @LotWafer VARCHAR(50)='LN47756-W06'
    --declare @ChipSN   VARCHAR(50)='A04-104'

    DECLARE @Bin INT = 2;  -- 默认 Bin2（兜底）
    DECLARE @ChannelNum INT, @impdNum INT

    -- =============================================
    -- 1. Spec 参数（替换为从配置表动态读取）
    -- =============================================
    DECLARE @ProductFamily      VARCHAR(50)
    SELECT @ProductFamily=left(w.SourceName,8) from dbo.Wafer w where w.Wafer号=@LotWafer
    SELECT @ChannelNum = case when @ProductFamily in ('Coral3p1','Coral3p5') then 4
                            when @ProductFamily in ('Coral4p1','Coral6p0') then 8
                        end
    SELECT @impdNum = case when @ProductFamily in ('Coral3p1','Coral3p5') then 1
                            when @ProductFamily in ('Coral4p1','Coral6p0') then 2
                        end
    IF @ChannelNum is null
    BEGIN
        RETURN -1
    END;

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
    -- 2. 取芯片数据
    -- =============================================
    DECLARE @v TABLE
    (
        UEC_Onchip           FLOAT,
        CH01 FLOAT, CH02 FLOAT, CH03 FLOAT, CH04 FLOAT,
        CH05 FLOAT, CH06 FLOAT, CH07 FLOAT, CH08 FLOAT,
        Loss_range             FLOAT,
        
        ER_CH01 FLOAT, ER_CH02 FLOAT, ER_CH03 FLOAT, ER_CH04 FLOAT,
        ER_CH05 FLOAT, ER_CH06 FLOAT, ER_CH07 FLOAT, ER_CH08 FLOAT,
        PPI_CH01 FLOAT, PPI_CH02 FLOAT, PPI_CH03 FLOAT, PPI_CH04 FLOAT,
        PPI_CH05 FLOAT, PPI_CH06 FLOAT, PPI_CH07 FLOAT, PPI_CH08 FLOAT,
        HTU_CH01 FLOAT, HTU_CH02 FLOAT, HTU_CH03 FLOAT, HTU_CH04 FLOAT,
        HTU_CH05 FLOAT, HTU_CH06 FLOAT, HTU_CH07 FLOAT, HTU_CH08 FLOAT,
        
        IMPD_CH01_C   FLOAT, IMPD_CH02_C   FLOAT,  -- impdNum
        OMPDM_CH01_C  FLOAT, OMPDM_CH02_C  FLOAT,
        OMPDM_CH03_C  FLOAT, OMPDM_CH04_C  FLOAT,
        OMPDM_CH05_C  FLOAT, OMPDM_CH06_C  FLOAT,
        OMPDM_CH07_C  FLOAT, OMPDM_CH08_C  FLOAT,
        OMPDS_CH01_C  FLOAT, OMPDS_CH02_C  FLOAT,
        OMPDS_CH03_C  FLOAT, OMPDS_CH04_C  FLOAT,
        OMPDS_CH05_C  FLOAT, OMPDS_CH06_C  FLOAT,
        OMPDS_CH07_C  FLOAT, OMPDS_CH08_C  FLOAT,
        
        Onchip_loss_CH01_MPD   FLOAT,
        Onchip_loss_CH02_MPD   FLOAT,
        Onchip_loss_CH03_MPD   FLOAT,
        Onchip_loss_CH04_MPD   FLOAT,
        Onchip_loss_CH05_MPD   FLOAT,
        Onchip_loss_CH06_MPD   FLOAT,
        Onchip_loss_CH07_MPD   FLOAT,
        Onchip_loss_CH08_MPD   FLOAT,
        MPD_Loss_range         FLOAT,
        
        OMPDM_CH01_db          FLOAT,
        OMPDM_CH02_db          FLOAT,
        OMPDM_CH03_db          FLOAT,
        OMPDM_CH04_db          FLOAT,
        OMPDM_CH05_db          FLOAT,
        OMPDM_CH06_db          FLOAT,
        OMPDM_CH07_db          FLOAT,
        OMPDM_CH08_db          FLOAT,
        OMPDS_CH01_db          FLOAT,
        OMPDS_CH02_db          FLOAT,
        OMPDS_CH03_db          FLOAT,
        OMPDS_CH04_db          FLOAT,
        OMPDS_CH05_db          FLOAT,
        OMPDS_CH06_db          FLOAT,
        OMPDS_CH07_db          FLOAT,
        OMPDS_CH08_db          FLOAT
    );
    INSERT INTO @v
    SELECT 
        UEC_Onchip,
        CH01,CH02,CH03,CH04,CH05,CH06,CH07,CH08, Loss_range,
        ER_CH01,ER_CH02,ER_CH03,ER_CH04,ER_CH05,ER_CH06,ER_CH07,ER_CH08,
        PPI_CH01,PPI_CH02,PPI_CH03,PPI_CH04,PPI_CH05,PPI_CH06,PPI_CH07,PPI_CH08,
        HTU_CH01,HTU_CH02,HTU_CH03,HTU_CH04,HTU_CH05,HTU_CH06,HTU_CH07,HTU_CH08,
        IMPD_CH01_C,IMPD_CH02_C,
        OMPDM_CH01_C,OMPDM_CH02_C,OMPDM_CH03_C,OMPDM_CH04_C,OMPDM_CH05_C,OMPDM_CH06_C,OMPDM_CH07_C,OMPDM_CH08_C,
        OMPDS_CH01_C,OMPDS_CH02_C,OMPDS_CH03_C,OMPDS_CH04_C,OMPDS_CH05_C,OMPDS_CH06_C,OMPDS_CH07_C,OMPDS_CH08_C,        
        Onchip_loss_CH01_MPD,Onchip_loss_CH02_MPD,Onchip_loss_CH03_MPD,Onchip_loss_CH04_MPD,Onchip_loss_CH05_MPD,Onchip_loss_CH06_MPD,Onchip_loss_CH07_MPD,Onchip_loss_CH08_MPD,
        MPD_Loss_range,
        OMPDM_CH01_db, OMPDM_CH02_db, OMPDM_CH03_db, OMPDM_CH04_db, OMPDM_CH05_db, OMPDM_CH06_db, OMPDM_CH07_db, OMPDM_CH08_db,
        OMPDS_CH01_db, OMPDS_CH02_db, OMPDS_CH03_db, OMPDS_CH04_db, OMPDS_CH05_db, OMPDS_CH06_db, OMPDS_CH07_db, OMPDS_CH08_db
    FROM dbo.vw_CPTestData v
    WHERE v.LotWafer = @LotWafer
        AND v.ChipSN   = @ChipSN
        AND v.isRecent = 1;
    
    IF NOT EXISTS (SELECT 1 FROM @v)
    BEGIN
        --PRINT '找不到数据'
        RETURN 0;
    END;

    -- =============================================
    -- 3. 非数值检查
    --    任一必需判定列为空，直接 Bin2
    -- =============================================
    IF @ChannelNum = 4 and @impdNum = 1
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM @v
            WHERE UEC_Onchip IS NULL
               OR CH01 IS NULL OR CH02 IS NULL OR CH03 IS NULL OR CH04 IS NULL 
               OR Loss_range IS NULL
               OR ER_CH01 IS NULL OR ER_CH02 IS NULL OR ER_CH03 IS NULL OR ER_CH04 IS NULL
               OR PPI_CH01 IS NULL OR PPI_CH02 IS NULL OR PPI_CH03 IS NULL OR PPI_CH04 IS NULL
               OR HTU_CH01 IS NULL OR HTU_CH02 IS NULL OR HTU_CH03 IS NULL OR HTU_CH04 IS NULL
               OR IMPD_CH01_C IS NULL
               OR OMPDM_CH01_C IS NULL OR OMPDM_CH02_C IS NULL OR OMPDM_CH03_C IS NULL OR OMPDM_CH04_C IS NULL
               OR OMPDS_CH01_C IS NULL OR OMPDS_CH02_C IS NULL OR OMPDS_CH03_C IS NULL OR OMPDS_CH04_C IS NULL
               OR Onchip_loss_CH01_MPD IS NULL OR Onchip_loss_CH02_MPD IS NULL OR Onchip_loss_CH03_MPD IS NULL OR Onchip_loss_CH04_MPD IS NULL
               OR OMPDM_CH01_db IS NULL OR OMPDM_CH02_db IS NULL OR OMPDM_CH03_db IS NULL OR OMPDM_CH04_db IS NULL
               OR OMPDS_CH01_db IS NULL OR OMPDS_CH02_db IS NULL OR OMPDS_CH03_db IS NULL OR OMPDS_CH04_db IS NULL
        )
        BEGIN
            RETURN 2;
        END;
    END
    ELSE IF @ChannelNum = 8 and @impdNum = 2
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM @v
            WHERE UEC_Onchip IS NULL
               OR CH01 IS NULL OR CH02 IS NULL OR CH03 IS NULL OR CH04 IS NULL OR CH05 IS NULL OR CH06 IS NULL OR CH07 IS NULL OR CH08 IS NULL
               OR Loss_range IS NULL
               OR ER_CH01 IS NULL OR ER_CH02 IS NULL OR ER_CH03 IS NULL OR ER_CH04 IS NULL
               OR ER_CH05 IS NULL OR ER_CH06 IS NULL OR ER_CH07 IS NULL OR ER_CH08 IS NULL
               OR PPI_CH01 IS NULL OR PPI_CH02 IS NULL OR PPI_CH03 IS NULL OR PPI_CH04 IS NULL
               OR PPI_CH05 IS NULL OR PPI_CH06 IS NULL OR PPI_CH07 IS NULL OR PPI_CH08 IS NULL
               OR HTU_CH01 IS NULL OR HTU_CH02 IS NULL OR HTU_CH03 IS NULL OR HTU_CH04 IS NULL
               OR HTU_CH05 IS NULL OR HTU_CH06 IS NULL OR HTU_CH07 IS NULL OR HTU_CH08 IS NULL
               OR IMPD_CH01_C IS NULL OR IMPD_CH02_C IS NULL
               OR OMPDM_CH01_C IS NULL OR OMPDM_CH02_C IS NULL OR OMPDM_CH03_C IS NULL OR OMPDM_CH04_C IS NULL OR OMPDM_CH05_C IS NULL OR OMPDM_CH06_C IS NULL OR OMPDM_CH07_C IS NULL OR OMPDM_CH08_C IS NULL
               OR OMPDS_CH01_C IS NULL OR OMPDS_CH02_C IS NULL OR OMPDS_CH03_C IS NULL OR OMPDS_CH04_C IS NULL OR OMPDS_CH05_C IS NULL OR OMPDS_CH06_C IS NULL OR OMPDS_CH07_C IS NULL OR OMPDS_CH08_C IS NULL
               OR Onchip_loss_CH01_MPD IS NULL OR Onchip_loss_CH02_MPD IS NULL OR Onchip_loss_CH03_MPD IS NULL OR Onchip_loss_CH04_MPD IS NULL OR Onchip_loss_CH05_MPD IS NULL OR Onchip_loss_CH06_MPD IS NULL OR Onchip_loss_CH07_MPD IS NULL OR Onchip_loss_CH08_MPD IS NULL
               OR OMPDM_CH01_db IS NULL OR OMPDM_CH02_db IS NULL OR OMPDM_CH03_db IS NULL OR OMPDM_CH04_db IS NULL OR OMPDM_CH05_db IS NULL OR OMPDM_CH06_db IS NULL OR OMPDM_CH07_db IS NULL OR OMPDM_CH08_db IS NULL
               OR OMPDS_CH01_db IS NULL OR OMPDS_CH02_db IS NULL OR OMPDS_CH03_db IS NULL OR OMPDS_CH04_db IS NULL OR OMPDS_CH05_db IS NULL OR OMPDS_CH06_db IS NULL OR OMPDS_CH07_db IS NULL OR OMPDS_CH08_db IS NULL
        )
        BEGIN
            RETURN 2;
        END;
    END

    -- 若 MPD_Loss_range 未落表，则按 4 个 MPD loss 现算
    IF @ChannelNum = 4 and @impdNum = 1
    BEGIN
        UPDATE v
           SET v.MPD_Loss_range = ca.max_loss - ca.min_loss
        FROM @v v
        CROSS APPLY
        (
            SELECT
                MAX(x.loss) AS max_loss,
                MIN(x.loss) AS min_loss
            FROM (VALUES
                (v.Onchip_loss_CH01_MPD),
                (v.Onchip_loss_CH02_MPD),
                (v.Onchip_loss_CH03_MPD),
                (v.Onchip_loss_CH04_MPD)
            ) AS x(loss)
        ) ca
        WHERE v.MPD_Loss_range IS NULL;
    END
    ELSE IF @ChannelNum = 8 and @impdNum = 2
    BEGIN
        UPDATE v
           SET v.MPD_Loss_range = ca.max_loss - ca.min_loss
        FROM @v v
        CROSS APPLY
        (
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
    END

    -- =============================================
    -- 4. 取 whole wafer 的 mean/std，生成 UEC 动态上下限, 再结合@uec_high/@uec_low
    -- =============================================
    DECLARE @mean         FLOAT;
    DECLARE @std          FLOAT;
    DECLARE @uec_upper    FLOAT;
    DECLARE @uec_lower    FLOAT;
    DECLARE @FileModifiedTime DATETIME
    SELECT @FileModifiedTime=f.FileModifiedTime FROM dbo.CPTest_File f WHERE f.LotWafer=@LotWafer AND f.isRecent=1
    SELECT TOP (1)
           @mean = l.[Mean],
           @std  = l.[Std]
    FROM dbo.LotWafer_UEC_Mean_Std l
    WHERE l.LotWafer = @LotWafer
    AND ISNULL(l.Udt,l.Cdt) >= @FileModifiedTime

    IF @mean IS NULL OR @std IS NULL
    BEGIN
        --PRINT '找不到mean/std'
        RETURN 2;
    END;

    SET @uec_upper = @mean + @std_multiplier * @std;
    SET @uec_lower = @mean - @std_multiplier * @std;

    IF @uec_upper > @uec_high SET @uec_upper = @uec_high;
    IF @uec_lower < @uec_low  SET @uec_lower = @uec_low;

    -- =============================================
    -- 5. 各项 Fail 判定
    -- =============================================
    DECLARE @fail INT = 0;
    DECLARE @fail_ER INT = 0;
    -- 5.1 UEC_Onchip
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE UEC_Onchip < @uec_lower
           OR UEC_Onchip > @uec_upper
    )
    BEGIN
        --PRINT '5.1'
        SET @fail = 1;
    END;

    -- 5.2 onchip_loss_optical：按 @ChannelNum 检查 CHxx
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                (1, v.CH01),
                (2, v.CH02),
                (3, v.CH03),
                (4, v.CH04),
                (5, v.CH05),
                (6, v.CH06),
                (7, v.CH07),
                (8, v.CH08)
            ) AS x(ch_no, loss_value)
            WHERE x.ch_no <= @ChannelNum
              AND (x.loss_value < @loss_low OR x.loss_value > @loss_high)
        ) ca
    )
    BEGIN
        --PRINT '5.2'
        SET @fail = 1;
    END;

    -- 5.3 loss_range：<= @loss_range_high
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE Loss_range > @loss_range_high
    )
    BEGIN
        --PRINT '5.3'
        SET @fail = 1;
    END;

    -- 5.4 onchip_loss_mpd：按 @ChannelNum 检查 CHxx
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                (1, v.Onchip_loss_CH01_MPD),
                (2, v.Onchip_loss_CH02_MPD),
                (3, v.Onchip_loss_CH03_MPD),
                (4, v.Onchip_loss_CH04_MPD),
                (5, v.Onchip_loss_CH05_MPD),
                (6, v.Onchip_loss_CH06_MPD),
                (7, v.Onchip_loss_CH07_MPD),
                (8, v.Onchip_loss_CH08_MPD)
            ) AS x(ch_no, loss_value)
            WHERE x.ch_no <= @ChannelNum
              AND (x.loss_value < @mpd_loss_low OR x.loss_value > @mpd_loss_high)
        ) ca
    )
    BEGIN
        --PRINT '5.4'
        SET @fail = 1;
    END;

    -- 5.5 loss_mpd_range：<= @mpd_loss_range
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE MPD_Loss_range > @mpd_loss_range
    )
    BEGIN
        --PRINT '5.5'
        SET @fail = 1;
    END;

    -- 5.6 mpd dark currents：
    -- IMPD 按 @impdNum 检查；OMPDM/OMPDS 按 @ChannelNum 检查
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                ('IMPD' , 1, v.IMPD_CH01_C),
                ('IMPD' , 2, v.IMPD_CH02_C),

                ('OMPDM', 1, v.OMPDM_CH01_C),
                ('OMPDM', 2, v.OMPDM_CH02_C),
                ('OMPDM', 3, v.OMPDM_CH03_C),
                ('OMPDM', 4, v.OMPDM_CH04_C),
                ('OMPDM', 5, v.OMPDM_CH05_C),
                ('OMPDM', 6, v.OMPDM_CH06_C),
                ('OMPDM', 7, v.OMPDM_CH07_C),
                ('OMPDM', 8, v.OMPDM_CH08_C),

                ('OMPDS', 1, v.OMPDS_CH01_C),
                ('OMPDS', 2, v.OMPDS_CH02_C),
                ('OMPDS', 3, v.OMPDS_CH03_C),
                ('OMPDS', 4, v.OMPDS_CH04_C),
                ('OMPDS', 5, v.OMPDS_CH05_C),
                ('OMPDS', 6, v.OMPDS_CH06_C),
                ('OMPDS', 7, v.OMPDS_CH07_C),
                ('OMPDS', 8, v.OMPDS_CH08_C)
            ) AS x(src_type, ch_no, dc_value)
            WHERE (
                (x.src_type = 'IMPD' AND x.ch_no <= @impdNum)
                OR
                (x.src_type IN ('OMPDM', 'OMPDS') AND x.ch_no <= @ChannelNum)
                )
              AND (x.dc_value < @dc_low OR x.dc_value > @dc_high)
        ) ca
    )
    BEGIN
        --PRINT '5.6'
        SET @fail = 1;
    END;

    -- 5.7 Heater Resistance：按 @ChannelNum 检查 HTU_CHxx
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                (1, v.HTU_CH01),
                (2, v.HTU_CH02),
                (3, v.HTU_CH03),
                (4, v.HTU_CH04),
                (5, v.HTU_CH05),
                (6, v.HTU_CH06),
                (7, v.HTU_CH07),
                (8, v.HTU_CH08)
            ) AS x(ch_no, ht_value)
            WHERE x.ch_no <= @ChannelNum
              AND (x.ht_value < @ht_low OR x.ht_value > @ht_high)
        ) ca
    )
    BEGIN
        --PRINT '5.7'
        SET @fail = 1;
    END;

    -- 5.8 PPI：按 @ChannelNum 检查 PPI_CHxx
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                (1, v.PPI_CH01),
                (2, v.PPI_CH02),
                (3, v.PPI_CH03),
                (4, v.PPI_CH04),
                (5, v.PPI_CH05),
                (6, v.PPI_CH06),
                (7, v.PPI_CH07),
                (8, v.PPI_CH08)
            ) AS x(ch_no, ppi_value)
            WHERE x.ch_no <= @ChannelNum
              AND (x.ppi_value < @ppi_low OR x.ppi_value > @ppi_high)
        ) ca
    )
    BEGIN
        --PRINT '5.8'
        SET @fail = 1;
    END;

    -- 5.9 ompd_range：max(db) - min(db) <= @ompd_range_high
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT
                MAX(x.db_value) AS max_db,
                MIN(x.db_value) AS min_db
            FROM (VALUES
                (1, v.OMPDM_CH01_db),
                (2, v.OMPDM_CH02_db),
                (3, v.OMPDM_CH03_db),
                (4, v.OMPDM_CH04_db),
                (5, v.OMPDM_CH05_db),
                (6, v.OMPDM_CH06_db),
                (7, v.OMPDM_CH07_db),
                (8, v.OMPDM_CH08_db),
                (1, v.OMPDS_CH01_db),
                (2, v.OMPDS_CH02_db),
                (3, v.OMPDS_CH03_db),
                (4, v.OMPDS_CH04_db),
                (5, v.OMPDS_CH05_db),
                (6, v.OMPDS_CH06_db),
                (7, v.OMPDS_CH07_db),
                (8, v.OMPDS_CH08_db)
            ) AS x(ch_no, db_value)
            WHERE x.ch_no <= @ChannelNum
        ) ca
        WHERE ca.max_db - ca.min_db > @ompd_range_high
    )
    BEGIN
        --PRINT '5.9'
        SET @fail = 1;
    END;

    -- 5.10 mpdm_mpds_dev：ABS(OMPDM_CHxx_db - OMPDS_CHxx_db) <= @mpdm_mpds_dev
    IF EXISTS
    (
        SELECT 1
        FROM @v v
        CROSS APPLY
        (
            SELECT 1 AS bad
            FROM (VALUES
                (1, ABS(v.OMPDM_CH01_db - v.OMPDS_CH01_db)),
                (2, ABS(v.OMPDM_CH02_db - v.OMPDS_CH02_db)),
                (3, ABS(v.OMPDM_CH03_db - v.OMPDS_CH03_db)),
                (4, ABS(v.OMPDM_CH04_db - v.OMPDS_CH04_db)),
                (5, ABS(v.OMPDM_CH05_db - v.OMPDS_CH05_db)),
                (6, ABS(v.OMPDM_CH06_db - v.OMPDS_CH06_db)),
                (7, ABS(v.OMPDM_CH07_db - v.OMPDS_CH07_db)),
                (8, ABS(v.OMPDM_CH08_db - v.OMPDS_CH08_db))
            ) AS x(ch_no, dev_value)
            WHERE x.ch_no <= @ChannelNum
              AND x.dev_value > @mpdm_mpds_dev
        ) ca
    )
    BEGIN
        --PRINT '5.10'
        SET @fail = 1;
    END;

    -- 5.11 ER：>= @er_low
    DECLARE @min_ER FLOAT;
    SELECT @min_ER = MIN(ca.er_value)
    FROM @v v
    CROSS APPLY
    (
        VALUES
            (1, v.ER_CH01),
            (2, v.ER_CH02),
            (3, v.ER_CH03),
            (4, v.ER_CH04),
            (5, v.ER_CH05),
            (6, v.ER_CH06),
            (7, v.ER_CH07),
            (8, v.ER_CH08)
    ) ca(ch_no, er_value)
    WHERE ca.ch_no <= @ChannelNum;

    -- =============================================
    -- 6. Bin 判定
    -- =============================================
    IF @fail = 0 AND @min_ER >= @er_low
    BEGIN
        RETURN 1  -- Pass → Bin 1，终止
    END
    IF @fail = 0 AND @ProductFamily='Coral6p0' AND @min_ER > 23 AND @min_ER <= 24
    BEGIN
        RETURN 7  -- Bin 7，终止
    END
    IF @fail = 0 AND @ProductFamily='Coral6p0' AND @min_ER > 24 AND @min_ER <= @er_low
    BEGIN
        RETURN 8  -- Bin 8，终止
    END

    RETURN 2

END