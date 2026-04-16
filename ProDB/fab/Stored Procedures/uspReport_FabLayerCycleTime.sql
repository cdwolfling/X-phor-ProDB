
/*
=============================================
Author:		Jackie Chen
Create date: 2026-04-14
Description: 用来查看 Fab CycleTime
Sample:
exec [fab].[uspReport_FabLayerCycleTime] @FAB = 'FAB3',@LotType = 'PROD',@CustomerPart ='All'

Change Log:
2026-04-15 JC: DateFalg-->DateFlag
=============================================
*/
CREATE   PROCEDURE [fab].[uspReport_FabLayerCycleTime](
    @FAB varchar(50)='All'
    ,@LotType varchar(50)='All'
    ,@CustomerPart varchar(20)='All'
)
AS
BEGIN
    SET NOCOUNT ON;
    if OBJECT_ID('tempdb..#CycleTime') is not null drop table #CycleTime

    create table #CycleTime(FAB varchar(50),LotType varchar(50),CustomerPart varchar(50),LotID varchar(50)
        ,CurrentLayer INT,CycleTime INT)
    insert #CycleTime(FAB, LotType, CustomerPart, LotID, CurrentLayer, CycleTime)
        select f.FAB,f.LotType,f.CustomerPart,f.LotID,f.CurrentLayer--,count(1) as countNum, min(f.DateFlag) as FirstD, max(f.DateFlag) as LastD
	    ,datediff(dd,min(f.DateFlag),max(f.DateFlag))+1 as CycleTime
	    from fab.tFabWIP f
        where (f.FAB=@FAB or @FAB='All')
        AND (f.LotType=@LotType or @LotType='All')
        AND (f.CustomerPart=@CustomerPart or @CustomerPart='All')
	    group by f.FAB,f.LotType,f.CustomerPart,f.LotID,f.CurrentLayer

    SELECT z.FAB, z.LotType, z.CustomerPart, z.LotID,
        MAX(CASE WHEN z.CurrentLayer = 1  THEN z.CycleTime END) AS Layer1,
        MAX(CASE WHEN z.CurrentLayer = 2  THEN z.CycleTime END) AS Layer2,
        MAX(CASE WHEN z.CurrentLayer = 3  THEN z.CycleTime END) AS Layer3,
        MAX(CASE WHEN z.CurrentLayer = 4  THEN z.CycleTime END) AS Layer4,
        MAX(CASE WHEN z.CurrentLayer = 5  THEN z.CycleTime END) AS Layer5,
        MAX(CASE WHEN z.CurrentLayer = 6  THEN z.CycleTime END) AS Layer6,
        MAX(CASE WHEN z.CurrentLayer = 7  THEN z.CycleTime END) AS Layer7,
        MAX(CASE WHEN z.CurrentLayer = 8  THEN z.CycleTime END) AS Layer8,
        MAX(CASE WHEN z.CurrentLayer = 9  THEN z.CycleTime END) AS Layer9,
        MAX(CASE WHEN z.CurrentLayer = 10 THEN z.CycleTime END) AS Layer10,
        MAX(CASE WHEN z.CurrentLayer = 11 THEN z.CycleTime END) AS Layer11,
        MAX(CASE WHEN z.CurrentLayer = 12 THEN z.CycleTime END) AS Layer12,
        MAX(CASE WHEN z.CurrentLayer = 13 THEN z.CycleTime END) AS Layer13,
        MAX(CASE WHEN z.CurrentLayer = 14 THEN z.CycleTime END) AS Layer14,
        MAX(CASE WHEN z.CurrentLayer = 15 THEN z.CycleTime END) AS Layer15,
        MAX(CASE WHEN z.CurrentLayer = 16 THEN z.CycleTime END) AS Layer16,
        MAX(CASE WHEN z.CurrentLayer = 17 THEN z.CycleTime END) AS Layer17,
        MAX(CASE WHEN z.CurrentLayer = 18 THEN z.CycleTime END) AS Layer18,
        MAX(CASE WHEN z.CurrentLayer = 19 THEN z.CycleTime END) AS Layer19,
        MAX(CASE WHEN z.CurrentLayer = 20 THEN z.CycleTime END) AS Layer20,
        MAX(CASE WHEN z.CurrentLayer = 21 THEN z.CycleTime END) AS Layer21,
        MAX(CASE WHEN z.CurrentLayer = 22 THEN z.CycleTime END) AS Layer22,
        MAX(CASE WHEN z.CurrentLayer = 23 THEN z.CycleTime END) AS Layer23,
        MAX(CASE WHEN z.CurrentLayer = 24 THEN z.CycleTime END) AS Layer24,
        MAX(CASE WHEN z.CurrentLayer = 25 THEN z.CycleTime END) AS Layer25,
        MAX(CASE WHEN z.CurrentLayer = 26 THEN z.CycleTime END) AS Layer26,
        MAX(CASE WHEN z.CurrentLayer = 27 THEN z.CycleTime END) AS Layer27,
        MAX(CASE WHEN z.CurrentLayer = 28 THEN z.CycleTime END) AS Layer28,
        MAX(CASE WHEN z.CurrentLayer = 29 THEN z.CycleTime END) AS Layer29
        FROM #CycleTime z
        GROUP BY z.FAB, z.LotType, z.CustomerPart, z.LotID

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabLayerCycleTime] TO [Production]
    AS [dbo];

