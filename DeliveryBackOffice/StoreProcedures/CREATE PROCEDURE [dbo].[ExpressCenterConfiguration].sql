USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetServiceRecolectUpdateStatus]    Script Date: 17/05/2021 09:47:01 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =====================================================================================
-- Author:		<Marco Jiménez>
-- Create date: <2021-05-17>
-- Description:	<Se crea un SP para que los compañeros de soporte
--				 puedan asociar el código de empleado a una cuenta en el portal web 
--				 junto a su respectivo Express Center>
-- =====================================================================================


--EXEC ExpressCenterConfiguration 7751,'','mako.a.jm@gmail.com',366,'SYS-MJIMENEZ'

CREATE PROCEDURE [dbo].[ExpressCenterConfiguration]
@USR_IdEmployee as BIGINT = 0,
@USR_IdUser as NVARCHAR(50) = '0',
@UserName as VARCHAR(100),
@IdVisitPoint as INT,
@Token AS NVARCHAR(100)
	
AS 
BEGIN
	
	SET NOCOUNT ON;

	DECLARE @IdEmployee   AS BIGINT = 0;
	DECLARE @IdUser       AS NVARCHAR(50) = '0';
	DECLARE @USR_Username AS VARCHAR(50) = '';
	DECLARE @ERROR        AS BIT = 'FALSE';
	DECLARE @IdUser_Portal AS BIGINT = 0;

	BEGIN TRANSACTION
		BEGIN TRY

		 IF @USR_IdEmployee != 0 OR @USR_IdEmployee IS NULL
		 BEGIN
			SELECT 
			@IdUser       = USR_IdUser,
			@USR_Username = USR_Username,
			@IdEmployee   = USR_IdEmployee
			FROM DenariusUser_Dev.dbo.LGN_User WHERE USR_IdEmployee = @USR_IdEmployee
		 END
		 ELSE  IF @USR_IdUser != '0' OR @USR_IdUser != '' 
		 BEGIN
		    SELECT 
			@IdUser       = USR_IdUser,
			@USR_Username = USR_Username,
			@IdEmployee   = USR_IdEmployee
			FROM DenariusUser_Dev.dbo.LGN_User WHERE USR_IdUser = @USR_IdUser
		 END
		 ELSE
		 BEGIN
		 SET @ERROR = 'TRUE' --SE ASIGNA VALOR TRUE DEBIDO A QUE NO SE PUEDE CONTINUAR CON EL PROCESO
		 END
		
		IF @ERROR = 'FALSE'
		BEGIN

		-- SE ASIGNA VALOR FALSE A LA BANDERA DE ERROR
		 SET @ERROR = 'FALSE'

		-- SE OBTIENE EL IDUSER DEL PORTAL 
		SET @IdUser_Portal =  (SELECT ru.UsrIdUser FROM DeliveryBackOffice.dbo.RegisterUser ru WHERE ru.UsrEmail = @UserName and ru.UsrRowStatus = 1)

		--INSERTAR EN TABLA INTERMEDIA PARA ASOCIAR EL CÓDIGO EMPLEADO CON LA CUENTA DE PORTAL WEB
		IF NOT EXISTS (SELECT * FROM DeliveryBackOffice.dbo.InternalUser iu WHERE iu.RegisterUserID = @IdUser_Portal)
			BEGIN
				INSERT INTO DeliveryBackOffice.dbo.InternalUser 
				SELECT @IdUser,@USR_Username,@IdEmployee,ru.UsrIdUser,1, @Token, GETDATE(),NULL, NULL
				FROM DeliveryBackOffice.dbo.RegisterUser ru 
				WHERE ru.UsrEmail = @UserName
		    END

		--SE ASIGNA EL ROL DE EXPRESS CENTER
		UPDATE DeliveryBackOffice.dbo.RolByUserByAccount  SET RuaIdRol = 4 WHERE RuaIdUser = @IdUser_Portal
		
		--SE ASOCIA EL USUARIO A UN EXPRESS CENTER
		--De existir una asociación, se NO se inserta.
		IF NOT EXISTS (SELECT * FROM DeliveryBackOffice.dbo.[VisitPointByUser] WHERE IdVisitPointClient = @IdVisitPoint AND RegisterUserID =  @IdUser_Portal)
			BEGIN
			 INSERT INTO DeliveryBackOffice.dbo.[VisitPointByUser] VALUES (@IdVisitPoint,@IdUser_Portal,1,@Token,GETDATE(),NULL, NULL)
			END

		END

		--SE CONFIGURA EL NOMBRE Y DESCRIPCION DE EXRESS CENTER 
		UPDATE Customer set Name = 'FD EXPRESS CENTER', Description = 'FD EXPRESS CENTER', Abbreviation = 'FD EXPRESS CENTER', IdCustomerType = 2 where IdCustomer = (
		                                    SELECT ac.IdCustomer
                                            FROM RegisterUser us
                                                 INNER JOIN [dbo].Person pe ON pe.PerIdPerson = us.UsrIdPerson
                                                                               AND pe.PerRowStatus = 1
                                                 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
                                                                                              AND rua.RuaRowStatus = 1
                                                 INNER JOIN [dbo].CatRol ro ON ro.RolIdRol = rua.RuaIdRol
                                                 INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
                                                                                AND ac.AccRowStatus = 1
                                                 INNER JOIN [dbo].CatTypeAccount ta ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                                            WHERE us.UsrIdUser = @IdUser_Portal
                                                  AND us.UsrRowStatus = 1 
		)

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			select ERROR_MESSAGE()
		END CATCH;
		IF @@TRANCOUNT > 0 and @ERROR = 'FALSE' BEGIN
		SELECT 200 AS ResultCode, 'Cuenta asociada correctamente' as [Description]
			COMMIT TRANSACTION;
			--- succesfull
		END
		
	

		

END



