CREATE TABLE [dbo].[SchedulePickupToProcess] (
    [IdSchedulePickupToProcess] INT            IDENTITY (1, 1) NOT NULL,
    [StartDate]                 DATETIME       NOT NULL,
    [EndDate]                   DATETIME       NOT NULL,
    [SenderID]                  INT            NOT NULL,
    [SenderName]                NVARCHAR (200) NOT NULL,
    [SenderAddress]             NVARCHAR (600) NOT NULL,
    [SpecialInstructions]       NVARCHAR (600) NULL,
    [EstimatedPackages]         INT            CONSTRAINT [DF_SchedulePickupToProcess_EstimatedPackages] DEFAULT ((1)) NOT NULL,
    [TypeVehicleId]             INT            NULL,
    [HubLogisticsId]            INT            NULL,
    [TokenAuthorized]           NVARCHAR (50)  NULL,
    [DateAuthorized]            DATETIME       NULL,
    [RowStatus]                 INT            CONSTRAINT [DF_SchedulePickupToProcess_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateUpdated]               DATETIME       NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    CONSTRAINT [PK_SchedulePickupToProcess] PRIMARY KEY CLUSTERED ([IdSchedulePickupToProcess] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'DateAuthorized';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'TokenAuthorized';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de hub', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'HubLogisticsId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de tipo de vehículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'TypeVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'paquete estimado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'EstimatedPackages';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descripción especial', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'SpecialInstructions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'dirección de cliente que envía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'SenderAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de persona que envía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'SenderName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identiifcador del ciente que envía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'SenderID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de finalización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de Inicio de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickupToProcess', @level2type = N'COLUMN', @level2name = N'StartDate';

