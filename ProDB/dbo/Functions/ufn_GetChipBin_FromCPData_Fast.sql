/*
Create by Jackiech on 2026-04-16
SELECT dbo.ufn_GetChipBin_FromCPData_Fast('LN41477-W01', 'E07-403') AS Bin
--Coral3p1
select w.Wafer号,d.Cbin,d.Bin, dbo.ufn_GetChipBin_FromCPData_Fast(d.LotWafer, d.Cbin) as MES_Bin
    from dbo.Die d
    join dbo.Wafer w on d.LotWafer=w.Wafer号
    where w.测试结束时间 between '2026-03-01' and  '2026-03-01 8:00' and d.Bin not in (0,3) and w.SourceName like 'Coral3p1%'
    and case when d.Bin in (4,5) then 1 else d.Bin end<>dbo.ufn_GetChipBin_FromCPData_Fast(d.LotWafer, d.Cbin)
--Coral6p0
select *, dbo.ufn_GetChipBin_FromCPData_Fast(w82.LotWafer,w82.Cbin) as MES_Bin from dbo.Die_WrongBin7_82Wafer w82
    where w82.Bin=7 and w82.Bin_V3<>dbo.ufn_GetChipBin_FromCPData_Fast(w82.LotWafer,w82.Cbin)

Change Log:
2026-04-17 JC: Bugfix.
2026-04-16 JC: 基于ufn_GetChipBin_FromCPData修改而来， 使用dbo.LotWafer_Die_CP_Parameter提高效率
2026-04-10 JC: bugfix, 修正取@mean @std的逻辑
2026-04-09 JC: 改用[dbo].[ufn_GetChipBin_FromCPData_Fast_Coral3p1]的判断方式; 增加Debug信息
2026-04-09 JC: 无测试结果， 返回0； 无部分测试项， 返回2
2026-04-02 JC: 使用dbo.LotWafer_UEC_Mean_Std 取代 ufn_GetUEC_Bounds/ufn_GetUEC_Mean_Std/dbo.LotWafer_UEC_Data
2026-04-01 JC: (临时)使用dbo.LotWafer_UEC_Data 取代 ufn_GetUEC_Bounds
*/
CREATE FUNCTION [dbo].[ufn_GetChipBin_FromCPData_Fast]
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
    SELECT @ProductFamily=left(w.SourceName,8) from dbo.Wafer w where w.Wafer号=@LotWafer
    
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
    DECLARE @uec_te_low         FLOAT
    DECLARE @uec_te_high         FLOAT
    DECLARE @uec_tm_low         FLOAT
    DECLARE @uec_tm_high         FLOAT

    DECLARE @spec_uec_low            FLOAT
    DECLARE @spec_uec_high           FLOAT
    DECLARE @spec_std_multiplier     FLOAT
    DECLARE @spec_loss_low           FLOAT
    DECLARE @spec_loss_high          FLOAT
    DECLARE @spec_loss_range_high    FLOAT
    DECLARE @spec_ompd_range_high    FLOAT
    DECLARE @spec_mpdm_mpds_dev      FLOAT
    DECLARE @spec_er_low             FLOAT
    DECLARE @spec_ppi_low            FLOAT
    DECLARE @spec_ppi_high           FLOAT
    DECLARE @spec_ht_low             FLOAT
    DECLARE @spec_ht_high            FLOAT
    DECLARE @spec_dc_low             FLOAT
    DECLARE @spec_dc_high            FLOAT
    DECLARE @spec_mpd_loss_low       FLOAT
    DECLARE @spec_mpd_loss_high      FLOAT
    DECLARE @spec_mpd_loss_range     FLOAT
    DECLARE @spec_uec_te_low         FLOAT
    DECLARE @spec_uec_te_high         FLOAT
    DECLARE @spec_uec_tm_low         FLOAT
    DECLARE @spec_uec_tm_high         FLOAT

    IF NOT EXISTS (SELECT 1 FROM dbo.LotWafer_Die_CP_Parameter p WHERE p.LotWafer = @LotWafer AND p.ChipSN = @ChipSN)
    BEGIN
        RETURN 0
    END

    SELECT
        @uec_low         = p.uec_onchip_low,
        @uec_high        = p.uec_conchip_high,
        @std_multiplier  = p.uec_onchip_std,
        @loss_low        = p.onchip_loss_optical_low,
        @loss_high       = p.onchip_loss_optical_high,
        @loss_range_high = p.loss_range_high,
        @ompd_range_high = p.ompd_range_high,
        @mpdm_mpds_dev   = p.mpdm_mpds_dev,
        @er_low          = p.ER_low,
        @ppi_low         = p.ppi_low,
        @ppi_high        = p.ppi_high,
        @ht_low          = p.heater_resistance_low,
        @ht_high         = p.heater_resistance_high,
        @dc_low          = p.dark_current_low,
        @dc_high         = p.dark_current_high,
        @mpd_loss_low    = p.onchip_loss_mpd_low,
        @mpd_loss_high   = p.onchip_loss_mpd_high,
        @mpd_loss_range  = p.mpd_loss_range_high,
        @uec_te_low     = p.uec_te_low,
        @uec_te_high    = p.uec_te_high,
        @uec_tm_low     = p.uec_tm_low,
        @uec_tm_high    = p.uec_tm_high
    FROM dbo.LotWafer_Die_CP_Parameter p
    WHERE p.LotWafer = @LotWafer and p.ChipSN = @ChipSN

    SELECT
        @spec_uec_low         = MAX(CASE WHEN v.ParameterKey = 'uec_onchip_low'          THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_uec_high        = MAX(CASE WHEN v.ParameterKey = 'uec_conchip_high'        THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_std_multiplier  = MAX(CASE WHEN v.ParameterKey = 'uec_onchip_std'          THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_loss_low        = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_optical_low' THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_loss_high       = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_optical_high'THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_loss_range_high = MAX(CASE WHEN v.ParameterKey = 'loss_range_high'         THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_ompd_range_high = MAX(CASE WHEN v.ParameterKey = 'ompd_range_high'         THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_mpdm_mpds_dev   = MAX(CASE WHEN v.ParameterKey = 'mpdm_mpds_dev'           THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_er_low          = MAX(CASE WHEN v.ParameterKey = 'ER_low'                  THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_ppi_low         = MAX(CASE WHEN v.ParameterKey = 'ppi_low'                 THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_ppi_high        = MAX(CASE WHEN v.ParameterKey = 'ppi_high'                THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_ht_low          = MAX(CASE WHEN v.ParameterKey = 'heater_resistance_low'   THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_ht_high         = MAX(CASE WHEN v.ParameterKey = 'heater_resistance_high'  THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_dc_low          = MAX(CASE WHEN v.ParameterKey = 'dark_current_low'        THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_dc_high         = MAX(CASE WHEN v.ParameterKey = 'dark_current_high'       THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_mpd_loss_low    = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_mpd_low'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_mpd_loss_high   = MAX(CASE WHEN v.ParameterKey = 'onchip_loss_mpd_high'    THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_mpd_loss_range  = MAX(CASE WHEN v.ParameterKey = 'mpd_loss_range_high'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_uec_te_low     = MAX(CASE WHEN v.ParameterKey = 'uec_te_low'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_uec_te_high    = MAX(CASE WHEN v.ParameterKey = 'uec_te_high'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_uec_tm_low     = MAX(CASE WHEN v.ParameterKey = 'uec_tm_low'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END),
        @spec_uec_tm_high    = MAX(CASE WHEN v.ParameterKey = 'uec_tm_high'     THEN TRY_CONVERT(FLOAT, v.SpecValue) END)
    FROM spec.vw_ProductFamilySpec v
    WHERE v.ProductFamily = @ProductFamily
      AND v.IsActive = 1

    -- =============================================
    -- 6. Bin 判定
    -- =============================================
    DECLARE @BasePass bit = 0;
    IF (@uec_low>@spec_uec_low or @spec_uec_low is null)
       AND (@uec_high<@spec_uec_high or @spec_uec_high is null)
       AND (@std_multiplier<@spec_std_multiplier or @spec_std_multiplier is null)
       AND (@loss_low>@spec_loss_low or @spec_loss_low is null)
       AND (@loss_high<@spec_loss_high or @spec_loss_high is null)
       AND (@loss_range_high<@spec_loss_range_high or @spec_loss_range_high is null)
       AND (@ompd_range_high<@spec_ompd_range_high or @spec_ompd_range_high is null)
       AND (@mpdm_mpds_dev<@spec_mpdm_mpds_dev or @spec_mpdm_mpds_dev is null)
       AND (@ppi_low>@spec_ppi_low or @spec_ppi_low is null)
       AND (@ppi_high<@spec_ppi_high or @spec_ppi_high is null)
       AND (@ht_low>@spec_ht_low or @spec_ht_low is null)
       AND (@ht_high<@spec_ht_high or @spec_ht_high is null)
       AND (@dc_low>@spec_dc_low or @spec_dc_low is null)
       AND (@dc_high<@spec_dc_high or @spec_dc_high is null)
       AND (@mpd_loss_low>@spec_mpd_loss_low or @spec_mpd_loss_low is null)
       AND (@mpd_loss_high<@spec_mpd_loss_high or @spec_mpd_loss_high is null)
       AND (@mpd_loss_range<@spec_mpd_loss_range or @spec_mpd_loss_range is null)
       AND (@uec_te_low>@spec_uec_te_low or @spec_uec_te_low is null)
       AND (@uec_te_high<@spec_uec_te_high or @spec_uec_te_high is null)
       AND (@uec_tm_low>@spec_uec_tm_low or @spec_uec_tm_low is null)
       AND (@uec_tm_high<@spec_uec_tm_high or @spec_uec_tm_high is null)
    BEGIN
        SET @BasePass = 1
    END

    IF @BasePass = 1 AND @ProductFamily='Coral6p0' AND @er_low > 23 AND @er_low <= 24
        RETURN 7

    IF @BasePass = 1 AND @ProductFamily='Coral6p0' AND @er_low > 24 AND @er_low < @spec_er_low
        RETURN 8

    IF @BasePass = 1 AND @er_low >= @spec_er_low
        RETURN 1

    RETURN 2

END