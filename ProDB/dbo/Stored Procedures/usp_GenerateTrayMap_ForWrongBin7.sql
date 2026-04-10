/*
2026-02-03 Jackie Chen
对 **Coral6p0** 在 **2026/2/4** 之前产生约65K的 **Bin7 错误 Tray Chip** 进行重新挑粒，此SP用来生成提供给外协厂 **季丰** 使用的 **Tray Map** 图。

exec [dbo].[usp_GenerateTrayMap_ForWrongBin7] @LotWafer='LN41477-W07'
exec [dbo].[usp_GenerateTrayMap_ForWrongBin7] @LotWafer='LN42184-W02'
exec [dbo].[usp_GenerateTrayMap_ForWrongBin7] @LotWafer='LN42173-W22'

Change Log:
2026-02-06 JC: line左边和右边都 加上 N'.'; 引入ufnFormatBinmap_ForWrongBin7修正bug
2026-02-05 JC: 如果先前导入了未分Box的Bin7数据， 则先删除此LotWafer数据再重新导入整个Wafer
2026-02-03 JC: 代码重构
*/
CREATE PROC [dbo].[usp_GenerateTrayMap_ForWrongBin7]
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
    -- 1. 如果无bin7, 返回空行
    IF NOT EXISTS (SELECT 1 FROM dbo.Die d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.BoxNo>0)
        AND NOT EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.BoxNo>0)
    BEGIN
        SELECT z.LotWafer, z.TrayNo, z.TrayMap, Msg='No Bin7 Data in Both Die and Die_WrongBin7' FROM #Result z
        RETURN
    END
    
    -- 2. 确保Bin7数据进一次dbo.Die_WrongBin7， 后续在dbo.Die_WrongBin7中处理
    IF NOT EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.BoxNo>0)
    BEGIN
        --如果先前导入了未分Box的Bin7数据， 则先删除此LotWafer数据再重新导入整个Wafer
        IF EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.BoxNo is null)
        BEGIN
            delete d FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer
        END

        insert dbo.Die_WrongBin7(LotWafer,Seqid,Cbin,Die_Location,Dev_ID,Bin,BoxNo,AOI_name,Cdt)
            select d.LotWafer,d.Seqid,d.Cbin,d.Die_Location,d.Dev_ID,d.Bin,d.BoxNo,d.AOI_name,d.Cdt
	        from dbo.Die d
	        where d.LotWafer=@LotWafer
    END
    
    -- 3. 收集信息进#WrongBin7ChipSN
    IF OBJECT_ID('tempdb..#WrongBin7ChipSN') is not null drop table #WrongBin7ChipSN
    if OBJECT_ID('tempdb..#Bin7Data') is not null drop table #Bin7Data
    CREATE TABLE #WrongBin7ChipSN(LotWafer varchar(20), TrayNo INT, ChipSN varchar(7), Tray_Y INT, Tray_X INT)
    CREATE TABLE #Bin7Data (LotWafer varchar(20), ChipSN varchar(7), MinER decimal(15,6), newBIN int);
    INSERT #WrongBin7ChipSN(LotWafer, TrayNo, ChipSN, Tray_Y, Tray_X)
        SELECT d.LotWafer, d.BoxNo, d.Cbin,
        TRY_CAST(LEFT(d.AOI_name, CHARINDEX('_', d.AOI_name) - 1) AS INT),
        TRY_CAST(SUBSTRING(d.AOI_name, CHARINDEX('_', d.AOI_name) + 1, LEN(d.AOI_name)) AS INT)
        FROM dbo.Die_WrongBin7 d
        WHERE d.LotWafer = @LotWafer AND d.Bin = 7
        AND CHARINDEX('_', d.AOI_name) > 0;
    CREATE INDEX IX_WrongBin7ChipSN_1 ON #WrongBin7ChipSN(LotWafer, TrayNo) INCLUDE (ChipSN, Tray_Y, Tray_X);

    -- 4. 若newBin尚未计算， 则算一次， 持久化到dbo.Die_WrongBin7
    IF EXISTS (SELECT 1 FROM dbo.Die_WrongBin7 d WHERE d.LotWafer = @LotWafer and d.Bin=7 and d.newBin is NULL)
    begin
        INSERT INTO #Bin7Data (LotWafer, ChipSN, MinER, newBIN)
            SELECT v.LotWafer, v.ChipSN, M.MinVal,
                CASE 
                    WHEN M.MinVal >= 24 AND M.MinVal < 25 THEN 8
                    WHEN M.MinVal >= 23 AND M.MinVal < 24 THEN 7
                    WHEN M.MinVal < 23                   THEN 2
                    ELSE -1 
                END
            FROM #WrongBin7ChipSN z
            JOIN dbo.vw_CPTestData v ON z.LotWafer = v.LotWafer AND z.ChipSN = v.ChipSN AND v.isRecent = 1
            CROSS APPLY (
                SELECT MIN(val) FROM (VALUES 
                    (v.ER_CH01), (v.ER_CH02), (v.ER_CH03), (v.ER_CH04),
                    (v.ER_CH05), (v.ER_CH06), (v.ER_CH07), (v.ER_CH08)
                ) x(val)
            ) AS M(MinVal);
        CREATE INDEX IX_Bin7Data_1 ON #Bin7Data(LotWafer, ChipSN) INCLUDE (newBIN);

        UPDATE w SET w.newBin=z.newBIN FROM #Bin7Data z
            JOIN dbo.Die_WrongBin7 w ON z.LotWafer=w.LotWafer AND z.ChipSN=w.Cbin
    END

    -- 5. 产生指定格式的tray map
    IF OBJECT_ID('tempdb..#s_raw') IS NOT NULL DROP TABLE #s_raw;
    CREATE TABLE #s_raw(LotWafer varchar(20),TrayNo int,TrayMapFlat nvarchar(max) NULL);
    -- 5.1 先拼“扁平字符串”，不足 @Box_X*@Box_Y 用 '0' 补到固定长度
    INSERT #s_raw(LotWafer, TrayNo, TrayMapFlat)
        SELECT x.LotWafer, x.TrayNo, TrayMapFlat = dbo.ufnFormatBinmap_ForWrongBin7(x.Flat, @Box_X, @Box_Y)
        FROM
        (
            SELECT c.LotWafer, c.TrayNo, Flat =
                    STRING_AGG(CONVERT(varchar(1), d.newBIN), '')
                    WITHIN GROUP (ORDER BY c.Tray_Y DESC, c.Tray_X DESC)
            FROM #WrongBin7ChipSN c
            JOIN dbo.Die_WrongBin7 d ON d.LotWafer = c.LotWafer AND d.Cbin = c.ChipSN
            GROUP BY c.LotWafer, c.TrayNo
        ) x;

    -- 5.2 每 @Box_X 个字符分行：行首加 "."，行尾加 CRLF
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

    SELECT z.LotWafer, z.TrayNo, z.TrayMap FROM #Result z

    --declare @traymaptxt varchar(max)
    --select top 1 @traymaptxt=z.TrayMap from #Result z
    --print @traymaptxt
END