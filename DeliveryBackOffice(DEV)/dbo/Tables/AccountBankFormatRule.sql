CREATE TABLE [dbo].[AccountBankFormatRule] (
    [IdAccountBankFormatRule] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [DeliveryBankId]          INT           NOT NULL,
    [CatBankAccountTypeId]    INT           NOT NULL,
    [MinimumLength]           INT           NULL,
    [MaximumLength]           INT           NULL,
    [StartsWith]              VARCHAR (150) NULL,
    [Complete]                BIT           NULL,
    [RowStatus]               BIT           CONSTRAINT [df_AccountBankFormatRule_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]            NVARCHAR (50) NOT NULL,
    [DateCreated]             DATETIME      NOT NULL,
    [TokenUpdated]            NVARCHAR (50) NULL,
    [DateUpdated]             DATETIME      NULL,
    CONSTRAINT [PK_AccountBankFormatRule_DeliveryBankId_CatBankAccountTypeId] PRIMARY KEY CLUSTERED ([IdAccountBankFormatRule] ASC),
    CONSTRAINT [FK_AccountBankFormatRule_CatBankAccountTypeId] FOREIGN KEY ([CatBankAccountTypeId]) REFERENCES [dbo].[CatBankAccountType] ([IdBankAccountType]),
    CONSTRAINT [FK_AccountBankFormatRule_DeliveryBankId] FOREIGN KEY ([DeliveryBankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las reglas del formato para una cuenta de banco.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla AccountBankFormatRule.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'IdAccountBankFormatRule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla DeliveryBank.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'DeliveryBankId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatBankAccountType..', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'CatBankAccountTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud minima del número de cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'MinimumLength';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud máxima del número de cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'MaximumLength';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lista de números separados por coma con los que puede iniciar un número de cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'StartsWith';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Completar con ceros a la izquierda un número de cuenta, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'Complete';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountBankFormatRule', @level2type = N'COLUMN', @level2name = N'DateUpdated';

