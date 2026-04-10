CREATE TABLE [dbo].[CPTest_Value] (
    [ChipTestId] BIGINT          NOT NULL,
    [ParamId]    INT             NOT NULL,
    [Val]        DECIMAL (15, 6) NULL,
    CONSTRAINT [PK_CPTest_Value] PRIMARY KEY CLUSTERED ([ChipTestId] ASC, [ParamId] ASC),
    CONSTRAINT [FK_CPTest_Value_Chip] FOREIGN KEY ([ChipTestId]) REFERENCES [dbo].[CPTest_Chip] ([ChipTestId]),
    CONSTRAINT [FK_CPTest_Value_Param] FOREIGN KEY ([ParamId]) REFERENCES [dbo].[CPTest_ParamDef] ([ParamId])
);


GO
CREATE NONCLUSTERED INDEX [IX_CPTest_Value_Param]
    ON [dbo].[CPTest_Value]([ParamId] ASC)
    INCLUDE([Val], [ChipTestId]);

