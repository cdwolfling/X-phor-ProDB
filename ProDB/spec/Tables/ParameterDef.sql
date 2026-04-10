CREATE TABLE [spec].[ParameterDef] (
    [ParameterId]   INT            IDENTITY (1, 1) NOT NULL,
    [ParameterKey]  VARCHAR (100)  NOT NULL,
    [ParameterName] NVARCHAR (100) NULL,
    [IsEnabled]     BIT            CONSTRAINT [DF_spec_ParameterDef_IsEnabled] DEFAULT ((1)) NOT NULL,
    [CreatedOn]     DATETIME       CONSTRAINT [DF_spec_ParameterDef_CreatedOn] DEFAULT (getdate()) NOT NULL,
    [CreatedBy]     NVARCHAR (50)  NULL,
    CONSTRAINT [PK_spec_ParameterDef] PRIMARY KEY CLUSTERED ([ParameterId] ASC),
    CONSTRAINT [UQ_spec_ParameterDef_ParameterKey] UNIQUE NONCLUSTERED ([ParameterKey] ASC)
);


GO
GRANT UPDATE
    ON OBJECT::[spec].[ParameterDef] TO [Production]
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[spec].[ParameterDef] TO [Production]
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[spec].[ParameterDef] TO [Production]
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[spec].[ParameterDef] TO [Production]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[spec].[ParameterDef] TO [Production]
    AS [dbo];

