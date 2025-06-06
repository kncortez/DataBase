CREATE TABLE [dbo].[AnticipatedCODHeader] (
    [IdAnticipatedCODHeader] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CustomerId]             INT             NOT NULL,
    [PortfolioId]            BIGINT          NULL,
    [DailyDate]              DATE            NOT NULL,
    [IsOldest]               INT             NOT NULL,
    [ReturnPercent]          DECIMAL (18, 2) NOT NULL,
    [MinGuidesPerMonth]      INT             NOT NULL,
    [DailyAmount]            DECIMAL (18, 2) NOT NULL,
    [IsCODAnticipatedValid]  INT             NOT NULL,
    [Balance]                DECIMAL (18, 2) NOT NULL,
    [AgaintsBalance]         DECIMAL (18, 2) NOT NULL,
    [RowStatus]              BIT             NOT NULL,
    [TokenCreated]           NVARCHAR (50)   NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           NVARCHAR (50)   NULL,
    [DateUpdated]            DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAnticipatedCODHeader] ASC),
    CONSTRAINT [FKCustomerId_AnticipatedCODHeader] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FKPortfolioId_AnticipatedCODHeader] FOREIGN KEY ([PortfolioId]) REFERENCES [dbo].[VisitPointByClientPortfolio] ([IdVisitPointByClientPortfolio])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Saldo en contra de la cuenta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'AgaintsBalance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Saldo de cuenta o balance', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'Balance';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para conocer si el cliente aplica o no a COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'IsCODAnticipatedValid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Promedio diario de monto COD Disponible calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'DailyAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad minima de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'MinGuidesPerMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de Devolucion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'ReturnPercent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Variable que maneja la antiguedad en dias en creacion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'IsOldest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización de validaciones para servicio COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'DailyDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona las validaciones con el cliente de cartera', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'PortfolioId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona las validaciones con el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal e identificador de la tabla validaciones COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader', @level2type = N'COLUMN', @level2name = N'IdAnticipatedCODHeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que Maneja informacion de clientes para validaciones de COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODHeader';


GO
CREATE NONCLUSTERED INDEX [idx_PortfolioId_IdAnticipatedCODHeader]
    ON [dbo].[AnticipatedCODHeader]([PortfolioId] ASC, [IdAnticipatedCODHeader] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CustomerId_PortfolioId_IdAnticipatedCODHeader]
    ON [dbo].[AnticipatedCODHeader]([CustomerId] ASC, [PortfolioId] ASC, [IdAnticipatedCODHeader] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CustomerId_PortfolioId]
    ON [dbo].[AnticipatedCODHeader]([CustomerId] ASC, [PortfolioId] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CustomerId]
    ON [dbo].[AnticipatedCODHeader]([CustomerId] ASC);

