CREATE TABLE [dbo].[TestTime_Record_History] (
    [HistoryID]     INT          IDENTITY (1, 1) NOT NULL,
    [ID]            INT          NOT NULL,
    [ProductFamily] VARCHAR (20) NULL,
    [LotWafer]      VARCHAR (11) NULL,
    [Station]       VARCHAR (10) NULL,
    [TestStartTime] DATETIME     NULL,
    [TestEndTime]   DATETIME     NULL,
    [Operator]      VARCHAR (10) NULL,
    [Cdt]           DATETIME     NULL,
    [Udt]           DATETIME     NULL,
    [HistoryCdt]    DATETIME     CONSTRAINT [DF_TestTime_Record_History_HistoryCdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TestTime_Record_History] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

