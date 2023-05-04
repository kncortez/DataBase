CREATE TABLE [dbo].[SenderReceiverLocationLog] (
    [IdSenderReceiverLocationLog] BIGINT     IDENTITY (1, 1) NOT NULL,
    [SenderReceiverId]            INT        NOT NULL,
    [CourierLatitude]             NCHAR (20) NOT NULL,
    [CourierLongitude]            NCHAR (20) NOT NULL,
    [LocationAccuracy]            NCHAR (20) NOT NULL,
    [LocationDate]                DATE       NOT NULL,
    [LocationTime]                TIME (7)   NOT NULL,
    [RowStatus]                   BIT        CONSTRAINT [DF_SenderReceiverLocationLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                 DATETIME   NOT NULL,
    [TokenCreated]                NCHAR (50) NOT NULL,
    [DateUpdated]                 DATETIME   NULL,
    [TokenUpdated]                NCHAR (50) NULL,
    CONSTRAINT [PK_SenderReceiverLocationLog] PRIMARY KEY CLUSTERED ([IdSenderReceiverLocationLog] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario que actualiza el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'hora de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'LocationTime';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'LocationDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precisión de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'LocationAccuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ubicación de longitud', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'CourierLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ubicación de  latitud', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'CourierLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'SenderReceiverId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del bitacora de registro de ubicación de courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLocationLog', @level2type = N'COLUMN', @level2name = N'IdSenderReceiverLocationLog';



