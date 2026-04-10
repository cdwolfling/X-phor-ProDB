CREATE TABLE [dbo].[CPStations] (
    [StationName] VARCHAR (10) NOT NULL,
    [Cdt]         DATETIME     CONSTRAINT [DF_CPStations_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CPStations] PRIMARY KEY CLUSTERED ([StationName] ASC)
);

