CREATE TABLE [dbo].[VehicleLog] (
    [IdVehicleLog] INT            IDENTITY (1, 1) NOT NULL,
    [Unidad]       NVARCHAR (10)  NOT NULL,
    [Kms]          INT            NOT NULL,
    [Observacion]  NVARCHAR (500) NOT NULL,
    [TokenCreate]  NVARCHAR (50)  NOT NULL,
    [DateCreate]   DATETIME       NOT NULL,
    [TokenUpdate]  NVARCHAR (50)  NULL,
    [DateUpdate]   DATETIME       NULL,
    CONSTRAINT [PK_VehicleLog] PRIMARY KEY CLUSTERED ([IdVehicleLog] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actuazización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'DateCreate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de persona que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'TokenCreate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'Observacion';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Kilometraje ingresado, no puede ser menor al anterior', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'Kms';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la unidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'Unidad';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de log ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLog', @level2type = N'COLUMN', @level2name = N'IdVehicleLog';

