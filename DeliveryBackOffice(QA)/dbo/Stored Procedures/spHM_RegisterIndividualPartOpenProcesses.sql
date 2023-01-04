
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-09>
-- Description:	<SP Para registrar Piezas individuales en procesos abiertos>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RegisterIndividualPartOpenProcesses]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@GuideNumberPiece AS INT,
@IdRoute AS INT,
@DateRoutePreparation AS datetime,
@Token AS NVARCHAR(50)


AS
BEGIN

DECLARE @IdDetail AS INT;
DECLARE @Acta AS INT;
DECLARE @GuidePiece AS INT;
DECLARE @PieceType AS INT;
DECLARE @Result AS INT = 0; /* 0 GUÍA SIN PROCESO ABIERTO */

	SET NOCOUNT ON;
	

	SELECT @GuidePiece = ISNULL(GuidePiece,0),
	       @PieceType   = ISNULL(IsDry,0)
		FROM [dbo].[DeliveryOrderPiece] WITH (NOLOCK) 
		WHERE GuideSerie  = @GuideSerie AND
		      GuideNumber = @GuideNumber AND
			  NoPiece = @GuideNumberPiece

	SELECT @IdDetail = RPD.IdRoutePreparationDetail  
	  FROM  [dbo].[RoutePreparation] RP  WITH(NOLOCK)
	        INNER JOIN
	        [dbo].[RoutePreparationDetail] RPD    WITH(NOLOCK)
			ON RP.IdRoutePreparation = RPD.RoutePreparationId
	  WHERE RPD.Guide_Number = @GuideNumber AND
	        RPD.Guide_Serie = @GuideSerie AND
			RP.CatRouteId = @IdRoute AND 
			RP.DateRoutePreparation = CONVERT(VARCHAR,@DateRoutePreparation, 23) AND
			RPD.IsOpenProcess=1
			
	 BEGIN
	  BEGIN TRANSACTION
	  BEGIN TRY		
	

	IF(@GuidePiece IS NOT NULL AND  @GuidePiece != '' AND @IdDetail IS NOT NULL AND @IdDetail !='' )
	 

	  IF (NOT EXISTS(SELECT TOP 1 1 FROM dbo.RoutePreparationDetailPiece
		    WHERE RoutePreparationDetailId=@IdDetail 
			AND PieceNumber =@GuideNumberPiece))
			BEGIN

				 INSERT INTO [dbo].[RoutePreparationDetailPiece]
				 (RoutePreparationDetailId,
				  PieceNumber,
				  PieceType,
				  RowStatus,
				  TokenCreated,
				  DateCreated)
				  VALUES 
				  (
				  @IdDetail,
				  @GuideNumberPiece,
				  @PieceType,
				  0,
				  @Token,
				  Getdate()
				  )

		SET @RESULT = 1; /* PROCESESO EXITOSO */
		
		END 

		COMMIT TRANSACTION
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @RESULT = 2; /* PROCESESO FALLIDO */
				
			END  CATCH
	
	END

		SELECT @Result AS Result;


END