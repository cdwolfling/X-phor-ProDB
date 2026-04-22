
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-04-22
-- Description:	比对 研发Binmap VS MES_Binmap
-- Notes:
exec [dbo].[uspReport_BinmapCheck] @ProductFamily='Coral4p1', @WaferList='TG16874-W13,TG16874-W05,TG16874-W12'
exec [dbo].[uspReport_BinmapCheck] @ProductFamily='Coral4p1', @WaferList='TG16874-W13,TG16874-W05,TG16874-W12', @SpecVersion='1.1_F2V1'

Change Log:
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_BinmapCheck]
(
@ProductFamily varchar(10)='Coral6p0',
@WaferList varchar(max)=null,
@SpecVersion varchar(50)=null
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @ProductFamily varchar(10)='Coral6p0'
    --declare @WaferList varchar(max)=null
    --declare @SpecVersion varchar(50)=null
    
    declare @ProductFamily_B varchar(10)
    select @ProductFamily_B=replace(@ProductFamily,'p','.')
    
    -- 1. 准备 #ToCheckUnits 临时表
	IF OBJECT_ID('tempdb..#ToCheckUnits') IS NOT NULL DROP TABLE #ToCheckUnits
	create table #ToCheckUnits(ProductFamily varchar(20), LotWafer varchar(11), ChipSN varchar(11), RD_Bin INT, BasePass bit, MES_Bin int)
	insert #ToCheckUnits(ProductFamily, LotWafer, ChipSN, RD_Bin)
		select w.ProductModel, w.LotWafer, d.Cbin, d.Bin
        from dbo.CPTest_File w
        join dbo.Die d on w.LotWafer=d.LotWafer
        where w.isRecent=1
            and d.Bin not in (0,3)
            and w.LotWafer in (select f.MyColumn from dbo.ufnGetListFromSourceString(@WaferList,',') f where f.MyColumn<>'')

    create clustered index IX_ToCheckDie on #ToCheckUnits(LotWafer, ChipSN, ProductFamily)
	
    -- 1.1 Update RD_Bin for Coral6p0 Bin7Issue
    if exists(select 1 from #ToCheckUnits z where z.ProductFamily='Coral6p0')
    begin
        --ReworkBatch 1
        update d set d.RD_Bin=v3.Bin from #ToCheckUnits d
            join dbo.Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV3 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
            where v3.Bin is not null
        --ReworkBatch 2
        update d set d.RD_Bin=v3.Bin_V3 from #ToCheckUnits d
            join dbo.Die_WrongBin7 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
            where v3.Bin=7 and v3.Bin_V3 is not null
        --ReworkBatch 3
        update d set d.RD_Bin=v3.Bin_V3 from #ToCheckUnits d
            join dbo.Die_WrongBin7_82Wafer v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
            where v3.Bin=7 and v3.Bin_V3 is not null
    end

    -- 2. 先准备 Spec 临时表
    if OBJECT_ID('tempdb..#Spec') is not null drop table #Spec;
    select
        v.ProductFamily,
        max(case when v.ParameterKey = 'uec_onchip_low'           then try_convert(float, v.SpecValue) end) as spec_uec_low,
        max(case when v.ParameterKey = 'uec_conchip_high'         then try_convert(float, v.SpecValue) end) as spec_uec_high,
        max(case when v.ParameterKey = 'uec_onchip_std'           then try_convert(float, v.SpecValue) end) as spec_std_multiplier,
        max(case when v.ParameterKey = 'onchip_loss_optical_low'  then try_convert(float, v.SpecValue) end) as spec_loss_low,
        max(case when v.ParameterKey = 'onchip_loss_optical_high' then try_convert(float, v.SpecValue) end) as spec_loss_high,
        max(case when v.ParameterKey = 'loss_range_high'          then try_convert(float, v.SpecValue) end) as spec_loss_range_high,
        max(case when v.ParameterKey = 'ompd_range_high'          then try_convert(float, v.SpecValue) end) as spec_ompd_range_high,
        max(case when v.ParameterKey = 'mpdm_mpds_dev'            then try_convert(float, v.SpecValue) end) as spec_mpdm_mpds_dev,
        max(case when v.ParameterKey = 'ER_low'                   then try_convert(float, v.SpecValue) end) as spec_er_low,
        max(case when v.ParameterKey = 'ppi_low'                  then try_convert(float, v.SpecValue) end) as spec_ppi_low,
        max(case when v.ParameterKey = 'ppi_high'                 then try_convert(float, v.SpecValue) end) as spec_ppi_high,
        max(case when v.ParameterKey = 'heater_resistance_low'    then try_convert(float, v.SpecValue) end) as spec_ht_low,
        max(case when v.ParameterKey = 'heater_resistance_high'   then try_convert(float, v.SpecValue) end) as spec_ht_high,
        max(case when v.ParameterKey = 'dark_current_low'         then try_convert(float, v.SpecValue) end) as spec_dc_low,
        max(case when v.ParameterKey = 'dark_current_high'        then try_convert(float, v.SpecValue) end) as spec_dc_high,
        max(case when v.ParameterKey = 'onchip_loss_mpd_low'      then try_convert(float, v.SpecValue) end) as spec_mpd_loss_low,
        max(case when v.ParameterKey = 'onchip_loss_mpd_high'     then try_convert(float, v.SpecValue) end) as spec_mpd_loss_high,
        max(case when v.ParameterKey = 'mpd_loss_range_high'      then try_convert(float, v.SpecValue) end) as spec_mpd_loss_range,
        max(case when v.ParameterKey = 'uec_te_low'               then try_convert(float, v.SpecValue) end) as spec_uec_te_low,
        max(case when v.ParameterKey = 'uec_te_high'              then try_convert(float, v.SpecValue) end) as spec_uec_te_high,
        max(case when v.ParameterKey = 'uec_tm_low'               then try_convert(float, v.SpecValue) end) as spec_uec_tm_low,
        max(case when v.ParameterKey = 'uec_tm_high'              then try_convert(float, v.SpecValue) end) as spec_uec_tm_high
        into #Spec
        from spec.vw_ProductFamilySpec v
        where v.ProductFamily=@ProductFamily
        and ((@SpecVersion is null and v.IsActive = 1)
            or v.SpecVersion=@SpecVersion
            )
        group by v.ProductFamily;
    create unique clustered index IX_Spec on #Spec(ProductFamily);
    
    -- 3. Update BasePass and MES_Bin
    ;with PassCTE as
    (
        select
            t.LotWafer,
            t.ChipSN,
            t.ProductFamily,
            p.ER_low,
            s.spec_er_low,
            BasePass = cast
            (
                case
                    when (p.uec_onchip_low           > s.spec_uec_low            or s.spec_uec_low is null)
                     and (p.uec_conchip_high         < s.spec_uec_high           or s.spec_uec_high is null)
                     and (p.uec_onchip_std           < s.spec_std_multiplier     or s.spec_std_multiplier is null)
                     and (p.onchip_loss_optical_low  > s.spec_loss_low           or s.spec_loss_low is null)
                     and (p.onchip_loss_optical_high < s.spec_loss_high          or s.spec_loss_high is null)
                     and (p.loss_range_high          < s.spec_loss_range_high    or s.spec_loss_range_high is null)
                     and (p.ompd_range_high          < s.spec_ompd_range_high    or s.spec_ompd_range_high is null)
                     and (p.mpdm_mpds_dev            < s.spec_mpdm_mpds_dev      or s.spec_mpdm_mpds_dev is null)
                     and (p.ppi_low                  > s.spec_ppi_low            or s.spec_ppi_low is null)
                     and (p.ppi_high                 < s.spec_ppi_high           or s.spec_ppi_high is null)
                     and (p.heater_resistance_low    > s.spec_ht_low             or s.spec_ht_low is null)
                     and (p.heater_resistance_high   < s.spec_ht_high            or s.spec_ht_high is null)
                     and (p.dark_current_low         > s.spec_dc_low             or s.spec_dc_low is null)
                     and (p.dark_current_high        < s.spec_dc_high            or s.spec_dc_high is null)
                     and (p.onchip_loss_mpd_low      > s.spec_mpd_loss_low       or s.spec_mpd_loss_low is null)
                     and (p.onchip_loss_mpd_high     < s.spec_mpd_loss_high      or s.spec_mpd_loss_high is null)
                     and (p.mpd_loss_range_high      < s.spec_mpd_loss_range     or s.spec_mpd_loss_range is null)
                     and (p.uec_te_low              > s.spec_uec_te_low         or s.spec_uec_te_low is null)
                     and (p.uec_te_high             < s.spec_uec_te_high        or s.spec_uec_te_high is null)
                     and (p.uec_tm_low              > s.spec_uec_tm_low         or s.spec_uec_tm_low is null)
                     and (p.uec_tm_high             < s.spec_uec_tm_high        or s.spec_uec_tm_high is null)
                    then 1 else 0
                end
                as bit
            )
        from #ToCheckUnits t
        left join dbo.LotWafer_Die_CP_Parameter p
            on p.LotWafer = t.LotWafer
           and p.ChipSN   = t.ChipSN
        join #Spec s
            on s.ProductFamily = t.ProductFamily
    ),
    BinCTE as
    (
        select
            p.LotWafer,
            p.ChipSN,
            p.BasePass,
            MES_Bin =
                case
                    when p.BasePass = 1 and p.ProductFamily = 'Coral6p0' and p.ER_low > 23 and p.ER_low <= 24 then 7
                    when p.BasePass = 1 and p.ProductFamily = 'Coral6p0' and p.ER_low > 24 and p.ER_low < p.spec_er_low then 8
                    when p.BasePass = 1 and p.ER_low >= p.spec_er_low then 1
                    else 2
                end
        from PassCTE p
    )
    update t
       set t.BasePass = b.BasePass,
           t.MES_Bin  = b.MES_Bin
        from #ToCheckUnits t
        join BinCTE b
        on b.LotWafer = t.LotWafer
        and b.ChipSN   = t.ChipSN;
        
    if @ProductFamily='Coral4p1' and @SpecVersion='1.1_F2V1'
    begin
        update t
           set t.MES_Bin  = 7
            from #ToCheckUnits t
            join dbo.LotWafer_Die_CP_Parameter b on b.LotWafer = t.LotWafer and t.ChipSN=b.ChipSN
            where t.MES_Bin=1 and b.onchip_loss_mpd_high > 10.5
    end
    
    if @ProductFamily='Coral4p1' and @SpecVersion='1.1_F2V2'
    begin
        update t
           set t.MES_Bin  = 7
            from #ToCheckUnits t
            join dbo.LotWafer_Die_CP_Parameter b on b.LotWafer = t.LotWafer and t.ChipSN=b.ChipSN
            where t.MES_Bin=1 and b.onchip_loss_mpd_high > 10.5
        update t
           set t.MES_Bin  = 7
            from #ToCheckUnits t
            where t.MES_Bin=1 and left(t.ChipSN,3) not in (
            'D01',
            'D02',
            'D03',
            'D04',
            'D05',
            'D06',
            'D07',
            'D08',
            'E01',
            'E02',
            'E03',
            'E04',
            'E05',
            'E06',
            'E07',
            'E08',
            'F01',
            'F02',
            'F03',
            'F04',
            'G01',
            'G02',
            'G03',
            'G04',
            'G05',
            'G06',
            'G07',
            'G08',
            'H02',
            'H03',
            'H04',
            'H05',
            'H06',
            'H07',
            'I03',
            'I04',
            'I05',
            'I06'
            )
    end

    --update z set z.RD_Bin=1 from #ToCheckUnits z where z.RD_Bin in (4,5)

	select z.ProductFamily, z.LotWafer, z.RD_Bin, z.MES_Bin, count(1) as Qty
        , case when z.RD_Bin=z.MES_Bin then 'Pass'
        when z.ProductFamily='Coral4p1' and z.RD_Bin in (4,5) and z.MES_Bin in (1,7) then 'Pass'
        when z.ProductFamily='Coral6p0' and z.RD_Bin in (4,5) and z.MES_Bin in (1) then 'Pass'
            else 'Fail'
            end as CheckResult
		from #ToCheckUnits z
        group by z.ProductFamily, z.LotWafer, z.RD_Bin, z.MES_Bin

END;