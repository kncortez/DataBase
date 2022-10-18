CREATE TABLE [dbo].[Act] (
    [IdAct]             INT            IDENTITY (1, 1) NOT NULL,
    [CatRouteId]        INT            NOT NULL,
    [DateOfRoute]       DATETIME       NOT NULL,
    [ResponsibleName]   NVARCHAR (100) NULL,
    [ResponsibleCUI]    NVARCHAR (50)  NULL,
    [CatTypeActId]      INT            NOT NULL,
    [AuthorizationDate] DATETIME       NULL,
    [RowStatus]         BIT            NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    CONSTRAINT [PK_Act] PRIMARY KEY CLUSTERED ([IdAct] ASC)
);

