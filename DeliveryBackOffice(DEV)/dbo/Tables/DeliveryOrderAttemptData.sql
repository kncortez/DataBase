CREATE TABLE [dbo].[DeliveryOrderAttemptData] (
    [IdDeliveryOrderAttemptData]   BIGINT        IDENTITY (1, 1) NOT NULL,
    [GuideSerie]                   NVARCHAR (2)  NOT NULL,
    [GuideNumber]                  INT           NOT NULL,
    [GuideDeliveryAttemptCount]    INT           DEFAULT ((0)) NOT NULL,
    [GuideDeliveryMaxAttemptCount] INT           NOT NULL,
    [GuideReturnAttemptCount]      INT           DEFAULT ((0)) NOT NULL,
    [GuideReturnMaxAttemptCount]   INT           NOT NULL,
    [RowStatus]                    BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateUptaded]                  DATETIME      NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdDeliveryOrderAttemptData] ASC),
    CONSTRAINT [FK_DeliveryOrderAttemptData_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'DateUptaded';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad maxima de intentos de devolución.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideReturnMaxAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de intentos de devoluciones actuales.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideReturnAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad maxima de intentos de entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideDeliveryMaxAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de intentos de entrega actuales.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideDeliveryAttemptCount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData', @level2type = N'COLUMN', @level2name = N'IdDeliveryOrderAttemptData';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para indicar los intentos que posee una guía en procesos operativos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAttemptData';


GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrderAttemptData_Guide]
    ON [dbo].[DeliveryOrderAttemptData]([GuideSerie] ASC, [GuideNumber] ASC);

