CREATE TABLE [dbo].[AnticipatedCODComission] (
    [IdAnticipatedCodComission] INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RateHeaderId]              INT             NOT NULL,
    [InitialRange]              INT             NOT NULL,
    [FinalRange]                INT             NOT NULL,
    [AnticipatedCODComission]   DECIMAL (18, 2) NOT NULL,
    [RowStatus]                 BIT             NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [DateUpdated]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAnticipatedCodComission] ASC),
    CONSTRAINT [FKRateHeaderId_AnticipatedCODComission] FOREIGN KEY ([RateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de comision aplicable al rango establecido', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'AnticipatedCODComission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango final para validacion de monto de comision', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'FinalRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Rango incial para validacion de monto de comision', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'InitialRange';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la comsion con la tarifa de un cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'RateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal e identificador de la tabla Comisiones COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission', @level2type = N'COLUMN', @level2name = N'IdAnticipatedCodComission';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que Maneja informacion de comisiones por tarifa para COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODComission';

