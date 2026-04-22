CREATE TABLE [dbo].[Coral4p1_F2Issue_V1] (
    [LotID] VARCHAR (10) NOT NULL,
    [Cdt]   DATETIME     CONSTRAINT [DF_Coral4p1_F2Issue_V1_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Coral4p1_F2Issue_V1] PRIMARY KEY CLUSTERED ([LotID] ASC)
);

