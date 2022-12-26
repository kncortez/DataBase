
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-11-25>
-- Description:	<proceso para almacenar en bitacora la informacion del consumo de servicios web de API mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RegisterPetitionLog] 
	-- Add the parameters for the stored procedure here
	@PetitionMethod nvarchar(10) = '',			    --GET → Uso de api rest full ; POST → Uso de api rest full ; SOAP → Uso de apisoap  [Val Esperado: GetProvince]
	@PetitionUrl nvarchar(MAX) = '' ,			    --URL consumida  [Val Esperado:  htpp:sandbox.forza.systems:40467/api.forzadelivery/ecommerce]
	@RequestHeader nvarchar(4000) = '',			    --Datos de conforman la cabezera del mensaje
	@RequestBody nvarchar(MAX) = '',			    --Datos que conforman el cuerpo del mensaje
	@RequestDateTime datetime = '2020-08-19',	    --Fecha de envío de solicitud
	@RequestLauValue nvarchar(500) = '',		    --Llave local de autenticación
	@ResponseHeader nvarchar(4000) = '',				--Respuesta de la solicitud encabezado
	@ResponseBody nvarchar(MAX) = '',				--Respuesta de la solicitud Cuerpo
	@ResponseDateTime datetime  = '2020-08-19',		--Fecha hora de respuesta de solicitud
	@ResponseCode int = 500				    --Código de respuesta standard de solicitud Http request method  200 de Success, 500 de Error, 400 de BarRequest ;  1 de Aprobado ; 2 de Declinado ; 3 Error

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @InsertedLog AS TABLE (
		IdInsert BIGINT
	);

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO [DeliveryBackOffice].[dbo].[APIMobileLogs]
			(
				[PetitionMethod]
				,[PetitionUrl]
				,[RequestHeader]
				,[RequestBody]
				,[RequestDateTime]
				,[RequestLauValue]
				,[ResponseHeader]
				,[ResponseBody]
				,[ResponseDateTime]
				,[ResponseCode]
			)
		OUTPUT inserted.IdAPIMobileLogs INTO @InsertedLog(IdInsert)
		VALUES
		(
			@PetitionMethod
			,@PetitionUrl
			,@RequestHeader
			,@RequestBody
			,@RequestDateTime
			,@RequestLauValue
			,@ResponseHeader
			,@ResponseBody
			,@ResponseDateTime
			,@ResponseCode
		)

		IF(EXISTS (SELECT TOP 1 1 FROM @InsertedLog))
		BEGIN

			COMMIT TRANSACTION;

			SELECT
				200 'ResultCode'

		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION;

			SELECT
				204 'ResultCode'

		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			500 'ResultCode'

	END CATCH
END