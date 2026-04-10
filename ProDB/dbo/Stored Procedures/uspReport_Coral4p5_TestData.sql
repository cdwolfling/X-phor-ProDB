

/*
=============================================
Author:		Jackie Chen
Create date: 2026-03-24
Description:	产生Coral4p5的TestData, output 170 parameters
Sample:
exec [dbo].[uspReport_Coral4p5_TestData] @Ship_date='2026-03-17', @Customer_Code='JM01000'
exec [dbo].[uspReport_Coral4p5_TestData] @Ship_date='2026-03-17', @Customer_Code='JM01000',@TrayList='LN34376-W17-01,LN34376-W17-04'
exec [dbo].[uspReport_Coral4p5_TestData] @Ship_date='2026-03-17', @Customer_Code='JM01000',@TrayList='LN37348-W16-02,LN34376-W14-06,LN34376-W13-04,LN34376-W17-01,LN34376-W14-05'

Change Log:
=============================================
*/
CREATE       PROCEDURE [dbo].[uspReport_Coral4p5_TestData]
(
@Ship_date date,
@Customer_Code varchar(15),
@TrayList varchar(MAX)=''
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @Ship_date date='2025-12-10'
    --declare @Customer_Code varchar(15)='hk02000'
    --declare @TrayList varchar(max)='LN34376-W17-01,LN34376-W17-04'

	select @TrayList=isnull(@TrayList,'')
    select @TrayList=replace(@TrayList,char(13),',')
    select @TrayList=replace(@TrayList,char(10),',')
	IF OBJECT_ID('tempdb..#TrayList') IS NOT NULL DROP TABLE #TrayList
	create table #TrayList(Lot_Wafer_Box_ID varchar(20))
	if @TrayList=''
	begin
		insert #TrayList(Lot_Wafer_Box_ID)
			select s.Lot_Wafer_Box_ID
			from dbo.Shipping_list s
			where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
	end
	else
	begin
		insert #TrayList(Lot_Wafer_Box_ID)
			select f.MyColumn
			from dbo.ufnGetListFromSourceString(@TrayList,',') f where f.MyColumn<>''
	end

	if (select count(1) from #TrayList)>10
	begin	
		select v.ProductModel, v.LotWafer as LotID_Wafer, v.Die_Location, v.Dev_ID, tray.LotWaferTrayKey, v.ChipSN
			, [UGC_CW_TE], [UGC_CW_TM], [UGC_TE], [UGC_TM], [UEC_TE], [UEC_TM], [UEC_Onchip_TE_1271], [UEC_Onchip_TM_1291], [UEC_Onchip_TE_1311], [UEC_Onchip_TM_1331]
			, [Onchip_CH01], [Onchip_CH02], [Onchip_CH03], [Onchip_CH04], [Onchip_CH05], [Onchip_CH06], [Onchip_CH07], [Onchip_CH08], [Range]
			, [Onchip_MPD_CH01], [Onchip_MPD_CH02], [Onchip_MPD_CH03], [Onchip_MPD_CH04], [Onchip_MPD_CH05], [Onchip_MPD_CH06], [Onchip_MPD_CH07], [Onchip_MPD_CH08], [Range_onchip_loss_mpd]
			, [Onchip_diff_CH01], [Onchip_diff_CH02], [Onchip_diff_CH03], [Onchip_diff_CH04], [Onchip_diff_CH05], [Onchip_diff_CH06], [Onchip_diff_CH07], [Onchip_diff_CH08]
			, [PSR_TE_loss_1271], [PSR_TM_loss_1291], [PSR_TE_loss_1311], [PSR_TM_loss_1331], [ER_CH01], [ER_CH02], [ER_CH03], [ER_CH04], [ER_CH05], [ER_CH06], [ER_CH07], [ER_CH08]
			, [PPI_CH01], [PPI_CH02], [PPI_CH03], [PPI_CH04], [PPI_CH05], [PPI_CH06], [PPI_CH07], [PPI_CH08], [HTU_CH01], [HTU_CH02], [HTU_CH03], [HTU_CH04], [HTU_CH05], [HTU_CH06], [HTU_CH07], [HTU_CH08]
			, [IMPD_CH01_OC], [IMPD_CH02_OC], [IMPD_CH03_OC], [IMPD_CH04_OC], [OMPDM_CH01_OC], [OMPDM_CH02_OC], [OMPDM_CH03_OC], [OMPDM_CH04_OC], [OMPDM_CH05_OC], [OMPDM_CH06_OC], [OMPDM_CH07_OC], [OMPDM_CH08_OC]
			, [OMPDS_CH01_OC], [OMPDS_CH02_OC], [OMPDS_CH03_OC], [OMPDS_CH04_OC], [OMPDS_CH05_OC], [OMPDS_CH06_OC], [OMPDS_CH07_OC], [OMPDS_CH08_OC]
			, [IMPD_CH01_C], [IMPD_CH02_C], [IMPD_CH03_C], [IMPD_CH04_C], [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C], [OMPDM_CH05_C], [OMPDM_CH06_C], [OMPDM_CH07_C], [OMPDM_CH08_C]
			, [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C], [OMPDS_CH05_C], [OMPDS_CH06_C], [OMPDS_CH07_C], [OMPDS_CH08_C]
			, [IMPD_CH01_RS], [IMPD_CH02_RS], [IMPD_CH03_RS], [IMPD_CH04_RS], [OMPDM_CH01_RS], [OMPDM_CH02_RS], [OMPDM_CH03_RS], [OMPDM_CH04_RS], [OMPDM_CH05_RS], [OMPDM_CH06_RS], [OMPDM_CH07_RS], [OMPDM_CH08_RS]
			, [OMPDS_CH01_RS], [OMPDS_CH02_RS], [OMPDS_CH03_RS], [OMPDS_CH04_RS], [OMPDS_CH05_RS], [OMPDS_CH06_RS], [OMPDS_CH07_RS], [OMPDS_CH08_RS]
			, [IMPD_CH01_OC_dB], [IMPD_CH02_OC_dB], [IMPD_CH03_OC_dB], [IMPD_CH04_OC_dB], [OMPDM_CH01_OC_dB], [OMPDM_CH02_OC_dB], [OMPDM_CH03_OC_dB], [OMPDM_CH04_OC_dB], [OMPDM_CH05_OC_dB], [OMPDM_CH06_OC_dB], [OMPDM_CH07_OC_dB], [OMPDM_CH08_OC_dB]
			, [OMPDS_CH01_OC_dB], [OMPDS_CH02_OC_dB], [OMPDS_CH03_OC_dB], [OMPDS_CH04_OC_dB], [OMPDS_CH05_OC_dB], [OMPDS_CH06_OC_dB], [OMPDS_CH07_OC_dB], [OMPDS_CH08_OC_dB]
			, [IL_MAX_UEC], [IL_AVE_UEC], [IL_MIN_UEC]
			, [ONCHIP_IL_MAX_CH01_1by4], [ONCHIP_IL_AVE_CH01_1by4], [ONCHIP_IL_MIN_CH01_1by4], [ONCHIP_IL_MAX_CH02_1by4], [ONCHIP_IL_AVE_CH02_1by4], [ONCHIP_IL_MIN_CH02_1by4], [ONCHIP_IL_MAX_CH03_1by4], [ONCHIP_IL_AVE_CH03_1by4], [ONCHIP_IL_MIN_CH03_1by4], [ONCHIP_IL_MAX_CH04_1by4], [ONCHIP_IL_AVE_CH04_1by4], [ONCHIP_IL_MIN_CH04_1by4]
			, [ONCHIP_IL_MAX_CH05_1by4], [ONCHIP_IL_AVE_CH05_1by4], [ONCHIP_IL_MIN_CH05_1by4], [ONCHIP_IL_MAX_CH06_1by4], [ONCHIP_IL_AVE_CH06_1by4], [ONCHIP_IL_MIN_CH06_1by4], [ONCHIP_IL_MAX_CH07_1by4], [ONCHIP_IL_AVE_CH07_1by4], [ONCHIP_IL_MIN_CH07_1by4], [ONCHIP_IL_MAX_CH08_1by4], [ONCHIP_IL_AVE_CH08_1by4]
			FROM [dbo].[vw_CPTestData_Coral4p5] v
			join (
			select h.LotWafer,h.LotWaferTrayKey,c.ChipSN from dbo.TrayMapHeader h 
			join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId) tray on v.LotWafer=tray.LotWafer and v.ChipSN=tray.ChipSN
			where 1=2
	end

	IF OBJECT_ID('tempdb..#ShippingTray') IS NOT NULL DROP TABLE #ShippingTray
	create table #ShippingTray(Ship_date date, Lot_Wafer_Box_ID varchar(20), Ship_Qty INT, TrayLastSN varchar(20), LotWafer varchar(11))
	insert #ShippingTray(Ship_date, Lot_Wafer_Box_ID, Ship_Qty, TrayLastSN, LotWafer)
		select s.Ship_date, z.LotWaferTrayKey, s.Ship_Qty, s.TrayLastSN, z.LotWafer
		from dbo.Shipping_list s
		right join dbo.[TrayMapHeader] z on s.Lot_Wafer_Box_ID=z.LotWaferTrayKey
		where z.LotWaferTrayKey in (select Lot_Wafer_Box_ID from #TrayList)
	
	IF OBJECT_ID('tempdb..#ShippingChip_WithBoxSeq') IS NOT NULL DROP TABLE #ShippingChip_WithBoxSeq
	create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), LotWafer varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT)
	insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
		select h.ProductModel, z.Ship_date, z.Lot_Wafer_Box_ID, h.LotWafer, c.ChipSN, z.Ship_Qty, z.TrayLastSN, BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
		from #ShippingTray z
		join dbo.TrayMapHeader h on z.Lot_Wafer_Box_ID=h.LotWaferTrayKey
		join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId

	select v.ProductModel, v.LotWafer as LotID_Wafer, v.Die_Location, v.Dev_ID, tray.Lot_Wafer_Box_ID as LotWaferTrayKey, v.ChipSN
		, CONVERT(bigint, tray.TrayLastSN) - tray.Ship_Qty + tray.BoxSeq AS ShipSN
		, [UGC_CW_TE], [UGC_CW_TM], [UGC_TE], [UGC_TM], [UEC_TE], [UEC_TM], [UEC_Onchip_TE_1271], [UEC_Onchip_TM_1291], [UEC_Onchip_TE_1311], [UEC_Onchip_TM_1331]
		, [Onchip_CH01], [Onchip_CH02], [Onchip_CH03], [Onchip_CH04], [Onchip_CH05], [Onchip_CH06], [Onchip_CH07], [Onchip_CH08], [Range]
		, [Onchip_MPD_CH01], [Onchip_MPD_CH02], [Onchip_MPD_CH03], [Onchip_MPD_CH04], [Onchip_MPD_CH05], [Onchip_MPD_CH06], [Onchip_MPD_CH07], [Onchip_MPD_CH08], [Range_onchip_loss_mpd]
		, [Onchip_diff_CH01], [Onchip_diff_CH02], [Onchip_diff_CH03], [Onchip_diff_CH04], [Onchip_diff_CH05], [Onchip_diff_CH06], [Onchip_diff_CH07], [Onchip_diff_CH08]
		, [PSR_TE_loss_1271], [PSR_TM_loss_1291], [PSR_TE_loss_1311], [PSR_TM_loss_1331], [ER_CH01], [ER_CH02], [ER_CH03], [ER_CH04], [ER_CH05], [ER_CH06], [ER_CH07], [ER_CH08]
		, [PPI_CH01], [PPI_CH02], [PPI_CH03], [PPI_CH04], [PPI_CH05], [PPI_CH06], [PPI_CH07], [PPI_CH08], [HTU_CH01], [HTU_CH02], [HTU_CH03], [HTU_CH04], [HTU_CH05], [HTU_CH06], [HTU_CH07], [HTU_CH08]
		, [IMPD_CH01_OC], [IMPD_CH02_OC], [IMPD_CH03_OC], [IMPD_CH04_OC], [OMPDM_CH01_OC], [OMPDM_CH02_OC], [OMPDM_CH03_OC], [OMPDM_CH04_OC], [OMPDM_CH05_OC], [OMPDM_CH06_OC], [OMPDM_CH07_OC], [OMPDM_CH08_OC]
		, [OMPDS_CH01_OC], [OMPDS_CH02_OC], [OMPDS_CH03_OC], [OMPDS_CH04_OC], [OMPDS_CH05_OC], [OMPDS_CH06_OC], [OMPDS_CH07_OC], [OMPDS_CH08_OC]
		, [IMPD_CH01_C], [IMPD_CH02_C], [IMPD_CH03_C], [IMPD_CH04_C], [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C], [OMPDM_CH05_C], [OMPDM_CH06_C], [OMPDM_CH07_C], [OMPDM_CH08_C]
		, [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C], [OMPDS_CH05_C], [OMPDS_CH06_C], [OMPDS_CH07_C], [OMPDS_CH08_C]
		, [IMPD_CH01_RS], [IMPD_CH02_RS], [IMPD_CH03_RS], [IMPD_CH04_RS], [OMPDM_CH01_RS], [OMPDM_CH02_RS], [OMPDM_CH03_RS], [OMPDM_CH04_RS], [OMPDM_CH05_RS], [OMPDM_CH06_RS], [OMPDM_CH07_RS], [OMPDM_CH08_RS]
		, [OMPDS_CH01_RS], [OMPDS_CH02_RS], [OMPDS_CH03_RS], [OMPDS_CH04_RS], [OMPDS_CH05_RS], [OMPDS_CH06_RS], [OMPDS_CH07_RS], [OMPDS_CH08_RS]
		, [IMPD_CH01_OC_dB], [IMPD_CH02_OC_dB], [IMPD_CH03_OC_dB], [IMPD_CH04_OC_dB], [OMPDM_CH01_OC_dB], [OMPDM_CH02_OC_dB], [OMPDM_CH03_OC_dB], [OMPDM_CH04_OC_dB], [OMPDM_CH05_OC_dB], [OMPDM_CH06_OC_dB], [OMPDM_CH07_OC_dB], [OMPDM_CH08_OC_dB]
		, [OMPDS_CH01_OC_dB], [OMPDS_CH02_OC_dB], [OMPDS_CH03_OC_dB], [OMPDS_CH04_OC_dB], [OMPDS_CH05_OC_dB], [OMPDS_CH06_OC_dB], [OMPDS_CH07_OC_dB], [OMPDS_CH08_OC_dB]
		, [IL_MAX_UEC], [IL_AVE_UEC], [IL_MIN_UEC]
		, [ONCHIP_IL_MAX_CH01_1by4], [ONCHIP_IL_AVE_CH01_1by4], [ONCHIP_IL_MIN_CH01_1by4], [ONCHIP_IL_MAX_CH02_1by4], [ONCHIP_IL_AVE_CH02_1by4], [ONCHIP_IL_MIN_CH02_1by4], [ONCHIP_IL_MAX_CH03_1by4], [ONCHIP_IL_AVE_CH03_1by4], [ONCHIP_IL_MIN_CH03_1by4], [ONCHIP_IL_MAX_CH04_1by4], [ONCHIP_IL_AVE_CH04_1by4], [ONCHIP_IL_MIN_CH04_1by4]
		, [ONCHIP_IL_MAX_CH05_1by4], [ONCHIP_IL_AVE_CH05_1by4], [ONCHIP_IL_MIN_CH05_1by4], [ONCHIP_IL_MAX_CH06_1by4], [ONCHIP_IL_AVE_CH06_1by4], [ONCHIP_IL_MIN_CH06_1by4], [ONCHIP_IL_MAX_CH07_1by4], [ONCHIP_IL_AVE_CH07_1by4], [ONCHIP_IL_MIN_CH07_1by4], [ONCHIP_IL_MAX_CH08_1by4], [ONCHIP_IL_AVE_CH08_1by4]
		FROM [dbo].[vw_CPTestData_Coral4p5] v
		join #ShippingChip_WithBoxSeq tray on v.LotWafer=tray.LotWafer and v.ChipSN=tray.ChipSN
		where v.isRecent=1
		ORDER BY tray.Lot_Wafer_Box_ID, ShipSN

END;