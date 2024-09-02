-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-04-28>
-- Description:	< Verificar estado de guía >
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-06-10>
-- Description:	<Se agrega el filtro por pais al pais destino >
-- =============================================
CREATE PROCEDURE [dbo].[spHD_VerifyGuideStatus]

	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@IdCountry NVARCHAR(2) = 'GT'

	AS
BEGIN

	DECLARE @BelongCountry BIT;

	SELECT @BelongCountry = CASE WHEN IIF(ReceiverCountryId IS NULL, 'GT', ReceiverCountryId) = @IdCountry THEN 1 ELSE 0 END
	FROM DeliveryOrder 
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber

	IF @BelongCountry = 1
	BEGIN

		DECLARE @TerminalStatusType INT =
		(
			SELECT 
				TOP (1)
					[CCT].[IdCatCheckpointType]
			FROM
				[DeliveryBackOffice].[dbo].[CatCheckpointType] CCT  WITH(NOLOCK) 
			WHERE
				[CCT].[CheckpointTypeDescription] = 'Checkpoint final'  COLLATE Latin1_General_CI_AI 
		);
		DECLARE @ActualGuideStatus INT;
		DECLARE @TerminalStatus TABLE
		(
			IdStatusOrder INT
		);
		INSERT INTO @TerminalStatus
		(
			[IdStatusOrder]
		)
		SELECT
			[SO].[StatusOrderId]
		FROM
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			[SO].[CatCheckpointTypeId] = @TerminalStatusType

		BEGIN TRY

			SET @ActualGuideStatus =
			(
				SELECT 
					TOP (1) 
						[DO].[StatusOrderId] 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				WHERE
					[DO].[Guide_Serie] = @GuideSerie
					AND
					[DO].[Guide_Number] = @GuideNumber
			)

			IF ( EXISTS ( SELECT TOP 1 1 FROM @TerminalStatus TS WHERE [TS].[IdStatusOrder] = @ActualGuideStatus ) )
			BEGIN
				
				SELECT
					401 [ResponseCode],
					'Guía no valida para proceder.' [ResponseMessage]

			END
			ELSE
			BEGIN
				
				SELECT
					200 [ResponseCode],
					'Guía valida para proceder.' [ResponseMessage]

			END

		END TRY
		BEGIN CATCH

			SELECT
				500 [ResponseCode],
				CONCAT('Mensaje: ', ERROR_MESSAGE(),'| Linea aproximada: ', ERROR_LINE()) [ResponseMessage]

		END CATCH
	END
	ELSE
	BEGIN
		SELECT
				-5 [ResponseCode],
				'Laguia no pertenece al pais logueado' [ResponseMessage]
	END
END