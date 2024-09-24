CREATE TABLE [dbo].[DeliveryLink]
(
	[IdDeliveryLink] INT IDENTITY (1, 1) NOT NULL,   
    [Token] NVARCHAR(200) NOT NULL, 
    [AccountId] BIGINT NOT NULL, 
    [OriginCodeOfReference] NVARCHAR(200) NOT NULL, 
    [DestinyCodeOfReference] NVARCHAR(200) NULL, 
    [ReceiverName] NVARCHAR(200) NOT NULL, 
    [ReceiverPhone] NVARCHAR(50) NOT NULL, 
    [ReceiverSettlementId] NVARCHAR(100) NOT NULL, 
    [ReceiverEmail] NVARCHAR(100) NOT NULL, 
    [ReceiverCatCityPlaceId] INT NULL, 
    [ReceiverZone] NVARCHAR(100) NULL, 
    [ReceiverNeighborhood] NVARCHAR(50) NULL, 
    [ReceiverAddress] NVARCHAR(600) NULL, 
    [ReceiverAdditionalInstuctions] NVARCHAR(250) NULL, 
    [ReceiverLatitude] NVARCHAR(50) NULL, 
    [ReceiverLongitude] NVARCHAR(50) NULL, 
    [WhatsappId] NVARCHAR(100) NULL, 
    [CatPaymentTypeId] INT NULL, 
    [CatTypeServiceId] INT NOT NULL, 
    [IsInsurance] BIT NULL, 
    [InsuranceAmount] DECIMAL(14,2) NULL, 
    [DeliveryFacCODId] INT NULL, 
    [CollectOnDelivery] DECIMAL(14,2) NULL, 
    [DeliveryLinkStatusId] INT NOT NULL, 
    [ExpirationDate] DATE NOT NULL, 
    [SubscriptionId] INT NULL, 
    [GuideSerie] NVARCHAR(2) NULL, 
    [GuideNumber] INT NULL, 
    [RowStatus] BIT NOT NULL, 
    [UserCreated] NVARCHAR(50) NOT NULL, 
    [DateCreated] DATETIME NOT NULL, 
    [UserUpdated] NVARCHAR(50) NULL, 
    [DateUpdated] DATETIME NULL, 
	PRIMARY KEY CLUSTERED ([IdDeliveryLink] ASC),
    CONSTRAINT FK_DeliveryLink_AccountId FOREIGN KEY (AccountId) REFERENCES Account(AccIdAccount),
    CONSTRAINT FK_DeliveryLink_ReceiverCatCityPlaceId FOREIGN KEY (ReceiverCatCityPlaceId) REFERENCES CatCityPlace(IdCityPlace),
    CONSTRAINT FK_DeliveryLink_CatPaymentTypeId FOREIGN KEY (CatPaymentTypeId) REFERENCES CatPaymentType(PayTypeId),
    CONSTRAINT FK_DeliveryLink_CatTypeServiceId FOREIGN KEY (CatTypeServiceId) REFERENCES CatTypeService(CtsId),
    CONSTRAINT FK_DeliveryLink_DeliveryFacCODId FOREIGN KEY (DeliveryFacCODId) REFERENCES DeliveryFavCOD(IdDeliveryFavCOD),
    CONSTRAINT FK_DeliveryLink_DeliveryLinkStatusId FOREIGN KEY (DeliveryLinkStatusId) REFERENCES DeliveryLinkStatus(IdDeliveryLinkStatus),
    CONSTRAINT FK_DeliveryLink_SubscriptionId FOREIGN KEY (SubscriptionId) REFERENCES Subscription(IdSubscription),
    CONSTRAINT FK_DeliveryLink_GuideSerie FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES DeliveryOrder(Guide_Serie, Guide_Number)
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del link de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'IdDeliveryLink'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de link de entrega',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'Token'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'A quien pertenece el link (FK a Account)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'AccountId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de origen',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'OriginCodeOfReference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Datos de destino',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'DestinyCodeOfReference'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre destinatario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Teléfono destinatario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverPhone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Poblado del destinatario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverSettlementId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Correo electrónico del destinatario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverEmail'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de dirección (FK a CatCityPlace)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverCatCityPlaceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Zona',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverZone'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Colonia',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverNeighborhood'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Dirección exacta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverAddress'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Otros datos de la dirección',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverAdditionalInstuctions'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Latitud de destino',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverLatitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Longitud de destino',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ReceiverLongitude'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Comunicación con WhatsApp',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'WhatsappId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Quién paga el envío? (FK a CatPaymentType)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'CatPaymentTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'La guía es estándar o COD (FK a CatTypeService)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'CatTypeServiceId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica si la guía esta asegurada',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'IsInsurance'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Monto del seguro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'InsuranceAmount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Cuenta bancaria (FK a DeliveryFavCOD)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'DeliveryFacCODId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Monto de COD',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'CollectOnDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del link (FK a DeliveryLinkStatus)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'DeliveryLinkStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de expiración',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'ExpirationDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Se usa suscripción (FK a Subscription)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'SubscriptionId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serie de guía asociada al link de entrega (FK a DeliveryOrder)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'GuideSerie'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de guía asociada al link de entrega (FK a DeliveryOrder)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'GuideNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado lógico',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'UserCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Usuario de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'UserUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryLink',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'