CREATE TABLE [dbo].[ServicePickupLog] (
    [IdServicePickupLog]     BIGINT        IDENTITY (1, 1) NOT NULL,
    [GuideSerie]             NVARCHAR (2)  NOT NULL,
    [GuideNumber]            INT           NOT NULL,
    [OldIdHeaderRecolection] INT           NOT NULL,
    [NewIdHeaderRecolection] INT           NOT NULL,
    [RowStatus]              BIT           CONSTRAINT [df_ServicePickupLog_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    CONSTRAINT [PK_ServicePickupLog_IdServicePickupLog] PRIMARY KEY CLUSTERED ([IdServicePickupLog] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el log de la reasignación de servicios de recolección.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla ServicePickupLog.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'IdServicePickupLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'IdHeaderRecolection que tenía asignado en la tabla DeliveryOrderPaymentDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'OldIdHeaderRecolection';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nuevo IdHeaderRecolection a asignar en la tabla DeliveryOrderPaymentDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'NewIdHeaderRecolection';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServicePickupLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';

