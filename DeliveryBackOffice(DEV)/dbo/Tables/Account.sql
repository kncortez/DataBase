CREATE TABLE [dbo].[Account] (
    [AccIdAccount]     BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AccName]          VARCHAR (100)  NOT NULL,
    [AccIdTypeAccount] INT            NOT NULL,
    [AccRowStatus]     BIT            NOT NULL,
    [AccTokenCreated]  VARCHAR (50)   NOT NULL,
    [AccDateCreated]   DATETIME       NOT NULL,
    [AccTokenUpdated]  VARCHAR (50)   NULL,
    [AccDateUpdated]   DATETIME       NULL,
    [IdCustomer]       INT            NULL,
    [AccConfirm]       CHAR (1)       NULL,
    [ImageProfile]     NVARCHAR (300) NULL,
    [StarRating]       INT            NULL,
    PRIMARY KEY CLUSTERED ([AccIdAccount] ASC),
    CONSTRAINT [FKAccountType] FOREIGN KEY ([AccIdTypeAccount]) REFERENCES [dbo].[CatTypeAccount] ([TacIdTypeAccount]),
    CONSTRAINT [FKIdCustumer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);














GO
CREATE NONCLUSTERED INDEX [IDX_IdCustomer]
    ON [dbo].[Account]([IdCustomer] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo que representa el numero de estrellas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'StarRating';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar imagen del perfil del usuario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'ImageProfile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenamiento de cuentas de usuarios.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente a quien le pertenece la cuenta de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'IdCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccTokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccTokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccRowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre que identifica al usuario de la cuenta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de cuenta de la tabla CatTypeAccount.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccIdTypeAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccIdAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccDateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccDateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador si la cuena esta confirmada (C) o no (P).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Account', @level2type = N'COLUMN', @level2name = N'AccConfirm';


GO
CREATE NONCLUSTERED INDEX [IDX_AccRowStatus_Include]
    ON [dbo].[Account]([AccRowStatus] ASC)
    INCLUDE([IdCustomer]);


GO
CREATE NONCLUSTERED INDEX [IX_Account_Customer_Include]
    ON [dbo].[Account]([IdCustomer] ASC)
    INCLUDE([AccIdAccount]);

