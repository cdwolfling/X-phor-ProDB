

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	产生ShippingData后， 记录
-- Notes:
exec [dbo].[uspGenerateShippingData_SaveResult] @Ship_date='2026-01-27', @Customer_Code='hk02000'

Change Log:
2025-03-01 JC: Add new parameter @PO
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspGenerateShippingData_SaveResult]
(
@Ship_date date,
@Customer_Code varchar(15),
@PO varchar(25)
)
AS
BEGIN
    SET NOCOUNT ON;

    update s set s.GenerateShippingData_Cdt=getdate(), Udt=GETDATE() from dbo.Shipping_list s
        where s.Ship_date=@Ship_date and s.Customer_Code=@Customer_Code
        and s.PO = @PO
    
END;