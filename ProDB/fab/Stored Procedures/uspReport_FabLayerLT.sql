/*
=============================================
Author:		Jackie Chen
Create date: 2026-04-14
Description: 用来查看 Fab LeadTime
Sample:
exec [fab].[uspReport_FabLayerLT] @FAB = 'FAB3',@LotType = 'PROD',@CustomerPart ='All'

Change Log:
=============================================
*/
CREATE     PROCEDURE [fab].[uspReport_FabLayerLT](
    @FAB varchar(50)='All'
    ,@LotType varchar(50)='All'
    ,@CustomerPart varchar(20)='All'
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
        where (f.FAB=@FAB or @FAB='All')
        AND (f.LotType=@LotType or @LotType='All')
        AND (f.CustomerPart=@CustomerPart or @CustomerPart='All')
	    group by f.FAB,f.LotType,f.CustomerPart,f.LotID,f.CurrentLayer

    SELECT z.FAB, z.LotType, z.CustomerPart, z.LotID,
        MAX(CASE WHEN z.CurrentLayer = 1  THEN z.LeadTime END) AS Layer1,
        MAX(CASE WHEN z.CurrentLayer = 2  THEN z.LeadTime END) AS Layer2,
        MAX(CASE WHEN z.CurrentLayer = 3  THEN z.LeadTime END) AS Layer3,
        MAX(CASE WHEN z.CurrentLayer = 4  THEN z.LeadTime END) AS Layer4,
        MAX(CASE WHEN z.CurrentLayer = 5  THEN z.LeadTime END) AS Layer5,
        MAX(CASE WHEN z.CurrentLayer = 6  THEN z.LeadTime END) AS Layer6,
        MAX(CASE WHEN z.CurrentLayer = 7  THEN z.LeadTime END) AS Layer7,
        MAX(CASE WHEN z.CurrentLayer = 8  THEN z.LeadTime END) AS Layer8,
        MAX(CASE WHEN z.CurrentLayer = 9  THEN z.LeadTime END) AS Layer9,
        MAX(CASE WHEN z.CurrentLayer = 10 THEN z.LeadTime END) AS Layer10,
        MAX(CASE WHEN z.CurrentLayer = 11 THEN z.LeadTime END) AS Layer11,
        MAX(CASE WHEN z.CurrentLayer = 12 THEN z.LeadTime END) AS Layer12,
        MAX(CASE WHEN z.CurrentLayer = 13 THEN z.LeadTime END) AS Layer13,
        MAX(CASE WHEN z.CurrentLayer = 14 THEN z.LeadTime END) AS Layer14,
        MAX(CASE WHEN z.CurrentLayer = 15 THEN z.LeadTime END) AS Layer15,
        MAX(CASE WHEN z.CurrentLayer = 16 THEN z.LeadTime END) AS Layer16,
        MAX(CASE WHEN z.CurrentLayer = 17 THEN z.LeadTime END) AS Layer17,
        MAX(CASE WHEN z.CurrentLayer = 18 THEN z.LeadTime END) AS Layer18,
        MAX(CASE WHEN z.CurrentLayer = 19 THEN z.LeadTime END) AS Layer19,
        MAX(CASE WHEN z.CurrentLayer = 20 THEN z.LeadTime END) AS Layer20,
        MAX(CASE WHEN z.CurrentLayer = 21 THEN z.LeadTime END) AS Layer21,
        MAX(CASE WHEN z.CurrentLayer = 22 THEN z.LeadTime END) AS Layer22,
        MAX(CASE WHEN z.CurrentLayer = 23 THEN z.LeadTime END) AS Layer23,
        MAX(CASE WHEN z.CurrentLayer = 24 THEN z.LeadTime END) AS Layer24,
        MAX(CASE WHEN z.CurrentLayer = 25 THEN z.LeadTime END) AS Layer25,
        MAX(CASE WHEN z.CurrentLayer = 26 THEN z.LeadTime END) AS Layer26,
        MAX(CASE WHEN z.CurrentLayer = 27 THEN z.LeadTime END) AS Layer27,
        MAX(CASE WHEN z.CurrentLayer = 28 THEN z.LeadTime END) AS Layer28,
        MAX(CASE WHEN z.CurrentLayer = 29 THEN z.LeadTime END) AS Layer29
        FROM #LeadTime z
        GROUP BY z.FAB, z.LotType, z.CustomerPart, z.LotID

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabLayerLT] TO [Production]
    AS [dbo];

