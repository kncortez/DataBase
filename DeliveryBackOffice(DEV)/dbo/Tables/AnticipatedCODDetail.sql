-- =============================================
-- Author:      <Oscar, Rodriguez>
-- Create date: <2024-11-27>
-- Description: < Se creo tabla para manejo de historial de validaciones por guia de COD Anticipado >
-- =============================================
CREATE TABLE dbo.AnticipatedCODDetail(
IdAnticipatedCODDetail		INT IDENTITY (1, 1) NOT NULL,
AnticipatedCODHeaderId		INT					NOT NULL,
GuideSerie					NVARCHAR (2)				NULL,
GuideNumber					INT				NOT NULL,
IsOldest					INT					NOT NULL,
ReturnPercent				INT					NOT NULL,
MinGuidesPerMonth			INT					NOT NULL,
DailyAmount					DECIMAL(18,2)		NOT NULL,
IsCODAnticipatedValid		INT					NOT NULL,
CollectOnDelivery			DECIMAL(18,2)		NOT NULL,
AnticipatedCODComissionId	INT					NULL,
BalanceStatus				NVARCHAR(50)		NOT NULL,
RowStatus					INT					NOT NULL,
TokenCreated				NVARCHAR(100)		NOT NULL,
DateCreated					DATETIME			NOT NULL,
TokenUpdated				NVARCHAR(100)		NULL,
DateUpdated					DATETIME			NULL,
PRIMARY KEY CLUSTERED (IdAnticipatedCODDetail ASC),
CONSTRAINT [FKGuideSerie_AnticipatedCODDetail] FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
CONSTRAINT [FKAnticipatedCODHeaderId_AnticipatedCODDetail] FOREIGN KEY (AnticipatedCODHeaderId) REFERENCES dbo.AnticipatedCODHeader (IdAnticipatedCODHeader),
CONSTRAINT [FKAnticipatedCODComissionId_AnticipatedCODDetail] FOREIGN KEY (AnticipatedCODComissionId) REFERENCES dbo.AnticipatedCODComission (IdAnticipatedCodComission)
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal e identificador de la tabla historico COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IdAnticipatedCODDetail';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la cabecera de validaciones COD Anticipado del cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AnticipatedCODHeaderId';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la seria de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona el numero de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Variable que maneja la antiguedad en dias en creacion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IsOldest';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje de Devolucion de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'ReturnPercent';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad minima de guias calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'MinGuidesPerMonth';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Promedio diario de monto COD Disponible calculado para el cliente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DailyAmount';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para conocer si el cliente aplica o no a COD anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'IsCODAnticipatedValid';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Monto COD Declarado sobre la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'CollectOnDelivery';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Llave foranea que relaciona la comision aplicable de COD Anticipado al monto de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'AnticipatedCODComissionId';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del saldo sobre la guia COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'BalanceStatus';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que Maneja informacion de clientes spbre historico de COD Anticipado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AnticipatedCODDetail', @level2type = NULL, @level2name = NULL;