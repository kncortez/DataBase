CREATE TABLE [dbo].[DeliveryOrderReversalStatus] (
    [IdReversalStatus] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Guide_Serie]      NVARCHAR (2)   NOT NULL,
    [Guide_Number]     INT            NOT NULL,
    [Comment]          NVARCHAR (150) NULL,
    [RowStatus]        BIT            NOT NULL,
    [TokenCreated]     NVARCHAR (100) NOT NULL,
    [DateCreated]      DATETIME       NULL,
    [TokenUpdated]     NVARCHAR (100) NULL,
    [DateUpdated]      DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdReversalStatus] ASC),
    FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para identificar de manera única cada registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'IdReversalStatus';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar la serie de la guía que se está reversando.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'Guide_Serie';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el número de la guía que se esta reversando.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'Guide_Number';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el motivo de la reversión de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'Comment';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el estado de la guía a reversar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'RowStatus';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el token del usuario que creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'TokenCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar la fecha en la que el usuario creó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'DateCreated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar el token del usuario que actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'TokenUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para almacenar la fecha en la que el usuario actualizó el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus', @level2type = N'COLUMN', @level2name = N'DateUpdated';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el log de las guías reversadas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderReversalStatus';

