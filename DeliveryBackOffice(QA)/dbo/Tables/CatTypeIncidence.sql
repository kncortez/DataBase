CREATE TABLE [dbo].[CatTypeIncidence] (
    [IdIncidenceType]          INT           IDENTITY (1, 1) NOT NULL,
    [NameIncidence]            VARCHAR (200) NULL,
    [DescriptionIncidence]     VARCHAR (200) NULL,
    [RowStatus]                BIT           NOT NULL,
    [TokenCreated]             VARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             VARCHAR (50)  NULL,
    [DateUpdated]              DATETIME      NULL,
    [ServiceType]              NVARCHAR (25) NULL,
    [OrderId]                  INT           NULL,
    [Code]                     INT           NULL,
    [IncidenceClasificationId] INT           NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceType] ASC)
);



