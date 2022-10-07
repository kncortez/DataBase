-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-30>
-- Description:	<SP para valdiar piezas en actas, en proceso de liqudición de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_ValidatePiecesinActUnifiedRoutes ]
@GuideSerie AS NVARCHAR(2),
@GuideNumber AS INT,
@IdAct AS INT

AS
BEGIN

	SET NOCOUNT ON;
    SELECT 
	       a.IdAct   as ActCode,
		   b.GuideSerie,
		   b.GuideNumber, 
		   c.PieceNumber,
		   CASE 
		       WHEN 
		   C.IsDryPiece = 1 THEN 'Pieza Seca'
		   ELSE 'Pieza fría'
		   END PieceType,
		   c.RowStatus
		   
	FROM
	[DeliveryBackOffice].[dbo].[Act] a WITH (NOLOCK)
	INNER  JOIN 
	[DeliveryBackOffice].[dbo].[ActDetail] b WITH (NOLOCK)
	ON a.IdAct = b.ActId
	INNER JOIN 
	[DeliveryBackOffice].[dbo].[ActDetailPiece] C WITH (NOLOCK)
	ON b.IdActDetail = c.ActDetailId
	WHERE b.GuideSerie = @GuideSerie AND
	      b.GuideNumber = @GuideNumber AND
		  a.IdAct = @IdAct AND
		  c.RowStatus = 1
		ORDER BY a.IdAct
	  
END