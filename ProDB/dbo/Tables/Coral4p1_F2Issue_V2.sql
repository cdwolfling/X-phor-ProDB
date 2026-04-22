CREATE TABLE [dbo].[Coral4p1_F2Issue_V2] (
    [LotID] VARCHAR (10) NOT NULL,
    [Cdt]   DATETIME     CONSTRAINT [DF_Coral4p1_F2Issue_V2_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_Coral4p1_F2Issue_V2] PRIMARY KEY CLUSTERED ([LotID] ASC)
);

