CREATE TABLE [dbo].[Contingency] (
    [IdContingency]               INT             IDENTITY (1, 1) NOT NULL,
    [DeliveryOrderBySettlementId] BIGINT          NOT NULL,
    [Type]                        VARCHAR (10)    NOT NULL,
    [Value]                       DECIMAL (10, 2) NOT NULL,
    [Description]                 NVARCHAR (500)  NULL,
    [TokenCreated]                NVARCHAR (50)   NOT NULL,
    [DateCreated]                 DATETIME        NOT NULL,
    CONSTRAINT [PK_Contingency_IdContingency] PRIMARY KEY CLUSTERED ([IdContingency] ASC),
    CONSTRAINT [FK_Contingency_DeliveryOrderBySettlementId] FOREIGN KEY ([DeliveryOrderBySettlementId]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID]),
    UNIQUE NONCLUSTERED ([DeliveryOrderBySettlementId] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar las contingencias relacionadas a un manifiesto liquidación última milla COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla Contingency, que indica el id de la contingencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'IdContingency';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla DeliveryOrderBySettlement, que indica el id del manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'DeliveryOrderBySettlementId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de la contingencia, FALTANTE o SOBRANTE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor faltante o sobrante.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'Value';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la contingencia.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Contingency', @level2type = N'COLUMN', @level2name = N'DateCreated';

