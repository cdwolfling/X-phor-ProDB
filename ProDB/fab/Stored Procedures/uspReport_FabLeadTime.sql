/*
=============================================
Author:		Jackie Chen
Create date: 2026-04-14
Description: 用来查看 Fab LeadTime
Sample:
exec [fab].[uspReport_FabLeadTime] @FAB = 'Fab3'

Change Log:
=============================================
*/
CREATE     PROCEDURE [fab].[uspReport_FabLeadTime](
    @FAB varchar(50)='All'
    --,@LotType varchar(50)='All'
    --,@CustomerPart varchar(20)='All'
)
AS
BEGIN
    SET NOCOUNT ON;
    if OBJECT_ID('tempdb..#LeadTime') is not null drop table #LeadTime

    create table #LeadTime(FAB varchar(50),LotType varchar(50),CustomerPart varchar(50),LotID varchar(50)
        ,CurrentLayer INT,LeadTime INT)
    insert #LeadTime(FAB, LotType, CustomerPart, LotID, CurrentLayer, LeadTime)
        select f.FAB,f.LotType,f.CustomerPart,f.LotID,f.CurrentLayer--,count(1) as countNum, min(f.DateFalg) as FirstD, max(f.DateFalg) as LastD
	    ,datediff(dd,min(f.DateFalg),max(f.DateFalg))+1 as LeadTime
	    from fab.tFabWIP f
	    group by f.FAB,f.LotType,f.CustomerPart,f.LotID,f.CurrentLayer
    
    select z.FAB, z.LotType, z.CustomerPart, z.LotID, z.CurrentLayer as Layer, z.LeadTime
        FROM #LeadTime z
        where z.FAB=@FAB or @FAB='All'

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabLeadTime] TO [Production]
    AS [dbo];

