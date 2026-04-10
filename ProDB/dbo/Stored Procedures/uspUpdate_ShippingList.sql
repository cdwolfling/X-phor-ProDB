

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/11/21
-- Description:	Refer Shipping_list_staging, Update Shipping_list
-- Notes:

Change Log:
2026-02-07 JC: Add @site parameter; Use Shipping_list_staging instead of Z_Shipping_list
2026-01-21 JC: Add Column TrayLastSN; Add the delete scenario
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspUpdate_ShippingList]
(
@site VARCHAR(2),
@Lot_Wafer_Box_ID VARCHAR(15)
)
AS
BEGIN
    SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROM dbo.Shipping_list_staging AS S WHERE S.site=@site AND S.Lot_Wafer_Box_ID=@Lot_Wafer_Box_ID)
		AND EXISTS(SELECT 1 FROM dbo.Shipping_list AS T WHERE T.site=@site AND T.Lot_Wafer_Box_ID=@Lot_Wafer_Box_ID)
	BEGIN
		UPDATE T SET T.Project = S.Project
			, T.Ship_Type = S.Ship_Type
			, T.PN = S.PN
			, T.Ship_date = S.Ship_date
			, T.Customer_Code = S.Customer_Code
			, T.PO = S.PO
			, T.PO_End = S.PO_End
			, T.Carton_ID_Inner = S.Carton_ID_Inner
			, T.Carton_ID_Outter = S.Carton_ID_Outter
			, T.Lotid_Wafer = S.Lotid_Wafer
			, T.Ship_Qty = S.Ship_Qty
			, T.TrayLastSN = S.TrayLastSN
			, T.Package_Type = S.Package_Type
			, T.Lot_ID = S.Lot_ID
			, T.Wafer_ID = S.Wafer_ID
			, T.Box_ID = S.Box_ID
			, T.TrackingNumber = S.TrackingNumber
			, T.OEM_Ship_date = S.OEM_Ship_date
			FROM dbo.Shipping_list_staging AS S
			JOIN dbo.Shipping_list AS T ON T.site=S.site AND T.Lot_Wafer_Box_ID=S.Lot_Wafer_Box_ID
			WHERE S.site=@site AND S.Lot_Wafer_Box_ID = @Lot_Wafer_Box_ID
			RETURN
	END
	
	IF EXISTS(SELECT 1 FROM dbo.Shipping_list_staging AS S WHERE S.site=@site AND S.Lot_Wafer_Box_ID=@Lot_Wafer_Box_ID)
	BEGIN
		INSERT dbo.Shipping_list(site, Project, Ship_Type, PN, Ship_date, Customer_Code, PO, PO_End, Carton_ID_Inner, Carton_ID_Outter, Lot_Wafer_Box_ID
			, Lotid_Wafer, Ship_Qty, TrayLastSN, Package_Type, Lot_ID, Wafer_ID, Box_ID, TrackingNumber, OEM_Ship_date)
			SELECT S.site, S.Project, S.Ship_Type, S.PN, S.Ship_date, S.Customer_Code, S.PO, S.PO_End, S.Carton_ID_Inner, S.Carton_ID_Outter, S.Lot_Wafer_Box_ID
			, S.Lotid_Wafer, S.Ship_Qty, S.TrayLastSN, S.Package_Type, S.Lot_ID, S.Wafer_ID, S.Box_ID, S.TrackingNumber, S.OEM_Ship_date
			FROM dbo.Shipping_list_staging AS S
			WHERE S.site=@site AND S.Lot_Wafer_Box_ID = @Lot_Wafer_Box_ID
	END
	ELSE
	BEGIN
		DELETE T
			FROM dbo.Shipping_list AS T
			WHERE T.site=@site AND T.Lot_Wafer_Box_ID = @Lot_Wafer_Box_ID
	END
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspUpdate_ShippingList] TO [Production]
    AS [dbo];
