-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2022-02-25>
-- Description:	<Desvincula un usuario de un EXC y lo vincula a otro nuevo usando un usuario nombrado>
-- ==============================================
CREATE Procedure [dbo].[sps_Set_Unlink_Link_UserExc]
	@Token VARCHAR(50),
    @Ficha VARCHAR(10),
    @Email VARCHAR(100),
	--@IdVisitPointAnt INT,
	@IdVisitPointNew INT
    
AS

BEGIN
	DECLARE @RegisterIDAnt VARCHAR(10)
	DECLARE @RegisterID VARCHAR(10)
	DECLARE @UsernameDenarius VARCHAR(50)
	DECLARE @Username VARCHAR(50)
	DECLARE @Station INT
	DECLARE @CodeOfReference INT
	DECLARE @IdVisitPointAnt INT

	SET @UsernameDenarius = (SELECT Username 
								FROM InternalUser 
								WHERE IdUser = @Ficha)
								PRINT(@UsernameDenarius)
	--obtener usuario 
	SET @Username = (SELECT USR_Username 
						FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
						WHERE USR_IdUser = @Ficha 
						AND USR_Username = @UsernameDenarius)

	PRINT(@Username)
	--obterner RegisterUserID a cambiar en InternalUser
	SET @RegisterIDAnt = (SELECT RegisterUserID 
							FROM InternalUser 
							WHERE IdUser= @Ficha 
							AND Username = @Username)

	PRINT(@RegisterIDAnt)
	--Obtener RegisterUserID(UsrIdUser)
	SET @RegisterID = (SELECT UsrIdUser 
							FROM RegisterUser
							WHERE UsrEmail = @Email)
	PRINT (@RegisterID)

	Declare @Fecha Varchar(15)
	SET @Fecha = (SELECT CONVERT(VARCHAR(10), GETDATE(), 103))
	PRINT(@Fecha)

	
			IF(@Username != '' OR @Username != NULL)

			BEGIN TRANSACTION
					BEGIN TRY
				BEGIN
					SET @IdVisitPointAnt = (SELECT IdVisitPointClient 
												FROM DeliveryBackOffice.dbo.VisitPointByUser
												WHERE RegisterUserID = @RegisterIDAnt) --5014

					PRINT(@IdVisitPointAnt)
					UPDATE InternalUser
					SET RegisterUserID = @RegisterID
					WHERE IdUser = @Ficha 
					AND Username = @Username 
					AND RegisterUserID = @RegisterIDAnt

					UPDATE VisitPointByUser
					SET IdVisitPointClient = @IdVisitPointNew,
					RegisterUserID = @RegisterID
					WHERE RegisterUserID = @RegisterIDAnt 
					AND IdVisitPointClient = @IdVisitPointAnt

					EXEC [dbo].[spgConfirmAccount]
					@Mode = 2,
					@DateIni = '2022-02-25',
					@TokenUpdated = @Token

					PRINT(@Token)

					IF (NOT EXISTS(SELECT RusIdUser 
									FROM dbo.RolByUserBySystem 
									WHERE RusIdUser = @RegisterID 
									AND RusIdRol = 5 
									AND RusIdSystem = 1))
						BEGIN
						--Select RusIdUser From dbo.RolByUserBySystem 
						--where RusIdUser = @RegisterID AND RusIdRol = 5 And RusIdSystem = 1--quitar

							SET @CodeOfReference = (SELECT CodeOfReference 
														FROM VisitPointClient 
														WHERE IdVisitPointClient = @IdVisitPointNew)
							SET @Station = (SELECT TOP 1 IdStation 
												FROM CatStation 
												WHERE CodeOfReference = @CodeOfReference 
												AND RowStatus = 1)
							INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem
								VALUES
								(   5,         -- RusIdRol - int
									1,         -- RusIdSystem - int
									@RegisterID,         -- RusIdUser - bigint  --registeruser
									'1',      -- RusRowStatus - bit
									@Token,        -- RusTokenCreated - varchar(50)
									GETDATE(), -- RusDateCreated - datetime
									NULL,      -- RusTokenUpdated - varchar(50)
									NULL       -- RusDateUpdated - datetime
									,@Station) --IdStation tabla CatStation
							

						END

					IF(NOT EXISTS(SELECT RuaIdUser FROM dbo.RolByUserByAccount 
						WHERE RuaIdUser = @RegisterID AND RuaIdRol = 5 AND RuaRowStatus = 1))

						--Select RuaIdUser From dbo.RolByUserByAccount 
						--where RuaIdUser = @RegisterID And RuaIdRol = 5 And RuaRowStatus = 1--quitar

						BEGIN
							UPDATE RolByUserByAccount 
							 SET RuaIdRol = 5
							 WHERE RuaIdUser = @RegisterID
						END


				END

				END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
							PRINT ('POR UN ERROR NO SE PUDO COMPLETAR LA PETICION')
					END CATCH;

					IF @@TRANCOUNT > 0 
					BEGIN
						COMMIT TRANSACTION;
						
						PRINT('ENROLAMIENTO REALIZADA EXITOSAMENTE')
					END


				ELSE
				BEGIN
					PRINT ('USUARIO NO REGISTRADO EN DENARIUS')
				END
END