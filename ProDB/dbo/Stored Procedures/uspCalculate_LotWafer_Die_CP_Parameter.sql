/*
-- =============================================
-- Author:      Jackie Chen
-- Create date: 2026-04-16
-- Description: 计算 LotWafer + ChipSN 的, 检查Spec会用到的， 18 项 计算结果 到 dbo.LotWafer_Die_CP_Parameter
-- Notes:       数据来源 LotWafer_UEC_Mean_Std (FinishDieParameter=0)
exec [dbo].[uspCalculate_LotWafer_Die_CP_Parameter] @LotWafer = 'LE74796-W18'

TODO：修改 dbo.LotWafer_Die_CP_Parameter，兼容 Coral4p5

Change Log:
2026-04-21 JC: Use Ddbo.ProductModel;
2026-04-17 JC: @ProductFamily_8bit 扩展到 Coral3p1/Coral3p5/CORAL5P3/Coral4p1/Coral6p0/Coral6p3/Coral4p5 7种; Add [IMPD_CH03_C],[IMPD_CH04_C]
-- =============================================
*/
CREATE     PROCEDURE [dbo].[uspCalculate_LotWafer_Die_CP_Parameter](
@LotWafer varchar(20)
)
AS
BEGIN
    SET NOCOUNT ON;

    --Test
    --Declare @LotWafer varchar(20) = 'LE74796-W18'
    IF NOT EXISTS(SELECT * FROM dbo.LotWafer_UEC_Mean_Std s
        WHERE s.LotWafer = @LotWafer AND s.FinishDieParameter = 0)
        RETURN
    
    DECLARE @Now DATETIME = GETDATE();
    DECLARE @ProductFamily_8bit varchar(20), @ChannelNum INT, @impdNum INT
    SELECT @ProductFamily_8bit = LEFT(w.SourceName, 8)
        FROM dbo.Wafer w
        WHERE w.Wafer号 = @LotWafer;
    SELECT @ChannelNum=P.Spec_ChannelNum, @impdNum=P.Spec_impdNum FROM dbo.ProductModel P WHERE P.ProductModel=@ProductFamily_8bit
    IF @ChannelNum IS NULL
        RETURN

    DECLARE @CPFileTime DATETIME, @Mean FLOAT, @Std FLOAT
    SELECT @CPFileTime = l.CPFileTime, @Mean = l.Mean, @Std = l.Std
        FROM dbo.LotWafer_UEC_Mean_Std l WHERE l.LotWafer = @LotWafer

    IF OBJECT_ID('tempdb..#CalculateResult') IS NOT NULL DROP TABLE #CalculateResult;
    CREATE TABLE #CalculateResult
    (
        LotWafer                 VARCHAR(50) NOT NULL,
        ChipSN                  VARCHAR(50) NOT NULL,
        dark_current_low         FLOAT NULL,
        dark_current_high        FLOAT NULL,
        uec_onchip_low           FLOAT NULL,
        uec_conchip_high         FLOAT NULL,
        onchip_loss_optical_low  FLOAT NULL,
        onchip_loss_optical_high FLOAT NULL,
        heater_resistance_low    FLOAT NULL,
        heater_resistance_high   FLOAT NULL,
        ppi_low                  FLOAT NULL,
        ppi_high                 FLOAT NULL,
        onchip_loss_mpd_low      FLOAT NULL,
        onchip_loss_mpd_high     FLOAT NULL,
        ER_low                   FLOAT NULL,
        loss_range_high          FLOAT NULL,
        mpd_loss_range_high      FLOAT NULL,
        ompd_range_high          FLOAT NULL,
        mpdm_mpds_dev            FLOAT NULL,
        uec_onchip_std           FLOAT NULL,
        uec_te_low              FLOAT NULL,
        uec_te_high             FLOAT NULL,
        uec_tm_low              FLOAT NULL,
        uec_tm_high             FLOAT NULL        
    );

    IF @ProductFamily_8bit in ('Coral4p5')
    BEGIN
        INSERT INTO #CalculateResult
        (
            LotWafer, ChipSN
            , dark_current_low
            , dark_current_high
            , uec_onchip_low
            , uec_conchip_high
            , onchip_loss_optical_low
            , onchip_loss_optical_high
            , heater_resistance_low
            , heater_resistance_high
            , ppi_low
            , ppi_high
            , onchip_loss_mpd_low
            , onchip_loss_mpd_high
            , ER_low
            , loss_range_high
            , mpd_loss_range_high
            , ompd_range_high
            , mpdm_mpds_dev
            , uec_onchip_std
            , uec_te_low
            , uec_te_high
            , uec_tm_low
            , uec_tm_high
        )
        SELECT cp.LotWafer, cp.ChipSN
            , ca.MinDc
            , ca.MaxDc
            , cp.UEC_Onchip
            , cp.UEC_Onchip
            , cc.MinCH
            , cc.MaxCH
            , cd.MinHTU
            , cd.MaxHTU
            , ce.MinPPI
            , ce.MaxPPI
            , cf.MinMPDLoss
            , cf.MaxMPDLoss
            , cg.MinER
            , cp.Loss_range
            , cp.Range_onchip_loss_mpd
            , ch.OmpdRange
            , ci.MaxDev
            , ABS(cp.UEC_Onchip - @Mean)/@Std
            , cj.MinTe
            , cj.MaxTe
            , ck.MinTm
            , ck.MaxTm
        FROM dbo.vw_CPTestData cp
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinDc,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxDc
            FROM (VALUES
                ('IMPD' , 1, cp.IMPD_CH01_C),
                ('IMPD' , 2, cp.IMPD_CH02_C),
                ('IMPD' , 3, cp.IMPD_CH03_C),
                ('IMPD' , 4, cp.IMPD_CH04_C),
                ('OMPDM', 1, cp.OMPDM_CH01_C),
                ('OMPDM', 2, cp.OMPDM_CH02_C),
                ('OMPDM', 3, cp.OMPDM_CH03_C),
                ('OMPDM', 4, cp.OMPDM_CH04_C),
                ('OMPDM', 5, cp.OMPDM_CH05_C),
                ('OMPDM', 6, cp.OMPDM_CH06_C),
                ('OMPDM', 7, cp.OMPDM_CH07_C),
                ('OMPDM', 8, cp.OMPDM_CH08_C),
                ('OMPDS', 1, cp.OMPDS_CH01_C),
                ('OMPDS', 2, cp.OMPDS_CH02_C),
                ('OMPDS', 3, cp.OMPDS_CH03_C),
                ('OMPDS', 4, cp.OMPDS_CH04_C),
                ('OMPDS', 5, cp.OMPDS_CH05_C),
                ('OMPDS', 6, cp.OMPDS_CH06_C),
                ('OMPDS', 7, cp.OMPDS_CH07_C),
                ('OMPDS', 8, cp.OMPDS_CH08_C)
            ) AS x(src_type, ch_no, Val)
            WHERE (
                (x.src_type = 'IMPD' AND x.ch_no <= @impdNum)
                OR
                (x.src_type IN ('OMPDM', 'OMPDS') AND x.ch_no <= @ChannelNum)
                )
        ) ca
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinCH,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxCH
            FROM (VALUES
                --Onchip_CH{ChannelNum}
                (1, cp.Onchip_CH01),
                (2, cp.Onchip_CH02),
                (3, cp.Onchip_CH03),
                (4, cp.Onchip_CH04),
                (5, cp.Onchip_CH05),
                (6, cp.Onchip_CH06),
                (7, cp.Onchip_CH07),
                (8, cp.Onchip_CH08)
            ) x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cc
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinHTU,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxHTU
            FROM (VALUES
                (1, cp.HTU_CH01),
                (2, cp.HTU_CH02),
                (3, cp.HTU_CH03),
                (4, cp.HTU_CH04),
                (5, cp.HTU_CH05),
                (6, cp.HTU_CH06),
                (7, cp.HTU_CH07),
                (8, cp.HTU_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cd
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinPPI,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxPPI
            FROM (VALUES
                (1, cp.PPI_CH01),
                (2, cp.PPI_CH02),
                (3, cp.PPI_CH03),
                (4, cp.PPI_CH04),
                (5, cp.PPI_CH05),
                (6, cp.PPI_CH06),
                (7, cp.PPI_CH07),
                (8, cp.PPI_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ce
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinMPDLoss,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxMPDLoss
            FROM (VALUES
                (1, cp.Onchip_MPD_CH01),
                (2, cp.Onchip_MPD_CH02),
                (3, cp.Onchip_MPD_CH03),
                (4, cp.Onchip_MPD_CH04),
                (5, cp.Onchip_MPD_CH05),
                (6, cp.Onchip_MPD_CH06),
                (7, cp.Onchip_MPD_CH07),
                (8, cp.Onchip_MPD_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cf
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinER
            FROM (VALUES
                (1, cp.ER_CH01),
                (2, cp.ER_CH02),
                (3, cp.ER_CH03),
                (4, cp.ER_CH04),
                (5, cp.ER_CH05),
                (6, cp.ER_CH06),
                (7, cp.ER_CH07),
                (8, cp.ER_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cg
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) - MIN(x.Val) END AS OmpdRange
            FROM (VALUES
                (1, cp.OMPDM_CH01_db),
                (2, cp.OMPDM_CH02_db),
                (3, cp.OMPDM_CH03_db),
                (4, cp.OMPDM_CH04_db),
                (5, cp.OMPDM_CH05_db),
                (6, cp.OMPDM_CH06_db),
                (7, cp.OMPDM_CH07_db),
                (8, cp.OMPDM_CH08_db),
                (1, cp.OMPDS_CH01_db),
                (2, cp.OMPDS_CH02_db),
                (3, cp.OMPDS_CH03_db),
                (4, cp.OMPDS_CH04_db),
                (5, cp.OMPDS_CH05_db),
                (6, cp.OMPDS_CH06_db),
                (7, cp.OMPDS_CH07_db),
                (8, cp.OMPDS_CH08_db)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ch
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxDev
            FROM (VALUES
                --ABS(OMPDM_CH{ChannelNum}_OC_db-OMPDS_CH{ChannelNum}_OC_db)
                (1, ABS(cp.OMPDM_CH01_OC_db - cp.OMPDS_CH01_OC_db)),
                (2, ABS(cp.OMPDM_CH02_OC_db - cp.OMPDS_CH02_OC_db)),
                (3, ABS(cp.OMPDM_CH03_OC_db - cp.OMPDS_CH03_OC_db)),
                (4, ABS(cp.OMPDM_CH04_OC_db - cp.OMPDS_CH04_OC_db)),
                (5, ABS(cp.OMPDM_CH05_OC_db - cp.OMPDS_CH05_OC_db)),
                (6, ABS(cp.OMPDM_CH06_OC_db - cp.OMPDS_CH06_OC_db)),
                (7, ABS(cp.OMPDM_CH07_OC_db - cp.OMPDS_CH07_OC_db)),
                (8, ABS(cp.OMPDM_CH08_OC_db - cp.OMPDS_CH08_OC_db))
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ci
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MinTe,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxTe
            FROM (VALUES
                (1, cp.UEC_Onchip_TE_1271),
                (2, cp.UEC_Onchip_TE_1311)
            ) AS x(ch_no, Val)
        ) cj
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MinTm,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxTm
            FROM (VALUES
                (1, cp.UEC_Onchip_TM_1291),
                (2, cp.UEC_Onchip_TM_1331)
            ) AS x(ch_no, Val)
        ) ck
        WHERE cp.LotWafer = @LotWafer and cp.FileModifiedTime = @CPFileTime
    END
    ELSE
    BEGIN
        INSERT INTO #CalculateResult
        (
            LotWafer, ChipSN
            , dark_current_low
            , dark_current_high
            , uec_onchip_low
            , uec_conchip_high
            , onchip_loss_optical_low
            , onchip_loss_optical_high
            , heater_resistance_low
            , heater_resistance_high
            , ppi_low
            , ppi_high
            , onchip_loss_mpd_low
            , onchip_loss_mpd_high
            , ER_low
            , loss_range_high
            , mpd_loss_range_high
            , ompd_range_high
            , mpdm_mpds_dev
            , uec_onchip_std
        )
        SELECT cp.LotWafer, cp.ChipSN
            , ca.MinDc
            , ca.MaxDc
            , cp.UEC_Onchip
            , cp.UEC_Onchip
            , cc.MinCH
            , cc.MaxCH
            , cd.MinHTU
            , cd.MaxHTU
            , ce.MinPPI
            , ce.MaxPPI
            , cf.MinMPDLoss
            , cf.MaxMPDLoss
            , cg.MinER
            , cp.Loss_range
            , cp.MPD_Loss_range
            , ch.OmpdRange
            , ci.MaxDev
            , ABS(cp.UEC_Onchip - @Mean)/@Std
        FROM dbo.vw_CPTestData cp
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinDc,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxDc
            FROM (VALUES
                ('IMPD' , 1, cp.IMPD_CH01_C),
                ('IMPD' , 2, cp.IMPD_CH02_C),
                ('IMPD' , 3, cp.IMPD_CH03_C),
                ('IMPD' , 4, cp.IMPD_CH04_C),
                ('OMPDM', 1, cp.OMPDM_CH01_C),
                ('OMPDM', 2, cp.OMPDM_CH02_C),
                ('OMPDM', 3, cp.OMPDM_CH03_C),
                ('OMPDM', 4, cp.OMPDM_CH04_C),
                ('OMPDM', 5, cp.OMPDM_CH05_C),
                ('OMPDM', 6, cp.OMPDM_CH06_C),
                ('OMPDM', 7, cp.OMPDM_CH07_C),
                ('OMPDM', 8, cp.OMPDM_CH08_C),
                ('OMPDS', 1, cp.OMPDS_CH01_C),
                ('OMPDS', 2, cp.OMPDS_CH02_C),
                ('OMPDS', 3, cp.OMPDS_CH03_C),
                ('OMPDS', 4, cp.OMPDS_CH04_C),
                ('OMPDS', 5, cp.OMPDS_CH05_C),
                ('OMPDS', 6, cp.OMPDS_CH06_C),
                ('OMPDS', 7, cp.OMPDS_CH07_C),
                ('OMPDS', 8, cp.OMPDS_CH08_C)
            ) AS x(src_type, ch_no, Val)
            WHERE (
                (x.src_type = 'IMPD' AND x.ch_no <= @impdNum)
                OR
                (x.src_type IN ('OMPDM', 'OMPDS') AND x.ch_no <= @ChannelNum)
                )
        ) ca
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinCH,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxCH
            FROM (VALUES
                (1, cp.CH01),
                (2, cp.CH02),
                (3, cp.CH03),
                (4, cp.CH04),
                (5, cp.CH05),
                (6, cp.CH06),
                (7, cp.CH07),
                (8, cp.CH08)
            ) x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cc
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinHTU,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxHTU
            FROM (VALUES
                (1, cp.HTU_CH01),
                (2, cp.HTU_CH02),
                (3, cp.HTU_CH03),
                (4, cp.HTU_CH04),
                (5, cp.HTU_CH05),
                (6, cp.HTU_CH06),
                (7, cp.HTU_CH07),
                (8, cp.HTU_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cd
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinPPI,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxPPI
            FROM (VALUES
                (1, cp.PPI_CH01),
                (2, cp.PPI_CH02),
                (3, cp.PPI_CH03),
                (4, cp.PPI_CH04),
                (5, cp.PPI_CH05),
                (6, cp.PPI_CH06),
                (7, cp.PPI_CH07),
                (8, cp.PPI_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ce
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinMPDLoss,
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxMPDLoss
            FROM (VALUES
                (1, cp.Onchip_loss_CH01_MPD),
                (2, cp.Onchip_loss_CH02_MPD),
                (3, cp.Onchip_loss_CH03_MPD),
                (4, cp.Onchip_loss_CH04_MPD),
                (5, cp.Onchip_loss_CH05_MPD),
                (6, cp.Onchip_loss_CH06_MPD),
                (7, cp.Onchip_loss_CH07_MPD),
                (8, cp.Onchip_loss_CH08_MPD)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cf
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS MinER
            FROM (VALUES
                (1, cp.ER_CH01),
                (2, cp.ER_CH02),
                (3, cp.ER_CH03),
                (4, cp.ER_CH04),
                (5, cp.ER_CH05),
                (6, cp.ER_CH06),
                (7, cp.ER_CH07),
                (8, cp.ER_CH08)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) cg
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) - MIN(x.Val) END AS OmpdRange
            FROM (VALUES
                (1, cp.OMPDM_CH01_db),
                (2, cp.OMPDM_CH02_db),
                (3, cp.OMPDM_CH03_db),
                (4, cp.OMPDM_CH04_db),
                (5, cp.OMPDM_CH05_db),
                (6, cp.OMPDM_CH06_db),
                (7, cp.OMPDM_CH07_db),
                (8, cp.OMPDM_CH08_db),
                (1, cp.OMPDS_CH01_db),
                (2, cp.OMPDS_CH02_db),
                (3, cp.OMPDS_CH03_db),
                (4, cp.OMPDS_CH04_db),
                (5, cp.OMPDS_CH05_db),
                (6, cp.OMPDS_CH06_db),
                (7, cp.OMPDS_CH07_db),
                (8, cp.OMPDS_CH08_db)
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ch
        CROSS APPLY
        (
            SELECT
                CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS MaxDev
            FROM (VALUES
                (1, ABS(cp.OMPDM_CH01_db - cp.OMPDS_CH01_db)),
                (2, ABS(cp.OMPDM_CH02_db - cp.OMPDS_CH02_db)),
                (3, ABS(cp.OMPDM_CH03_db - cp.OMPDS_CH03_db)),
                (4, ABS(cp.OMPDM_CH04_db - cp.OMPDS_CH04_db)),
                (5, ABS(cp.OMPDM_CH05_db - cp.OMPDS_CH05_db)),
                (6, ABS(cp.OMPDM_CH06_db - cp.OMPDS_CH06_db)),
                (7, ABS(cp.OMPDM_CH07_db - cp.OMPDS_CH07_db)),
                (8, ABS(cp.OMPDM_CH08_db - cp.OMPDS_CH08_db))
            ) AS x(ch_no, Val)
            WHERE x.ch_no <= @ChannelNum
        ) ci
        WHERE cp.LotWafer = @LotWafer and cp.FileModifiedTime = @CPFileTime
    END

    -- when mpd_loss_range_high is null， calculate..
    IF EXISTS(SELECT 1 FROM #CalculateResult z WHERE z.mpd_loss_range_high IS NULL)
    BEGIN
        UPDATE r SET r.mpd_loss_range_high = ca.max_loss - ca.min_loss
            FROM #CalculateResult r
            JOIN dbo.vw_CPTestData cp on r.LotWafer=cp.LotWafer and r.ChipSN=cp.ChipSN and cp.FileModifiedTime = @CPFileTime
            CROSS APPLY
            (
                SELECT
                    CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MIN(x.Val) END AS min_loss,
                    CASE WHEN COUNT(*) <> COUNT(x.Val) THEN NULL ELSE MAX(x.Val) END AS max_loss
                FROM (VALUES
                    (1, cp.Onchip_loss_CH01_MPD),
                    (2, cp.Onchip_loss_CH02_MPD),
                    (3, cp.Onchip_loss_CH03_MPD),
                    (4, cp.Onchip_loss_CH04_MPD),
                    (5, cp.Onchip_loss_CH05_MPD),
                    (6, cp.Onchip_loss_CH06_MPD),
                    (7, cp.Onchip_loss_CH07_MPD),
                    (8, cp.Onchip_loss_CH08_MPD)
                ) AS x(ch_no, Val)
                WHERE x.ch_no <= @ChannelNum
            ) ca
    END

    MERGE dbo.LotWafer_Die_CP_Parameter AS tgt
    USING
    (
        SELECT
            s.LotWafer
            , s.ChipSN
            , s.dark_current_low
            , s.dark_current_high
            , s.uec_onchip_low
            , s.uec_conchip_high
            , s.onchip_loss_optical_low
            , s.onchip_loss_optical_high
            , s.heater_resistance_low
            , s.heater_resistance_high
            , s.ppi_low
            , s.ppi_high
            , s.onchip_loss_mpd_low
            , s.onchip_loss_mpd_high
            , s.ER_low
            , s.loss_range_high
            , s.mpd_loss_range_high
            , s.ompd_range_high
            , s.mpdm_mpds_dev
            , s.uec_onchip_std
            , s.uec_te_low
            , s.uec_te_high
            , s.uec_tm_low
            , s.uec_tm_high
        FROM #CalculateResult s
    ) src
       ON tgt.LotWafer = src.LotWafer
      AND tgt.ChipSN = src.ChipSN
    WHEN MATCHED THEN
        UPDATE SET
            tgt.dark_current_low = src.dark_current_low,
            tgt.dark_current_high = src.dark_current_high,
            tgt.uec_onchip_low = src.uec_onchip_low,
            tgt.uec_conchip_high = src.uec_conchip_high,
            tgt.onchip_loss_optical_low = src.onchip_loss_optical_low,
            tgt.onchip_loss_optical_high = src.onchip_loss_optical_high,
            tgt.heater_resistance_low = src.heater_resistance_low,
            tgt.heater_resistance_high = src.heater_resistance_high,
            tgt.ppi_low = src.ppi_low,
            tgt.ppi_high = src.ppi_high,
            tgt.onchip_loss_mpd_low = src.onchip_loss_mpd_low,
            tgt.onchip_loss_mpd_high = src.onchip_loss_mpd_high,
            tgt.ER_low = src.ER_low,
            tgt.loss_range_high = src.loss_range_high,
            tgt.mpd_loss_range_high = src.mpd_loss_range_high,
            tgt.ompd_range_high = src.ompd_range_high,
            tgt.mpdm_mpds_dev = src.mpdm_mpds_dev,
            tgt.uec_onchip_std = src.uec_onchip_std,
            tgt.uec_te_low = src.uec_te_low,
            tgt.uec_te_high = src.uec_te_high,
            tgt.uec_tm_low = src.uec_tm_low,
            tgt.uec_tm_high = src.uec_tm_high,
            tgt.Udt = @Now
    WHEN NOT MATCHED BY TARGET THEN
        INSERT
        (
            LotWafer,
            ChipSN,
            dark_current_low,
            dark_current_high,
            uec_onchip_low,
            uec_conchip_high,
            onchip_loss_optical_low,
            onchip_loss_optical_high,
            heater_resistance_low,
            heater_resistance_high,
            ppi_low,
            ppi_high,
            onchip_loss_mpd_low,
            onchip_loss_mpd_high,
            ER_low,
            loss_range_high,
            mpd_loss_range_high,
            ompd_range_high,
            mpdm_mpds_dev,
            uec_onchip_std,
            Cdt,
            Udt,
            uec_te_low,
            uec_te_high,
            uec_tm_low,
            uec_tm_high
        )
        VALUES
        (
            src.LotWafer,
            src.ChipSN,
            src.dark_current_low,
            src.dark_current_high,
            src.uec_onchip_low,
            src.uec_conchip_high,
            src.onchip_loss_optical_low,
            src.onchip_loss_optical_high,
            src.heater_resistance_low,
            src.heater_resistance_high,
            src.ppi_low,
            src.ppi_high,
            src.onchip_loss_mpd_low,
            src.onchip_loss_mpd_high,
            src.ER_low,
            src.loss_range_high,
            src.mpd_loss_range_high,
            src.ompd_range_high,
            src.mpdm_mpds_dev,
            src.uec_onchip_std,
            @Now,
            @Now,
            src.uec_te_low,
            src.uec_te_high,
            src.uec_tm_low,
            src.uec_tm_high
        );

    UPDATE s SET s.FinishDieParameter = 1
        FROM dbo.LotWafer_UEC_Mean_Std s
        WHERE s.LotWafer = @LotWafer
END