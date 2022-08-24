CREATE TABLE [dbo].[LocationRecord] (
    [IdLocationRecord]  INT            IDENTITY (1, 1) NOT NULL,
    [SocialSecurityId]  NVARCHAR (200) NULL,
    [Phone]             NVARCHAR (10)  NULL,
    [Address]           NVARCHAR (600) NULL,
    [Accuracy]          NVARCHAR (20)  NULL,
    [Latitud]           NVARCHAR (20)  NULL,
    [Longitude]         NVARCHAR (20)  NULL,
    [RowStatus]         BIT            CONSTRAINT [df_LocationRecord_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    [AddressToReview]   NVARCHAR (600) NULL,
    [AccuracyToReview]  NVARCHAR (20)  NULL,
    [LatitudeToReview]  NVARCHAR (20)  NULL,
    [LongitudeToReview] NVARCHAR (20)  NULL,
    CONSTRAINT [PK_LocationRecord_IdLocationRecord] PRIMARY KEY CLUSTERED ([IdLocationRecord] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_NC_SocialSecurityId_LocationRecord]
    ON [dbo].[LocationRecord]([SocialSecurityId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_NC_Phone_LocationRecord]
    ON [dbo].[LocationRecord]([Phone] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el historico de ubicaciones basada en número de seguridad social o número de teléfono.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla LocationRecord.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'IdLocationRecord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de seguridad social que se registró en la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'SocialSecurityId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de telefono que se registró en la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'Phone';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'Address';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Exactitud de la ubicación, menor valor más exacto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'Accuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'Latitud';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitude de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'Longitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección ingresada de la nueva ubicación para ser revisada manualmente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'AddressToReview';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precisión ingresada de la nueva ubicación para ser revisada manualmente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'AccuracyToReview';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud ingresada de la nueva ubicación para ser revisada manualmente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'LatitudeToReview';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud ingresada de la nueva ubicación para ser revisada manualmente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'LocationRecord', @level2type = N'COLUMN', @level2name = N'LongitudeToReview';

