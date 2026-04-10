/*
2026-02-13 Jackie Chen
查找优先队列中尚未处理的Traveler清单, 更新标记位， 输出文件清单

Change Log:
*/
CREATE   PROCEDURE dbo.uspProcessTravelerOfPriorityQueue
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE t WITH (UPDLOCK, READPAST, ROWLOCK)
        SET t.ProcessedCount  = t.ProcessedCount + 1,
            t.LastProcessedAt = GETDATE()
    OUTPUT
        inserted.Id,
        inserted.LotWafer,
        CASE
            WHEN inserted.SourceDir IS NULL OR LTRIM(RTRIM(inserted.SourceDir)) = '' THEN inserted.SourceName
            WHEN RIGHT(inserted.SourceDir, 1) IN ('\', '/') THEN inserted.SourceDir + inserted.SourceName
            ELSE inserted.SourceDir + '\' + inserted.SourceName
        END AS FullPath,
        inserted.ProcessedCount AS NewProcessedCount,
        inserted.LastProcessedAt
    FROM dbo.TravelerFilePriorityQueue AS t
    WHERE t.ProcessedCount = 0;
END