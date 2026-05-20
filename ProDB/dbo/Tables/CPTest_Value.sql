CREATE TABLE [dbo].[CPTest_Value] (
    [ChipTestId] BIGINT          NOT NULL,
    [ParamId]    INT             NOT NULL,
    [Val]        DECIMAL (15, 6) NULL,
    CONSTRAINT [PK_CPTest_Value] PRIMARY KEY CLUSTERED ([ChipTestId] ASC, [ParamId] ASC),
    CONSTRAINT [FK_CPTest_Value_Chip] FOREIGN KEY ([ChipTestId]) REFERENCES [dbo].[CPTest_Chip] ([ChipTestId]) ON DELETE CASCADE,
    CONSTRAINT [FK_CPTest_Value_Param] FOREIGN KEY ([ParamId]) REFERENCES [dbo].[CPTest_ParamDef] ([ParamId])
);






GO
