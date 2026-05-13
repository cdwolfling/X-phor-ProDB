CREATE TABLE [dbo].[Config_Label_View_Date_History] (
    [HistoryID]      INT            IDENTITY (1, 1) NOT NULL,
    [ID]             INT            NOT NULL,
    [Label_View]     NVARCHAR (128) NULL,
    [Date]           DATE           NULL,
    [Cdt]            DATETIME       NULL,
    [Udt]            DATETIME       NULL,
    [UserID]         INT            NULL,
    [Updated_UserID] INT            NOT NULL,
    [Updated_Cdt]    DATETIME       CONSTRAINT [DF_Config_Label_View_Date_History_HistoryCdt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_Config_Label_View_Date_History] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

