

/*
-- =============================================
-- Author:		Jackie Chen
-- Create date: 2026-01-30
-- Description:	检查出货产品的插损数据
-- Notes:
exec [dbo].[uspReport_InsertionLossCheck_For_Shipping] @Ship_date='2026-02-06', @Customer_Code='hk02'
exec [dbo].[uspReport_InsertionLossCheck_For_Shipping] @Ship_date='2026-03-06', @Customer_Code='CD04', @PO='/'
exec [dbo].[uspReport_InsertionLossCheck_For_Shipping] @Ship_date='2026-04-07', @Customer_Code='SZ04000'
exec [dbo].[uspReport_InsertionLossCheck_For_Shipping] @Ship_date='2026-04-07', @Customer_Code='SZ04000', @PO='81000012938'

Change Log:
2026-04-08 JC: output ReferenceProject, ReferencePN
2026-04-07 JC: Base [dbo].[uspGenerateShippingData]
-- =============================================
*/
CREATE   PROCEDURE [dbo].[uspReport_InsertionLossCheck_For_Shipping]
(
@Ship_date date,
@Customer_Code varchar(15),
@PO varchar(25)=null
)
AS
BEGIN
    SET NOCOUNT ON;

    --declare @Ship_date date='2026-03-19'
    --declare @Customer_Code varchar(15)='HK02004'
    --declare @PO varchar(25)='Z20251028-01'
    
	IF OBJECT_ID('tempdb..#InsertionLossCheck_ShippingData') IS NOT NULL DROP TABLE #InsertionLossCheck_ShippingData
	create table #InsertionLossCheck_ShippingData(Ship_date date, Lot_Wafer_Box_ID varchar(20), SN BIGINT
		, Onchip_loss_CH01_MPD decimal(15,6), Onchip_loss_CH02_MPD decimal(15,6), Onchip_loss_CH03_MPD decimal(15,6), Onchip_loss_CH04_MPD decimal(15,6)
		, Onchip_loss_CH05_MPD decimal(15,6), Onchip_loss_CH06_MPD decimal(15,6), Onchip_loss_CH07_MPD decimal(15,6), Onchip_loss_CH08_MPD decimal(15,6)
        , PO varchar(25), ReferenceProject varchar(15), ReferencePN varchar(50))
    
	IF OBJECT_ID('tempdb..#PO_List') IS NOT NULL DROP TABLE #PO_List
    create table #PO_List(Seqid INT identity(1,1), PO varchar(25))
    if @PO is not null
    begin
        insert #PO_List(PO) values(@PO)
    end
    else
    begin
        insert #PO_List(PO)
            select s.PO from dbo.Shipping_list s
		    where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
            group by s.PO
    end
    declare @PO_SeqID INT=1, @PO_MaxSeqID INT, @PO_Selected varchar(20)
    select @PO_MaxSeqID=count(1) from #PO_List
    while @PO_SeqID<=@PO_MaxSeqID
    begin
        select @PO_Selected=null
        select @PO_Selected=PO from #PO_List z where z.Seqid=@PO_SeqID
        select @PO_SeqID=@PO_SeqID+1
        insert #InsertionLossCheck_ShippingData(Ship_date,Lot_Wafer_Box_ID,SN
            , Onchip_loss_CH01_MPD, Onchip_loss_CH02_MPD, Onchip_loss_CH03_MPD, Onchip_loss_CH04_MPD
		    , Onchip_loss_CH05_MPD, Onchip_loss_CH06_MPD, Onchip_loss_CH07_MPD, Onchip_loss_CH08_MPD
            )
            exec [dbo].[uspGenerateShippingData] @Ship_date=@Ship_date, @Customer_Code=@Customer_Code, @PO=@PO_Selected
        update z set z.PO=@PO_Selected from #InsertionLossCheck_ShippingData z where z.PO is null
    end

    
	IF OBJECT_ID('tempdb..#InsertionLossCheck_Summary') IS NOT NULL DROP TABLE #InsertionLossCheck_Summary
    create table #InsertionLossCheck_Summary(Ship_date date, Customer_Code varchar(15), PO varchar(25), Qty INT, testdataQty INT, ReferenceProject varchar(15), ReferencePN varchar(50))
    insert #InsertionLossCheck_Summary(Ship_date,Customer_Code,PO,Qty, testdataQty, ReferenceProject, ReferencePN)
	    select s.Ship_date, s.Customer_Code, s.PO, sum(s.Ship_Qty) as Qty,0,max(s.Project),max(s.PN)
		from dbo.Shipping_list s
		where s.Ship_date between @Ship_date and @Ship_date and s.Customer_Code = @Customer_Code
        and (s.PO=@PO or @PO is null)
        group by s.Ship_date, s.Customer_Code, s.PO

    ;with cte as(
        select z.PO,count(1) as testdataQty from #InsertionLossCheck_ShippingData z group by z.PO)
        update z set z.testdataQty=c.testdataQty, z.ReferenceProject=z.ReferenceProject, z.ReferencePN=z.ReferencePN
        from cte c
        join #InsertionLossCheck_Summary z on c.PO=z.PO

    select s.Ship_date, s.Customer_Code, s.PO, s.Qty, s.testdataQty
        , case when s.Qty=s.testdataQty then 'Pass' else 'Fail' end as CheckResult
        , s.ReferenceProject, s.ReferencePN
		from #InsertionLossCheck_Summary s

END;