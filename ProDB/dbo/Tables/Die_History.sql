CREATE TABLE [dbo].[Die_History] (
    [History_ID]   BIGINT       IDENTITY (1, 1) NOT NULL,
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
    [UpdateUser]   [sysname]    DEFAULT (original_login()) NOT NULL,
    [UpdateDate]   DATETIME     DEFAULT (getdate()) NOT NULL,
    [UpdateHost]   VARCHAR (64) DEFAULT (host_name()) NOT NULL,
    CONSTRAINT [PK_Die_History] PRIMARY KEY CLUSTERED ([History_ID] ASC)
);

