-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-11-30>
-- Description:	<SP para asignar courier a usuario interno>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_AssignCouriertoInternalUser]
@IdUser AS INT,
@SenderReceiverId  AS INT,
@Token AS nvarchar(50)


AS
BEGIN

BEGIN TRANSACTION
BEGIN TRY

	IF(EXISTS(SELECT TOP  1 1 from dbo.RegisterUser where UsrIdUser=@IdUser))
	BEGIN

		INSERT INTO [dbo].[SenderReceiverbyUser]
		(
			SenderReceiverId,	
			UserId,	
			RowStatus,
			TokenCreated,
			DateCreated
			
		   ) 
		VALUES
		(
		@SenderReceiverId,
		@IdUser,
		1,
		@Token,
		GETDATE()
		
		)

		 
		SELECT [blnResult] = 1
	END
	ELSE
		BEGIN
	
			 SELECT [blnResult] = 2
	
		END
		COMMIT TRANSACTION
END TRY
BEGIN CATCH
          
	ROLLBACK TRANSACTION
			SELECT [blnResult] = 0
                  
			
END CATCH

END