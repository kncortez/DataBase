CREATE TABLE [dbo].[IncidentTypeRelation] (
    [IdRelation]            INT           IDENTITY (1, 1) NOT NULL,
    [StatusOrderExternalId] INT           NOT NULL,
    [IncidenceTypeId]       INT           NOT NULL,
    [RowStatus]             BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateUpdated]           DATETIME      NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdRelation] ASC),
    CONSTRAINT [FK_IncidentTypeRelation_CatTypeIncidence] FOREIGN KEY ([IncidenceTypeId]) REFERENCES [dbo].[CatTypeIncidence] ([IdIncidenceType]),
    CONSTRAINT [FK_IncidentTypeRelation_StatusOrderExternal] FOREIGN KEY ([StatusOrderExternalId]) REFERENCES [dbo].[StatusOrderExternal] ([IdStatusOrderExternal])
);

