CREATE TABLE [dbo].[CodProfile] (
    [CustomerId]             INT             NOT NULL,
    [NotificationEmail]      NVARCHAR (200)  NOT NULL,
    [TradeName]              NVARCHAR (100)  NOT NULL,
    [LocalCommission]        DECIMAL (14, 2) NOT NULL,
    [MetropolitanCommission] DECIMAL (14, 2) NOT NULL,
    [ForeignCommission]      DECIMAL (14, 2) NOT NULL,
    [SpecialCommision]       DECIMAL (14, 2) NOT NULL,
    [TokenCreated]           NVARCHAR (50)   NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           NVARCHAR (50)   NULL,
    [DateUpdated]            DATETIME        NULL,
    CONSTRAINT [PK_CodProfile] PRIMARY KEY CLUSTERED ([CustomerId] ASC),
    CONSTRAINT [FK_CodProfile_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Perfil de COD para clientes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente	', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Email notificación acreditamiento	', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'NotificationEmail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del comercio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'TradeName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Comisión local', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'LocalCommission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de comisión área metropolitana', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'MetropolitanCommission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de comisión foráneo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'ForeignCommission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de comisión especial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'SpecialCommision';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CodProfile', @level2type = N'COLUMN', @level2name = N'DateUpdated';

