/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
CREATE TABLE dbo.Tmp_LOG_Http_Interceptor
	(
	Id bigint NOT NULL IDENTITY (1, 1),
	TypeOfUse nvarchar(10) NOT NULL,
	IdSystem int NOT NULL,
	EntityObjectName nvarchar(100) NULL,
	TransactionID bigint NULL,
	RQ_Method nvarchar(10) NOT NULL,
	RQ_Uri nvarchar(4000) NOT NULL,
	RQ_Service int NOT NULL,
	RQ_Header nvarchar(4000) NULL,
	RQ_Body nvarchar(MAX) NULL,
	RQ_Object nvarchar(4000) NULL,
	RQ_Datetime datetime NOT NULL,
	RQ_LauValue nvarchar(MAX) NULL,
	RQ_Token nvarchar(MAX) NULL,
	RQ_IdOrder bigint NULL,
	RS_Service int NOT NULL,
	RS_StatusCode int NULL,
	RS_ReasonPhrase nvarchar(50) NULL,
	RS_ReasonCode nvarchar(4000) NULL,
	RS_ReasonCodeMessage nvarchar(4000) NULL,
	RS_Header nvarchar(4000) NULL,
	RS_Body nvarchar(MAX) NULL,
	RS_Object nvarchar(4000) NULL,
	RS_Datetime datetime NULL,
	RS_IdOrder nvarchar(4000) NULL,
	RS_LauValue nvarchar(MAX) NULL,
	RS_Token nvarchar(MAX) NULL
	)  ON [PRIMARY]
	 TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_LOG_Http_Interceptor SET (LOCK_ESCALATION = TABLE)
GO
DECLARE @v sql_variant 
SET @v = N'Identificador del log (identity)'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'Id'
GO
DECLARE @v sql_variant 
SET @v = N'Push ? Consumo de un servicio externo
Pull ? Consumo de nuestros servicios'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'TypeOfUse'
GO
DECLARE @v sql_variant 
SET @v = N'Id Sistema Api que gestiona la transaccion'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'IdSystem'
GO
DECLARE @v sql_variant 
SET @v = N'nombre del objeto de la tabla que tiene su referencia detalle de la bitacora transaccional'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'EntityObjectName'
GO
DECLARE @v sql_variant 
SET @v = N'ID de la transaccion referencial maestro, que necesitamos guardar para busqueda y validacion de registro en bitacora'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'TransactionID'
GO
DECLARE @v sql_variant 
SET @v = N'GET ? Uso de api rest full 

POST ? Uso de api rest full

SOAP ? Uso de apisoap'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Method'
GO
DECLARE @v sql_variant 
SET @v = N'URL consumida'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Uri'
GO
DECLARE @v sql_variant 
SET @v = N'Request - Quien solicita el servicio'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Service'
GO
DECLARE @v sql_variant 
SET @v = N'Datos de conforman la cabezera del mensaje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Header'
GO
DECLARE @v sql_variant 
SET @v = N'Datos que conforman el cuerpo del mensaje'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Body'
GO
DECLARE @v sql_variant 
SET @v = N'Objeto guardado como JSON que sirva 

como estructura de envío'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Object'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de envío de solicitud'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Datetime'
GO
DECLARE @v sql_variant 
SET @v = N'Llave local de autenticación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_LauValue'
GO
DECLARE @v sql_variant 
SET @v = N'Token generado para validar una solicitud

generalmente usando JWT'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_Token'
GO
DECLARE @v sql_variant 
SET @v = N'Número de orden externa de referencia de búsqueda de registro	'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RQ_IdOrder'
GO
DECLARE @v sql_variant 
SET @v = N'Quien provee el servicio'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Service'
GO
DECLARE @v sql_variant 
SET @v = N'Código de respuesta standard de solicitud Http request method'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_StatusCode'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción de éxito o error interno del servidor'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_ReasonPhrase'
GO
DECLARE @v sql_variant 
SET @v = N'Descripción de la respuesta de solicitud'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_ReasonCode'
GO
DECLARE @v sql_variant 
SET @v = N'Mensaje de la descripción de la respuesta de solicitud'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_ReasonCodeMessage'
GO
DECLARE @v sql_variant 
SET @v = N'Respuesta de la solicitud encabezado'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Header'
GO
DECLARE @v sql_variant 
SET @v = N'Respuesta de la solicitud Cuerpo'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Body'
GO
DECLARE @v sql_variant 
SET @v = N'Objeto de respuesta que sirva como estructura'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Object'
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de respuesta de solicitud'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Datetime'
GO
DECLARE @v sql_variant 
SET @v = N'Código de respuesta de la solicitud, puede

ser un identificador de transacción bancaria o el identity de registro en nuestro sistema'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_IdOrder'
GO
DECLARE @v sql_variant 
SET @v = N'Llave local de autenticación'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_LauValue'
GO
DECLARE @v sql_variant 
SET @v = N'Token generado para validar una solicitud

generalmente usando JWT'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Tmp_LOG_Http_Interceptor', N'COLUMN', N'RS_Token'
GO
SET IDENTITY_INSERT dbo.Tmp_LOG_Http_Interceptor ON
GO
IF EXISTS(SELECT * FROM dbo.LOG_Http_Interceptor)
	 EXEC('INSERT INTO dbo.Tmp_LOG_Http_Interceptor (Id, TypeOfUse, IdSystem, EntityObjectName, TransactionID, RQ_Method, RQ_Uri, RQ_Service, RQ_Header, RQ_Body, RQ_Object, RQ_Datetime, RQ_LauValue, RQ_Token, RQ_IdOrder, RS_Service, RS_StatusCode, RS_ReasonPhrase, RS_ReasonCode, RS_ReasonCodeMessage, RS_Header, RS_Body, RS_Object, RS_Datetime, RS_IdOrder, RS_LauValue, RS_Token)
		SELECT Id, TypeOfUse, IdSystem, EntityObjectName, TransactionID, RQ_Method, RQ_Uri, RQ_Service, RQ_Header, RQ_Body, RQ_Object, RQ_Datetime, RQ_LauValue, RQ_Token, RQ_IdOrder, RS_Service, RS_StatusCode, CONVERT(nvarchar(50), RS_ReasonPhrase), RS_ReasonCode, RS_ReasonCodeMessage, RS_Header, RS_Body, RS_Object, RS_Datetime, RS_IdOrder, RS_LauValue, RS_Token FROM dbo.LOG_Http_Interceptor WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_LOG_Http_Interceptor OFF
GO
DROP TABLE dbo.LOG_Http_Interceptor
GO
EXECUTE sp_rename N'dbo.Tmp_LOG_Http_Interceptor', N'LOG_Http_Interceptor', 'OBJECT' 
GO
ALTER TABLE dbo.LOG_Http_Interceptor ADD CONSTRAINT
	PK_LOG_Http_Interceptor PRIMARY KEY CLUSTERED 
	(
	Id
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
COMMIT
