
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
    ,@Lot_Status varchar(20)='All'
)
AS
BEGIN
    SET NOCOUNT ON;
    if OBJECT_ID('tempdb..#CycleTime') is not null drop table #CycleTime

    create table #CycleTime(FAB varchar(50),LotType varchar(50),CustomerPart varchar(50),LotID varchar(50),BaseLot varchar(50)
        ,CurrentLayer INT,CycleTime INT)
    insert #CycleTime(FAB, LotType, CustomerPart, LotID, BaseLot, CurrentLayer, CycleTime)
        select f.FAB,f.LotType,f.CustomerPart,f.LotID,f.BaseLot,f.CurrentLayer--,count(1) as countNum, min(f.DateFlag) as FirstD, max(f.DateFlag) as LastD
	    ,datediff(dd,min(f.DateFlag),max(f.DateFlag))+1 as CycleTime
	    from fab.tFabWIP f
        where (f.FAB=@FAB or @FAB='All')
        AND (f.LotType=@LotType or @LotType='All')
        AND (f.CustomerPart=@CustomerPart or @CustomerPart='All')
	    group by f.FAB,f.LotType,f.CustomerPart,f.LotID,f.BaseLot,f.CurrentLayer
        
	if OBJECT_ID('tempdb..#Lot') is not null drop table #Lot
	create table #Lot(SeqID INT identity(1,1), FAB varchar(50),LotType varchar(50),CustomerPart varchar(50),LotID varchar(50),BaseLot varchar(50),XPLot varchar(50), Lot_Status varchar(10)
        , Layer1 INT, Layer2 INT, Layer3 INT, Layer4 INT, Layer5 INT, Layer6 INT, Layer7 INT, Layer8 INT, Layer9 INT, Layer10 INT
        , Layer11 INT, Layer12 INT, Layer13 INT, Layer14 INT, Layer15 INT, Layer16 INT, Layer17 INT, Layer18 INT, Layer19 INT, Layer20 INT
        , Layer21 INT, Layer22 INT, Layer23 INT, Layer24 INT, Layer25 INT, Layer26 INT, Layer27 INT, Layer28 INT, Layer29 INT
		)
    insert #Lot(FAB, LotType, CustomerPart, LotID, BaseLot
			, Layer1, Layer2, Layer3, Layer4, Layer5, Layer6, Layer7, Layer8, Layer9, Layer10
            , Layer11, Layer12, Layer13, Layer14, Layer15, Layer16, Layer17, Layer18, Layer19, Layer20
            , Layer21, Layer22, Layer23, Layer24, Layer25, Layer26, Layer27, Layer28, Layer29)
        SELECT z.FAB, z.LotType, z.CustomerPart, z.LotID, z.BaseLot,
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
        GROUP BY z.FAB, z.LotType, z.CustomerPart, z.LotID, z.BaseLot
        
	--10. Lot Status
	declare @LastDay date=(select top 1 w.DateFlag from fab.tFabWIP w order by w.DateFlag desc)
	--10.1
	update l set l.Lot_Status='WIP' from #Lot l
		where l.Lot_Status is null
		and l.BaseLot in (select r.BaseLot from fab.tFabWIP r where r.DateFlag=@LastDay)
	--10.1
	--N,E的前面加L,其他T开头的直接用
	update l set l.XPLot=case when left(l.BaseLot,1) in ('N','E') then 'L'+l.BaseLot else l.BaseLot end
		from #Lot l
	update l set l.Lot_Status='Finished' from #Lot l
		where l.Lot_Status is null
		and l.XPLot in (select distinct w.Lot号 from dbo.Wafer w)
	--10.3
	if OBJECT_ID('tempdb..#LastLayerLot') is not null drop table #LastLayerLot
	create table #LastLayerLot(FAB varchar(50),BaseLot varchar(50),LastLayer INT)
	insert #LastLayerLot(FAB,BaseLot,LastLayer)
		select wip.FAB,wip.BaseLot,wip.LastLayer from (
		select w.FAB, w.BaseLot,max(w.CurrentLayer) as LastLayer from fab.tFabWIP w group by w.FAB, w.BaseLot) wip
		join (
		select lt.FabName,max(lt.Layer) as MaxLayer from fab.tFAB_LT lt group by lt.FabName) lt on wip.FAB=lt.FabName and wip.LastLayer=lt.MaxLayer
	update l set l.Lot_Status='Ship' from #Lot l
		where l.Lot_Status is null
		and l.BaseLot in (select r.BaseLot from #LastLayerLot r)
	--10.4
	update l set l.Lot_Status='Warn' from #Lot l
		where l.Lot_Status is null

	if @Lot_Status='All'
	begin
		select l.SeqID, l.FAB, l.LotType, l.CustomerPart, l.LotID, l.Lot_Status
			, l.Layer1, l.Layer2, l.Layer3, l.Layer4, l.Layer5, l.Layer6, l.Layer7, l.Layer8, l.Layer9, l.Layer10
            , l.Layer11, l.Layer12, l.Layer13, l.Layer14, l.Layer15, l.Layer16, l.Layer17, l.Layer18, l.Layer19, l.Layer20
            , l.Layer21, l.Layer22, l.Layer23, l.Layer24, l.Layer25, l.Layer26, l.Layer27, l.Layer28, l.Layer29
			from #Lot l
	end
	else
	begin
		select l.SeqID, l.FAB, l.LotType, l.CustomerPart, l.LotID, l.Lot_Status
			, l.Layer1, l.Layer2, l.Layer3, l.Layer4, l.Layer5, l.Layer6, l.Layer7, l.Layer8, l.Layer9, l.Layer10
            , l.Layer11, l.Layer12, l.Layer13, l.Layer14, l.Layer15, l.Layer16, l.Layer17, l.Layer18, l.Layer19, l.Layer20
            , l.Layer21, l.Layer22, l.Layer23, l.Layer24, l.Layer25, l.Layer26, l.Layer27, l.Layer28, l.Layer29
			from #Lot l
			where l.Lot_Status=@Lot_Status
	end

END;
GO
GRANT EXECUTE
    ON OBJECT::[fab].[uspReport_FabLayerCycleTime] TO [Production]
    AS [dbo];

