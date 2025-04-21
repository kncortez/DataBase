CREATE TABLE [dbo].[VisitPointByUser] (
    [IdVisitPointByUser] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdVisitPointClient] INT           NOT NULL,
    [RegisterUserID]     BIGINT        NULL,
    [RowStatus]          BIT           CONSTRAINT [DF_VisitPointByUser_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]       NVARCHAR (50) NULL,
    [DateCreated]        DATETIME      NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    [DateUpdated]        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdVisitPointByUser] ASC),
    CONSTRAINT [FK_VisitPointByUser_RegisterUser] FOREIGN KEY ([RegisterUserID]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO
CREATE NONCLUSTERED INDEX [IDX_RegisterUserID_Included_Rows]
    ON [dbo].[VisitPointByUser]([RegisterUserID] ASC)
    INCLUDE([IdVisitPointClient]);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa los puntos de visita por cliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'IdVisitPointByUser'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia al punto de visita',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'IdVisitPointClient'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia al usuario registrado',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'RegisterUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'VisitPointByUser',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'