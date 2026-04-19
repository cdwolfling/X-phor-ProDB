CREATE TABLE [spec].[Parameter_Xlsx_Yaml_Map] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [Xlsx_Parameter]     VARCHAR (100)  NOT NULL,
    [Min_Yaml_Parameter] NVARCHAR (100) NULL,
    [Max_Yaml_Parameter] NVARCHAR (100) NULL,
    [CreatedOn]          DATETIME       CONSTRAINT [DF_spec_Parameter_Xlsx_Yaml_Map_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [Data_colunm]        VARCHAR (1000) NULL,
    CONSTRAINT [PK_spec_Parameter_Xlsx_Yaml_Map] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [UQ_spec_Parameter_Xlsx_Yaml_Map_ParameterKey] UNIQUE NONCLUSTERED ([Xlsx_Parameter] ASC)
);


GO
GRANT SELECT
    ON OBJECT::[spec].[Parameter_Xlsx_Yaml_Map] TO [Production]
    AS [dbo];

