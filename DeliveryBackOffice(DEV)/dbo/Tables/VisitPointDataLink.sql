CREATE TABLE [dbo].[VisitPointDataLink] (
    [IdVisitPointDataLink]   BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [VisitPointId]           INT            NULL,
    [ServiceToken]           NVARCHAR (50)  NOT NULL,
    [ServiceTokenExpiration] DATETIME       NULL,
    [DataLinkStatusId]       INT            NOT NULL,
    [RowStatus]              BIT            CONSTRAINT [DF__VisitPoin__RowSt__3DC8FF7D] DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    [DateUPdated]            DATETIME       NULL,
    [AccountId]              BIGINT         NULL,
    [VisitPointPhone]        NVARCHAR (50)  NULL,
    [VisitPointName]         NVARCHAR (100) NULL,
    [IsOnlyVisitPoint]       BIT            DEFAULT ((0)) NULL,
    CONSTRAINT [PK__VisitPoi__074B3DC8E6B2A218] PRIMARY KEY CLUSTERED ([IdVisitPointDataLink] ASC),
    CONSTRAINT [FK_VisitPointDataLink_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_VisitPointDataLink_DataLinkStatus] FOREIGN KEY ([DataLinkStatusId]) REFERENCES [dbo].[CatDataLinkStatus] ([IdCatDataLinkStatus]),
    CONSTRAINT [FK_VisitPointDataLink_VisitPoint] FOREIGN KEY ([VisitPointId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del Cliente del VisitPoint si no se ha creado el VisitPoint.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'VisitPointName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Telefono del VisitPoint si no se ha creado el VisitPoint.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'VisitPointPhone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta para poder generar servicio de recolección de la tabla AccountId.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'DateUPdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del link de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'DataLinkStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de expiración del link de recolección, NULL indica que no tiene vencimiento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'ServiceTokenExpiration';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que identifica el link de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'ServiceToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Codigo de referencia del punto de visita de la tabla VisitPointClient.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'VisitPointId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'IdVisitPointDataLink';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de links para recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si el token corresponde a un flujo el cual solo debe generar punto de visita', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VisitPointDataLink', @level2type = N'COLUMN', @level2name = N'IsOnlyVisitPoint';

