USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatVehicleCategories
   ( IdCatVehicleCategories int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
    Name nvarchar (200)  NULL,
    RowStatus bit not NULL,
    TokenCreated varchar(50)  NOT NULL,
    DateCreated datetime  NOT NULL,
    TokenUpdated varchar(50)   NULL,
    DateUpdated datetime   NULL)
GO