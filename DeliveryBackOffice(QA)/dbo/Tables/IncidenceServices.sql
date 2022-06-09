CREATE TABLE [dbo].[IncidenceServices] (
    [IdIncidence]          INT            IDENTITY (1, 1) NOT NULL,
    [ServiceManagementId]  INT            NULL,
    [IncidenceTypeId]      INT            NULL,
    [DescriptionIncidence] VARCHAR (300)  NULL,
    [Latitude]             VARCHAR (30)   NULL,
    [Longitude]            VARCHAR (30)   NULL,
    [Accuracy]             VARCHAR (30)   NULL,
    [RowStatus]            BIT            NOT NULL,
    [TokenCreated]         VARCHAR (50)   NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [TokenUpdated]         VARCHAR (50)   NULL,
    [DateUpdated]          DATETIME       NULL,
    [Guide]                NVARCHAR (25)  NULL,
    [Observations]         NVARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([IdIncidence] ASC),
    CONSTRAINT [FKIncidentRecolection] FOREIGN KEY ([ServiceManagementId]) REFERENCES [dbo].[ServiceManagement] ([IdServiceManagement]),
    CONSTRAINT [FKIncidenTypProduct] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType])
);

