-- =============================================
-- Author:		<Edelman>
-- Create date: <2022-11-30>
-- Description:	<SP desasignar Courier de usuario interno>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_DeallocateCourierfromInternalUser]
@IdUser AS INT,
@IdCourier  AS INT,
@Token AS nvarchar(50)
AS
BEGIN
	
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	BEGIN TRY

		UPDATE [dbo].[SenderReceiverByUser]
		SET RowStatus=0
		WHERE UserId =@IdUser AND SenderReceiverId = @IdCourier

		COMMIT TRANSACTION
		SELECT  [blnResult]=1
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT  [blnResult]=0
	END CATCH

END