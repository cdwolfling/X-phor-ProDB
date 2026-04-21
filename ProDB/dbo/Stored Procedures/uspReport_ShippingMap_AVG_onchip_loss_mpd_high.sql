/*
=============================================
Author:		Jackie Chen
Create date: 2026-03-16
Description:	产生Shipping AVG_onchip_loss_mpd_high BinMap
Sample:
exec [dbo].[uspReport_ShippingMap_AVG_onchip_loss_mpd_high] @Wafer='LN41683-W16', @InputCode='C05-303'
exec [dbo].[uspReport_ShippingMap_AVG_onchip_loss_mpd_high] @Wafer='', @InputCode='LN42173-W08-03'

Change Log:
2026-04-21 JC: Initial. Base uspReport_ShippingMap, 输出ufn_GetChipBin_FromCPData_AVG_onchip_loss_mpd_high的结果
=============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_ShippingMap_AVG_onchip_loss_mpd_high]
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
    create table #ShippingChip_WithBoxSeq(ProductModel varchar(8), Ship_date date, Lot_Wafer_Box_ID varchar(20), ChipSN varchar(50), Ship_Qty INT, TrayLastSN varchar(20), BoxSeq INT, RowNo INT, ColNo INT, ShippingSN varchar(20)
        ,AVG_onchip_loss_mpd_high_BIN int)
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
    update z set z.AVG_onchip_loss_mpd_high_BIN=dbo.ufn_GetChipBin_FromCPData_AVG_onchip_loss_mpd_high(left(z.Lot_Wafer_Box_ID,11), z.ChipSN)
	    from #ShippingChip_WithBoxSeq z		

	SELECT TOP 1 @ProductModel = z.ProductModel
    FROM #ShippingChip_WithBoxSeq AS z
    WHERE z.ProductModel <> '';

    DECLARE @Box_X INT;
    DECLARE @Box_Y INT;
    SELECT
        @Box_X = p.Box_X,
        @Box_Y = p.Box_Y
    FROM dbo.ProductModel AS p
    WHERE p.ProductModel = @ProductModel;

    ;WITH R AS
    (
        SELECT 1 AS RowNo
        WHERE ISNULL(@Box_Y, 0) >= 1

        UNION ALL

        SELECT RowNo + 1
        FROM R
        WHERE RowNo < @Box_Y
    ),
    C AS
    (
        SELECT 1 AS ColNo
        WHERE ISNULL(@Box_X, 0) >= 1

        UNION ALL

        SELECT ColNo + 1
        FROM C
        WHERE ColNo < @Box_X
    )
    SELECT
        R.RowNo,
        C.ColNo,
        T.AVG_onchip_loss_mpd_high_BIN,
        T.ChipSN,
        @ProductModel AS ProductModel,
        @LotWaferTrayKey AS Lot_Wafer_Box_ID
    FROM R
    CROSS JOIN C
    LEFT JOIN #ShippingChip_WithBoxSeq AS T
        ON T.RowNo = R.RowNo
       AND T.ColNo = C.ColNo
    ORDER BY
        R.RowNo,
        C.ColNo
    OPTION (MAXRECURSION 30);

END;