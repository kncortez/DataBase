CREATE TABLE PointsByServiceLog (
	IdPointsByServiceLog BIGINT IDENTITY(1,1) NOT NULL,
	MembershipId INT NOT NULL,
	GuideSerie NVARCHAR(2) NOT NULL,
	GuideNumber INT NOT NULL,
	GuidePrice DECIMAL(18,2) NOT NULL,
	PointsReceived INT NULL DEFAULT 0,
	PointsConsumed INT NULL DEFAULT 0,
	RowStatus BIT NOT NULL DEFAULT 1,
	DateCreated DATETIME NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DATETIME NULL,
	TokenUpdated NVARCHAR(50) NULL,
	PRIMARY KEY (IdPointsByServiceLog),
	CONSTRAINT FK_PointsByService_Membership FOREIGN KEY (MembershipId) REFERENCES [Membership] (IdMembership),
	CONSTRAINT FK_PointsByService_Guide FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [DeliveryOrder] (Guide_Serie, Guide_Number),
	CONSTRAINT CHK_PointsByService_Points CHECK ((ISNULL(PointsReceived, 0) > 0 AND ISNULL(PointsConsumed, 0) = 0) OR (ISNULL(PointsReceived, 0) = 0 AND ISNULL(PointsConsumed, 0) > 0))
);

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'IdPointsByServiceLog'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Membresía asociada a la acreditación o debito de puntos de la tabla Membership', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'MembershipId'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'GuideSerie'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Número de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'GuideNumber'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Precio de la guía (referencia para bitácora de puntos)', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'GuidePrice'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Puntos acreditados por el servicio', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'PointsReceived'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Puntos debitados por el servicio', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'PointsConsumed'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'RowStatus'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'DateCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'TokenCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'DateUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog', N'COLUMN', N'TokenUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Bitácora de acreditación o canjeo de puntos forza', N'SCHEMA', N'dbo', N'TABLE', N'PointsByServiceLog'
GO
