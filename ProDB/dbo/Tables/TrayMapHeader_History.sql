CREATE TABLE [dbo].[TrayMapHeader_History] (
    [HistoryId]       BIGINT       IDENTITY (1, 1) NOT NULL,
    [TrayMapId]       BIGINT       NOT NULL,
    [LotWaferTrayKey] VARCHAR (30) NOT NULL,
    [ProductModel]    VARCHAR (20) NOT NULL,
    [LotNo]           VARCHAR (7)  NOT NULL,
    [Wafer]           VARCHAR (3)  NOT NULL,
    [LotWafer]        VARCHAR (11) NOT NULL,
    [TrayNo]          VARCHAR (2)  NOT NULL,
    [OQCTrackOutTime] DATETIME     NULL,
    [Cdt]             DATETIME     NULL,
    [Udt]             DATETIME     NULL,
    [HistoryTime]     DATETIME     CONSTRAINT [DF_TrayMapHeader_History_HistoryTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_TrayMapHeader_History] PRIMARY KEY CLUSTERED ([HistoryId] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_TrayMapHeader_History_Query]
    ON [dbo].[TrayMapHeader_History]([ProductModel] ASC, [LotNo] ASC, [Wafer] ASC, [TrayNo] ASC, [HistoryTime] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TrayMapHeader_History_TrayMapId]
    ON [dbo].[TrayMapHeader_History]([TrayMapId] ASC);

