-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-09>
-- Description:	<SP >
-- =============================================
CREATE PROCEDURE [dbo].[spHM_RegisterIndividualPartOpenProcesses]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@GuideNumberPiece AS INT,
@GuideType AS INT,
@Token AS NVARCHAR(50)

AS
BEGIN

DECLARE @IdDetail AS INT;
DECLARE @Acta AS INT;
DECLARE @GuidePiece AS INT;
	SET NOCOUNT ON;
	
	SELECT @GuidePiece = ISNULL(GuidePiece,0)
		FROM [dbo].[DeliveryOrderPiece] WITH (NOLOCK) 
		WHERE GuideSerie  = @GuideSerie AND
		      GuideNumber = @GuideSerie AND
			  NoPiece = @GuideNumberPiece


	SELECT @IdDetail = IdRoutePreparationDetail 
	  FROM [dbo].[RoutePreparationDetail]   WITH (NOLOCK)
	WHERE Guide_Number = @GuideNumber AND
	      Guide_Serie = @GuideSerie
	
	IF(@GuidePiece IS NOT NULL AND  @GuidePiece != '' )
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
	  @GuideType,
	  0,
	  @Token,
	  Getdate()
	  )


	
	END
END