CREATE TABLE [dbo].[ProcessedGuideCODNotifications]
(
	[IdProcessedNotification]     BIGINT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
	[IdDepositReportCODHeader]    BIGINT					NOT NULL,		
	[GuideSerie]                  NVARCHAR(4)				NOT NULL,		
	[GuideNumber]                 INT						NOT NULL,		
	[IdCustomerType]              INT						NULL,			
	[ConditionOfPaymentID]        INT						NULL,			
	[Pieces_Dry]                  INT						NULL,			
	[Pieces_Cold]                 INT						NULL,			
	[TotalWeight]				  DECIMAL(18,2)				NULL,			
	[Department_Name]			  NVARCHAR(200)				NULL,			
	[Township_Name]				  NVARCHAR(200)				NULL,			
	[ArrivalDate]				  DATETIME					NULL,			
	[DeliveryDate]				  DATETIME					NULL,			
	[Sender_ID]                   INT						NULL,			
	[ReceiverIdTownship]          INT						NULL,			
	[Receiver_FirstName]          NVARCHAR(200)				NULL,			
	[Receiver_LastName]           NVARCHAR(200)				NULL,			
	[Receiver_Town]               NVARCHAR(200)				NULL,			
	[Collect_OnDelivery]          DECIMAL(9,2)				NULL,			
	[TypeService]                 NVARCHAR(3)				NULL,			
	[IsCollect]                   BIT						NULL,			
	[PriceShippment]              DECIMAL(9,2)				NULL,
	[Commission]                  DECIMAL(9,2)				NULL,			
	[CODCommissionPercentage]     DECIMAL(9,2)				NULL,			
	[Amount]                      DECIMAL(9,2)				NULL,			
	[Country_Id]                  NVARCHAR(2)				NOT NULL,		
	[RowStatus]					  BIT						NOT NULL,
	[TokenCreated]				  NVARCHAR(100)				NOT NULL,
	[DateCreated]				  DATETIME					NOT NULL,
	[TokenUpdated]				  NVARCHAR(100)				NULL,
	[DateUpdated]				  DATETIME					NULL,
	CONSTRAINT [FK_PGuideCODNot_DepositHeader] FOREIGN KEY ([IdDepositReportCODHeader]) REFERENCES [dbo].[DepositReportCODHeader] ([IdDepositReportCODHeader])
)

GO
CREATE NONCLUSTERED INDEX IX_PGCN_Header_Guide
ON dbo.ProcessedGuideCODNotifications (IdDepositReportCODHeader, GuideSerie, GuideNumber)
INCLUDE (
	Pieces_Dry, Pieces_Cold, TotalWeight, Department_Name, Township_Name,
	ArrivalDate, DeliveryDate, Receiver_FirstName, Receiver_LastName,
	Collect_OnDelivery, TypeService, IsCollect, ConditionOfPaymentID,
	PriceShippment, Commission, CODCommissionPercentage, Amount
);

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Detalle de guías COD asociadas a un reporte de depósito COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador único del registro de detalle de guía COD en el reporte/notificación.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'IdProcessedNotification';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Referencia al encabezado de reporte COD al que pertenece la guía (FK a DepositReportCODHeader).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'IdDepositReportCODHeader';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Serie de la guía asociada al depósito COD (BatchDetailCOD.GuideSerie).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'GuideSerie';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Número de guía asociada al depósito COD (BatchDetailCOD.GuideNumber).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'GuideNumber';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Tipo de cliente asociado a la guía (Customer.IdCustomerType).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'IdCustomerType';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Condición de pago del cliente.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'ConditionOfPaymentID';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Cantidad de piezas secas de la guía (DeliveryOrder.Pieces_Dry).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Pieces_Dry';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Cantidad de piezas frías de la guía (DeliveryOrder.Pieces_Cold).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Pieces_Cold';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Peso total de la guía en base a DeliveryOrderPiece (suma de MassWeight/PieceWeight).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'TotalWeight';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Nombre del departamento de destino de la guía.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Department_Name';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Nombre del municipio de destino de la guía.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Township_Name';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha de arribo de la guía.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'ArrivalDate';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha de entrega de la guía.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'DeliveryDate';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador del remitente de la guía (DeliveryOrder.Sender_ID, correlacionado con VisitPointClient).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Sender_ID';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador del municipio de destino configurado en la guía (DeliveryOrder.ReceiverIdTownship).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'ReceiverIdTownship';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Primer nombre del receptor de la guía (DeliveryOrder.Receiver_FirstName).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Receiver_FirstName';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Apellido(s) del receptor de la guía (DeliveryOrder.Receiver_LastName).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Receiver_LastName';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Nombre de la ciudad/población de destino según viene en la guía (DeliveryOrder.Receiver_Town).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Receiver_Town';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Monto COD a cobrar al momento de la entrega (DeliveryOrder.Collect_OnDelivery).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Collect_OnDelivery';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Tipo de servicio de la guía utilizado para clasificar el envío.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'TypeService';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Indica si la guía es de tipo Collect (true/false).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'IsCollect';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Monto del envío cobrado por la guía (DeliveryOrder.PriceShippment).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'PriceShippment';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Monto de comisión aplicada a la guía dentro del lote COD (BatchDetailCOD.Commission).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Commission';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Porcentaje de comisión COD aplicado a la guía dentro del lote (BatchDetailCOD.CODCommissionPercentage).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'CODCommissionPercentage';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Monto neto acreditado al cliente por la guía dentro del depósito COD (BatchDetailCOD.Amount).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Amount';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Código de país asociado al destino de la guía o al depósito (DeliveryOrder.ReceiverCountryId).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'Country_Id';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Estado lógico del registro de detalle (1 = activo, 0 = inactivo).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador o usuario que creó el registro de detalle de la guía COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha y hora de creación del registro de detalle de la guía COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador o usuario que realizó la última actualización del detalle de la guía COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha y hora de la última actualización del detalle de la guía COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'ProcessedGuideCODNotifications',
	@level2type = N'COLUMN', @level2name = N'DateUpdated';

GO
