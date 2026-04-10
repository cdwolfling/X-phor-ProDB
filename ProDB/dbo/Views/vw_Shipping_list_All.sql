



/*
用于Shippinglist上传程序（Shipping_List_Upload）, 显示excel中内容与数据库中内容的差异点

Change Log:
2026-02-07 JC: Add Site/TrackingNumber/OEM_Ship_date column
2026-01-22 JC: Add TrayLastSN column
2025-12-22 JC: Add comments
*/
CREATE VIEW [dbo].[vw_Shipping_list_All] AS
SELECT s.Shipping_list_ID
	, s.Site
	, s.Project
	, s.Ship_Type
	, s.PN
	, s.Ship_date
	, s.Customer_Code
	, s.PO
	, s.PO_End
	, s.Carton_ID_Inner
	, s.Carton_ID_Outter
	, s.Lot_Wafer_Box_ID
	, s.Lotid_Wafer
	, s.Ship_Qty
	, s.TrayLastSN
	, s.Package_Type
	, s.Lot_ID
	, s.Wafer_ID
	, s.Box_ID
	, s.TrackingNumber
	, s.OEM_Ship_date
	FROM Shipping_list s
UNION ALL
SELECT 0 AS Shipping_list_ID
	, z.Site
	, z.Project
	, z.Ship_Type
	, z.PN
	, z.Ship_date
	, z.Customer_Code
	, z.PO
	, z.PO_End
	, z.Carton_ID_Inner
	, z.Carton_ID_Outter
	, z.Lot_Wafer_Box_ID
	, z.Lotid_Wafer
	, z.Ship_Qty
	, z.TrayLastSN
	, z.Package_Type
	, z.Lot_ID
	, z.Wafer_ID
	, z.Box_ID
	, z.TrackingNumber
	, z.OEM_Ship_date
	FROM dbo.Shipping_list_staging z