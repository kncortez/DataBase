CREATE TABLE [dbo].[MembershipSubscriptionLog] (
    [IdMembershipSubscriptionLog] BIGINT          IDENTITY (1, 1) NOT NULL,
    [SystemId]                    INT             NOT NULL,
    [ModuleId]                    INT             NOT NULL,
    [MembershipId]                INT             NULL,
    [SubscriptionId]              INT             NULL,
    [SalesPackageStatusId]        INT             NULL,
    [StationId]                   INT             NULL,
    [CustomerId]                  INT             NULL,
    [AccountId]                   BIGINT          NULL,
    [VisitPointClientId]          INT             NULL,
    [LogActionDescription]        NVARCHAR (300)  NOT NULL,
    [LogGuideSerie]               NVARCHAR (2)    NULL,
    [LogGuideNumber]              INT             NULL,
    [LogGuideOriginalValue]       DECIMAL (14, 2) NULL,
    [LogGuideNewValue]            DECIMAL (14, 2) NULL,
    [RowStatus]                   BIT             CONSTRAINT [DF_MembershipSubscriptionLog_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                NVARCHAR (50)   NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    [TokenUpdated]                NVARCHAR (50)   NULL,
    [DateUpdated]                 DATETIME        NULL,
    [LogAuthorizationValue]       NVARCHAR (50)   NULL,
    [LogTransactionId]            NVARCHAR (50)   NULL,
    [LogTransactionOrder]         NVARCHAR (50)   NULL,
    [LogServiceNumber]            INT             NULL,
    CONSTRAINT [PK_MembershipSubscriptionLog] PRIMARY KEY CLUSTERED ([IdMembershipSubscriptionLog] ASC),
    CONSTRAINT [FK_MembershipSubscriptionLog_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_MembershipSubscriptionLog_DeliveryOrder] FOREIGN KEY ([LogGuideSerie], [LogGuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Membership] FOREIGN KEY ([MembershipId]) REFERENCES [dbo].[Membership] ([IdMembership]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Module] FOREIGN KEY ([ModuleId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Station] FOREIGN KEY ([StationId]) REFERENCES [dbo].[CatStation] ([IdStation]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Status] FOREIGN KEY ([SalesPackageStatusId]) REFERENCES [dbo].[CatSalesPackageStatus] ([IdCatSalesPackageStatus]),
    CONSTRAINT [FK_MembershipSubscriptionLog_Subscription] FOREIGN KEY ([SubscriptionId]) REFERENCES [dbo].[Subscription] ([IdSubscription]),
    CONSTRAINT [FK_MembershipSubscriptionLog_System] FOREIGN KEY ([SystemId]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FK_MembershipSubscriptionLog_VisitPointClient] FOREIGN KEY ([VisitPointClientId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


GO
ALTER TABLE [dbo].[MembershipSubscriptionLog] NOCHECK CONSTRAINT [FK_MembershipSubscriptionLog_Membership];




GO
ALTER TABLE [dbo].[MembershipSubscriptionLog] NOCHECK CONSTRAINT [FK_MembershipSubscriptionLog_Membership];




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identiificador de la tabla de puntos de visita de cliente ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'VisitPointClientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario de actualización ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de tipo de sistema que se usa para el registro ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'SystemId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identidicador de las suscripciones adquiridas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'SubscriptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de estaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'StationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla que indica el estado del paquete vendido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'SalesPackageStatusId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica si el registro esta activo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla que indica el módulo donde se realizo el registron', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'ModuleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de  tabla de membresía adquirida ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'MembershipId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rergistro de código de transacción de compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogTransactionOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tabla de registro de transacción de compra', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogTransactionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de numero de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogServiceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'registro de la serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogGuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro del valor original de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogGuideOriginalValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'registro del número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogGuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'registro del nuevo valor de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogGuideNewValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Registro de campo OrderNumber de la trancción de compra ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogAuthorizationValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'registro de lla descripción de la acción ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'LogActionDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tabla de registros de compras de membresías y subscripciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'IdMembershipSubscriptionLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualziación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de la tabla de datos de los clientes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de la tabla de cuentas de clientes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'MembershipSubscriptionLog', @level2type = N'COLUMN', @level2name = N'AccountId';

