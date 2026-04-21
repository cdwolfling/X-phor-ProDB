CREATE TABLE [dbo].[TrayMapCell_History] (
    [HistoryId]   BIGINT       IDENTITY (1, 1) NOT NULL,
    [TrayMapId]   BIGINT       NOT NULL,
    [RowNo]       TINYINT      NOT NULL,
    [ColNo]       TINYINT      NOT NULL,
    [SeqAtTray]   INT          NULL,
    [ChipSN]      VARCHAR (50) NULL,
    [Udt]         DATETIME     NOT NULL,
    [HistoryTime] DATETIME     CONSTRAINT [DF_TrayMapCell_History_HistoryTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TrayMapCell_History] PRIMARY KEY CLUSTERED ([HistoryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TrayMapCell_History_TrayMapId]
    ON [dbo].[TrayMapCell_History]([TrayMapId] ASC, [HistoryTime] ASC);

