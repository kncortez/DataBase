-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-12-20>
-- Description:	<Crea, actualiza o elimina Segmentos de Socios de Negocio Desktop>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_SetBusinessPartnerSegments]
	-- Add the parameters for the stored procedure here
	@IdCorporateTownshipCoverage INT = NULL,
	@TownshipSourceId INT,
	@TownshipDestinyId INT,
	@SegmentTypeId INT,
	@RowStatus BIT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    BEGIN TRANSACTION
	BEGIN TRY
		
		IF @IdCorporateTownshipCoverage IS NULL OR @RowStatus = 1
		BEGIN

			IF @IdCorporateTownshipCoverage IS NOT NULL
			BEGIN

				UPDATE CorporateTownshipCoverage
				SET SegmentTypeId = @SegmentTypeId
				   ,RowStatus = 1
				   ,TokenUpdated = @Token
				   ,DateUpdated = GETDATE()
				WHERE IdCorporateTownshipCoverage = @IdCorporateTownshipCoverage


				IF @@ROWCOUNT > 0
				BEGIN
					COMMIT TRANSACTION

					SELECT
						1 'StatusCode'
					   ,'Operación realizada exitosamente.' 'Description'
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION

					SELECT
						0 'StatusCode'
					   ,'Operacion no realizada, no se encontró el registro.' 'Description'
				END
			END
			ELSE
			BEGIN
			
				IF NOT EXISTS (SELECT
						1
					FROM CorporateTownshipCoverage
					WHERE TownshipSourceId = @TownshipSourceId
					AND TownshipDestinyId = @TownshipDestinyId
					AND RowStatus = 1)
				BEGIN

					INSERT INTO [dbo].[CorporateTownshipCoverage] ([TownshipSourceId]
					, [TownshipDestinyId]
					, [SegmentTypeId]
					, [RowStatus]
					, [TokenCreated]
					, [DateCreated])
						VALUES (@TownshipSourceId, @TownshipDestinyId, @SegmentTypeId, 1, @Token, GETDATE())

					COMMIT TRANSACTION

					SELECT
						1 'StatusCode'
					   ,'Operación realizada exitosamente.' 'Description'
					   ,SCOPE_IDENTITY() Id
				END
				ELSE
				BEGIN
					ROLLBACK TRANSACTION

					SELECT
						0 'StatusCode'
					   ,'Ya existe un registro con el mismo origen y destino.' 'Description'
				END
			END
		END
		ELSE IF @IdCorporateTownshipCoverage IS NOT NULL
		BEGIN

			UPDATE CorporateTownshipCoverage
			SET RowStatus = 0
			   ,TokenUpdated = @Token
			   ,DateUpdated = GETDATE()
			WHERE IdCorporateTownshipCoverage = @IdCorporateTownshipCoverage

			IF @@ROWCOUNT > 0
			BEGIN
				COMMIT TRANSACTION

				SELECT
					1 'StatusCode'
				   ,'Operación realizada exitosamente.' 'Description'
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					0 'StatusCode'
				   ,'Operacion no realizada, no se encontró el registro.' 'Description'
			END
		END
		ELSE 
		BEGIN 
			ROLLBACK TRANSACTION

			SELECT
				0 'StatusCode'
			   ,'Operacion no realizada, falta información.' 'Description'
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END