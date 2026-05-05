/* =================================================
   SP:        [dbo].[SPWS_SetInterceptorLogSQS]
   Propósito: Almacenar logs en base de datos, según datos obtenidos por SQS y procesados en Worker. [spws_set_interceptor_log] tomado como base.
   Autor:     Erick Guerra
   Historia:  FDAPI-6220
   Fecha:     2026-04-30
============================================
=== CHANGELOG ================================
=========================================== */

CREATE PROCEDURE SPWS_SetInterceptorLogSQS 
	@TypeOfUse nvarchar(10)  = 'PULL',		    --Push ? Consumo de un servicio externo ; Pull ? Consumo de nuestros servicios [Val Esperado: PULL]
	@IdSystem int  = 13,					    --Sistema DenariusUser de donde viene  [Val Esperado: 13]
	@EntityObjectName nvarchar(100) = '',       --Nombre del objeto de la tabla que tiene su referencia detalle de la bitacora transaccional [Val Esp: GetProvince]
	@TransactionID bigint = 0 ,				    --ID de la transaccion referencial maestro, que necesitamos guardar para busqueda y validacion de registro en bitacora [Val Esperado: 0]
    @TicketNumber nvarchar(150),                --Referencia del cliente
	@IdCustomer int,                            --Identificador del cliente
	@RS_GuideResponse int,                      --Respuesta de creación de la guía
	@RQ_Method nvarchar(10) = '',			    --GET ? Uso de api rest full ; POST ? Uso de api rest full ; SOAP ? Uso de apisoap  [Val Esperado: GetProvince]
	@RQ_Uri nvarchar(4000) = '' ,			    --URL consumida  [Val Esperado:  htpp:sandbox.forza.systems:40467/api.forzadelivery/ecommerce]
	@RQ_Service int  = -1 ,					    --Request - Quien solicita el servicio   [Val Esperado: 1]
	@RQ_Header nvarchar(4000) = '',			    --Datos de conforman la cabezera del mensaje
	@RQ_Body nvarchar(MAX) = '',			    --Datos que conforman el cuerpo del mensaje
	@RQ_Object nvarchar(4000) = '',			    --Objeto guardado como JSON que sirva como estructura de envío
	@RQ_Datetime datetime = '2020-08-19',	    --Fecha de envío de solicitud
	@RQ_LauValue nvarchar(MAX) = '',		    --Llave local de autenticación
	@RQ_Token nvarchar(MAX) = '',			    --Token generado para validar una solicitud; generalmente usando JWT
	@RQ_IdOrder bigint  = -1,				    --Número de orden externa de referencia de búsqueda de registro
	@RS_Service int = -1,					    --Quien provee el servicio
	@RS_StatusCode int = 500,				    --Código de respuesta standard de solicitud Http request method  200 de Success, 500 de Error, 400 de BarRequest ;  1 de Aprobado ; 2 de Declinado ; 3 Error
	@RS_ReasonPhrase nvarchar(50) = '',		    --Descripción de éxito o error interno del servidor               OK | Internal Server Error | BadRequest        ;       Aprobado |      Declinado |   Error
	@RS_ReasonCode nvarchar(4000) = '',		    --Descripción de la respuesta de solicitud - 50001
	@RS_ReasonCodeMessage nvarchar(4000) = '',  --Mensaje de la descripción de la respuesta de solicitud ; Ocurrió un fallo en el motor FAC
	@RS_Header nvarchar(4000) = '',				--Respuesta de la solicitud encabezado
	@RS_Body nvarchar(MAX) = '',				--Respuesta de la solicitud Cuerpo
	@RS_Object nvarchar(4000) = '',				--Objeto de respuesta que sirva como estructura
	@RS_Datetime datetime  = '2020-08-19',		--Fecha hora de respuesta de solicitud
	@RS_IdOrder nvarchar(4000) = '',			--Código de respuesta de la solicitud, puede ser un identificador de transacción bancaria o el identity de registro en nuestro sistema
	@RS_LauValue nvarchar(MAX) = '',			--Llave local de autenticación
	@RS_Token nvarchar(MAX) = ''				--Token generado para validar una solicitud generalmente usando JWT

AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO [DenariusLog_Dev].[dbo].[ApiForzaLogs]
           ([TypeOfUse]
           ,[IdSystem]
           ,[EntityObjectName]
           ,[TransactionID]
           ,[TicketNumber]
           ,[IdCustomer]
           ,[RS_GuideResponse]
           ,[RQ_Method]
           ,[RQ_Uri]
           ,[RQ_Service]
           ,[RQ_Header]
           ,[RQ_Body]
           ,[RQ_Object]
           ,[RQ_Datetime]
           ,[RQ_LauValue]
           ,[RQ_Token]
           ,[RQ_IdOrder]
           ,[RS_Service]
           ,[RS_StatusCode]
           ,[RS_ReasonPhrase]
           ,[RS_ReasonCode]
           ,[RS_ReasonCodeMessage]
           ,[RS_Header]
           ,[RS_Body]
           ,[RS_Object]
           ,[RS_Datetime]
           ,[RS_IdOrder]
           ,[RS_LauValue]
           ,[RS_Token])
     VALUES
           (@TypeOfUse,
            @IdSystem, 
            @EntityObjectName,
            @TransactionID, 
            @TicketNumber,
	        @IdCustomer,
            @RS_GuideResponse,
            @RQ_Method, 
            @RQ_Uri, 
            @RQ_Service, 
            @RQ_Header, 
            @RQ_Body, 
            @RQ_Object, 
            @RQ_Datetime, 
            @RQ_LauValue, 
            @RQ_Token, 
            @RQ_IdOrder, 
            @RS_Service, 
            @RS_StatusCode, 
            @RS_ReasonPhrase, 
            @RS_ReasonCode, 
            @RS_ReasonCodeMessage, 
            @RS_Header, 
            @RS_Body, 
            @RS_Object, 
            @RS_Datetime, 
            @RS_IdOrder, 
            @RS_LauValue, 
            @RS_Token)
			
	SELECT  @@IDENTITY AS 'ID'
END
GO
