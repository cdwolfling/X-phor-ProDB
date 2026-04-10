CREATE TABLE [dbo].[Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV2] (
    [DieID]        INT          NOT NULL,
    [LotWafer]     VARCHAR (20) NOT NULL,
    [Seqid]        INT          NOT NULL,
    [Cbin]         VARCHAR (7)  NULL,
    [Die_Location] VARCHAR (3)  NULL,
    [Dev_ID]       VARCHAR (3)  NULL,
    [Bin]          INT          NULL,
    [BoxNo]        INT          NULL,
    [AOI_name]     VARCHAR (5)  NULL,
    [Cdt]          DATETIME     NULL,
    [UpdateDate]   DATETIME     NULL
);


GO
CREATE NONCLUSTERED INDEX [IX_Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV2]
    ON [dbo].[Z_Die_Bin7Case_Coral6p0_33Wafer_BinmapV2]([LotWafer] ASC, [Cbin] ASC);

