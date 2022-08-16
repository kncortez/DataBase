-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-08-12>
-- Description:	<Agrega una pieza de una guía con múltiples piezas a una liquidación de linehaul>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_AddGuideToContainerLinehaulSettlementMultiplePieces]
	@LinehaulRouteSettlementContainerId AS INT,
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@GuidePiece INT,
	@UserProcess NVARCHAR(25),
	@TknUser NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

		DECLARE @StatusDescription NVARCHAR(100)

		SELECT
			@StatusDescription = so.OrderDescription
		FROM DeliveryOrder do WITH (NOLOCK)
		INNER JOIN StatusOrder so
			ON so.StatusOrderId = do.StatusOrderId
		WHERE do.Guide_Serie = @GuideSerie
		AND do.Guide_Number = @GuideNumber

		IF @StatusDescription IS NOT NULL
		BEGIN
			
			IF @StatusDescription = 'En Tránsito'
			BEGIN
				IF EXISTS (SELECT
						1
					FROM DeliveryOrderPiece
					WHERE GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie
					AND NoPiece = @GuidePiece)
				BEGIN
					
					DECLARE @linehaulRouteSettlementContainerDetailId INT 

					SELECT 
						 @linehaulRouteSettlementContainerDetailId = IdLinehaulRouteSettlementContainerDetail
					FROM LinehaulRouteSettlementContainerDetail 
					WHERE LinehaulRouteSettlementContainerId = @LinehaulRouteSettlementContainerId
					AND GuideNumber = @GuideNumber
					AND GuideSerie = @GuideSerie

					IF @linehaulRouteSettlementContainerDetailId IS NULL
					BEGIN
						INSERT INTO [dbo].[LinehaulRouteSettlementContainerDetail] ([LinehaulRouteSettlementContainerId]
						, [GuideSerie]
						, [GuideNumber]
						, [PiecesReceived]
						, [PiecesMissing]
						, [GuideReceived]
						, [UserProcess]
						, [RowStatus]
						, [TokenCreated]
						, [DateCreated]
						, [TokenUpdated]
						, [DateUpdated]
						, [IsOpenProcess])
							VALUES (@LinehaulRouteSettlementContainerId, @GuideSerie, @GuideNumber, 0, 0, 0, @UserProcess, 1, @TknUser, GETDATE(), NULL, NULL, 1)

						SET @linehaulRouteSettlementContainerDetailId = @@IDENTITY
					END
					ELSE
					BEGIN
						UPDATE LinehaulRouteSettlementContainerDetail
						SET UserProcess = @UserProcess
						   ,IsOpenProcess = 1
						   ,TokenUpdated = @TknUser
						   ,DateUpdated = GETDATE()
						WHERE IdLinehaulRouteSettlementContainerDetail = @linehaulRouteSettlementContainerDetailId
					END


					DECLARE @linehaulRouteSettlementContainerDetailPieceId INT 

					SELECT 
						 @linehaulRouteSettlementContainerDetailPieceId = IdLinehaulRouteSettlementContainerDetailPiece
					FROM LinehaulRouteSettlementContainerDetailPiece 
					WHERE LinehaulRouteSettlementContainerDetailId = @linehaulRouteSettlementContainerDetailId
					AND PieceNumber = @GuidePiece

					IF @linehaulRouteSettlementContainerDetailPieceId IS NULL
					BEGIN
						INSERT INTO [dbo].[LinehaulRouteSettlementContainerDetailPiece]
							   ([LinehaulRouteSettlementContainerDetailId]
							   ,[PieceNumber]
							   ,[IsDryPiece]
							   ,[ActCode]
							   ,[RowStatus]
							   ,[TokenCreated]
							   ,[DateCreated]
							   ,[TokenUpdated]
							   ,[DateUpdated])
						 VALUES
							   (@linehaulRouteSettlementContainerDetailId
							   ,@GuidePiece
							   ,(SELECT IsDry FROM DeliveryOrderPiece WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber AND NoPiece = @GuidePiece)
							   ,NULL
							   ,1
							   ,@TknUser
							   ,GETDATE()
							   ,NULL
							   ,NULL)
					END
					
					UPDATE DeliveryOrderPiece
					SET [StatusOrderId] = (SELECT
							StatusOrderId
						FROM StatusOrder
						WHERE OrderDescription = 'Arribó a las instalaciones')
					WHERE [GuideSerie] = @GuideSerie
					AND [GuideNumber] = @GuideNumber
					AND [NoPiece] = @GuidePiece

					SELECT
						1 'StatusCode'
					   ,'Successfull added to container ' 'Description'
				END
				ELSE
				BEGIN
					SELECT
						4 'StatusCode'
					   ,'Piece doesn''t exist' 'Description'
				END
			END
			ELSE
			BEGIN
				SELECT
					3 'StatusCode'
					,'Guide not in transit' 'Description'
			END
		END
		ELSE
		BEGIN 
			SELECT
				2 'StatusCode'
			   ,'Not found records' 'Description'
		END

	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT 0 StatusCode,
				ERROR_MESSAGE() Description,
				ERROR_NUMBER() ErrorNumber,
				ERROR_SEVERITY() ErrorSeverity,
				ERROR_STATE() ErrorState,
				ERROR_PROCEDURE() ErrorProcedure,
				ERROR_LINE() ErrorLine
				
	END CATCH
END