/*
2026-03-27 Jackie Chen
对 **Coral6p0** 在 **2026/2/4** 之前产生约65K的 **Bin7 错误 Tray Chip** 进行重新挑粒，
usp_GenerateTrayMap_ForWrongBin7 用来生成提供给外协厂 **季丰** 使用的 **Tray Map** 图。
usp_GenerateTrayMap_ForWrongBin78 则是对已挑粒成Bin7+Bin8的产品， 再根据V3的binmap去除bin2的产品

exec [dbo].[usp_GenerateTrayMap_ForWrongBin78] @LotWafer='LN41477-W01'
exec [dbo].[usp_GenerateTrayMap_ForWrongBin78] @LotWafer='LN42184-W02'

Change Log:
*/
CREATE   PROC [dbo].[usp_GenerateTrayMap_ForWrongBin78]
(
    @LotWafer   varchar(20)
)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Box_X INT
    DECLARE @Box_Y INT
    SELECT @Box_X=p.Box_X,@Box_Y=p.Box_Y FROM dbo.Wafer w
        JOIN dbo.ProductModel p on LEFT(w.SourceName,8)=p.ProductModel
        WHERE w.Wafer号=@LotWafer
        
    IF OBJECT_ID('tempdb..#Result') is not null drop table #Result
    CREATE TABLE #Result(SeqID INT identity(1,1), LotWafer varchar(20), TrayNo INT, TrayMap nvarchar(max))
    -- 1. 如果无bin78, 返回空行
    IF NOT EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.newBin in (7,8) and d.newBoxNo>0 and d.Lot_Wafer_Box_ID<>'' and d.Shipped_Customer_Code in('CD04000'))
    BEGIN
        SELECT z.LotWafer, z.TrayNo, z.TrayMap, Msg='No new Bin78 finished Data in Die_WrongBin7' FROM #Result z
        RETURN
    END
    
    -- 2. 确保Bin7数据进一次dbo.Die_WrongBin7， 后续在dbo.Die_WrongBin7中处理
    --》usp_GenerateTrayMap_ForWrongBin78只处理已经在 dbo.Die_WrongBin7 中的Wafer
    
    -- 3. 收集信息进#WrongBin7ChipSN
    IF OBJECT_ID('tempdb..#WrongBin7ChipSN') is not null drop table #WrongBin7ChipSN
    CREATE TABLE #WrongBin7ChipSN(LotWafer varchar(20), newBIN INT, TrayNo INT, ChipSN varchar(7), Tray_Y INT, Tray_X INT)
    INSERT #WrongBin7ChipSN(LotWafer, newBIN, TrayNo, ChipSN, Tray_Y, Tray_X)
        SELECT d.LotWafer, d.newBin, d.newBoxNo, d.Cbin,
        TRY_CAST(LEFT(d.newAOI_name, CHARINDEX('_', d.newAOI_name) - 1) AS INT),
        TRY_CAST(SUBSTRING(d.newAOI_name, CHARINDEX('_', d.newAOI_name) + 1, LEN(d.newAOI_name)) AS INT)
        FROM dbo.Die_WrongBin7 d
        WHERE d.LotWafer = @LotWafer AND d.Bin = 7 and d.newBin in (7,8)
        AND CHARINDEX('_', d.newAOI_name) > 0;
    CREATE INDEX IX_WrongBin7ChipSN_1 ON #WrongBin7ChipSN(LotWafer, TrayNo) INCLUDE (ChipSN, Tray_Y, Tray_X);

    -- 4. 若newBin尚未计算， 则算一次， 持久化到dbo.Die_WrongBin7
    --》Bin_V3已经在前面的工作中处理好了

    -- 5. 产生指定格式的tray map
    IF OBJECT_ID('tempdb..#s_raw') IS NOT NULL DROP TABLE #s_raw;
    CREATE TABLE #s_raw(LotWafer varchar(20),TrayNo int,TrayMapFlat nvarchar(max) NULL, Bin78_Qty INT, V3Bin2_Qty INT, Shipped_Customer_Code varchar(15));
    -- 5.1 先拼“扁平字符串”，不足 @Box_X*@Box_Y 用 '0' 补到固定长度
    INSERT #s_raw(LotWafer, TrayNo, TrayMapFlat, Bin78_Qty, V3Bin2_Qty, Shipped_Customer_Code)
        SELECT x.LotWafer, x.TrayNo, TrayMapFlat = dbo.ufnFormatBinmap_ForWrongBin7(x.Flat, @Box_X, @Box_Y), x.Bin78_Qty, x.V3Bin2_Qty, x.Shipped_Customer_Code
        FROM
        (
            SELECT c.LotWafer, c.TrayNo, Flat =
                    STRING_AGG(CONVERT(varchar(1)
                        , case when d.Lot_Wafer_Box_ID is null then 0
                            when d.Bin_V3=2 then 2
                            else d.newBIN
                            end
                        ), '')
                    WITHIN GROUP (ORDER BY c.Tray_Y DESC, c.Tray_X DESC)
                    , Bin78_Qty = sum(case when d.Lot_Wafer_Box_ID is not null and d.newBin in (7,8) then 1 else 0 end)
                    , V3Bin2_Qty = sum(case when d.Lot_Wafer_Box_ID is not null and d.Bin_V3=2 then 1 else 0 end)
                    , max(Shipped_Customer_Code) as Shipped_Customer_Code
            FROM #WrongBin7ChipSN c
            JOIN dbo.Die_WrongBin7 d ON d.LotWafer = c.LotWafer AND d.Cbin = c.ChipSN
            WHERE d.LotWafer = @LotWafer AND d.Bin = 7 and d.newBin in (7,8)
            GROUP BY c.LotWafer, c.TrayNo
        ) x;
    delete z from #s_raw z where V3Bin2_Qty=0 or z.Bin78_Qty=z.V3Bin2_Qty
    delete z from #s_raw z where Shipped_Customer_Code<>'CD04000'

    -- 5.2 每 @Box_X 个字符分行：行首行尾加 "."，最后行尾加 CRLF
    ;WITH n AS
    (
        SELECT 0 AS n
        UNION ALL
        SELECT n + 1
        FROM n
        WHERE n + 1 < @Box_Y
    )
    INSERT #Result(LotWafer, TrayNo, TrayMap)
        SELECT r.LotWafer, r.TrayNo, TrayMap =
            STRING_AGG(
            N'.' + SUBSTRING(r.TrayMapFlat, (n.n * @Box_X)+1, @Box_X) + N'.',
            CHAR(13) + CHAR(10)
        ) WITHIN GROUP (ORDER BY n.n)
        FROM #s_raw r
        CROSS JOIN n
        GROUP BY r.LotWafer, r.TrayNo

    SELECT z.LotWafer, z.TrayNo, z.TrayMap
        FROM #Result z

END