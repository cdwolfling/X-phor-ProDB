CREATE TABLE [dbo].[TestTime_Record] (
    [ID]            INT          IDENTITY (1, 1) NOT NULL,
    [ProductFamily] VARCHAR (20) NULL,
    [LotWafer]      VARCHAR (11) NULL,
    [Station]       VARCHAR (10) NULL,
    [TestStartTime] DATETIME     NULL,
    [TestEndTime]   DATETIME     NULL,
    [Operator]      VARCHAR (10) NULL,
    [Cdt]           DATETIME     CONSTRAINT [DF_TestTime_Record_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TestTime_Record] PRIMARY KEY CLUSTERED ([ID] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_TestTime_Record_LotWafer_TestStartTime]
    ON [dbo].[TestTime_Record]([LotWafer] ASC, [TestStartTime] ASC);

