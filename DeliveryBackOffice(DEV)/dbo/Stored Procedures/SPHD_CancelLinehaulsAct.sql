-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2022-08-17>
-- Description:	<Description, SP para anulación de actas, detalle y piezas (borrado logico)>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_CancelLinehaulsAct] 
	-- Add the parameters for the stored procedure here
@IdAct AS INT,
@Token AS NVARCHAR(100)
	
AS
BEGIN
	
	SET NOCOUNT ON;

	BEGIN TRANSACTION
		BEGIN TRY

     UPDATE  [dbo].[Act]   
	     SET RowStatus    = 0,
		     TokenUpdated = @Token,
			 DateUpdated  = GETDATE()
		 WHERE IdAct  = @IdAct

	 UPDATE   [dbo].[ActDetail]     
		 SET RowStatus    = 0,
			 TokenUpdated = @Token,
			 DateUpdated  = GETDATE()
		 WHERE ActId  = @IdAct

	 UPDATE  [dbo].[ActDetailPiece] 
	      SET RowStatus    = 0,
		      TokenUpdated = @Token,
			  DateUpdated  = GETDATE()
	 WHERE ActDetailId = (SELECT TOP 1 IdActDetail FROM dbo.ActDetail WHERE ActId= @IdAct)

		COMMIT TRANSACTION

		SELECT 1 AS RESULT
		
    END TRY
	   BEGIN CATCH
			ROLLBACK
		SELECT 0 AS RESULT
	   END CATCH

END