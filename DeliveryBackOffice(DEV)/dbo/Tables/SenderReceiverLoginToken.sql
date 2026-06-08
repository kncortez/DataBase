CREATE TABLE [dbo].[SenderReceiverLoginToken] (
    [IdSenderRecieverLoginToken] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [LoginToken]                 NVARCHAR (6)  NOT NULL,
    [SenderReceiverId]           INT           NOT NULL,
    [RowStatus]                  BIT           CONSTRAINT [DF_SenderReceiverLoginToken_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    CONSTRAINT [PK_SenderReceiverLoginToken] PRIMARY KEY CLUSTERED ([IdSenderRecieverLoginToken] ASC)
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del courier de la tabla SenderReceiver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'SenderReceiverId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token para autenticación de doble factor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'LoginToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken', @level2type = N'COLUMN', @level2name = N'IdSenderRecieverLoginToken';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para el almacenamiento de token de CourierApp.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SenderReceiverLoginToken';


GO
CREATE NONCLUSTERED INDEX [IDX_SenderReceiverId_iNCLUDE]
    ON [dbo].[SenderReceiverLoginToken]([SenderReceiverId] ASC)
    INCLUDE([LoginToken]);


GO
CREATE NONCLUSTERED INDEX [IX_SenderReceiverLoginToken_SenderReceiverId_RowStatus]
    ON [dbo].[SenderReceiverLoginToken]([SenderReceiverId] ASC, [RowStatus] ASC)
    INCLUDE([LoginToken]);

