
-- =============================================
-- Author:		<Marco,Jiménez>
-- Create date: <2021-09-28>
-- Description:	<Se actualiza el flag Notificated en la tabla ProccessGuideCOD para indicar que ya se envió el correo>
-- =============================================

CREATE PROCEDURE [dbo].[SetNotificatedDepositReportCOD]
    @IdCustomer INT,
    @IdBank INT,
	@SenderEmail VARCHAR(max)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON

	BEGIN TRANSACTION
	BEGIN TRY
	UPDATE dbo.DepositReportCODHeader
	SET Notificated = 1,
	TokenUpdated = 'SYS_SNDR',
	DateUpdated = GETDATE()
	WHERE 
	Bank_Id = @IdBank
	AND Notificated = 0
	AND   (
          @IdCustomer = 0 
          OR Customer_Id = @IdCustomer
      )
    AND   (
          @SenderEmail = '0'
          OR Sender_Email = @SenderEmail
      )
	END TRY
	BEGIN CATCH
		SELECT 
			0 AS 'StatusCode', 
			ERROR_MESSAGE() AS 'Description', 
			CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0
	BEGIN
			SELECT			  
				1 AS 'StatusCode',
				'Flag [Notificated] = 1 , registrado correctamente' AS 'Description', 
				1 AS 'NumTransferID'
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			
			
				SELECT 
					-1 AS 'StatusCode',
					'Error al actualizar registros' AS 'Description', 
					-1 AS 'NumTransferID'
			
			
			ROLLBACK TRANSACTION
		END
	


	 SET NOCOUNT OFF
END

  

