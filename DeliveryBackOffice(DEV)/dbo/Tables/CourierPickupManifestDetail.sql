CREATE TABLE [dbo].[CourierPickupManifestDetail] (
    [IdManifestDetail] BIGINT       IDENTITY (1, 1) NOT NULL,
    [ManifestId]       BIGINT       NOT NULL,
    [GuideSerie]       NVARCHAR (2) NOT NULL,
    [GuideNumber]      INT          NOT NULL,
    [PieceNumber]      INT          NOT NULL,
    [TokenCreated]     VARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME     NOT NULL,
    [TokenUpdated]     VARCHAR (50) NULL,
    [DateUpdated]      DATETIME     NULL,
    [RowStatus]        BIT          NOT NULL,
    CONSTRAINT [PKCourierPickupManifestDetail] PRIMARY KEY CLUSTERED ([IdManifestDetail] ASC),
    CONSTRAINT [FKCourierPickupManifestDetailManifestId] FOREIGN KEY ([ManifestId]) REFERENCES [dbo].[CourierPickupManifest] ([IdManifest]),
    CONSTRAINT [FKPickUpManifestDetailGuideSerie_GuideNumber] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CorporateManifestDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'IdManifestDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de referencia a tabla CorporateManifest', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'ManifestId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de pieza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de fila si esta activa o no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CourierPickupManifestDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';

