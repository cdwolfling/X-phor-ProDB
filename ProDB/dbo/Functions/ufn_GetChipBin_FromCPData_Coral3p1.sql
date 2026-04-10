/*
Create by Jackiech on 2026-04-08
select *
    FROM spec.vw_ProductFamilySpec v
    WHERE v.ProductFamily = 'Coral3p1'
      AND v.IsActive = 1
--Test units in 2026-03
if OBJECT_ID('tempdb..#Wafer_Die') is not null drop table #Wafer_Die
create table #Wafer_Die(SeqID INT identity(1,1), LotWafer varchar(11),ChipSN varchar(10), Bin int)
insert #Wafer_Die(LotWafer,ChipSN,Bin)
	select w.LotWafer,d.Cbin,d.Bin
	from dbo.CPTest_File w
	join dbo.Die d on w.LotWafer=d.LotWafer and d.Bin not in (0,3)
	where w.ProductModel like 'Coral3p1%' and w.FileModifiedTime between '2026-03-01' and '2026-04-01' and w.isRecent=1
select d.LotWafer,d.ChipSN,d.Bin,[dbo].[ufn_GetChipBin_FromCPData_Coral3p1](d.LotWafer, d.ChipSN)
	from #Wafer_Die d
	where [dbo].[ufn_GetChipBin_FromCPData_Coral3p1](d.LotWafer, d.ChipSN)<>case when d.bin in (1,4,5) then 1 else d.bin end

Change Log:
2026-04-09 JC: 无测试结果， 返回0； 无部分测试项， 返回2
2026-04-08 JC: Align spec logic to 《Xphor Coral3p1 DR4Tx  WLT Specs-Manufacture_update.xlsx》V1.2:
               1) UEC dynamic range = clamp(mean ± 2.5 * std, 1.5, 8.5)
               2) onchip_loss_optical = 8 ~ 11 dB
               3) onchip_loss_mpd = 8.5 ~ 10.5 dB
               4) loss_range / loss_mpd_range upper limit = 1 dB
               5) ompd_range = max(db columns) - min(db columns), upper limit 1.5 dB
               6) mpdm_mpds_dev = abs(OMPDM_CHxx_db - OMPDS_CHxx_db), upper limit 0.5 dB
2026-04-08 JC: Base ufn_GetChipBin_FromCPData
*/
CREATE   FUNCTION [dbo].[ufn_GetChipBin_FromCPData_Coral3p1]
(
    @LotWafer VARCHAR(50),
    @ChipSN   VARCHAR(50)
)
RETURNS INT
AS
BEGIN
    DECLARE @Bin INT = 2;  -- 默认 Bin2（兜底）

    -- =============================================
    -- 1. Spec 参数（替换为从配置表动态读取）
    -- =============================================
    DECLARE @ProductFamily      VARCHAR(50)
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
    -- 2. 取芯片数据
    --    说明：这里默认使用 Coral3p1 视图。
    --    如果当前数据库实际仍使用 Coral6p0 视图，请仅修改下面 FROM 那一行。
    -- =============================================
    DECLARE @v TABLE
    (
        UEC_Onchip             FLOAT,

        CH01                   FLOAT,
        CH02                   FLOAT,
        CH03                   FLOAT,
        CH04                   FLOAT,
        Loss_range             FLOAT,

        ER_CH01                FLOAT,
        ER_CH02                FLOAT,
        ER_CH03                FLOAT,
        ER_CH04                FLOAT,

        PPI_CH01               FLOAT,
        PPI_CH02               FLOAT,
        PPI_CH03               FLOAT,
        PPI_CH04               FLOAT,

        HTU_CH01               FLOAT,
        HTU_CH02               FLOAT,
        HTU_CH03               FLOAT,
        HTU_CH04               FLOAT,

        IMPD_CH01_C            FLOAT,
        OMPDM_CH01_C           FLOAT,
        OMPDM_CH02_C           FLOAT,
        OMPDM_CH03_C           FLOAT,
        OMPDM_CH04_C           FLOAT,
        OMPDS_CH01_C           FLOAT,
        OMPDS_CH02_C           FLOAT,
        OMPDS_CH03_C           FLOAT,
        OMPDS_CH04_C           FLOAT,

        Onchip_loss_CH01_MPD   FLOAT,
        Onchip_loss_CH02_MPD   FLOAT,
        Onchip_loss_CH03_MPD   FLOAT,
        Onchip_loss_CH04_MPD   FLOAT,
        MPD_Loss_range         FLOAT,

        OMPDM_CH01_db          FLOAT,
        OMPDM_CH02_db          FLOAT,
        OMPDM_CH03_db          FLOAT,
        OMPDM_CH04_db          FLOAT,
        OMPDS_CH01_db          FLOAT,
        OMPDS_CH02_db          FLOAT,
        OMPDS_CH03_db          FLOAT,
        OMPDS_CH04_db          FLOAT
    );

    INSERT INTO @v
    (
        UEC_Onchip,
        CH01, CH02, CH03, CH04, Loss_range,
        ER_CH01, ER_CH02, ER_CH03, ER_CH04,
        PPI_CH01, PPI_CH02, PPI_CH03, PPI_CH04,
        HTU_CH01, HTU_CH02, HTU_CH03, HTU_CH04,
        IMPD_CH01_C,
        OMPDM_CH01_C, OMPDM_CH02_C, OMPDM_CH03_C, OMPDM_CH04_C,
        OMPDS_CH01_C, OMPDS_CH02_C, OMPDS_CH03_C, OMPDS_CH04_C,
        Onchip_loss_CH01_MPD, Onchip_loss_CH02_MPD, Onchip_loss_CH03_MPD, Onchip_loss_CH04_MPD,
        MPD_Loss_range,
        OMPDM_CH01_db, OMPDM_CH02_db, OMPDM_CH03_db, OMPDM_CH04_db,
        OMPDS_CH01_db, OMPDS_CH02_db, OMPDS_CH03_db, OMPDS_CH04_db
    )
    SELECT
        v.UEC_Onchip,
        v.CH01, v.CH02, v.CH03, v.CH04, v.Loss_range,
        v.ER_CH01, v.ER_CH02, v.ER_CH03, v.ER_CH04,
        v.PPI_CH01, v.PPI_CH02, v.PPI_CH03, v.PPI_CH04,
        v.HTU_CH01, v.HTU_CH02, v.HTU_CH03, v.HTU_CH04,
        v.IMPD_CH01_C,
        v.OMPDM_CH01_C, v.OMPDM_CH02_C, v.OMPDM_CH03_C, v.OMPDM_CH04_C,
        v.OMPDS_CH01_C, v.OMPDS_CH02_C, v.OMPDS_CH03_C, v.OMPDS_CH04_C,
        v.Onchip_loss_CH01_MPD, v.Onchip_loss_CH02_MPD, v.Onchip_loss_CH03_MPD, v.Onchip_loss_CH04_MPD,
        v.MPD_Loss_range,
        v.OMPDM_CH01_db, v.OMPDM_CH02_db, v.OMPDM_CH03_db, v.OMPDM_CH04_db,
        v.OMPDS_CH01_db, v.OMPDS_CH02_db, v.OMPDS_CH03_db, v.OMPDS_CH04_db
    FROM dbo.vw_CPTestData_Coral3p1 v
    WHERE v.LotWafer = @LotWafer
      AND v.ChipSN   = @ChipSN
      AND v.isRecent = 1;

    IF NOT EXISTS (SELECT 1 FROM @v)
    BEGIN
        RETURN 0;  -- 找不到数据
    END;

    -- =============================================
    -- 3. 非数值检查
    --    任一必需判定列为空，直接 Bin2
    -- =============================================
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

    -- 若 MPD_Loss_range 未落表，则按 4 个 MPD loss 现算
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

    -- =============================================
    -- 4. 取 whole wafer 的 mean/std，生成 UEC 动态上下限
    --    动态范围 = mean ± 2.5 * std
    --    最终范围 = clamp(动态范围, 1.5, 8.5)
    -- =============================================
    DECLARE @mean         FLOAT;
    DECLARE @std          FLOAT;
    DECLARE @uec_upper    FLOAT;
    DECLARE @uec_lower    FLOAT;

    SELECT TOP (1)
           @mean = l.[Mean],
           @std  = l.[Std]
    FROM dbo.LotWafer_UEC_Mean_Std l
    JOIN dbo.CPTest_File f
      ON f.LotWafer = l.LotWafer
     AND f.isRecent = 1
    WHERE l.LotWafer = @LotWafer
      AND l.Cdt >= f.FileModifiedTime
    ORDER BY l.Cdt DESC;

    IF @mean IS NULL OR @std IS NULL
    BEGIN
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

    -- 5.1 UEC_Onchip
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE UEC_Onchip < @uec_lower
           OR UEC_Onchip > @uec_upper
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.2 onchip_loss_optical：CH01~CH04，8~11 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE CH01 < @loss_low OR CH01 > @loss_high
           OR CH02 < @loss_low OR CH02 > @loss_high
           OR CH03 < @loss_low OR CH03 > @loss_high
           OR CH04 < @loss_low OR CH04 > @loss_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.3 loss_range：<= 1 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE Loss_range > @loss_range_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.4 onchip_loss_mpd：8.5~10.5 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE Onchip_loss_CH01_MPD < @mpd_loss_low OR Onchip_loss_CH01_MPD > @mpd_loss_high
           OR Onchip_loss_CH02_MPD < @mpd_loss_low OR Onchip_loss_CH02_MPD > @mpd_loss_high
           OR Onchip_loss_CH03_MPD < @mpd_loss_low OR Onchip_loss_CH03_MPD > @mpd_loss_high
           OR Onchip_loss_CH04_MPD < @mpd_loss_low OR Onchip_loss_CH04_MPD > @mpd_loss_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.5 loss_mpd_range：<= 1 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE MPD_Loss_range > @mpd_loss_range
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.6 mpd dark currents：10~300 nA
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE IMPD_CH01_C  < @dc_low OR IMPD_CH01_C  > @dc_high
           OR OMPDM_CH01_C < @dc_low OR OMPDM_CH01_C > @dc_high
           OR OMPDM_CH02_C < @dc_low OR OMPDM_CH02_C > @dc_high
           OR OMPDM_CH03_C < @dc_low OR OMPDM_CH03_C > @dc_high
           OR OMPDM_CH04_C < @dc_low OR OMPDM_CH04_C > @dc_high
           OR OMPDS_CH01_C < @dc_low OR OMPDS_CH01_C > @dc_high
           OR OMPDS_CH02_C < @dc_low OR OMPDS_CH02_C > @dc_high
           OR OMPDS_CH03_C < @dc_low OR OMPDS_CH03_C > @dc_high
           OR OMPDS_CH04_C < @dc_low OR OMPDS_CH04_C > @dc_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.7 Heater Resistance：110~140 ohm
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE HTU_CH01 < @ht_low OR HTU_CH01 > @ht_high
           OR HTU_CH02 < @ht_low OR HTU_CH02 > @ht_high
           OR HTU_CH03 < @ht_low OR HTU_CH03 > @ht_high
           OR HTU_CH04 < @ht_low OR HTU_CH04 > @ht_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.8 PPI：8~13 mW/pi
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE PPI_CH01 < @ppi_low OR PPI_CH01 > @ppi_high
           OR PPI_CH02 < @ppi_low OR PPI_CH02 > @ppi_high
           OR PPI_CH03 < @ppi_low OR PPI_CH03 > @ppi_high
           OR PPI_CH04 < @ppi_low OR PPI_CH04 > @ppi_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.9 ompd_range：max(db) - min(db) <= 1.5 dB
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
                (v.OMPDM_CH01_db),
                (v.OMPDM_CH02_db),
                (v.OMPDM_CH03_db),
                (v.OMPDM_CH04_db),
                (v.OMPDS_CH01_db),
                (v.OMPDS_CH02_db),
                (v.OMPDS_CH03_db),
                (v.OMPDS_CH04_db)
            ) AS x(db_value)
        ) ca
        WHERE ca.max_db - ca.min_db > @ompd_range_high
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.10 mpdm_mpds_dev：ABS(OMPDM_CHxx_db - OMPDS_CHxx_db) <= 0.5 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE ABS(OMPDM_CH01_db - OMPDS_CH01_db) > @mpdm_mpds_dev
           OR ABS(OMPDM_CH02_db - OMPDS_CH02_db) > @mpdm_mpds_dev
           OR ABS(OMPDM_CH03_db - OMPDS_CH03_db) > @mpdm_mpds_dev
           OR ABS(OMPDM_CH04_db - OMPDS_CH04_db) > @mpdm_mpds_dev
    )
    BEGIN
        SET @fail = 1;
    END;

    -- 5.11 ER：>= 25 dB
    IF EXISTS
    (
        SELECT 1
        FROM @v
        WHERE ER_CH01 < @er_low
           OR ER_CH02 < @er_low
           OR ER_CH03 < @er_low
           OR ER_CH04 < @er_low
    )
    BEGIN
        SET @fail = 1;
    END;

    -- =============================================
    -- 6. Bin 判定
    -- =============================================
    IF @fail = 0
    BEGIN
        RETURN 1;
    END;

    RETURN 2;
END