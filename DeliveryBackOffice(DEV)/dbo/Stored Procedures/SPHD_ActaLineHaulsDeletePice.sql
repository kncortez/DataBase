-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022/08/30>
-- Description:	<SP para anular pieza de un acta de justificación pieza incompleta ruta Linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ActaLineHaulsDeletePice]
@IdAct AS INT,
@GuideNumberPice AS NVARCHAR(20),
@Token AS NVARCHAR (100)
AS
BEGIN
	

	SET NOCOUNT ON;
	DECLARE @IdActDetail AS INT; 


	SELECT 
		 @IdActDetail = AD.IdActDetail 
	From dbo.ActDetail AD WITH (NOLOCK)
		INNER JOIN dbo.ActDetailPiece ADP WITH (NOLOCK)
		ON AD.IdActDetail =ADP.ActDetailId
	WHERE AD.ActId= @IdAct 
		  AND AD.GuideSerie + CAST(AD.GuideNumber AS NVARCHAR)+'-'+ CAST(ADP.PieceNumber AS NVARCHAR) = @GuideNumberPice

	BEGIN TRANSACTION
		BEGIN TRY
		
    

	 UPDATE   [dbo].[ActDetail]     
		 SET RowStatus    = 0,
			 TokenUpdated = @Token,
			 DateUpdated  = GETDATE()
		 WHERE IdActDetail  = @IdActDetail 

	 UPDATE  [dbo].[ActDetailPiece] 
	      SET RowStatus    = 0,
		      TokenUpdated = @Token,
			  DateUpdated  = GETDATE()
	 WHERE ActDetailId =@IdActDetail

		COMMIT TRANSACTION

		SELECT 1 AS RESULT
		
    END TRY
	   BEGIN CATCH
			ROLLBACK
		SELECT 0 AS RESULT
	   END CATCH
    
	
END