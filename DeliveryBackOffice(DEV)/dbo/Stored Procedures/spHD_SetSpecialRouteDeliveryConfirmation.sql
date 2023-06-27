-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-06-07>
-- Description:	<Marca un entrega como entregada en módulo de entrega de rutas especiales>
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetSpecialRouteDeliveryConfirmation]
	-- Add the parameters for the stored procedure here
	@IDTSERoutePreparationHeader INT,
	@SignatureUrl NVARCHAR(300),
	@Token NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION
	BEGIN TRY
		
		DECLARE @GuidesIterate TABLE (
				GuideSerie NVARCHAR(2)
				,GuideNumber INT
			);
		DECLARE @GuideSerie NVARCHAR(2)
		DECLARE @GuideNumber INT
		DECLARE @DeliveryProofId INT 
		DECLARE @SenderReceiverId INT = ( SELECT
				SenderReceiverId
			FROM TSERoutePreparationHeader WITH (NOLOCK)
			WHERE IDTSERoutePreparationHeader = @IDTSERoutePreparationHeader)

		INSERT INTO @GuidesIterate
		SELECT
			trpd.GuideSerie
			,trpd.GuideNumber
		FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
		WHERE trpd.TSERoutePreparationHeaderID = @IDTSERoutePreparationHeader
		AND trpd.RowStatus = 1

		WHILE EXISTS (SELECT
			TOP 1
				1
			FROM @GuidesIterate)
		BEGIN
			SELECT TOP 1
				@GuideSerie = GuideSerie
				,@GuideNumber = GuideNumber
			FROM @GuidesIterate

			INSERT INTO DeliveryProof (Guide_Serie, Guide_Number, Date_Photo, PathSignature, Path_Dry, Path_Cold)
				VALUES (@GuideSerie, @GuideNumber, GETDATE(), @SignatureUrl, @SignatureUrl, '')
			SET @DeliveryProofId = SCOPE_IDENTITY()

			INSERT INTO DeliveryAttempt (Guide_Serie, Guide_Number, Dry, Cold, Delivered, ID_Courier, User_Created, Date_Created, ID_Proof, Guide_Piece, IsLastMileReturn)
				SELECT
					trpd.GuideSerie
				   ,trpd.GuideNumber
				   ,1
				   ,0
				   ,1
				   ,@SenderReceiverId
				   ,@Token
				   ,GETDATE()
				   ,@DeliveryProofId
				   ,trpdp.PieceNumber
				   ,1
				FROM TSERoutePreparationDetail trpd WITH (NOLOCK)
				INNER JOIN TSERoutePreparationDetailPiece trpdp WITH (NOLOCK)
					ON trpd.IDTSERoutePreparationDetail = trpdp.TSERoutePreparationDetailId
				WHERE trpd.TSERoutePreparationHeaderID = @IDTSERoutePreparationHeader
				AND trpd.GuideSerie = @GuideSerie
				AND trpd.GuideNumber = @GuideNumber
				AND trpdp.RowStatus = 1

			DELETE FROM @GuidesIterate
			WHERE GuideSerie = @GuideSerie
				AND GuideNumber = @GuideNumber;
		END
		
		UPDATE TSERoutePreparationHeader
		SET HasLastDeliveryProccess = 1
		   ,TokenUpdated = @Token
		   ,DateUpdated = GETDATE()
		WHERE IDTSERoutePreparationHeader = @IDTSERoutePreparationHeader
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