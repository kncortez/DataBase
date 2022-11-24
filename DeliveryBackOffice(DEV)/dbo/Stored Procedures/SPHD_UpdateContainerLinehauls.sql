-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-11-16>
-- Description:	<SP Update de contenedor ruta linehauls>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_UpdateContainerLinehauls]
@IdContainer AS INT,
@Token AS NVARCHAR(50),
@RowStatus AS BIT

AS
BEGIN
	
	DECLARE @Result AS INT=0;

	BEGIN TRANSACTION
	BEGIN TRY

	    UPDATE [DeliveryBackOffice].[dbo].[Container] 
		SET 
		    RowStatus = @RowStatus,
			TokenUpdated= @Token,
            DateCreated = GETDATE()
		WHERE IdContainer = @IdContainer

		COMMIT TRANSACTION
		SELECT @Result = 1
	END TRY
	BEGIN CATCH

		ROLLBACK
		SELECT @Result = 2
	END CATCH
   
	SELECT @Result as Result
	

END