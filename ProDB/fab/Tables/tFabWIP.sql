CREATE TABLE [fab].[tFabWIP] (
    [ID]           INT          IDENTITY (1, 1) NOT NULL,
    [LotID]        VARCHAR (50) NULL,
    [LotType]      VARCHAR (50) NULL,
    [CustomerPart] VARCHAR (50) NULL,
    [Qty]          INT          NULL,
    [StartDate]    DATE         NULL,
    [FAB]          VARCHAR (50) NULL,
    [CurrentLayer] INT          NULL,
    [TotalLayers]  INT          NULL,
    [DateFalg]     DATE         NULL,
    [Cdt]          DATETIME     CONSTRAINT [DF_tFabWIP_Cdt] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_tFabWIP] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
GRANT VIEW DEFINITION
    ON OBJECT::[fab].[tFabWIP] TO [Production]
    AS [dbo];


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

