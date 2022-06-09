-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,23-02-2022,>
-- Description:	<Description,SP para desvincular usuario de express center,de usuario Hermes desktop>
-- =============================================


CREATE PROCEDURE [dbo].[sphdDisassociateUserExpressCenterOfUserHermesDesktop] 
	-- Add the parameters for the stored procedure here
	@Email as nvarchar(50),-- correo
	@UserName as varchar(50), -- carlos.cano
	@IdCodeUser as Int, -- 100051
	@Token as varchar(50) --- token de usuario
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF (EXISTS(Select A.IdUser,A.RegisterUserID,A.Username,B.UsrEmail, B.UsrIdUser 
	           From dbo.InternalUser A 
					Inner Join dbo.RegisterUser B
					ON A.RegisterUserID=B.UsrIdUser
			   Where A.IdUser=@IdCodeUser And A.Username=@UserName And B.UsrEmail=@Email))
		BEGIN 
	 
			  UPDATE dbo.InternalUser
					 SET RegisterUserID = NULL, TokenUpdated= @Token, DateUpdated= GETDATE()
			  WHERE IdUser =@IdCodeUser AND Username =@UserName

			  UPDATE dbo.RolByUserBySystem
					SET RusIdUser= Null, RusTokenUpdated= @Token, RusDateUpdated= GETDATE()
			  WHERE   RusIdUser=@IdCodeUser AND RusRowStatus ='true'
			  PRINT 'Desvinculación exitosa…!!'
		END
			ELSE
				BEGIN 
					PRINT 'Sin Usuario Express Center Asociado...!!'
				END
END
