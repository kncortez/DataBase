/* =================================================
   Script:    Creación de tabla
   Propósito: Se encargara en crear las nuevas tablas utilizada para seguimiento de reporte/notificación en lotes de clientes COD.
   Autor:     Walter Orozco
   Historia:  FDAPI-5247 [FDAPI-5248]
   Fecha:     2025-12-05
=================================================*/

BEGIN TRY
    BEGIN TRANSACTION;

	IF NOT EXISTS (
		SELECT 1 FROM sys.tables T
		INNER JOIN sys.schemas S ON T.schema_id = S.schema_id
		WHERE T.name = 'DepositReportCODHeader' AND S.name = 'dbo'
	)
	BEGIN

		CREATE TABLE dbo.DepositReportCODHeader (
			IdDepositReportCODHeader  BIGINT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
			Batch_COD_Id              INT					NOT NULL,   -- BatchCOD.IdBatchCOD
			Customer_Id               INT					NOT NULL,   -- Customer.IdCustomer
			Customer_Type			  INT					NOT NULL,	-- Customer.IdCustomerType
			Customer_Name             NVARCHAR(200)			NOT NULL,	-- Customer.Name o DeliveryOrder.Sender_FirstName
			Customer_Email            NVARCHAR(200)			NOT NULL,	-- Customer.CODContactEmail o Customer.RegexEmail (RegexEmail)
			Sender_Email              NVARCHAR(400)			NOT NULL,	-- DeliveryOrder.Sender_Mail (SenderEmail)
			Bank_Id                   INT					NOT NULL,	-- BatchDetailCOD.BankId
			BankName                  NVARCHAR(100)			NOT NULL,	-- BatchDetailCOD.BankName
			AccountNumber             NVARCHAR(100)			NOT NULL,	-- BatchDetailCOD.AccountNumber
			Currency_Symbol           NVARCHAR(5)			NOT NULL,	-- CatCurrencyCOD.Symbol
			Country_Id                NVARCHAR(2)			NOT NULL,	-- DeliveryOrder.ReceiverCountryId o DeliveryBank.Id_country
			AuthorizationNumber       NVARCHAR(100)			NOT NULL,	-- BatchDetailCOD.AuthorizationNumber
			AuthorizationDate         DATETIME				NOT NULL,	-- BatchDetailCOD.AuthorizationDate
			Notificated               TINYINT				NOT NULL,	-- ProcessedGuideCOD.Notificated
			SalePipeLineId            INT					NULL,		-- DeliveryOrder.SalePipeLineId
			IdKindOfVPClient          INT					NULL,		-- VisitPointClient.IdKindOfVPClient
			SaleChannelId             INT					NULL,		-- VisitPointClient.SaleChannelId
			RowStatus                 BIT					NOT NULL,
			TokenCreated              NVARCHAR(100)			NOT NULL,
			DateCreated               DATETIME				NOT NULL,
			TokenUpdated              NVARCHAR(100)			NULL,
			DateUpdated               DATETIME				NULL,
			CONSTRAINT FK_DepositReportCODHeader_BatchCOD		FOREIGN KEY (Batch_COD_Id)
			REFERENCES dbo.BatchCOD (IdBatchCOD),
			CONSTRAINT FK_DepositReportCODHeader_Customer		FOREIGN KEY (Customer_Id)
			REFERENCES dbo.Customer (IdCustomer),
			CONSTRAINT FK_DepositReportCODHeader_DeliveryBank	FOREIGN KEY (Bank_Id)
			REFERENCES dbo.DeliveryBank (Id_bank)
		);

		-- Descripción de la tabla
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Encabezado de reporte de depósitos COD por lote.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader';

		-- IdDepositReportCODHeader
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador único del encabezado de reporte de depósito COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'IdDepositReportCODHeader';

		-- Batch_COD_Id
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del lote COD asociado al reporte (BatchCOD.IdBatchCOD).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Batch_COD_Id';

		-- Customer_Id
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del cliente asociado al reporte (Customer.IdCustomer).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Customer_Id';

		-- Customer_Type
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del tipo de cliente asociado al reporte (Customer.IdCustomerType).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Customer_Type';

		-- Customer_Name
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Nombre del cliente que recibe el reporte (Customer.Name o Sender_FirstName según el caso).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Customer_Name';

		-- Customer_Email
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Correo principal del cliente para notificación de depósitos (CODContactEmail o RegexEmail).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Customer_Email';

		-- Sender_Email
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Correo de remitente configurado en la DeliveryOrder (Sender_Mail).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Sender_Email';

		-- Bank_Id
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del banco en el que se realizó el depósito (BatchDetailCOD.BankId / DeliveryBank.Id_bank).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Bank_Id';

		-- BankName
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Nombre del banco utilizado en el depósito COD (BatchDetailCOD.BankName).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'BankName';

		-- AccountNumber
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Número de cuenta bancaria donde se acreditan los depósitos COD (BatchDetailCOD.AccountNumber).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'AccountNumber';

		-- Currency_Symbol
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Símbolo de la moneda utilizada en el depósito (CatCurrencyCOD.Symbol).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Currency_Symbol';

		-- Country_Id
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Código de país asociado al depósito (ReceiverCountryId o DeliveryBank.Id_country).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Country_Id';

		-- AuthorizationNumber
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Número de autorización del depósito COD (BatchDetailCOD.AuthorizationNumber).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'AuthorizationNumber';

		-- AuthorizationDate
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha y hora en que se registró la autorización del depósito COD (BatchDetailCOD.AuthorizationDate).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'AuthorizationDate';

		-- Notificated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Indicador de notificación de depósito COD (0 = pendiente, 1 = notificado).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'Notificated';

		-- SalePipeLineId
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Pipeline de la guía según configuración (DeliveryOrder.SalePipeLineId).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'SalePipeLineId';

		-- IdKindOfVPClient
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Tipo de punto de venta asociado al cliente (VisitPointClient.IdKindOfVPClient).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'IdKindOfVPClient';

		-- SaleChannelId
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Canal de venta asociado al punto de venta del cliente (VisitPointClient.SaleChannelId).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'SaleChannelId';

		-- RowStatus
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Estado lógico del registro (1 = activo, 0 = inactivo).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'RowStatus';

		-- TokenCreated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador o usuario que creó el registro del encabezado de reporte COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'TokenCreated';

		-- DateCreated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha y hora de creación del registro del encabezado de reporte COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'DateCreated';

		-- TokenUpdated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador o usuario que realizó la última actualización del registro del encabezado.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'TokenUpdated';

		-- DateUpdated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha y hora de la última actualización del registro del encabezado.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
			@level2type = N'COLUMN', @level2name = N'DateUpdated';

		CREATE NONCLUSTERED INDEX IX_DRCH_Customer_AuthDate
		ON dbo.DepositReportCODHeader (Customer_Id, AuthorizationDate)
		INCLUDE (Bank_Id, Customer_Name, Customer_Email, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol, Sender_Email);

		CREATE NONCLUSTERED INDEX IX_DRCH_Customer_Bank_AuthDate
		ON dbo.DepositReportCODHeader (Customer_Id, Bank_Id, AuthorizationDate)
		INCLUDE (Customer_Name, Customer_Email, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol, Sender_Email);

		CREATE NONCLUSTERED INDEX IX_DRCH_SenderEmail_AuthDate
		ON dbo.DepositReportCODHeader (Sender_Email, AuthorizationDate)
		INCLUDE (Customer_Id, Customer_Name, Bank_Id, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol);

		CREATE NONCLUSTERED INDEX IX_DRCH_SenderEmail_Bank_AuthDate
		ON dbo.DepositReportCODHeader (Sender_Email, Bank_Id, AuthorizationDate)
		INCLUDE (Customer_Id, Customer_Name, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol);

	END;

	IF NOT EXISTS (
		SELECT 1 FROM sys.tables T
		INNER JOIN sys.schemas S ON T.schema_id = S.schema_id
		WHERE T.name = 'ProcessedGuideCODNotifications' AND S.name = 'dbo'
	)
	BEGIN

		CREATE TABLE dbo.ProcessedGuideCODNotifications (
			IdProcessedNotification     BIGINT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
			IdDepositReportCODHeader    BIGINT					NOT NULL,		-- FK al encabezado del reporte
			GuideSerie                  NVARCHAR(4)				NOT NULL,		-- BatchDetailCOD.GuideSerie
			GuideNumber                 INT						NOT NULL,		-- BatchDetailCOD.GuideNumber
			IdCustomerType              INT						NULL,			-- Customer.IdCustomerType
			ConditionOfPaymentID        INT						NULL,			-- Customer.ConditionOfPaymentID
			Pieces_Dry                  INT						NULL,			-- DeliveryOrder.Pieces_Dry
			Pieces_Cold                 INT						NULL,			-- DeliveryOrder.Pieces_Cold
			TotalWeight					DECIMAL(18,2)			NULL,			-- SUM(ISNULL(DeliveryOrderPiece.MassWeight, DeliveryOrderPiece.PieceWeight))
			Department_Name				NVARCHAR(200)			NULL,			-- Province.ProvinceName
			Township_Name				NVARCHAR(200)			NULL,			-- Township.TownshipName
			ArrivalDate					DATETIME				NULL,			-- FechaArribo (DeliveryOrderDetail.DateCreated -> StatusOrderId IN ( 11, 2 ))
			DeliveryDate				DATETIME				NULL,			-- FechaEntrega (DeliveryOrderDetail.DateCreated -> StatusOrderId = 5)
			Sender_ID                   INT						NULL,			-- DeliveryOrder.Sender_ID
			ReceiverIdTownship          INT						NULL,			-- DeliveryOrder.ReceiverIdTownship
			Receiver_FirstName          NVARCHAR(200)			NULL,			-- DeliveryOrder.Receiver_FirstName
			Receiver_LastName           NVARCHAR(200)			NULL,			-- DeliveryOrder.Receiver_LastName
			Receiver_Town               NVARCHAR(200)			NULL,			-- DeliveryOrder.Receiver_Town
			Collect_OnDelivery          DECIMAL(9,2)			NULL,			-- DeliveryOrder.Collect_OnDelivery
			TypeService                 NVARCHAR(3)				NULL,			-- DeliveryOrder.TypeService
			IsCollect                   BIT						NULL,			-- DeliveryOrder.IsCollect
			PriceShippment              DECIMAL(9,2)			NULL,			-- DeliveryOrder.PriceShippment
			Commission                  DECIMAL(9,2)			NULL,			-- BatchDetailCOD.Commission
			CODCommissionPercentage     DECIMAL(9,2)			NULL,			-- BatchDetailCOD.CODCommissionPercentage
			Amount                      DECIMAL(9,2)			NULL,			-- BatchDetailCOD.Amount
			Country_Id                  NVARCHAR(2)				NOT NULL,		-- DeliveryOrder.ReceiverCountryId			--pendiente
			RowStatus					BIT					NOT NULL,
			TokenCreated				NVARCHAR(100)			NOT NULL,
			DateCreated					DATETIME				NOT NULL,
			TokenUpdated				NVARCHAR(100)			NULL,
			DateUpdated					DATETIME				NULL,
			CONSTRAINT FK_PGuideCODNot_DepositHeader FOREIGN KEY (IdDepositReportCODHeader)
			REFERENCES dbo.DepositReportCODHeader (IdDepositReportCODHeader)
		);

		-- Descripción de la tabla
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Detalle de guías COD asociadas a un reporte de depósito COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications';

		-- IdProcessedNotification
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador único del registro de detalle de guía COD en el reporte/notificación.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'IdProcessedNotification';

		-- IdDepositReportCODHeader
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Referencia al encabezado de reporte COD al que pertenece la guía (FK a DepositReportCODHeader).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'IdDepositReportCODHeader';

		-- GuideSerie
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Serie de la guía asociada al depósito COD (BatchDetailCOD.GuideSerie).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'GuideSerie';

		-- GuideNumber
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Número de guía asociada al depósito COD (BatchDetailCOD.GuideNumber).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'GuideNumber';

		-- IdCustomerType
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Tipo de cliente asociado a la guía (Customer.IdCustomerType).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'IdCustomerType';

		-- ConditionOfPaymentID
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Condición de pago del cliente.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'ConditionOfPaymentID';

		-- Pieces_Dry
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Cantidad de piezas secas de la guía (DeliveryOrder.Pieces_Dry).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Pieces_Dry';

		-- Pieces_Cold
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Cantidad de piezas frías de la guía (DeliveryOrder.Pieces_Cold).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Pieces_Cold';

		-- TotalWeight
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Peso total de la guía en base a DeliveryOrderPiece (suma de MassWeight/PieceWeight).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'TotalWeight';

		-- Department_Name
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Nombre del departamento de destino de la guía.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Department_Name';

		-- Township_Name
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Nombre del municipio de destino de la guía.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Township_Name';

		-- ArrivalDate
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha de arribo de la guía.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'ArrivalDate';

		-- DeliveryDate
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha de entrega de la guía.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'DeliveryDate';

		-- Sender_ID
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del remitente de la guía (DeliveryOrder.Sender_ID, correlacionado con VisitPointClient).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Sender_ID';

		-- ReceiverIdTownship
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador del municipio de destino configurado en la guía (DeliveryOrder.ReceiverIdTownship).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'ReceiverIdTownship';

		-- Receiver_FirstName
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Primer nombre del receptor de la guía (DeliveryOrder.Receiver_FirstName).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Receiver_FirstName';

		-- Receiver_LastName
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Apellido(s) del receptor de la guía (DeliveryOrder.Receiver_LastName).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Receiver_LastName';

		-- Receiver_Town
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Nombre de la ciudad/población de destino según viene en la guía (DeliveryOrder.Receiver_Town).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Receiver_Town';

		-- Collect_OnDelivery
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Monto COD a cobrar al momento de la entrega (DeliveryOrder.Collect_OnDelivery).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Collect_OnDelivery';

		-- TypeService
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Tipo de servicio de la guía utilizado para clasificar el envío.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'TypeService';

		-- IsCollect
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Indica si la guía es de tipo Collect (true/false).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'IsCollect';

		-- PriceShippment
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Monto del envío cobrado por la guía (DeliveryOrder.PriceShippment).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'PriceShippment';

		-- Commission
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Monto de comisión aplicada a la guía dentro del lote COD (BatchDetailCOD.Commission).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Commission';

		-- CODCommissionPercentage
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Porcentaje de comisión COD aplicado a la guía dentro del lote (BatchDetailCOD.CODCommissionPercentage).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'CODCommissionPercentage';

		-- Amount
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Monto neto acreditado al cliente por la guía dentro del depósito COD (BatchDetailCOD.Amount).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Amount';

		-- Country_Id
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Código de país asociado al destino de la guía o al depósito (DeliveryOrder.ReceiverCountryId).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'Country_Id';

		-- RowStatus
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Estado lógico del registro de detalle (1 = activo, 0 = inactivo).',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'RowStatus';

		-- TokenCreated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador o usuario que creó el registro de detalle de la guía COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'TokenCreated';

		-- DateCreated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha y hora de creación del registro de detalle de la guía COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'DateCreated';

		-- TokenUpdated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Identificador o usuario que realizó la última actualización del detalle de la guía COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'TokenUpdated';

		-- DateUpdated
		EXEC sys.sp_addextendedproperty 
			@name = N'MS_Description',
			@value = N'Fecha y hora de la última actualización del detalle de la guía COD.',
			@level0type = N'SCHEMA', @level0name = N'dbo',
			@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
			@level2type = N'COLUMN', @level2name = N'DateUpdated';

		CREATE NONCLUSTERED INDEX IX_PGCN_Header_Guide
		ON dbo.ProcessedGuideCODNotifications (IdDepositReportCODHeader, GuideSerie, GuideNumber)
		INCLUDE (
			Pieces_Dry, Pieces_Cold, TotalWeight, Department_Name, Township_Name,
			ArrivalDate, DeliveryDate, Receiver_FirstName, Receiver_LastName,
			Collect_OnDelivery, TypeService, IsCollect, ConditionOfPaymentID,
			PriceShippment, Commission, CODCommissionPercentage, Amount
		);

	END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;