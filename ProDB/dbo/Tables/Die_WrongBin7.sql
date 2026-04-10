CREATE TABLE [dbo].[Die_WrongBin7] (
    [DieID]                 INT          IDENTITY (1, 1) NOT NULL,
    [LotWafer]              VARCHAR (20) NOT NULL,
    [Seqid]                 INT          NOT NULL,
    [Cbin]                  VARCHAR (7)  NULL,
    [Die_Location]          VARCHAR (3)  NULL,
    [Dev_ID]                VARCHAR (3)  NULL,
    [Bin]                   INT          NULL,
    [BoxNo]                 INT          NULL,
    [AOI_name]              VARCHAR (5)  NULL,
    [Cdt]                   DATETIME     NULL,
    [newBin]                INT          NULL,
    [newBoxNo]              INT          NULL,
    [newAOI_name]           VARCHAR (5)  NULL,
    [WrongBin7Cdt]          DATETIME     CONSTRAINT [DF_Die_WrongBin7_WrongBin7Cdt] DEFAULT (getdate()) NULL,
    [Bin_V3]                INT          NULL,
    [Shipped_Ship_date]     DATE         NULL,
    [Shipped_Customer_Code] VARCHAR (15) NULL,
    [Lot_Wafer_Box_ID]      VARCHAR (15) NULL,
    CONSTRAINT [PK_Die_WrongBin7] PRIMARY KEY CLUSTERED ([DieID] ASC)
);








GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Die_WrongBin7_LotWafer_Cbin]
    ON [dbo].[Die_WrongBin7]([LotWafer] ASC, [Cbin] ASC);

