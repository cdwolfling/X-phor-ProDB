CREATE TABLE [dbo].[CPStations_Product] (
    [StationName]  VARCHAR (10) NOT NULL,
    [ProductModel] VARCHAR (8)  NOT NULL,
    [Cdt]          DATETIME     CONSTRAINT [DF_CPStations_Product_Cdt] DEFAULT (getdate()) NULL,
    CONSTRAINT [PK_CPStations_Product] PRIMARY KEY CLUSTERED ([StationName] ASC, [ProductModel] ASC)
);

