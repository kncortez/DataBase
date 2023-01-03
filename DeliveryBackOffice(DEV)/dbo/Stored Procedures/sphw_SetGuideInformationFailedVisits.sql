-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-11-24>
-- Description:	<Actualiza teléfono y dirección para monitoreo de visitas fallidas>
-- =============================================
CREATE PROCEDURE [dbo].[sphw_SetGuideInformationFailedVisits]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Phone NVARCHAR(100) = '',
	@Address NVARCHAR(600) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IsLastMileReturn BIT
	DECLARE @StatusOrder NVARCHAR(100)

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		
		SELECT
			@IsLastMileReturn = ISNULL(do.IsLastMileReturn, 0)
		   ,@StatusOrder =
			CASE
				WHEN so.OrderDescription IN ('Anulado', 'Entregado', 'Devuelto', 'Traslado a Express Center', 'Entregado En Express Center', 'Devuelto en Express Center', 'COD liquidado', 'COD pagado', 'Paquete destruido') THEN so.OrderDescription
				ELSE NULL
			END
		FROM DeliveryOrder do WITH (NOLOCK)
		INNER JOIN StatusOrder so WITH (NOLOCK)
			ON do.StatusOrderId = so.StatusOrderId
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber

		IF @IsLastMileReturn IS NOT NULL
		BEGIN

			IF @StatusOrder IS NULL
			BEGIN

				IF @IsLastMileReturn = 1
					UPDATE DeliveryOrder
					SET Sender_Phone = CASE WHEN @Phone <> '' THEN @Phone ELSE Sender_Phone END
						,Sender_Address = CASE WHEN @Address <> '' THEN @Address ELSE Sender_Address END
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber
				ELSE
					UPDATE DeliveryOrder
					SET Receiver_Phone = CASE WHEN @Phone <> '' THEN @Phone ELSE Receiver_Phone END
						,Receiver_Address = CASE WHEN @Address <> '' THEN @Address ELSE Receiver_Address END
					WHERE Guide_Serie = @GuideSerie
					AND Guide_Number = @GuideNumber

				IF @@ROWCOUNT > 0
				BEGIN
					COMMIT TRANSACTION

					SELECT
						1 'StatusCode'
					   ,'Registros actualizados correctamente.' 'Description'
				END
				ELSE
				BEGIN 
					SELECT
						0 'StatusCode'
					   ,'Registros no actualizados.' 'Description'
				END
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					0 'StatusCode'
				   ,CONCAT('La guía ', @GuideSerie, @GuideNumber, ' se encuentra en estado ', @StatusOrder, '.') 'Description'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				0 'StatusCode'
			   ,CONCAT('La guía ', @GuideSerie, @GuideNumber, ' no existe.') 'Description'
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END