CREATE TABLE [dbo].[CourierPickupManifest] (
    [IdManifest]       BIGINT         IDENTITY (1000, 1) NOT FOR REPLICATION NOT NULL,
    [ManifestSerie]    NVARCHAR (50)  NOT NULL,
    [SenderReceiverId] INT            NOT NULL,
    [ManifestURL]      NVARCHAR (MAX) NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     NVARCHAR (100) NOT NULL,
    [DateCreated]      DATETIME       NOT NULL,
    [TokenUpdated]     NVARCHAR (100) NULL,
    [DateUpdated]      DATETIME       NULL,
    CONSTRAINT [PKCourierPickupManifest] PRIMARY KEY CLUSTERED ([IdManifest] ASC),
    CONSTRAINT [FKCourierPickupManifestSenderReceiverId] FOREIGN KEY ([SenderReceiverId]) REFERENCES [dbo].[SenderReceiver] ([ID])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CourierPickupManifest y Numero de manifiesto de recoleccion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'IdManifest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de manifiesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'ManifestSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de referencia a tabla SenderReceiver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'SenderReceiverId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'URL de descarga de manifiesto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'ManifestURL';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Stado de fila 1 activa 0 inactiva', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifest', @level2type = N'COLUMN', @level2name = N'DateUpdated';

