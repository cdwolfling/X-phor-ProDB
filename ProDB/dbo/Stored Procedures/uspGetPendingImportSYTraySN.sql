
/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026/02/08
-- Description:	获取 待处理 SY Tray SN 的清单
-- Notes:

Change Log:
2026-02-09 JC: Add Ship_date <= @Today
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspGetPendingImportSYTraySN]
AS
BEGIN
    SET NOCOUNT ON;
	declare @Today date=dateadd(dd,datediff(dd,0,getdate()),0)

	IF OBJECT_ID('tempdb..#Result') IS NOT NULL DROP TABLE #Result
	CREATE TABLE #Result(SeqID int identity(1,1), Customer_Code VARCHAR(15), OEM_Ship_date date, Carton_ID_Outter VARCHAR(15), Carton_ID_Inner VARCHAR(15), Lot_Wafer_Box_ID VARCHAR(15))

	INSERT #Result(Customer_Code, OEM_Ship_date, Carton_ID_Outter, Carton_ID_Inner, Lot_Wafer_Box_ID)
		SELECT s.Customer_Code, s.OEM_Ship_date, s.Carton_ID_Outter,s.Carton_ID_Inner, s.Lot_Wafer_Box_ID
			FROM dbo.Shipping_list s
			where s.Site='SY' and s.ImportTraySN_Cdt is null
			and s.Ship_date <= @Today
			order by s.Customer_Code, s.OEM_Ship_date, s.Carton_ID_Outter,s.Carton_ID_Inner, s.Lot_Wafer_Box_ID

	select z.SeqID, Customer_Code, OEM_Ship_date, Carton_ID_Outter, Carton_ID_Inner, z.Lot_Wafer_Box_ID
		FROM #Result z
		order by z.SeqID

END;