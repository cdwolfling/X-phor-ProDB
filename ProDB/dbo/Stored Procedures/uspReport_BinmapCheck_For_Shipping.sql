

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	产生ShippingData
-- Notes:
exec [dbo].[uspReport_BinmapCheck_For_Shipping] @ProductFamily='Coral6p0', @Ship_date='2026-04-07', @Customer_Code='SZ04000'
exec [dbo].[uspReport_BinmapCheck_For_Shipping] @ProductFamily='Coral6p0', @Ship_date='2026-04-07', @Customer_Code='QD01000'

Change Log:
2026-04-09 JC: Replace ufn_GetChipBin_FromCPData with ufn_GetChipBin_FromCPData_Coral6p0
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_BinmapCheck_For_Shipping]
(
@ProductFamily varchar(10)='Coral6p0',
@Ship_date date,
@Customer_Code varchar(15),
@PO varchar(25)=null
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @ProductFamily varchar(10)='Coral6p0'
    --declare @Ship_date date='2026-04-07'
    --declare @Customer_Code varchar(15)='HK02004'
    --declare @PO varchar(25)='Z20251028-01'
    
    declare @ProductFamily_B varchar(10)
    select @ProductFamily_B=replace(@ProductFamily,'p','.')

	IF OBJECT_ID('tempdb..#ShippingUnit') IS NOT NULL DROP TABLE #ShippingUnit
	create table #ShippingUnit(Ship_date date, Customer_Code varchar(15), PO varchar(25), Lot_Wafer_Box_ID varchar(20), LotWafer varchar(11), ChipSN varchar(11), ShippingBin INT, MESBin INT)
	insert #ShippingUnit(Ship_date, Customer_Code, PO, Lot_Wafer_Box_ID, LotWafer, ChipSN, ShippingBin, MESBin)
		select s.Ship_date, s.Customer_Code, PO, s.Lot_Wafer_Box_ID, tray.LotWafer, tray.ChipSN, d.Bin, dbo.ufn_GetChipBin_FromCPData_Coral6p0(tray.LotWafer,tray.ChipSN)
		from dbo.Shipping_list s
		join dbo.vw_TrayMap tray on s.Lot_Wafer_Box_ID=tray.LotWaferTrayKey
        join dbo.Die d on tray.LotWafer=d.LotWafer and tray.ChipSN=d.Cbin
		where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
        and (s.PO = @PO or @PO is null)
        and s.Project in (@ProductFamily,@ProductFamily_B)
	
    --ReworkBatch 1
    update d set d.ShippingBin=v3.Bin from #ShippingUnit d
        join dbo.Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV3 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
        where v3.Bin is not null
    --ReworkBatch 2
    update d set d.ShippingBin=v3.Bin_V3 from #ShippingUnit d
        join dbo.Die_WrongBin7 v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
        where v3.Bin=7 and v3.Bin_V3 is not null
    --ReworkBatch 3
    update d set d.ShippingBin=v3.Bin_V3 from #ShippingUnit d
        join dbo.Die_WrongBin7_82Wafer v3 on v3.LotWafer=d.LotWafer and v3.Cbin=d.ChipSN
        where v3.Bin=7 and v3.Bin_V3 is not null

	select z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MESBin, count(1) as Qty
        , case when z.ShippingBin=z.MESBin then 'Pass' else 'Fail' end as CheckResult
		from #ShippingUnit z
        group by z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MESBin
        ORDER by z.Ship_date, z.Customer_Code, z.PO, z.ShippingBin, z.MESBin

END;