CREATE TABLE [dbo].[Traveler_修正目检产出] (
    [LotWafer]     VARCHAR (20)   NOT NULL,
    [FileFullPath] VARCHAR (1000) NULL,
    [FileContent]  VARCHAR (200)  NULL,
    [Notes]        VARCHAR (200)  NULL,
    [Cdt]          DATETIME       CONSTRAINT [DF_Traveler_目检产生_却第8盘之后数据_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Traveler_目检产生_却第8盘之后数据] PRIMARY KEY CLUSTERED ([LotWafer] ASC)
);

