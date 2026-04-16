

/*
=============================================
Author:		Jackie Chen
Create date: 2026-03-09
Description:	产生测试数据, based on uspGenerateShippingData, output 59 parameters
Sample:
exec [dbo].[uspReport_TestDataForShipping_20260309] @Ship_date='2025-12-10', @Customer_Code='HK02000',@TrayList='LN42167-W05-03,LN42167-W06-02,LN42167-W05-04,LN42167-W06-03'
exec [dbo].[uspReport_TestDataForShipping_20260309] @Ship_date='2026-01-08', @Customer_Code='HK02',@TrayList='LN41683-W16-04,LN41683-W24-03'
exec [dbo].[uspReport_TestDataForShipping_20260309] @Wafer='LN41683-W16', @ChipSNList='F00-104,F00-103,F00-102'
exec [dbo].[uspReport_TestDataForShipping_20260309] @Wafer='TH00020-W04', @ChipSNList='H03-302,H03-303,I03-301'

Change Log:
2026-04-16 JC: 按SN查询时， 也输出Lot_Wafer_Box_ID
2026-03-18 JC: If @Wafer and @ChipSNList are not blank, output test data for all SNs in @ChipSNList. Even if some SNs have no test data, blank test data should still be returned.
=============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_TestDataForShipping_20260309]
(
    @Ship_date date=NULL,
    @Customer_Code varchar(15)=NULL,
    @TrayList varchar(MAX)='',
    @Wafer varchar(20)='',
    @ChipSNList varchar(MAX)=''
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @Ship_date date='2025-12-10'
    --declare @Customer_Code varchar(15)='hk02000'
    --declare @TrayList varchar(max)='LN42167-W05-03,LN42167-W06-02,LN42167-W05-04,LN42167-W06-03'
    
	select @TrayList=isnull(@TrayList,'')
    select @TrayList=replace(@TrayList,char(13),',')
    select @TrayList=replace(@TrayList,char(10),',')
	select @ChipSNList=isnull(@ChipSNList,'')
    select @ChipSNList=replace(@ChipSNList,char(13),',')
    select @ChipSNList=replace(@ChipSNList,char(10),',')
    select @ChipSNList=replace(@ChipSNList,',','/')
	IF OBJECT_ID('tempdb..#TrayList') IS NOT NULL DROP TABLE #TrayList
	IF OBJECT_ID('tempdb..#ChipSNList') IS NOT NULL DROP TABLE #ChipSNList
	create table #TrayList(Lot_Wafer_Box_ID varchar(20))
	create table #ChipSNList(ChipSN varchar(20))
	if @TrayList<>''
	begin
		insert #TrayList(Lot_Wafer_Box_ID)
			select f.MyColumn
			from dbo.ufnGetListFromSourceString(@TrayList,',') f where f.MyColumn<>''
	end
	else if @Wafer<>''
	begin
		print '--Wafer is: ' + @Wafer
	end
	else
	begin
		insert #TrayList(Lot_Wafer_Box_ID)
			select s.Lot_Wafer_Box_ID
			from dbo.Shipping_list s
			where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
	end
    
	IF OBJECT_ID('tempdb..#ShippingTray') IS NOT NULL DROP TABLE #ShippingTray
	create table #ShippingTray(Ship_date date, Lot_Wafer_Box_ID varchar(20), Ship_Qty INT, TrayLastSN varchar(20), LotWafer varchar(11))
	IF OBJECT_ID('tempdb..#ShippingChip_WithBoxSeq') IS NOT NULL DROP TABLE #ShippingChip_WithBoxSeq
	create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), LotWafer varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT)
	if @Wafer<>''
	begin
		insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
			select h.ProductModel, s.Ship_date, h.LotWaferTrayKey, h.LotWafer, c.ChipSN, s.Ship_Qty, s.TrayLastSN, BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
			from dbo.TrayMapHeader h
			join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
			left join dbo.Shipping_list s on h.LotWaferTrayKey=s.Lot_Wafer_Box_ID
			where h.LotWafer=@Wafer
		if @ChipSNList<>''
		begin
			--1. 非清单中的SN， 不输出
			delete z from #ShippingChip_WithBoxSeq z
				where z.ChipSN not in (select f.MyColumn
				from dbo.ufnGetListFromSourceString(@ChipSNList,'/') f where f.MyColumn<>'')
			--2. 清单中的SN， 全输出
			Declare @ProductModel varchar(8)
			select top 1 @ProductModel= left(w.SourceName,8) from dbo.Wafer w where w.Wafer号=@Wafer
			insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
				select @ProductModel, Ship_date=NULL, tray.LotWaferTrayKey, @Wafer,f.MyColumn, Ship_Qty=0, TrayLastSN=0, BoxSeq = 0
					from dbo.ufnGetListFromSourceString(@ChipSNList,'/') f
					left join dbo.vw_TrayMap tray on tray.LotWafer=@Wafer and convert(varchar(7),f.MyColumn)=tray.ChipSN
					left join #ShippingChip_WithBoxSeq z on f.MyColumn=z.ChipSN
					where f.MyColumn<>''
					and z.ChipSN is null
		end
	end
	else
	begin
		insert #ShippingTray(Ship_date, Lot_Wafer_Box_ID, Ship_Qty, TrayLastSN, LotWafer)
			select s.Ship_date, s.Lot_Wafer_Box_ID, s.Ship_Qty, s.TrayLastSN, z.LotWafer
			from dbo.Shipping_list s
			left join dbo.[TrayMapHeader] z on s.Lot_Wafer_Box_ID=z.LotWaferTrayKey
			where s.Lot_Wafer_Box_ID in (select Lot_Wafer_Box_ID from #TrayList)
		insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
			select h.ProductModel, z.Ship_date, z.Lot_Wafer_Box_ID, h.LotWafer, c.ChipSN, z.Ship_Qty, z.TrayLastSN, BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
			from #ShippingTray z
			join dbo.TrayMapHeader h on z.Lot_Wafer_Box_ID=h.LotWaferTrayKey
			join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
	end

    SELECT
        z.ProductModel,
        z.Ship_date,
        z.Lot_Wafer_Box_ID,
        CONVERT(bigint, z.TrayLastSN) - z.Ship_Qty + z.BoxSeq AS SN,
        z.LotWafer,
        z.BoxSeq,
        z.ChipSN,
        z.Ship_Qty,
        z.TrayLastSN
		,v.Station
		,v.[CH01],v.[CH02],v.[CH03],v.[CH04],v.[CH05],v.[CH06],v.[CH07],v.[CH08],v.[Loss_range]  
		,v.[ER_CH01],v.[ER_CH02],v.[ER_CH03],v.[ER_CH04],v.[ER_CH05],v.[ER_CH06],v.[ER_CH07],v.[ER_CH08]  
		,v.[PPI_CH01],v.[PPI_CH02],v.[PPI_CH03],v.[PPI_CH04],v.[PPI_CH05],v.[PPI_CH06],v.[PPI_CH07],v.[PPI_CH08]  
		,v.[HTU_CH01],v.[HTU_CH02],v.[HTU_CH03],v.[HTU_CH04],v.[HTU_CH05],v.[HTU_CH06],v.[HTU_CH07],v.[HTU_CH08]  
		,v.[IMPD_CH01_C],v.[IMPD_CH02_C],v.[OMPDM_CH01_C],v.[OMPDM_CH02_C],v.[OMPDM_CH03_C],v.[OMPDM_CH04_C],v.[OMPDM_CH05_C],v.[OMPDM_CH06_C],v.[OMPDM_CH07_C],v.[OMPDM_CH08_C]  
		,v.[OMPDS_CH01_C],v.[OMPDS_CH02_C],v.[OMPDS_CH03_C],v.[OMPDS_CH04_C],v.[OMPDS_CH05_C],v.[OMPDS_CH06_C],v.[OMPDS_CH07_C],v.[OMPDS_CH08_C]  
		,v.[Onchip_loss_CH01_MPD],v.[Onchip_loss_CH02_MPD],v.[Onchip_loss_CH03_MPD],v.[Onchip_loss_CH04_MPD],v.[Onchip_loss_CH05_MPD],v.[Onchip_loss_CH06_MPD],v.[Onchip_loss_CH07_MPD],v.[Onchip_loss_CH08_MPD]  
        FROM #ShippingChip_WithBoxSeq z
        JOIN dbo.Wafer w ON z.LotWafer = w.Wafer号
        LEFT JOIN dbo.vw_CPTestData_59Param v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1

END;