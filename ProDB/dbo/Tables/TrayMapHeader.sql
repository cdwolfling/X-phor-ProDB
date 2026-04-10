CREATE TABLE [dbo].[TrayMapHeader] (
    [TrayMapId]       BIGINT       IDENTITY (1, 1) NOT NULL,
    [LotWaferTrayKey] VARCHAR (30) NOT NULL,
    [ProductModel]    VARCHAR (8)  NOT NULL,
    [LotNo]           VARCHAR (7)  NOT NULL,
    [Wafer]           VARCHAR (3)  NOT NULL,
    [LotWafer]        VARCHAR (11) NOT NULL,
    [TrayNo]          VARCHAR (2)  NOT NULL,
    [OQCTrackOutTime] DATETIME     NULL,
    [Cdt]             DATETIME     CONSTRAINT [DF_TrayMapHeader_Cdt] DEFAULT (getdate()) NULL,
    [Udt]             DATETIME     CONSTRAINT [DF_TrayMapHeader_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_TrayMapHeader] PRIMARY KEY CLUSTERED ([TrayMapId] ASC)
);








GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_TrayMapHeader_LWT]
    ON [dbo].[TrayMapHeader]([LotWaferTrayKey] ASC);

