-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-06>
-- Description:	<Marca una guía como devuelta en módulo de entrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetGuideSpecialRouteDeliveryConfirmation]
	-- Add the parameters for the stored procedure here
	@IDTSERoutePreparationHeader INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece INT,
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @IDTSERoutePreparationDetail INT

		SELECT
			@IDTSERoutePreparationDetail = IDTSERoutePreparationDetail
		FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
		INNER JOIN TSERoutePreparationDetailPiece trpdp WITH (NOLOCK)
			ON trpdp.TSERoutePreparationDetailId = trpd.IDTSERoutePreparationDetail
		WHERE trpd.TSERoutePreparationHeaderID = @IDTSERoutePreparationHeader
		AND trpd.GuideSerie = @GuideSerie
		AND trpd.GuideNumber = @GuideNumber
		AND trpdp.PieceNumber = @GuidePiece
		AND trpd.RowStatus = 1
		AND trpdp.RowStatus = 1

		IF @IDTSERoutePreparationDetail > 0
		BEGIN

			DECLARE @StatusOrderId TINYINT = ( SELECT
					StatusOrderId
				FROM StatusOrder
				WHERE OrderDescription = 'Devuelto')

			UPDATE do
			SET do.StatusOrderId = @StatusOrderId
				,do.DateUpdated = GETDATE()
				,do.TokenUpdated = @Token
			FROM DeliveryOrder do WITH (NOLOCK)
			WHERE do.Guide_Serie = @GuideSerie
			AND do.Guide_Number = @GuideNumber

			UPDATE dop
			SET dop.StatusOrderId = @StatusOrderId
				,dop.DateUpdated = GETDATE()
			FROM DeliveryOrderPiece dop WITH (NOLOCK)
			WHERE dop.GuideSerie = @GuideSerie
			AND dop.GuideNumber = @GuideNumber
			AND dop.NoPiece = @GuidePiece

			IF NOT EXISTS (SELECT 1 FROM DeliveryOrderDetail WITH (NOLOCK) WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber AND StatusOrderId = @StatusOrderId AND RowStatus = 1 )
			BEGIN

				INSERT INTO DeliveryOrderDetail ([Guide_Serie],
				[Guide_Number],
				[StatusOrderId],
				[UserCreated],
				[DateCreated],
				[DateCreatedInSystem],
				[Observations],
				[Temperature_Celsius],
				[PieceId])
					SELECT
						@GuideSerie
					   ,@GuideNumber
					   ,@StatusOrderId
					   ,@Token
					   ,GETDATE()
					   ,GETDATE()
					   ,NULL
					   ,NULL
					   ,NULL
			END

			COMMIT TRANSACTION;

			SELECT
				'1' 'ResultCode'
			   ,'Registros actualizados correctamente.' 'Description'

			SELECT
				CONCAT(do.Guide_Serie, do.Guide_Number) [Guide]
			   ,do.Receiver_Department [Department]
			   ,do.Receiver_Town [Town]
			   ,CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName) [Receiver]
			   ,do.Receiver_Address [Address]
			   ,CONCAT(
				Ret.Returned, ' de ', CAST(do.Pieces_Dry + do.Pieces_Cold AS VARCHAR)) [Pieces]
			   ,Ret.Returned [TotalReturned]
			   ,do.Pieces_Dry + do.Pieces_Cold [Total]
			FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
			INNER JOIN DeliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
					AND do.Guide_Number = trpd.GuideNumber
			OUTER APPLY (SELECT
					COUNT(1) Returned
				FROM DeliveryOrderPiece dop WITH (NOLOCK)
				INNER JOIN StatusOrder so WITH (NOLOCK)
					ON dop.StatusOrderId = so.StatusOrderId
				WHERE dop.GuideSerie = do.Guide_Serie
				AND dop.GuideNumber = do.Guide_Number
				AND so.OrderDescription = 'Devuelto') Ret
			WHERE trpd.TSERoutePreparationHeaderID = @IDTSERoutePreparationHeader
			AND trpd.RowStatus = 1

		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION;

			SELECT
				'-2' 'ResultCode'
			   ,'La Caja/Sobre no existe o no ha sido asignada a la ruta.' 'Description'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END