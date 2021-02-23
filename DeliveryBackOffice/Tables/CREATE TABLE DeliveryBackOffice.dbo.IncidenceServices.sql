USE [DeliveryBackOffice]
GO

drop table dbo.IncidenceServices

CREATE TABLE DeliveryBackOffice.dbo.IncidenceServices
   ( IdIncidence int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
    ServiceManagementId int  NULL,
    IncidenceTypeId int  NULL,
    DescriptionIncidence varchar (200) NULL,
    Accuracy varchar(200) null,
    Latitude varchar (200) null,
    Longitude varchar (200) null,
    RowStatus bit not NULL,
    TokenCreated varchar(50)  NOT NULL,
    DateCreated datetime  NOT NULL,
    TokenUpdated varchar(50)   NULL,
    DateUpdated datetime   NULL,
    CONSTRAINT FKIncidentRecolection FOREIGN KEY (ServiceManagementId) REFERENCES ServiceManagement(IdServiceManagement),
    CONSTRAINT FKIncidenTypProduct FOREIGN KEY (IncidenceTypeId) REFERENCES CatTypeIncidence(IdIncidenceType))
GO



