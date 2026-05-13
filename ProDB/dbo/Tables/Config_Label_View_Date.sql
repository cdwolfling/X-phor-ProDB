CREATE TABLE [dbo].[Config_Label_View_Date] (
    [ID]         INT            IDENTITY (1, 1) NOT NULL,
    [Label_View] NVARCHAR (128) NOT NULL,
    [Date]       DATE           NULL,
    [Cdt]        DATETIME       CONSTRAINT [DF_Config_Label_View_Date_Cdt] DEFAULT (getdate()) NULL,
    [Udt]        DATETIME       CONSTRAINT [DF_Config_Label_View_Date_Udt] DEFAULT (getdate()) NULL,
    [UserID]     INT            NULL,
    CONSTRAINT [PK_Config_Label_View_Date] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Config_Label_View_Date_Label_View]
    ON [dbo].[Config_Label_View_Date]([Label_View] ASC);

