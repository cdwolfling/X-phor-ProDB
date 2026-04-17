CREATE TABLE [fab].[tFabWIP] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [LotID]        VARCHAR (50) NULL,
    [LotType]      VARCHAR (50) NULL,
    [TowerPart]    VARCHAR (50) NULL,
    [CustomerPart] VARCHAR (50) NULL,
    [Stage]        VARCHAR (50) NULL,
    [FutHold]      VARCHAR (50) NULL,
    [CompPct]      INT          NULL,
    [Qty]          INT          NULL,
    [Priority]     VARCHAR (50) NULL,
    [GrossDPW]     INT          NULL,
    [StartDate]    DATE         NULL,
    [ECD]          DATE         NULL,
    [CRD]          DATE         NULL,
    [FCD]          DATE         NULL,
    [RFCD]         DATE         NULL,
    [FAB]          VARCHAR (50) NULL,
    [CurrentLayer] INT          NULL,
    [TotalLayers]  INT          NULL,
    [PONumber]     VARCHAR (50) NULL,
    [POLine]       INT          NULL,
    [DateFlag]     DATE         NULL,
    [Cdt]          DATETIME     CONSTRAINT [DF_tFabWIP_Cdt] DEFAULT (getdate()) NOT NULL,
    [BaseLot]      VARCHAR (50) NULL,
    CONSTRAINT [PK_tFabWIP] PRIMARY KEY CLUSTERED ([ID] ASC)
);








GO



GO
GRANT UPDATE
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_tFabWIP_LotID_DateFlag]
    ON [fab].[tFabWIP]([LotID] ASC, [DateFlag] ASC);

