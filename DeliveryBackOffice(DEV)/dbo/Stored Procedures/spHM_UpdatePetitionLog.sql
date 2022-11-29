
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-11-25>
-- Description:	<proceso para almacenar en bitacora la informacion del consumo de servicios web de API mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_UpdatePetitionLog] 
	-- Add the parameters for the stored procedure here
	@LogId BIGINT,
	@ResponseHeader nvarchar(4000),
	@ResponseBody nvarchar(MAX) = '',
	@ResponseDateTime datetime = NULL,
	@ResponseCode int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF(@ResponseDateTime IS NULL)
		SET @ResponseDateTime = GETDATE()

	DECLARE @InsertedLog AS TABLE (
		IdInsert BIGINT
	);

	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE 
			[DeliveryBackOffice].[dbo].[APIMobileLog]
		SET
			[ResponseHeader] = @ResponseHeader
			,[ResponseBody] = @ResponseBody
			,[ResponseDateTime] = @ResponseDateTime
			,[ResponseCode] = @ResponseCode
		OUTPUT inserted.IdAPIMobileLog INTO @InsertedLog(IdInsert)
		WHERE
			IdAPIMobileLog = @LogId

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