CREATE TABLE [spec].[Parameter_Xlsx_Yaml_Map_ProductModel] (
    [ParameterId]   INT          NOT NULL,
    [ProductModel]  VARCHAR(20)  NOT NULL,
    [Data_column]   VARCHAR(100) NOT NULL,
    [CreatedOn]     DATETIME     NOT NULL CONSTRAINT [DF_spec_PXYM_PM_CreatedOn] DEFAULT (GETDATE()),
    [CreatedBy]     NVARCHAR(50) NULL,
    CONSTRAINT [PK_spec_PXYM_ProductModel]
        PRIMARY KEY CLUSTERED ([ParameterId], [ProductModel]),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ParameterDef]
        FOREIGN KEY ([ParameterId]) REFERENCES [spec].[ParameterDef]([ParameterId]),
    CONSTRAINT [FK_spec_PXYM_ProductModel_ProductModel]
        FOREIGN KEY ([ProductModel]) REFERENCES [dbo].[ProductModel]([ProductModel])
);
GO

CREATE INDEX [IX_spec_PXYM_ProductModel_ProductModel]
    ON [spec].[Parameter_Xlsx_Yaml_Map_ProductModel]([ProductModel]);