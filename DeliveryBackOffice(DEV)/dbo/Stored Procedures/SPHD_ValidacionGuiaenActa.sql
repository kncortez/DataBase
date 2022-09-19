-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-9-19>
-- Description:	<SP para validar que una pieza de guía no este en un acta>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ValidacionGuiaenActa]
@Guidepart AS NVARCHAR(20)


AS
BEGIN
	
	SET NOCOUNT ON;
IF(EXISTS(SELECT Top 1 1 FROM DBO.ActDetail a
		  INNER JOIN DBO.ActDetailPiece b
		  ON a.IdActDetail=b.ActDetailId
		  WHERE a.GuideSerie+CAST(a.GuideNumber AS nvarchar(14))+'-'+CAST(b.PieceNumber AS nvarchar) = @Guidepart
		  )
   )
	BEGIN 

		SELECT Result = 1;
	END
ELSE
	BEGIN
		SELECT Result = 0;
	END
END