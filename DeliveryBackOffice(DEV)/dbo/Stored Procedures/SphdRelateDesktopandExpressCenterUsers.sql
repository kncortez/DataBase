-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,04-02-2022,>
-- Description:	<Description,Asociar Usuarios de Hermes Desktop a express center,>
-- =============================================


-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,24-02-2022,>
-- Description:	<Description,Insert en la tabla InternalUserLog y filtro de nuevo campo idRegisteruser>
-- =============================================

-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,28-02-2022,>
-- Description:	<Description,Filtro para no permitir asociación de usuario estandar>
-- =============================================


-- =============================================
-- Author:		<Author,Edelman Vásquez,Name>
-- Create date: <Create Date,22-03-2022,>
-- Description:	<Description, No modificar tabla: dbo.RolByUserBySystem>
-- =============================================

 CREATE PROCEDURE [dbo].[SphdRelateDesktopandExpressCenterUsers] 
	-- Add the parameters for the stored procedure here
	@Email as nvarchar(50),-- correo
	@UserName as varchar(50), -- carlos.cano
	@IdCodeUser as Int, -- 100051
	@Token as varchar(50) --- token de usuario
AS
BEGIN	

	SET NOCOUNT ON;
	DECLARE @IdUsr as Int -- Id Usuar Desktop
	DECLARE @RuaIdRol as Int -- Rol of user
	DECLARE @TypeUser as Varchar(50) -- nombre del rol del usuario
--------- Express Center -----------------------------------
	SELECT @IdUsr = RU.UsrIdUser 
		  FROM dbo.RegisterUser RU
	          WHERE UsrEmail = @Email
	
	IF (@IdUsr IS NOT NULL OR @IdUsr !='')
	BEGIN
			SELECT @RuaIdRol = RuaIdRol 
				FROM dbo.RolByUserByAccount
			WHERE RuaIdUser = @IdUsr		 
				IF (@RuaIdRol IS NULL)
				BEGIN
					PRINT 'USUARIO EXPRESS CENTER NO TIENE ROLL ASIGNADO...!!'
				END
					ELSE
			  			BEGIN
						------------- Valida que usuario no sea tipo estandar
						SELECT @TypeUser=RolName
						       FROM dbo.CatRol
								    WHERE RolIdRol=@RuaIdRol
								
						IF (@TypeUser='Estandar')
						BEGIN
						             Print'Usuario Tipo Estandar no esta permitido asociar...!!'
						 END
							ELSE
							BEGIN
								DECLARE @RegisterUserID as Int
								--------------- Hermes Desktop -----------------------------
								SELECT @RegisterUserID = RegisterUserID FROM dbo.InternalUser
											WHERE IdUser =@IdCodeUser AND Username =@UserName
                               
										IF( NOT EXISTS(
										Select Top 1
											a.RegisterUserID
											From dbo.InternalUser a
											INNER JOIN  dbo.RegisterUser b
											On a.RegisterUserID=b.UsrIdUser
											Where a.IdUser=@IdCodeUser and  a.Username=@UserName
										
										))
										BEGIN 

												IF ( NOT  EXISTS(									   
															Select 
															a.RegisterUserID
															From dbo.InternalUser a
															INNER JOIN  dbo.RegisterUser b
															On a.RegisterUserID=b.UsrIdUser
															Where b.UsrEmail=@Email
															)
										       )
											   BEGIN

													UPDATE dbo.InternalUser
														SET RegisterUserID = @IdUsr, TokenUpdated= @Token, DateUpdated= GETDATE()
													WHERE IdUser =@IdCodeUser AND Username =@UserName

													UPDATE dbo.RolByUserBySystem
														SET RusIdUser= @IdUsr, RusTokenUpdated= @Token, RusDateUpdated= GETDATE()
													WHERE   RusIdUser=@IdCodeUser AND RusRowStatus ='true'

													Insert Into [dbo].[InternalUserLog]  (IdUser,UserName,DateUpdate,UserUpdate,IdUserNew,UserRegisterID,UsrIdUser,UsrEmail)
																				   Values(@IdCodeUser,@UserName,Getdate(),@Token,@IdUsr,@RegisterUserID,@IdUsr,@Email)
													PRINT 'USUARIO BACK OFFICE ASOCIADO CORRECTAMENTE...!!'	
								              END
											   ELSE
													BEGIN 
								   						PRINT 'USUARIO EXPRESS CENTER YA TIENE ASOCIADO USUARIO BACK OFFICE...!!'+ char(13) +'Rol :' +@TypeUser
													END

										END
										   ELSE
										   BEGIN 
								   				PRINT 'USUARIO BACK OFFICE YA TIENE EXPRESS CENTER ASOCIADO...!!'
										   END
								
					END
            END
		END
		ELSE 
		BEGIN
			PRINT 'USURIO NO EXISTE EN SISTEMA...!! '
		END	
	END

