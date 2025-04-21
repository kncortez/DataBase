CREATE TABLE [dbo].[DayForDeliveryCoverage] (
    [IdDayForDeliveryCoverage] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [HubLogisticsOrigin]       INT           NOT NULL,
    [HubLogisticsDestiny]      INT           NOT NULL,
    [DaysToAdd]                INT           NOT NULL,
    [RowStatus]                BIT           DEFAULT ((0)) NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateUpdated]              DATETIME      NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdDayForDeliveryCoverage] ASC),
    CONSTRAINT [CHK_DayForDeliveryCoverage_Days] CHECK ([DaysToAdd]>=(0)),
    CONSTRAINT [FK_DayForDeliveryCoverage_DestinyHub] FOREIGN KEY ([HubLogisticsDestiny]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FK_DayForDeliveryCoverage_OriginHub] FOREIGN KEY ([HubLogisticsOrigin]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dias por adicionar en el cálculo de tiempo estimado de entrega de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'DaysToAdd';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hub de destino de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'HubLogisticsDestiny';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del hub de origen de la tabla HubLogistics.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'HubLogisticsOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage', @level2type = N'COLUMN', @level2name = N'IdDayForDeliveryCoverage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de cobertura de HUB a HUB para adición de días en cálculo de ETA de entrega de guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DayForDeliveryCoverage';

GO
CREATE NONCLUSTERED INDEX IDX_DayForDeliveryCoverage_HubsAvailable
ON [dbo].[DayForDeliveryCoverage] ( [HubLogisticsOrigin], [HubLogisticsDestiny], [RowStatus] )

