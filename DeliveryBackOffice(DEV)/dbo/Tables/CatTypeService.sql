CREATE TABLE [dbo].[CatTypeService] (
    [CtsId]             INT           IDENTITY (1, 1) NOT NULL,
    [CtsName]           VARCHAR (100) NOT NULL,
    [CtsShortName]      VARCHAR (4)   NOT NULL,
    [CtsDescription]    VARCHAR (200) NULL,
    [CtsRowStatus]      BIT           NOT NULL,
    [CtsTokenCreated]   VARCHAR (50)  NOT NULL,
    [CtsDateCreated]    DATETIME      NOT NULL,
    [CtsTokenUpdated]   VARCHAR (50)  NULL,
    [CtsDateUpdated]    DATETIME      NULL,
    [RateGroup]         INT           NULL,
    [LimitHourDelivery] TIME (7)      NULL,
    [LimitHourPickup]   TIME (7)      NULL,
    PRIMARY KEY CLUSTERED ([CtsId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla describiendo tipos de servicios de entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del grupo de tarifa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'RateGroup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora limite para realizar la recolección este tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'LimitHourPickup';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora limite para realizar la entrega este tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'LimitHourDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsTokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsTokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acronimo del tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsShortName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsRowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsDateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeService', @level2type = N'COLUMN', @level2name = N'CtsDateCreated';

