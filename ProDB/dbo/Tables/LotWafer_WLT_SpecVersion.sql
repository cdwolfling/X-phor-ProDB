CREATE TABLE [dbo].[LotWafer_WLT_SpecVersion] (
    [ID]                  INT          IDENTITY (1, 1) NOT NULL,
    [LotWafer]            VARCHAR (11) NOT NULL,
    [ProductFamily]       VARCHAR (20) NOT NULL,
    [ProductFamilySpecId] INT          NOT NULL,
    [Cdt]                 DATETIME     CONSTRAINT [DF_LotWafer_WLT_SpecVersion_Cdt] DEFAULT (getdate()) NULL,
    [Udt]                 DATETIME     CONSTRAINT [DF_LotWafer_WLT_SpecVersion_Udt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_LotWafer_WLT_SpecVersion] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_LotWafer_WLT_SpecVersion_ProductFamilySpec] FOREIGN KEY ([ProductFamilySpecId]) REFERENCES [spec].[ProductFamilySpec] ([ProductFamilySpecId])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_LotWafer_WLT_SpecVersion_LotWafer]
    ON [dbo].[LotWafer_WLT_SpecVersion]([LotWafer] ASC);

