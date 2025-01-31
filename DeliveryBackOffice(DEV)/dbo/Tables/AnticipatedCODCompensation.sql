-- =============================================
-- Author:      <Oscar, Rodriguez>
-- Create date: <2025-01-30>
-- Description: < Se creo tabla para manejo de historial de pago de saldos en contra para guias COD Anticipado >
-- =============================================
CREATE TABLE dbo.AnticipatedCODCompensation(
IdAnticipatedCODCompensation		INT IDENTITY (1, 1) NOT NULL,
AnticipatedCODDetailId		        INT					NOT NULL,
GuideSerie					        NVARCHAR (2)        NOT NULL,
GuideNumber					        INT				    NOT NULL,
AgaintsBalancePaid			        DECIMAL(18,2)		NOT NULL,
RowStatus					        BIT					NOT NULL,
TokenCreated				        NVARCHAR(50)		NOT NULL,
DateCreated					        DATETIME			NOT NULL,
TokenUpdated				        NVARCHAR(50)		NULL,
DateUpdated					        DATETIME			NULL,
PRIMARY KEY CLUSTERED (IdAnticipatedCODCompensation ASC),
CONSTRAINT [FKGuideSerie_AnticipatedCODCompensation] FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
CONSTRAINT [FKAnticipatedCODDetailId_AnticipatedCODCompensation] FOREIGN KEY (AnticipatedCODDetailId) REFERENCES dbo.AnticipatedCODDetail (IdAnticipatedCODDetail)
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal e identificador de la tabla historico de pago de saldo en contra para guias COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'IdAnticipatedCODCompensation';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona el detalle de la guia con saldo en contra a cobrar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'AnticipatedCODDetailId';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la serie de la guia que se utilizo para pagar de saldo en contra de guia relacionada en AnticipatedCODDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'GuideSerie';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona el numero de la guia que se utilizo para pagar de saldo en contra de guia relacionada en AnticipatedCODDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'GuideNumber';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Variable que maneja el monto utilizado para pago total o parcial de guia con saldo en contra COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'AgaintsBalancePaid';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que Maneja informacion de pagos totales o parciales de saldo en contra para guias COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODCompensation', @level2type = NULL, @level2name = NULL;