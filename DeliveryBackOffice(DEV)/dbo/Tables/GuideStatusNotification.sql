CREATE TABLE dbo.GuideStatusNotification (
IdGuideStatusNotification	INT IDENTITY (1, 1) NOT NULL,
NirPhoner					NVARCHAR(6)			NOT NULL,
Phone						INT					NOT NULL,
GuideSerie					NVARCHAR (2)		NOT NULL,
GuideNumber					INT					NOT NULL,
CountryId					VARCHAR(2)			NOT NULL,
LastChangeDate				DATETIME			NULL,
FinalStatus					INT					NULL,
RowStatus					INT					NULL,
TokenCreated				NVARCHAR(100)		NULL,
DateCreated					DATETIME			NULL,
TokenUpdated				NVARCHAR(100)		NULL,
DateUpdated					DATETIME			NULL,
PRIMARY KEY CLUSTERED (IdGuideStatusNotification ASC),
CONSTRAINT [FKGuideSerie_GuideStatusNotification] FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
CONSTRAINT [FKCountryId_GuideStatusNotification] FOREIGN KEY (CountryId) REFERENCES dbo.CatCountry (IdCountry)
);

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador unico de registro de guia y telefono para notificaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'IdGuideStatusNotification';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Extension de numero telefonico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'NirPhoner';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Numero telefonico asociado a la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'Phone';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guia asociada a DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'GuideSerie';
GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de guia asociado a DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'GuideNumber';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de pais asociado a la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'CountryId';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Ultima fecha y hora de notificacion realizada para la guia asociada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'LastChangeDate';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado final de la guia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'FinalStatus';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Valor booleano que valida el estado activo o inactivo del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualizacion del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que maneja los registros de notificaciones de estados por guia y telefono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideStatusNotification', @level2type = NULL, @level2name = NULL;