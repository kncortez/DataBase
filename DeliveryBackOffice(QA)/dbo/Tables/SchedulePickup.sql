CREATE TABLE [dbo].[SchedulePickup] (
    [SchedulePickupId]               BIGINT          IDENTITY (1, 1) NOT NULL,
    [AccountId]                      BIGINT          NULL,
    [StartDate]                      DATETIME        NULL,
    [EndDate]                        DATETIME        NULL,
    [EstimatedWeight]                DECIMAL (18)    NULL,
    [IsLargePackage]                 BIT             NULL,
    [QuantityRegularPackages]        INT             NULL,
    [QuantityOverDimensionedPackage] INT             NULL,
    [SpecialInstructions]            NVARCHAR (200)  NULL,
    [RowStatus]                      BIT             NOT NULL,
    [TokenCreated]                   NVARCHAR (50)   NOT NULL,
    [DateCreated]                    DATETIME        NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    [SenderId]                       INT             NULL,
    [SenderName]                     VARCHAR (200)   NULL,
    [SenderPhone]                    VARCHAR (50)    NULL,
    [IdHubLogistics]                 INT             NULL,
    [AmountPickup]                   DECIMAL (12, 2) NULL,
    [IdSourcePlataform]              INT             NULL,
    [AddressPickup]                  VARCHAR (500)   NULL,
    [AssigmentStatus]                BIT             NULL,
    [TransaccionFAC]                 VARCHAR (200)   NULL,
    [TownshipId]                     INT             NULL,
    [SchedulePickupStatus]           BIT             CONSTRAINT [df_SchedulePickup_SchedulePickup] DEFAULT ((1)) NULL,
    [TypeVehicleId]                  INT             NULL,
    [IsScheduled]                    BIT             NULL,
    CONSTRAINT [PK_SchedulePickup] PRIMARY KEY CLUSTERED ([SchedulePickupId] ASC),
    FOREIGN KEY ([IdHubLogistics]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    FOREIGN KEY ([IdSourcePlataform]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    FOREIGN KEY ([SenderId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference]),
    CONSTRAINT [FK_SchedulePickup_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_SchedulePickup_CatTypeVehicle] FOREIGN KEY ([TypeVehicleId]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle])
);


GO
CREATE NONCLUSTERED INDEX [idx_TransaccionFAC]
    ON [dbo].[SchedulePickup]([TransaccionFAC] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de recolección programada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'SchedulePickupId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cuenta asociada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primer hora de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'StartDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última hora de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'EndDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso estimado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'EstimatedWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Contiene su recolección paquetes grandes?', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'IsLargePackage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas regulares', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'QuantityRegularPackages';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de piezas sobredimensionadas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'QuantityOverDimensionedPackage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones especiales', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'SpecialInstructions';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado SchedulePickup 1=Habilitado 0=Cancelado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'SchedulePickupStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatTypeVehicle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'TypeVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica si el servicio de recolección es considerado "A demanda" (0) o "Programada" (1)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SchedulePickup', @level2type = N'COLUMN', @level2name = N'IsScheduled';

