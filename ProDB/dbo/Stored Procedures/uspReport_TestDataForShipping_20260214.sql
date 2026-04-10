

/*
=============================================
Author:		Jackie Chen
Create date: 2026-01-30
Description:	产生ShippingData, based on uspGenerateShippingData, output 18 parameters
Sample:
exec [dbo].[uspReport_TestDataForShipping_20260214] @Ship_date='2025-12-10', @Customer_Code='HK02000',@TrayList='LN42167-W05-03,LN42167-W06-02,LN42167-W05-04,LN42167-W06-03'
exec [dbo].[uspReport_TestDataForShipping_20260214] @Ship_date='2026-01-08', @Customer_Code='HK02',@TrayList='LN41683-W16-04,LN41683-W24-03'

Change Log:
2026-03-13 JC: Change SP name from uspReport_TestDataForShipping_20260214 to uspReport_TestDataForShipping_20260214
2026-02-27 JC: Replace char 13/10 to ',' for @TrayList
2026-02-24 JC: Update sample code
=============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_TestDataForShipping_20260214]
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
    --declare @TrayList varchar(max)='LN42167-W05-03,LN42167-W06-02,LN42167-W05-04,LN42167-W06-03'

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
    
	IF OBJECT_ID('tempdb..#ShippingTray') IS NOT NULL DROP TABLE #ShippingTray
	create table #ShippingTray(Ship_date date, Lot_Wafer_Box_ID varchar(20), Ship_Qty INT, TrayLastSN varchar(20), LotWafer varchar(11))
	insert #ShippingTray(Ship_date, Lot_Wafer_Box_ID, Ship_Qty, TrayLastSN, LotWafer)
		select s.Ship_date, s.Lot_Wafer_Box_ID, s.Ship_Qty, s.TrayLastSN, z.LotWafer
		from dbo.Shipping_list s
		left join dbo.[TrayMapHeader] z on s.Lot_Wafer_Box_ID=z.LotWaferTrayKey
		where s.Lot_Wafer_Box_ID in (select Lot_Wafer_Box_ID from #TrayList)
	
	IF OBJECT_ID('tempdb..#ShippingChip_WithBoxSeq') IS NOT NULL DROP TABLE #ShippingChip_WithBoxSeq
	create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), LotWafer varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT)
	insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
		select h.ProductModel, z.Ship_date, z.Lot_Wafer_Box_ID, h.LotWafer, c.ChipSN, z.Ship_Qty, z.TrayLastSN, BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
		from #ShippingTray z
		join dbo.TrayMapHeader h on z.Lot_Wafer_Box_ID=h.LotWaferTrayKey
		join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
		
	IF OBJECT_ID('tempdb..#ShippingData') IS NOT NULL DROP TABLE #ShippingData
	create table #ShippingData(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), SN BIGINT, LotWafer varchar(20), BoxSeq INT, ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20)
        , [IMPD_CH01_C] decimal(15,6), [IMPD_CH02_C] decimal(15,6)
		, [OMPDM_CH01_C] decimal(15,6), [OMPDM_CH02_C] decimal(15,6), [OMPDM_CH03_C] decimal(15,6), [OMPDM_CH04_C] decimal(15,6) , [OMPDM_CH05_C] decimal(15,6), [OMPDM_CH06_C] decimal(15,6), [OMPDM_CH07_C] decimal(15,6), [OMPDM_CH08_C] decimal(15,6)
		, [OMPDS_CH01_C] decimal(15,6), [OMPDS_CH02_C] decimal(15,6), [OMPDS_CH03_C] decimal(15,6), [OMPDS_CH04_C] decimal(15,6) , [OMPDS_CH05_C] decimal(15,6), [OMPDS_CH06_C] decimal(15,6), [OMPDS_CH07_C] decimal(15,6), [OMPDS_CH08_C] decimal(15,6)
        , minMPD decimal(15,6), maxMPD decimal(15,6)
		)
		
    -- 4-channel
    INSERT #ShippingData(
        ProductModel, Ship_date, Lot_Wafer_Box_ID, SN, LotWafer, BoxSeq, ChipSN, Ship_Qty, TrayLastSN
        , [IMPD_CH01_C], [IMPD_CH02_C]
		, [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C] , [OMPDM_CH05_C], [OMPDM_CH06_C], [OMPDM_CH07_C], [OMPDM_CH08_C]
		, [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C] , [OMPDS_CH05_C], [OMPDS_CH06_C], [OMPDS_CH07_C], [OMPDS_CH08_C]
        , maxMPD
        )
        SELECT
            z.ProductModel,
            z.Ship_date,
            z.Lot_Wafer_Box_ID,
            CONVERT(bigint, z.TrayLastSN) - z.Ship_Qty + z.BoxSeq AS SN,
            z.LotWafer,
            z.BoxSeq,
            z.ChipSN,
            z.Ship_Qty,
            z.TrayLastSN,
            ISNULL(v.[IMPD_CH01_C],0),
            0,
            ISNULL(v.[OMPDM_CH01_C],0),
            ISNULL(v.[OMPDM_CH02_C],0),
            ISNULL(v.[OMPDM_CH03_C],0),
            ISNULL(v.[OMPDM_CH04_C],0),
            0,
            0,
            0,
            0,
            ISNULL(v.[OMPDS_CH01_C],0),
            ISNULL(v.[OMPDS_CH02_C],0),
            ISNULL(v.[OMPDS_CH03_C],0),
            ISNULL(v.[OMPDS_CH04_C],0),
            0,
            0,
            0,
            0,
            ca.maxMPD
        FROM #ShippingChip_WithBoxSeq z
        JOIN dbo.Wafer w ON z.LotWafer = w.Wafer号
        JOIN dbo.vw_CPTestData v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1
        CROSS APPLY (
            SELECT
                MAX(x.val) AS maxMPD
            FROM (VALUES
                (ISNULL(v.[IMPD_CH01_C],0)),
                (ISNULL(v.[OMPDM_CH01_C],0)),
                (ISNULL(v.[OMPDM_CH02_C],0)),
                (ISNULL(v.[OMPDM_CH03_C],0)),
                (ISNULL(v.[OMPDM_CH04_C],0)),
                (ISNULL(v.[OMPDS_CH01_C],0)),
                (ISNULL(v.[OMPDS_CH02_C],0)),
                (ISNULL(v.[OMPDS_CH03_C],0)),
                (ISNULL(v.[OMPDS_CH04_C],0))
            ) x(val)
        ) ca
        WHERE z.ProductModel IN ('Coral3p1', 'Coral3p5', 'Coral5p3')
    -- 8-channel
    INSERT #ShippingData(
        ProductModel, Ship_date, Lot_Wafer_Box_ID, SN, LotWafer, BoxSeq, ChipSN, Ship_Qty, TrayLastSN
        , [IMPD_CH01_C], [IMPD_CH02_C]
		, [OMPDM_CH01_C], [OMPDM_CH02_C], [OMPDM_CH03_C], [OMPDM_CH04_C] , [OMPDM_CH05_C], [OMPDM_CH06_C], [OMPDM_CH07_C], [OMPDM_CH08_C]
		, [OMPDS_CH01_C], [OMPDS_CH02_C], [OMPDS_CH03_C], [OMPDS_CH04_C] , [OMPDS_CH05_C], [OMPDS_CH06_C], [OMPDS_CH07_C], [OMPDS_CH08_C]
        , maxMPD
        )
        SELECT
            z.ProductModel,
            z.Ship_date,
            z.Lot_Wafer_Box_ID,
            CONVERT(bigint, z.TrayLastSN) - z.Ship_Qty + z.BoxSeq AS SN,
            z.LotWafer,
            z.BoxSeq,
            z.ChipSN,
            z.Ship_Qty,
            z.TrayLastSN,
            ISNULL(v.[IMPD_CH01_C],0),
            ISNULL(v.[IMPD_CH02_C],0),
            ISNULL(v.[OMPDM_CH01_C],0),
            ISNULL(v.[OMPDM_CH02_C],0),
            ISNULL(v.[OMPDM_CH03_C],0),
            ISNULL(v.[OMPDM_CH04_C],0),
            ISNULL(v.[OMPDM_CH05_C],0),
            ISNULL(v.[OMPDM_CH06_C],0),
            ISNULL(v.[OMPDM_CH07_C],0),
            ISNULL(v.[OMPDM_CH08_C],0),
            ISNULL(v.[OMPDS_CH01_C],0),
            ISNULL(v.[OMPDS_CH02_C],0),
            ISNULL(v.[OMPDS_CH03_C],0),
            ISNULL(v.[OMPDS_CH04_C],0),
            ISNULL(v.[OMPDS_CH05_C],0),
            ISNULL(v.[OMPDS_CH06_C],0),
            ISNULL(v.[OMPDS_CH07_C],0),
            ISNULL(v.[OMPDS_CH08_C],0),
            ca.maxMPD
        FROM #ShippingChip_WithBoxSeq z
        JOIN dbo.Wafer w ON z.LotWafer = w.Wafer号
        JOIN dbo.vw_CPTestData v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1
        CROSS APPLY (
            SELECT
                MAX(x.val) AS maxMPD
            FROM (VALUES
                (ISNULL(v.[IMPD_CH01_C],0)),
                (ISNULL(v.[IMPD_CH02_C],0)),
                (ISNULL(v.[OMPDM_CH01_C],0)),
                (ISNULL(v.[OMPDM_CH02_C],0)),
                (ISNULL(v.[OMPDM_CH03_C],0)),
                (ISNULL(v.[OMPDM_CH04_C],0)),
                (ISNULL(v.[OMPDM_CH05_C],0)),
                (ISNULL(v.[OMPDM_CH06_C],0)),
                (ISNULL(v.[OMPDM_CH07_C],0)),
                (ISNULL(v.[OMPDM_CH08_C],0)),
                (ISNULL(v.[OMPDS_CH01_C],0)),
                (ISNULL(v.[OMPDS_CH02_C],0)),
                (ISNULL(v.[OMPDS_CH03_C],0)),
                (ISNULL(v.[OMPDS_CH04_C],0)),
                (ISNULL(v.[OMPDS_CH05_C],0)),
                (ISNULL(v.[OMPDS_CH06_C],0)),
                (ISNULL(v.[OMPDS_CH07_C],0)),
                (ISNULL(v.[OMPDS_CH08_C],0))
            ) x(val)
        ) ca
        WHERE z.ProductModel IN ('Coral4p1', 'Coral6p0', 'Coral4p5', 'Coral6p5')

	--if not match the Qty, not output
	declare @Defined_Qty INT
	select @Defined_Qty=SUM(s.Ship_Qty) from dbo.Shipping_list s where s.Lot_Wafer_Box_ID in (select Lot_Wafer_Box_ID from #TrayList)
	select @Defined_Qty=isnull(@Defined_Qty,0)
    print @Defined_Qty
	if @Defined_Qty<>(select count(1) from #ShippingData)
	begin
		select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
			, z.[IMPD_CH01_C], z.[IMPD_CH02_C], z.[OMPDM_CH01_C], z.[OMPDM_CH02_C], z.[OMPDM_CH03_C], z.[OMPDM_CH04_C], z.[OMPDM_CH05_C], z.[OMPDM_CH06_C], z.[OMPDM_CH07_C], z.[OMPDM_CH08_C], z.[OMPDS_CH01_C], z.[OMPDS_CH02_C], z.[OMPDS_CH03_C], z.[OMPDS_CH04_C], z.[OMPDS_CH05_C], z.[OMPDS_CH06_C], z.[OMPDS_CH07_C], z.[OMPDS_CH08_C]
			from #ShippingData z
            where 1=2
		return
	end
        
	IF OBJECT_ID('tempdb..#ExceptionWafer') IS NOT NULL DROP TABLE #ExceptionWafer
	create table #ExceptionWafer(LotWafer varchar(11))
    --insert #ExceptionWafer(LotWafer) Values('LN44130-W22'),('LN44793-W03')

	--if not match the Spec, not output
	if exists (select * from #ShippingData z where z.maxMPD >=300)
	begin
        print '--not match the Spec: '+'select * from #ShippingData z where z.maxMPD >=300'
	    select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
		    , z.[IMPD_CH01_C], z.[IMPD_CH02_C], z.[OMPDM_CH01_C], z.[OMPDM_CH02_C], z.[OMPDM_CH03_C], z.[OMPDM_CH04_C], z.[OMPDM_CH05_C], z.[OMPDM_CH06_C], z.[OMPDM_CH07_C], z.[OMPDM_CH08_C], z.[OMPDS_CH01_C], z.[OMPDS_CH02_C], z.[OMPDS_CH03_C], z.[OMPDS_CH04_C], z.[OMPDS_CH05_C], z.[OMPDS_CH06_C], z.[OMPDS_CH07_C], z.[OMPDS_CH08_C]
		    from #ShippingData z
            where 1=2
		return
	end

	select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
		, z.[IMPD_CH01_C], z.[IMPD_CH02_C], z.[OMPDM_CH01_C], z.[OMPDM_CH02_C], z.[OMPDM_CH03_C], z.[OMPDM_CH04_C], z.[OMPDM_CH05_C], z.[OMPDM_CH06_C], z.[OMPDM_CH07_C], z.[OMPDM_CH08_C]
        , z.[OMPDS_CH01_C], z.[OMPDS_CH02_C], z.[OMPDS_CH03_C], z.[OMPDS_CH04_C], z.[OMPDS_CH05_C], z.[OMPDS_CH06_C], z.[OMPDS_CH07_C], z.[OMPDS_CH08_C]
		from #ShippingData z
		ORDER BY z.Ship_date, z.SN

END;