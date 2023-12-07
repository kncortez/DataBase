CREATE TABLE [dbo].[CatTypeIncidence] (
    [IdIncidenceType]          INT            IDENTITY (1, 1) NOT NULL,
    [NameIncidence]            VARCHAR (200)  NULL,
    [DescriptionIncidence]     VARCHAR (200)  NULL,
    [RowStatus]                BIT            NOT NULL,
    [TokenCreated]             VARCHAR (50)   NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             VARCHAR (50)   NULL,
    [DateUpdated]              DATETIME       NULL,
    [ServiceType]              NVARCHAR (25)  NULL,
    [OrderId]                  INT            NULL,
    [Code]                     INT            NULL,
    [IncidenceClasificationId] INT            NULL,
    [IsForcedIncidence]        BIT            DEFAULT ((0)) NOT NULL,
    [ValidatesLocation]        BIT            DEFAULT ((0)) NOT NULL,
    [HasConfirmationProcess]   BIT            DEFAULT ((0)) NOT NULL,
    [NotifiesOrigin]           BIT            DEFAULT ((0)) NOT NULL,
    [NameIncidencePublic]      VARCHAR (50)   NULL,
    [EvidenceRequirement]      BIT            NULL,
    [CourierInstructions]      NVARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceType] ASC)
);







GO


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la incidencia esta forzada a ser incidencia en ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IsForcedIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia valida ubicación para procesamiento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'ValidatesLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia genera una notificación para el remitente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'NotifiesOrigin';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si incidencia genera proceso de confirmación de incidencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'HasConfirmationProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si requiere evidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'EvidenceRequirement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones para courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'CourierInstructions';

