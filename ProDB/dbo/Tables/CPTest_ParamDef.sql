CREATE TABLE [dbo].[CPTest_ParamDef] (
    [ParamId]   INT           IDENTITY (1, 1) NOT NULL,
    [ParamName] VARCHAR (128) NOT NULL,
    CONSTRAINT [PK_CPTest_ParamDef] PRIMARY KEY CLUSTERED ([ParamId] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CPTest_ParamDef]
    ON [dbo].[CPTest_ParamDef]([ParamName] ASC);

