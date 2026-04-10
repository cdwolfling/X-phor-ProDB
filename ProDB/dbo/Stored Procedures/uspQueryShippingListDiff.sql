

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2025/11/21
-- Description:	Query the difference between Shipping_list_staging and Shipping_list for a given site
-- Notes:
exec [uspQueryShippingListDiff] 'SH'
exec [uspQueryShippingListDiff] 'SY'

Change Log:
2026-03-28 JC: Update filter to (S.Ship_date>=DATEADD(dd,-30,getdate()) or S.Ship_date is null)
		(T.Ship_date>=DATEADD(dd,-30,getdate()) or T.Ship_date is null)
2026-03-23 JC: output order by Ship_date
2026-02-14 JC: Add filter Ship_date>=DATEADD(dd,-30,getdate()) for all DiffType
2026-02-07 JC: Add @site parameter; Use Shipping_list_staging instead of Z_Shipping_list
2026-01-21 JC: compare TrayLastSN; output "delete"; only update records in recent 30 days since performance issue
2025-11-25 JC: Add 3 output columns.
-- =============================================
*/
CREATE PROCEDURE [dbo].[uspQueryShippingListDiff]
(
@site VARCHAR(2)
)
AS
BEGIN
    SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#Gap') IS NOT NULL DROP TABLE #Gap
	CREATE TABLE #Gap(DiffType VARCHAR(10), Lot_Wafer_Box_ID VARCHAR(15), Ship_date DATE, Customer_Code VARCHAR(15), PN VARCHAR(50))

	INSERT #Gap(DiffType, Lot_Wafer_Box_ID, Ship_date, Customer_Code, PN)
		SELECT 'insert', S.Lot_Wafer_Box_ID, S.Ship_date, S.Customer_Code, S.PN
			FROM dbo.Shipping_list_staging AS S
			LEFT JOIN dbo.Shipping_list AS T ON T.site = S.site AND T.Lot_Wafer_Box_ID = S.Lot_Wafer_Box_ID
			WHERE S.site=@site AND S.Ship_date>=DATEADD(dd,-30,getdate())
			AND S.Lot_Wafer_Box_ID <> '' AND T.Lot_Wafer_Box_ID IS NULL
		UNION ALL
		SELECT 'update', S.Lot_Wafer_Box_ID, S.Ship_date, S.Customer_Code, S.PN
			FROM dbo.Shipping_list_staging AS S
			JOIN dbo.Shipping_list AS T ON T.site=S.site AND T.Lot_Wafer_Box_ID=S.Lot_Wafer_Box_ID
			WHERE S.site=@site AND (S.Ship_date>=DATEADD(dd,-30,getdate()) or S.Ship_date is null)
			AND
			(T.Project <> S.Project
			OR ISNULL(T.Ship_Type, '') <> ISNULL(S.Ship_Type, '')
			OR T.PN <> S.PN
			OR ISNULL(T.Ship_date, '2000/1/1') <> ISNULL(S.Ship_date, '2000/1/1')
			OR ISNULL(T.Customer_Code, '') <> ISNULL(S.Customer_Code, '')
			OR ISNULL(T.PO, '') <> ISNULL(S.PO, '')
			OR ISNULL(T.PO_End, '') <> ISNULL(S.PO_End, '')
			OR ISNULL(T.Carton_ID_Inner, '') <> ISNULL(S.Carton_ID_Inner, '')
			OR ISNULL(T.Carton_ID_Outter, '') <> ISNULL(S.Carton_ID_Outter, '')
			OR ISNULL(T.Lotid_Wafer, '') <> ISNULL(S.Lotid_Wafer, '')
			OR ISNULL(T.Ship_Qty, 0) <> ISNULL(S.Ship_Qty, 0)
			OR ISNULL(T.TrayLastSN, '') <> ISNULL(S.TrayLastSN, '')
			OR ISNULL(T.Package_Type, '') <> ISNULL(S.Package_Type, '')
			OR ISNULL(T.Lot_ID, '') <> ISNULL(S.Lot_ID, '')
			OR ISNULL(T.Wafer_ID, '') <> ISNULL(S.Wafer_ID, '')
			OR ISNULL(T.Box_ID, '') <> ISNULL(S.Box_ID, '')
			OR ISNULL(T.TrackingNumber, '') <> ISNULL(S.TrackingNumber, '')
			OR ISNULL(T.OEM_Ship_date, '') <> ISNULL(S.OEM_Ship_date, '')
			)
		UNION ALL
		SELECT 'delete', T.Lot_Wafer_Box_ID, T.Ship_date, T.Customer_Code, T.PN
			FROM dbo.Shipping_list_staging AS S
			RIGHT JOIN dbo.Shipping_list AS T ON T.site = S.site AND T.Lot_Wafer_Box_ID = S.Lot_Wafer_Box_ID AND S.site=@site
			WHERE T.site=@site AND (T.Ship_date>=DATEADD(dd,-30,getdate()) or T.Ship_date is null)
			AND T.Lot_Wafer_Box_ID <> '' AND S.Lot_Wafer_Box_ID IS NULL

	SELECT g.DiffType, g.Lot_Wafer_Box_ID, g.Ship_date, g.Customer_Code, g.PN
		FROM #Gap g
		order by g.Ship_date
END;
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[uspQueryShippingListDiff] TO [Production]
    AS [dbo];
