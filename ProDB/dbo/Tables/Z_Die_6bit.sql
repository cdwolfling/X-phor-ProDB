CREATE TABLE [dbo].[Z_Die_6bit] (
    [DieID]        INT          NOT NULL,
    [LotWafer]     VARCHAR (20) NOT NULL,
    [Seqid]        INT          NOT NULL,
    [Cbin]         VARCHAR (7)  NULL,
    [Die_Location] VARCHAR (3)  NULL,
    [Dev_ID]       VARCHAR (3)  NULL,
    [Bin]          INT          NULL,
    [BoxNo]        INT          NULL,
    [AOI_name]     VARCHAR (5)  NULL,
    [Cdt]          DATETIME     NULL
);

