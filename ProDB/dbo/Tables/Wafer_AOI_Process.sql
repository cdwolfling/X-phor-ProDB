CREATE TABLE [dbo].[Wafer_AOI_Process] (
    [Seqid]        INT         IDENTITY (1, 1) NOT NULL,
    [ProductModel] VARCHAR (8) NULL,
    [LotNo]        VARCHAR (7) NULL,
    [Wafer]        VARCHAR (3) NULL,
    [Cdt]          DATETIME    CONSTRAINT [DF_Wafer_AOI_Process_Cdt] DEFAULT (getdate()) NULL,
    [Udt]          DATETIME    CONSTRAINT [DF_Wafer_AOI_Process_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Wafer_AOI_Process] PRIMARY KEY CLUSTERED ([Seqid] ASC)
);




GO
GRANT UPDATE
    ON OBJECT::[dbo].[Wafer_AOI_Process] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[Wafer_AOI_Process] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[Wafer_AOI_Process] TO [Production]
    AS [dbo];


GO
CREATE NONCLUSTERED INDEX [IX_Wafer_AOI_Process_Lot_Wafer]
    ON [dbo].[Wafer_AOI_Process]([LotNo] ASC, [Wafer] ASC);

