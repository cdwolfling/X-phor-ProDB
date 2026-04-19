

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	产生ShippingData
-- Notes:
exec [dbo].[uspGenerateShippingData] @Ship_date='2026-01-27', @Customer_Code='hk02000'
exec [dbo].[uspGenerateShippingData] @Ship_date='2026-02-06', @Customer_Code='hk02'
exec [dbo].[uspGenerateShippingData] @Ship_date='2026-03-06', @Customer_Code='CD04', @PO='/'
exec [dbo].[uspGenerateShippingData] @Ship_date='2026-03-06', @Customer_Code='CD04000', @PO='Z20260224-03'

Change Log:
2026-04-18 JC: Add exception: LN44130-W11
2026-03-27 JC: Add Debug info
2026-03-21 JC: Update logic about #ExceptionWafer, Add LN44130-W06 into #ExceptionWafer
2026-03-09 JC: Update the specifications of 6 products
2026-03-01 JC: add new parameter @PO
2026-02-12 JC: add #ExceptionWafer(夏斌：这个是1月12号测的，卡loss range是2月2号流程走完，真正落地的)
2026-02-09 JC: if not match the Qty, not output; 
2026-02-08 JC: Add left join
2026-02-02 JC: Hotfix: Add v.isRecent=1
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspGenerateShippingData]
(
@Ship_date date,
@Customer_Code varchar(15),
@PO varchar(25)
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @Ship_date date='2026-03-19'
    --declare @Customer_Code varchar(15)='HK02004'
    --declare @PO varchar(25)='Z20251028-01'
    
	IF OBJECT_ID('tempdb..#ShippingTray') IS NOT NULL DROP TABLE #ShippingTray
	create table #ShippingTray(Ship_date date, Lot_Wafer_Box_ID varchar(20), Ship_Qty INT, TrayLastSN varchar(20), LotWafer varchar(11))
	insert #ShippingTray(Ship_date, Lot_Wafer_Box_ID, Ship_Qty, TrayLastSN, LotWafer)
		select s.Ship_date, s.Lot_Wafer_Box_ID, s.Ship_Qty, s.TrayLastSN, z.LotWafer
		from dbo.Shipping_list s
		left join dbo.[TrayMapHeader] z on s.Lot_Wafer_Box_ID=z.LotWaferTrayKey
		where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
        and s.PO = @PO
	
	IF OBJECT_ID('tempdb..#ShippingChip_WithBoxSeq') IS NOT NULL DROP TABLE #ShippingChip_WithBoxSeq
	create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), LotWafer varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT)
	insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, LotWafer, ChipSN, Ship_Qty, TrayLastSN, BoxSeq)
		select h.ProductModel, z.Ship_date, z.Lot_Wafer_Box_ID, h.LotWafer, c.ChipSN, z.Ship_Qty, z.TrayLastSN, BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
		from #ShippingTray z
		join dbo.TrayMapHeader h on z.Lot_Wafer_Box_ID=h.LotWaferTrayKey
		join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
		
	IF OBJECT_ID('tempdb..#ShippingData') IS NOT NULL DROP TABLE #ShippingData
	create table #ShippingData(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), SN BIGINT, LotWafer varchar(20), BoxSeq INT, ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20)
		, Onchip_loss_CH01_MPD decimal(15,6), Onchip_loss_CH02_MPD decimal(15,6), Onchip_loss_CH03_MPD decimal(15,6), Onchip_loss_CH04_MPD decimal(15,6)
		, Onchip_loss_CH05_MPD decimal(15,6), Onchip_loss_CH06_MPD decimal(15,6), Onchip_loss_CH07_MPD decimal(15,6), Onchip_loss_CH08_MPD decimal(15,6)
        , minMPD decimal(15,6), maxMPD decimal(15,6)
		)
    -- 4-channel
    INSERT #ShippingData(
        ProductModel, Ship_date, Lot_Wafer_Box_ID, SN, LotWafer, BoxSeq, ChipSN, Ship_Qty, TrayLastSN,
        Onchip_loss_CH01_MPD, Onchip_loss_CH02_MPD, Onchip_loss_CH03_MPD, Onchip_loss_CH04_MPD,
        Onchip_loss_CH05_MPD, Onchip_loss_CH06_MPD, Onchip_loss_CH07_MPD, Onchip_loss_CH08_MPD,
        minMPD, maxMPD
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
            ISNULL(v.Onchip_loss_CH01_MPD,0),
            ISNULL(v.Onchip_loss_CH02_MPD,0),
            ISNULL(v.Onchip_loss_CH03_MPD,0),
            ISNULL(v.Onchip_loss_CH04_MPD,0),
            0,
            0,
            0,
            0,
            ca.minMPD,
            ca.maxMPD
        FROM #ShippingChip_WithBoxSeq z
        JOIN dbo.Wafer w ON z.LotWafer = w.Wafer号
        JOIN dbo.vw_CPTestData v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1
        CROSS APPLY (
            SELECT
                MIN(x.val) AS minMPD,
                MAX(x.val) AS maxMPD
            FROM (VALUES
                (ISNULL(v.Onchip_loss_CH01_MPD,0)),
                (ISNULL(v.Onchip_loss_CH02_MPD,0)),
                (ISNULL(v.Onchip_loss_CH03_MPD,0)),
                (ISNULL(v.Onchip_loss_CH04_MPD,0))
            ) x(val)
        ) ca
        WHERE z.ProductModel IN ('Coral3p1', 'Coral3p5', 'Coral5p3')
    -- 8-channel
    INSERT #ShippingData(
        ProductModel, Ship_date, Lot_Wafer_Box_ID, SN, LotWafer, BoxSeq, ChipSN, Ship_Qty, TrayLastSN,
        Onchip_loss_CH01_MPD, Onchip_loss_CH02_MPD, Onchip_loss_CH03_MPD, Onchip_loss_CH04_MPD,
        Onchip_loss_CH05_MPD, Onchip_loss_CH06_MPD, Onchip_loss_CH07_MPD, Onchip_loss_CH08_MPD,
        minMPD, maxMPD
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
            ISNULL(v.Onchip_loss_CH01_MPD,0),
            ISNULL(v.Onchip_loss_CH02_MPD,0),
            ISNULL(v.Onchip_loss_CH03_MPD,0),
            ISNULL(v.Onchip_loss_CH04_MPD,0),
            ISNULL(v.Onchip_loss_CH05_MPD,0),
            ISNULL(v.Onchip_loss_CH06_MPD,0),
            ISNULL(v.Onchip_loss_CH07_MPD,0),
            ISNULL(v.Onchip_loss_CH08_MPD,0),
            ca.minMPD,
            ca.maxMPD
        FROM #ShippingChip_WithBoxSeq z
        JOIN dbo.Wafer w ON z.LotWafer = w.Wafer号
        JOIN dbo.vw_CPTestData v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1
        CROSS APPLY (
            SELECT
                MIN(x.val) AS minMPD,
                MAX(x.val) AS maxMPD
            FROM (VALUES
                (ISNULL(v.Onchip_loss_CH01_MPD,0)),
                (ISNULL(v.Onchip_loss_CH02_MPD,0)),
                (ISNULL(v.Onchip_loss_CH03_MPD,0)),
                (ISNULL(v.Onchip_loss_CH04_MPD,0)),
                (ISNULL(v.Onchip_loss_CH05_MPD,0)),
                (ISNULL(v.Onchip_loss_CH06_MPD,0)),
                (ISNULL(v.Onchip_loss_CH07_MPD,0)),
                (ISNULL(v.Onchip_loss_CH08_MPD,0))
            ) x(val)
        ) ca
        WHERE z.ProductModel IN ('Coral4p1', 'Coral6p0', 'Coral4p5', 'Coral6p5')
        
	--if not match the Qty, not output
	declare @Defined_Qty INT, @Data_Qty INT
	select @Defined_Qty=SUM(s.Ship_Qty) from dbo.Shipping_list s
        where s.Ship_date=@Ship_date and s.Customer_Code=@Customer_Code
        and s.PO = @PO
	select @Defined_Qty=isnull(@Defined_Qty,0)
	select @Data_Qty=count(1) from #ShippingData
	if @Defined_Qty<>@Data_Qty
	begin
        print @Defined_Qty
        print @Data_Qty
		select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
			, z.Onchip_loss_CH01_MPD, z.Onchip_loss_CH02_MPD, z.Onchip_loss_CH03_MPD, z.Onchip_loss_CH04_MPD, z.Onchip_loss_CH05_MPD, z.Onchip_loss_CH06_MPD, z.Onchip_loss_CH07_MPD, z.Onchip_loss_CH08_MPD
			from #ShippingData z
            where 1=2
		return
	end

	declare @ProductModel varchar(max)=''
    select @ProductModel=@ProductModel+z.ProductModel+',' from #ShippingData z group by z.ProductModel
    print @ProductModel
        
	IF OBJECT_ID('tempdb..#ExceptionWafer') IS NOT NULL DROP TABLE #ExceptionWafer
	create table #ExceptionWafer(LotWafer varchar(11))
    insert #ExceptionWafer(LotWafer) Values('LN44130-W22'),('LN44793-W03'),('LN44130-W06'),('LN44130-W11')

	--if not match the Qty, not output
	if exists (select * from #ShippingData z where z.ProductModel in ('Coral3p1','Coral4p1')
                                                and (z.minMPD <= 8.5 or z.maxMPD >=10.5 or 
                                                    (z.maxMPD-z.minMPD>=1 and z.LotWafer not in (select e.LotWafer from #ExceptionWafer e))
                                                    )
                                                )
	    or exists (select * from #ShippingData z where z.ProductModel='Coral4p5'
                                                and (z.minMPD <= 5 or z.maxMPD >=8 or 
                                                    (z.maxMPD-z.minMPD>=1 and z.LotWafer not in (select e.LotWafer from #ExceptionWafer e))
                                                    )
                                                )
	    or exists (select * from #ShippingData z where z.ProductModel in ('Coral5p3','Coral6p0')
                                                and (z.minMPD <= 8.5 or z.maxMPD >=11.5 or 
                                                    (z.maxMPD-z.minMPD>=1 and z.LotWafer not in (select e.LotWafer from #ExceptionWafer e))
                                                    )
                                                )
	    or exists (select * from #ShippingData z where z.ProductModel='Coral6p5'
                                                and (z.minMPD <= 5 or z.maxMPD >=8.5 or 
                                                    (z.maxMPD-z.minMPD>=1 and z.LotWafer not in (select e.LotWafer from #ExceptionWafer e))
                                                    )
                                                )
	begin
		select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
			, z.Onchip_loss_CH01_MPD, z.Onchip_loss_CH02_MPD, z.Onchip_loss_CH03_MPD, z.Onchip_loss_CH04_MPD, z.Onchip_loss_CH05_MPD, z.Onchip_loss_CH06_MPD, z.Onchip_loss_CH07_MPD, z.Onchip_loss_CH08_MPD
			from #ShippingData z
            where 1=2
		return
	end

	select z.Ship_date, z.Lot_Wafer_Box_ID, z.SN
		, z.Onchip_loss_CH01_MPD, z.Onchip_loss_CH02_MPD, z.Onchip_loss_CH03_MPD, z.Onchip_loss_CH04_MPD, z.Onchip_loss_CH05_MPD, z.Onchip_loss_CH06_MPD, z.Onchip_loss_CH07_MPD, z.Onchip_loss_CH08_MPD
		from #ShippingData z
		ORDER BY z.Ship_date, z.SN

END;