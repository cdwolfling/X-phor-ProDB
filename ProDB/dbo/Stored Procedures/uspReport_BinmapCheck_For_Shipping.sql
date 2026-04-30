
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	产生ShippingData
-- Notes:
exec [dbo].[uspReport_BinmapCheck_For_Shipping] @ProductFamily='Coral6p0', @Ship_date='2026-04-07', @Customer_Code='SZ04000'
exec [dbo].[uspReport_BinmapCheck_For_Shipping] @ProductFamily='Coral6p0', @Ship_date='2026-04-07', @Customer_Code='QD01000'
exec [dbo].[uspReport_BinmapCheck_For_Shipping] @ProductFamily='Coral4p1', @Ship_date='2026-04-29', @Customer_Code='WH03003'

Change Log:
2026-04-23 JC: ">" --> ">="
2026-04-22 JC: Use left join in line 64/65
2026-04-21 JC: Add Coral4p5. Add input @WaferList
2026-04-17 JC: Performance improved.
2026-04-09 JC: Replace ufn_GetChipBin_FromCPData with ufn_GetChipBin_FromCPData_Coral6p0
-- =============================================
*/
CREATE     PROCEDURE [dbo].[uspReport_BinmapCheck_For_Shipping]
(
@ProductFamily varchar(10)='Coral6p0',
@Ship_date date=null,
@Customer_Code varchar(15)=null,
@PO varchar(25)=null,
@WaferList varchar(max)=null
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @ProductFamily varchar(10)='Coral6p0'
    --declare @Ship_date date='2026-04-07'
    --declare @Customer_Code varchar(15)='HK02004'
    --declare @PO varchar(25)='Z20251028-01'
    --declare @WaferList varchar(max)=null
    
    declare @ProductFamily_B varchar(10)
    select @ProductFamily_B=replace(@ProductFamily,'p','.')
    
    -- 1. 准备 #ToCheckUnits 临时表
	IF OBJECT_ID('tempdb..#ToCheckUnits') IS NOT NULL DROP TABLE #ToCheckUnits
	create table #ToCheckUnits(Ship_date date, Customer_Code varchar(15), PO varchar(25), Lot_Wafer_Box_ID varchar(20)
        , ProductFamily varchar(20), LotWafer varchar(11), ChipSN varchar(11), ShippingBin INT, BasePass bit, MES_Bin int)
    if @WaferList<>''
    begin
	    insert #ToCheckUnits(ProductFamily, LotWafer, ChipSN, ShippingBin)
		    select w.ProductModel, w.LotWafer, d.Cbin, d.Bin
            from dbo.CPTest_File w
            join dbo.Die d on w.LotWafer=d.LotWafer
            where w.isRecent=1
               and d.Bin not in (0,3)
               and w.LotWafer in (select f.MyColumn from dbo.ufnGetListFromSourceString(@WaferList,',') f where f.MyColumn<>'')
    end
    else
    begin
	    insert #ToCheckUnits(Ship_date, Customer_Code, PO, Lot_Wafer_Box_ID, ProductFamily, LotWafer, ChipSN, ShippingBin)
		    select s.Ship_date, s.Customer_Code, PO, s.Lot_Wafer_Box_ID, tray.ProductModel, tray.LotWafer, tray.ChipSN, d.Bin--, dbo.ufn_GetChipBin_FromCPData_Coral6p0(tray.LotWafer,tray.ChipSN)
		    from dbo.Shipping_list s
		    left join dbo.vw_TrayMap tray on s.Lot_Wafer_Box_ID=tray.LotWaferTrayKey
            left join dbo.Die d on tray.LotWafer=d.LotWafer and tray.ChipSN=d.Cbin
		    where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
            and (s.PO = @PO or @PO is null)
            and s.Project in (@ProductFamily,@ProductFamily_B)
    end
    create clustered index IX_ToCheckDie on #ToCheckUnits(LotWafer, ChipSN, ProductFamily)
	
    -- 1.1 Update ShippingBin for Coral6p0 Bin7Issue
    if exists(select 1 from #ToCheckUnits z where z.ProductFamily='Coral6p0')
    begin
        --ReworkBatch 1
        update d set d.ShippingBin=v3.Bin from #ToCheckUnits d
            join dbo.Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV3 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
            where v3.Bin is not null
        --ReworkBatch 2
        update d set d.ShippingBin=v3.Bin_V3 from #ToCheckUnits d
            join dbo.Die_WrongBin7 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
            where v3.Bin=7 and v3.Bin_V3 is not null
        --ReworkBatch 3
        update d set d.ShippingBin=v3.Bin_V3 from #ToCheckUnits d
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
        where v.IsActive = 1
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
                    when (p.uec_onchip_low           >= s.spec_uec_low            or s.spec_uec_low is null)
                     and (p.uec_conchip_high         <= s.spec_uec_high           or s.spec_uec_high is null)
                     and (p.uec_onchip_std           <= s.spec_std_multiplier     or s.spec_std_multiplier is null)
                     and (p.onchip_loss_optical_low  >= s.spec_loss_low           or s.spec_loss_low is null)
                     and (p.onchip_loss_optical_high <= s.spec_loss_high          or s.spec_loss_high is null)
                     and (p.loss_range_high          <= s.spec_loss_range_high    or s.spec_loss_range_high is null)
                     and (p.ompd_range_high          <= s.spec_ompd_range_high    or s.spec_ompd_range_high is null)
                     and (p.mpdm_mpds_dev            <= s.spec_mpdm_mpds_dev      or s.spec_mpdm_mpds_dev is null)
                     and (p.ppi_low                  >= s.spec_ppi_low            or s.spec_ppi_low is null)
                     and (p.ppi_high                 <= s.spec_ppi_high           or s.spec_ppi_high is null)
                     and (p.heater_resistance_low    >= s.spec_ht_low             or s.spec_ht_low is null)
                     and (p.heater_resistance_high   <= s.spec_ht_high            or s.spec_ht_high is null)
                     and (p.dark_current_low         >= s.spec_dc_low             or s.spec_dc_low is null)
                     and (p.dark_current_high        <= s.spec_dc_high            or s.spec_dc_high is null)
                     and (p.onchip_loss_mpd_low      >= s.spec_mpd_loss_low       or s.spec_mpd_loss_low is null)
                     and (p.onchip_loss_mpd_high     <= s.spec_mpd_loss_high      or s.spec_mpd_loss_high is null)
                     and (p.mpd_loss_range_high      <= s.spec_mpd_loss_range     or s.spec_mpd_loss_range is null)
                     and (p.uec_te_low              >= s.spec_uec_te_low         or s.spec_uec_te_low is null)
                     and (p.uec_te_high             <= s.spec_uec_te_high        or s.spec_uec_te_high is null)
                     and (p.uec_tm_low              >= s.spec_uec_tm_low         or s.spec_uec_tm_low is null)
                     and (p.uec_tm_high             <= s.spec_uec_tm_high        or s.spec_uec_tm_high is null)
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
    join dbo.LotWafer_WLT_SpecVersion s on t.LotWafer=s.LotWafer
    join BinCTE b on b.LotWafer = t.LotWafer and b.ChipSN   = t.ChipSN
    where s.LotWafer is null

    update t
       set t.MES_Bin  = dbo.ufn_GetChipBin_FromCPData_Fast_WithSpecVersion(t.LotWafer,t.ChipSN,s.ProductFamilySpecId)
    from #ToCheckUnits t
    join dbo.LotWafer_WLT_SpecVersion s on t.LotWafer=s.LotWafer

	select z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MES_Bin as MESBin, count(1) as Qty
        , case when z.ShippingBin=z.MES_Bin then 'Pass' else 'Fail' end as CheckResult
		from #ToCheckUnits z
        group by z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MES_Bin
        ORDER by z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MES_Bin

END;