

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	产生ShippingData的待处理清单
-- Notes:
exec [dbo].[uspGenerateShippingData_ToDoList]

Change Log:
2026-04-20 JC: dbo.Customer_ShippingData-->dbo.Config_Ship_InsertionLoss_Customer
2026-03-09 JC: Add white list: s.Project in ('Coral3.1','Coral6.0','CORAL3P1','CORAL6P0')
2026-03-01 JC: Add Output PO
2026-02-14 JC: Add Ship_date between '2026/1/12' and DATEADD(dd,-1,@Today), 2026/1/12之前的数据在“Chip_Shipment_Statistics_2025.xlsx”文件中, 不再处理
2026-02-09 JC: Add Ship_date between '2026/1/1' and DATEADD(dd,-1,@Today)
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspGenerateShippingData_ToDoList]
AS
BEGIN
    SET NOCOUNT ON;
	declare @Today date=dateadd(dd,datediff(dd,0,getdate()),0)
	select s.Ship_date, s.Customer_Code, s.PO, sum(s.Ship_Qty) as Ship_Qty
		from dbo.Shipping_list s
		join dbo.Config_Ship_InsertionLoss_Customer c on s.Customer_Code=c.Customer_Code
		join dbo.Config_Ship_InsertionLoss_ProductModel m on replace(s.Project,'.','p')=m.ProductModel
		where s.Ship_date between '2026/1/12' and DATEADD(dd,-1,@Today)
		and s.GenerateShippingData_Cdt is null
		--and s.Project in ('Coral3.1','Coral6.0','CORAL3P1','CORAL6P0')
		group by s.Ship_date, s.Customer_Code, s.PO
END;