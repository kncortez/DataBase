CREATE TABLE [dbo].[ApiForzaLogs](
    [Id] [bigint] IDENTITY(1,1) NOT NULL,
	[TypeOfUse] [nvarchar](10) NOT NULL,
	[IdSystem] [int] NOT NULL,
	[EntityObjectName] [nvarchar](100) NULL,
	[TransactionID] [bigint] NULL,
    [TicketNumber] [nvarchar](150),
	[IdCustomer] [int],
	[RS_GuideResponse] [int],
    [RQ_Method] [nvarchar](10) NOT NULL,
	[RQ_Uri] [nvarchar](4000) NOT NULL,
	[RQ_Service] [int] NOT NULL,
	[RQ_Header] [nvarchar](4000) NULL,
	[RQ_Body] [nvarchar](max) NULL,
	[RQ_Object] [nvarchar](4000) NULL,
	[RQ_Datetime] [datetime] NOT NULL,
	[RQ_LauValue] [nvarchar](max) NULL,
	[RQ_Token] [nvarchar](max) NULL,
	[RQ_IdOrder] [bigint] NULL,
	[RS_Service] [int] NOT NULL,
	[RS_StatusCode] [int] NULL,
	[RS_ReasonPhrase] [nvarchar](50) NULL,
	[RS_ReasonCode] [nvarchar](4000) NULL,
	[RS_ReasonCodeMessage] [nvarchar](4000) NULL,
	[RS_Header] [nvarchar](4000) NULL,
	[RS_Body] [nvarchar](max) NULL,
	[RS_Object] [nvarchar](4000) NULL,
	[RS_Datetime] [datetime] NULL,
	[RS_IdOrder] [nvarchar](4000) NULL,
	[RS_LauValue] [nvarchar](max) NULL,
	[RS_Token] [nvarchar](max) NULL,
    PRIMARY KEY NONCLUSTERED ([Id] ASC)
    WITH
        (
            PAD_INDEX = OFF,
            STATISTICS_NORECOMPUTE = OFF,
            IGNORE_DUP_KEY = OFF,
            ALLOW_ROW_LOCKS = ON,
            ALLOW_PAGE_LOCKS = ON,
            OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF
        ) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del log (identity)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'Id'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Push → Consumo de un servicio externo
Pull → Consumo de nuestros servicios' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'TypeOfUse'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Id Sistema Api que gestiona la transaccion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'IdSystem'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'nombre del objeto de la tabla que tiene su referencia detalle de la bitacora transaccional' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'EntityObjectName'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID de la transaccion referencial maestro, que necesitamos guardar para busqueda y validacion de registro en bitacora' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'TransactionID'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Referencia del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'TicketNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'IdCustomer'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Respuesta de creación de guía' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_GuideResponse'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GET → Uso de api rest full 

POST → Uso de api rest full

SOAP → Uso de apisoap' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Method'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'URL consumida' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Uri'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request - Quien solicita el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Service'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Datos de conforman la cabezera del mensaje' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Header'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Datos que conforman el cuerpo del mensaje' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Body'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Objeto guardado como JSON que sirva 

como estructura de envío' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Object'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de envío de solicitud' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Datetime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave local de autenticación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_LauValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token generado para validar una solicitud

generalmente usando JWT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_Token'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de orden externa de referencia de búsqueda de registro	' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RQ_IdOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Quien provee el servicio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Service'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de respuesta standard de solicitud Http request method' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_StatusCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de éxito o error interno del servidor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_ReasonPhrase'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción de la respuesta de solicitud' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_ReasonCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Mensaje de la descripción de la respuesta de solicitud' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_ReasonCodeMessage'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Respuesta de la solicitud encabezado' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Header'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Respuesta de la solicitud Cuerpo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Body'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Objeto de respuesta que sirva como estructura' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Object'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de respuesta de solicitud' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Datetime'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código de respuesta de la solicitud, puede

ser un identificador de transacción bancaria o el identity de registro en nuestro sistema' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_IdOrder'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Llave local de autenticación' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_LauValue'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Token generado para validar una solicitud

generalmente usando JWT' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ApiForzaLogs', @level2type=N'COLUMN',@level2name=N'RS_Token'
GO


