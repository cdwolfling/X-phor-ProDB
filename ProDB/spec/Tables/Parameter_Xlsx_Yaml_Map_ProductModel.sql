CREATE TABLE [spec].[Parameter_Xlsx_Yaml_Map_ProductModel] (
    [MapId]        INT           NOT NULL,
    [ProductModel] VARCHAR (20)  NOT NULL,
    [Data_column]  VARCHAR (100) NOT NULL,
    [CreatedOn]    DATETIME      CONSTRAINT [DF_spec_PXYM_PM_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]    NVARCHAR (50) NULL,
    CONSTRAINT [PK_spec_PXYM_ProductModel] PRIMARY KEY CLUSTERED ([MapId] ASC, [ProductModel] ASC),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ParameterMap] FOREIGN KEY ([MapId]) REFERENCES [spec].[Parameter_Xlsx_Yaml_Map] ([ID]),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ProductModel] FOREIGN KEY ([ProductModel]) REFERENCES [dbo].[ProductModel] ([ProductModel])
);


GO

CREATE INDEX [IX_spec_PXYM_ProductModel_ProductModel]
    ON [spec].[Parameter_Xlsx_Yaml_Map_ProductModel]([ProductModel]);
GO
GRANT SELECT
    ON OBJECT::[spec].[Parameter_Xlsx_Yaml_Map_ProductModel] TO [SpecMaintainer]
    AS [dbo];

