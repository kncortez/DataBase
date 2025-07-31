CREATE TABLE [dbo].[AnticipatedCODDetail] (
    [IdAnticipatedCODDetail]    INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [AnticipatedCODHeaderId]    INT             NOT NULL,
    [GuideSerie]                NVARCHAR (2)    NULL,
    [GuideNumber]               INT             NOT NULL,
    [IsOldest]                  INT             NOT NULL,
    [ReturnPercent]             DECIMAL (18, 2) NOT NULL,
    [MinGuidesPerMonth]         INT             NOT NULL,
    [DailyAmount]               DECIMAL (18, 2) NOT NULL,
    [IsCODAnticipatedValid]     INT             NOT NULL,
    [CollectOnDelivery]         DECIMAL (18, 2) NOT NULL,
    [IsAgaintsBalancePaid]      INT             NULL,
    [AgaintsBalanceAmount]      DECIMAL (18, 2) NULL,
    [AgaintsBalancePaid]        DECIMAL (18, 2) NULL,
    [AnticipatedCODComissionId] INT             NULL,
    [BalanceStatus]             NVARCHAR (50)   NOT NULL,
    [RowStatus]                 BIT             NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [DateUpdated]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAnticipatedCODDetail] ASC),
    CONSTRAINT [FKAnticipatedCODComissionId_AnticipatedCODDetail] FOREIGN KEY ([AnticipatedCODComissionId]) REFERENCES [dbo].[AnticipatedCODComission] ([IdAnticipatedCodComission]),
    CONSTRAINT [FKAnticipatedCODHeaderId_AnticipatedCODDetail] FOREIGN KEY ([AnticipatedCODHeaderId]) REFERENCES [dbo].[AnticipatedCODHeader] ([IdAnticipatedCODHeader]),
    CONSTRAINT [FKGuideSerie_AnticipatedCODDetail] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);






GO
CREATE NONCLUSTERED INDEX [IDX_GuideSerie_GuideNumber]
    ON [dbo].[AnticipatedCODDetail]([GuideSerie] ASC, [GuideNumber] ASC)
    INCLUDE([AnticipatedCODHeaderId]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del saldo sobre la guia COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'BalanceStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la comision aplicable de COD Anticipado al monto de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AnticipatedCODComissionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de saldo en contra de guia pendiente por recuperar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AgaintsBalancePaid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor depositado a cliente por lote de pago a proveedores', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AgaintsBalanceAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que indica si una guia cuenta con saldo en contra pendiente por pagar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IsAgaintsBalancePaid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto COD Declarado sobre la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'CollectOnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para conocer si el cliente aplica o no a COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IsCODAnticipatedValid';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Promedio diario de monto COD Disponible calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DailyAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad minima de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'MinGuidesPerMonth';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de Devolucion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'ReturnPercent';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Variable que maneja la antiguedad en dias en creacion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IsOldest';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona el numero de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la seria de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la cabecera de validaciones COD Anticipado del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AnticipatedCODHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal e identificador de la tabla historico COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IdAnticipatedCODDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que Maneja informacion de clientes spbre historico de COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail';


GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_INCLUDE]
    ON [dbo].[AnticipatedCODDetail]([RowStatus] ASC)
    INCLUDE([AnticipatedCODHeaderId], [CollectOnDelivery], [BalanceStatus]);


GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_DateCreated_include]
    ON [dbo].[AnticipatedCODDetail]([RowStatus] ASC, [DateCreated] ASC)
    INCLUDE([AnticipatedCODHeaderId], [CollectOnDelivery]);


GO
CREATE NONCLUSTERED INDEX [idx_AnticipatedCODHeaderId_RowStatus_INCLUDE]
    ON [dbo].[AnticipatedCODDetail]([AnticipatedCODHeaderId] ASC, [RowStatus] ASC)
    INCLUDE([CollectOnDelivery], [BalanceStatus]);

