-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2023-02-17>
-- Description:	<Marcar guías para inspección>
-- =============================================
CREATE PROCEDURE [dbo].[SetGuideAbandoned]
	@IdUser INT,
	@Username VARCHAR(50),
	@Password VARCHAR(200),
	@NameSystem VARCHAR(100),
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@Token NVARCHAR(50),
	@SenderReceiverId INT
AS
BEGIN
	BEGIN  TRANSACTION
	BEGIN TRY
		DECLARE @StatusOrderId TINYINT
		DECLARE @Exists BIT = 0
		DECLARE @IsValidPassword BIT = 0
		DECLARE @IsValidRol BIT = 0

		SELECT
			@Exists = 1
		   ,@IsValidPassword =
			CASE
				WHEN u.USR_Password = @Password THEN 1
				ELSE 0
			END
		   ,@IsValidRol =
			CASE
				WHEN EXISTS (SELECT
								1
							FROM InternalUser iu
							INNER JOIN RegisterUser ru
								ON iu.RegisterUserID = ru.UsrIdUser
								AND ru.UsrRowStatus = 1
							INNER JOIN RolByUserBySystem rus
								ON ru.UsrIdUser = rus.RusIdUser
							INNER JOIN CatRol cr
								ON rus.RusIdRol = cr.RolIdRol
							INNER JOIN CatSystem cs
								ON rus.RusIdSystem = cs.SysIdSystem
							WHERE iu.IdUser = @IdUser
							AND iu.Username = @Username
							AND iu.RowStatus = 1
							AND rus.RusRowStatus = 1
							AND cr.RolName = 'Supervisor') THEN 1
				ELSE 0
			END
		FROM DenariusUser_Dev.dbo.LGN_User u
		WHERE u.USR_IdUser = @IdUser
		AND u.USR_Username = @Username

		IF (@Exists = 1)
		BEGIN

			IF (@IsValidPassword = 1)
			BEGIN

				IF (@IsValidRol = 1)
				BEGIN

					UPDATE
						[URSDP]
					SET
						[URSDP].[RowStatus] = 1
						,[URSDP].[TokenUpdated] = @Token
						,[URSDP].[DateUpdated] = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RouteAssigment] RA  WITH(NOLOCK) 
						INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS  WITH(NOLOCK) 
							ON
								[URS].[RouteAssignmentId] = [RA].[IdRouteAssigment]
								AND
								[URS].[RowStatus] = 1
						INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD  WITH(NOLOCK) 
							ON
								[URSD].[UnifiedRouteSettlementId] = [URS].[IdUnifiedRouteSettlement]
						INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDP  WITH(NOLOCK) 
							ON
								[URSDP].[UnifiedRouteSettlementDetailId] = [URSD].[IdUnifiedRouteSettlementDetail]
						OUTER APPLY
						(
							SELECT 
								TOP (1) 
									[URSDaux].[IdUnifiedRouteSettlementDetail]
							FROM 
								[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDaux  WITH(NOLOCK) 
							WHERE
								[URSDaux].[UnifiedRouteSettlementId] = [URS].[IdUnifiedRouteSettlement]
								AND
								[URSDaux].[GuideSerie] = @GuideSerie
								AND
								[URSDaux].[GuideNumber] = @GuideNumber
							ORDER BY
								[URSDaux].[DateCreated] DESC
						) URSDaux
					WHERE
						-- Rutas del courier activo
						[RA].[IdCurrierMan] = @SenderReceiverId
						AND
						[RA].[DateOfRoute] = CAST(GETDATE() AS DATE)
						-- Guía
						AND
						[URSD].[GuideSerie] = @GuideSerie
						AND
						[URSD].[GuideNumber] = @GuideNumber
						-- Último ingreso de guía
						AND
						[URSD].[IdUnifiedRouteSettlementDetail] = [URSDaux].[IdUnifiedRouteSettlementDetail]

					UPDATE
						[URSD]
					SET
						[URSD].[RowStatus] = 1
						,[URSD].[TokenUpdated] = @Token
						,[URSD].[DateUpdated] = GETDATE()
					FROM
						[DeliveryBackOffice].[dbo].[RouteAssigment] RA  WITH(NOLOCK) 
						INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS  WITH(NOLOCK) 
							ON
								[URS].[RouteAssignmentId] = [RA].[IdRouteAssigment]
								AND
								[URS].[RowStatus] = 1
						INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD  WITH(NOLOCK) 
							ON
								[URSD].[UnifiedRouteSettlementId] = [URS].[IdUnifiedRouteSettlement]
						OUTER APPLY
						(
							SELECT 
								TOP (1) 
									[URSDaux].[IdUnifiedRouteSettlementDetail]
							FROM 
								[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDaux  WITH(NOLOCK) 
							WHERE
								[URSDaux].[UnifiedRouteSettlementId] = [URS].[IdUnifiedRouteSettlement]
								AND
								[URSDaux].[GuideSerie] = @GuideSerie
								AND
								[URSDaux].[GuideNumber] = @GuideNumber
							ORDER BY
								[URSDaux].[DateCreated] DESC
						) URSDaux
					WHERE
						-- Rutas del courier activo
						[RA].[IdCurrierMan] = @SenderReceiverId
						AND
						[RA].[DateOfRoute] = CAST(GETDATE() AS DATE)
						-- Guía
						AND
						[URSD].[GuideSerie] = @GuideSerie
						AND
						[URSD].[GuideNumber] = @GuideNumber
						-- Último ingreso de guía
						AND
						[URSD].[IdUnifiedRouteSettlementDetail] = [URSDaux].[IdUnifiedRouteSettlementDetail]

					SELECT
						200 AS 'StatusCode'
					   ,'Credenciales correctas.' AS 'Description'

					COMMIT TRANSACTION
				END
				ELSE 
				BEGIN
					ROLLBACK TRANSACTION

					SELECT
						403 AS 'StatusCode'
					   ,'El usuario ingresado no posee los permisos necesarios.' AS 'Description'

				END
			END
			ELSE 
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					401 AS 'StatusCode'
				   ,'El usuario o la contraseña no coinciden, por favor revise la información.' AS 'Description'

			END
		END
		ELSE 
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				404 AS 'StatusCode'
			   ,'El usuario ingresado no ha sido encontrado.' AS 'Description'

		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		
		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
	END CATCH
END