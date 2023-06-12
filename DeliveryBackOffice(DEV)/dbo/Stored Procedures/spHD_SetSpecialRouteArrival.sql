-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-05-30>
-- Description:	<Marca un marchamo como arribo en módulo del detalle ingreso de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetSpecialRouteArrival]
	-- Add the parameters for the stored procedure here
	@CustomMark NVARCHAR(50),
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @StatusOrderId TINYINT = ( SELECT
				StatusOrderId
			FROM StatusOrder
			WHERE OrderDescription = 'Arribó a las instalaciones')

		UPDATE do
		SET do.StatusOrderId = @StatusOrderId
		FROM DeliveryOrder do WITH (NOLOCK)
		INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
			ON do.Guide_Serie = trpd.GuideSerie
			AND do.Guide_Number = trpd.GuideNumber
		INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
			ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
			AND trph.TSECustomsMark = @CustomMark
		WHERE trpd.RowStatus = 1
		AND trph.RowStatus = 1
		AND (do.Pieces_Dry + do.Pieces_Cold) > 1

		UPDATE dop
		SET dop.StatusOrderId = @StatusOrderId
		FROM DeliveryOrderPiece dop WITH (NOLOCK)
		INNER JOIN DeliveryOrder do WITH (NOLOCK)
			ON do.Guide_Serie = dop.GuideSerie
			AND do.Guide_Number = dop.GuideNumber
		INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
			ON do.Guide_Serie = trpd.GuideSerie
			AND do.Guide_Number = trpd.GuideNumber
		INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
			ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
			AND trph.TSECustomsMark = @CustomMark
		WHERE trpd.RowStatus = 1
		AND trph.RowStatus = 1
		AND (do.Pieces_Dry + do.Pieces_Cold) > 1

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
				trpd.GuideSerie
			   ,trpd.GuideNumber
			   ,@StatusOrderId
			   ,@Token
			   ,GETDATE()
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,NULL
			FROM DeliveryOrder do WITH (NOLOCK)
			INNER JOIN TSERoutePreparationDetail trpd WITH (NOLOCK)
				ON do.Guide_Serie = trpd.GuideSerie
				AND do.Guide_Number = trpd.GuideNumber
			INNER JOIN TSERoutePreparationHeader trph WITH (NOLOCK)
				ON trpd.TSERoutePreparationHeaderID = trph.IDTSERoutePreparationHeader
					AND trph.TSECustomsMark = @CustomMark
			WHERE trpd.RowStatus = 1
			AND trph.RowStatus = 1
			AND (do.Pieces_Dry + do.Pieces_Cold) > 1

		UPDATE TSERoutePreparationHeader
		SET HasFirstArrivalProcess = 1
		   ,TokenUpdated = @Token
		   ,DateUpdated = GETDATE()
		WHERE TSECustomsMark = @CustomMark
		AND RowStatus = 1

		COMMIT TRANSACTION;

		SELECT
			'1' 'ResultCode'
		   ,'Registros actualizados correctamente.' 'Description'

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION;

		SELECT
			'-1' 'ResultCode'
		   ,ERROR_MESSAGE() 'Description'

	END CATCH
END