CREATE TABLE [dbo].[LotWafer_WLT_SpecVersion_History] (
    [HistoryID]           INT          IDENTITY (1, 1) NOT NULL,
    [ID]                  INT          NOT NULL,
    [LotWafer]            VARCHAR (11) NOT NULL,
    [ProductFamily]       VARCHAR (20) NOT NULL,
    [ProductFamilySpecId] INT          NOT NULL,
    [Cdt]                 DATETIME     NULL,
    [Udt]                 DATETIME     NULL,
    [UserID]              INT          NULL,
    [Deleted_UserID]      INT          NOT NULL,
    [Deleted_Cdt]         DATETIME     CONSTRAINT [DF_LotWafer_WLT_SpecVersion_History_HistoryCdt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_LotWafer_WLT_SpecVersion_History] PRIMARY KEY CLUSTERED ([HistoryID] ASC)
);

