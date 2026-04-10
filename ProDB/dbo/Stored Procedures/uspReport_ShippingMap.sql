/*
=============================================
Author:		Jackie Chen
Create date: 2026-03-16
Description:	产生ShippingMap
Sample:
exec [dbo].[uspReport_ShippingMap] @Wafer='LN41683-W16', @InputCode='C05-303'
exec [dbo].[uspReport_ShippingMap] @Wafer='', @InputCode='LN42167-W05-03'
exec [dbo].[uspReport_ShippingMap] @Wafer='', @InputCode='25120065590'
exec [dbo].[uspReport_ShippingMap] @Wafer='', @InputCode='LN42164-W06-05'

Change Log:
2026-03-23 JC: Add new samples
=============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_ShippingMap]
(
    @Wafer varchar(20)='',
    @InputCode varchar(20)='' --Input ChipSN or LotWaferTrayKey or ShippingSN
)
AS
BEGIN
    SET NOCOUNT ON;
    
    declare @LotWaferTrayKey varchar(20)
    declare @ProductModel varchar(20)

	if len(@InputCode)=7
	begin
		select @LotWaferTrayKey=h.LotWaferTrayKey
			from dbo.TrayMapHeader h
			join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
			where h.LotWafer=@Wafer and c.ChipSN=@InputCode
	end
	else
	begin	
		select @LotWaferTrayKey=s.Lot_Wafer_Box_ID
			from dbo.Shipping_list s
			where s.Lot_Wafer_Box_ID = @InputCode
		if @LotWaferTrayKey is null
        begin
            declare @TrayLastSN varchar(20)
            declare @Ship_Qty varchar(20)
			select top 1 @LotWaferTrayKey=s.Lot_Wafer_Box_ID, @TrayLastSN=s.TrayLastSN, @Ship_Qty=s.Ship_Qty
				from dbo.Shipping_list s
				where s.TrayLastSN>=@InputCode
				order by s.TrayLastSN
            if CONVERT(bigint,@TrayLastSN)-CONVERT(bigint,@InputCode)>=@Ship_Qty
                select @LotWaferTrayKey=NULL
        end
	end
	
    IF OBJECT_ID('tempdb..#ShippingChip_WithBoxSeq') IS NOT NULL DROP TABLE #ShippingChip_WithBoxSeq
    create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT, RowNo INT, ColNo INT, ShippingSN varchar(20))
    insert #ShippingChip_WithBoxSeq(ProductModel, Ship_date, Lot_Wafer_Box_ID, ChipSN, Ship_Qty, TrayLastSN, BoxSeq, RowNo, ColNo)
	    select h.ProductModel, s.Ship_date, h.LotWaferTrayKey, c.ChipSN, s.Ship_Qty, s.TrayLastSN
	    , BoxSeq = ROW_NUMBER() OVER (PARTITION BY c.TrayMapId ORDER BY c.RowNo, c.ColNo)
	    , c.RowNo,c.ColNo
	    from dbo.[TrayMapHeader] h
	    join dbo.Shipping_list s on h.LotWaferTrayKey=s.Lot_Wafer_Box_ID and s.Site='SH'
	    join dbo.TrayMapCell c on h.TrayMapId=c.TrayMapId
	    where h.LotWaferTrayKey=@LotWaferTrayKey
	    order by c.RowNo,c.ColNo
    update z set z.ShippingSN=CONVERT(bigint, z.TrayLastSN) - z.Ship_Qty + z.BoxSeq
	    from #ShippingChip_WithBoxSeq z

    select top 1 @ProductModel=z.ProductModel from #ShippingChip_WithBoxSeq z where z.ProductModel<>''

    ;WITH R AS
    (
        SELECT 1 AS RowNo
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
        UNION ALL SELECT 11
        UNION ALL SELECT 12
        UNION ALL SELECT 13
        UNION ALL SELECT 14
    ),
    C AS
    (
        SELECT 1 AS ColNo
        UNION ALL SELECT 2
        UNION ALL SELECT 3
        UNION ALL SELECT 4
        UNION ALL SELECT 5
        UNION ALL SELECT 6
        UNION ALL SELECT 7
        UNION ALL SELECT 8
        UNION ALL SELECT 9
        UNION ALL SELECT 10
        UNION ALL SELECT 11
        UNION ALL SELECT 12
        UNION ALL SELECT 13
        UNION ALL SELECT 14
        UNION ALL SELECT 15
        UNION ALL SELECT 16
        UNION ALL SELECT 17
        UNION ALL SELECT 18
    )
    SELECT R.RowNo,C.ColNo,T.ShippingSN,T.ChipSN
    ,@ProductModel as ProductModel, @LotWaferTrayKey as Lot_Wafer_Box_ID
    FROM R
    CROSS JOIN C
    LEFT JOIN #ShippingChip_WithBoxSeq T
        ON T.RowNo = R.RowNo
       AND T.ColNo = C.ColNo
       -- AND T.TrayLastSN = @TrayLastSN
    ORDER BY
        R.RowNo,
        C.ColNo;

END;