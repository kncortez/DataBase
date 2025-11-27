CREATE TABLE [dbo].[CreditCardTransaction] (
    [IdTransaction]         BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [System]                TINYINT         NOT NULL,
    [CardNumber]            NVARCHAR (20)   NOT NULL,
    [TypeCardNumber]        NVARCHAR (50)   NOT NULL,
    [Ammount]               DECIMAL (18, 2) NULL,
    [Currency]              INT             NOT NULL,
    [OrderNumber]           NVARCHAR (38)   NULL,
    [Signature]             NVARCHAR (100)  NULL,
    [CustomerReference]     NVARCHAR (50)   NULL,
    [ReferenceNumber]       NVARCHAR (50)   NULL,
    [ECIIndicator]          NVARCHAR (2)    NULL,
    [Authenticationresult]  NVARCHAR (1)    NULL,
    [TransactionStain]      NVARCHAR (50)   NULL,
    [CAVV]                  NVARCHAR (50)   NULL,
    [DatetimeCreated]       DATETIME        NOT NULL,
    [DatetimeUpdated]       DATETIME        NULL,
    [ReasonCode]            NVARCHAR (100)  NULL,
    [ReasonCodeDescription] NVARCHAR (100)  NULL,
    CONSTRAINT [PK_CreditCardTransaction] PRIMARY KEY CLUSTERED ([IdTransaction] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identity, identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'IdTransaction';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1. App android
2. App IOS
3. Sitio Web', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'System';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'CardNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de tarjeta, visa, master card, american express', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'TypeCardNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de transacción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'Ammount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código ISO del país de divisa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'Currency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'firma generada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'Signature';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente al que pertenece la tarjeta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'CustomerReference';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador FAC al finalizar una transacción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'ReferenceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Requerido para autorización una transacción 3DS', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'ECIIndicator';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Respuesta de una validación de código 3DS para

tarjetas Visa y Master Card', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'Authenticationresult';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Una versión “hash” del número de identificación de la transacción
(XID). Permite el reenvío de la misma.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'TransactionStain';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Este es un valor criptográfico que se deriva del emisor durante la
autenticación del pago', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'CAVV';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'DatetimeCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'DatetimeUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código Respuesta FAC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'ReasonCode';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción Respuesta FAC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CreditCardTransaction', @level2type = N'COLUMN', @level2name = N'ReasonCodeDescription';

