USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_login]    Script Date: 14/01/2021 5:01:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-15>
-- Description:	<Reset Password Portal Web>
-- =============================================


ALTER PROCEDURE [dbo].[spws_get_ResetPassword]
	-- Add the parameters for the stored procedure here
	@UserName VARCHAR(100),
	@IP VARCHAR(30),
	@IdSystem INT = 1,
	@TokenId NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @StatusRestrinct as nvarchar(50)
	DECLARE @StatusUser as bit
	DECLARE @IdUser as bigint
	DECLARE @ValidaUsuario INT


	-- insertar en tabla temporal posbibles mensajes de error

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;
			select * INTO #errormessage from (SELECT  500 AS IdResult
					,'Cuenta no Existe' AS Message
					,'Invalid' as Id )  as errror

	-- validar que exista la cuenta
		SET @ValidaUsuario = (
								SELECT COUNT(1)
								FROM [dbo].RegisterUser usr
									 INNER JOIN [dbo].RolByUserBySystem rus ON rus.RusIdUser = usr.UsrIdUser
																			   AND rus.RusIdSystem = @IdSystem
									 LEFT JOIN [dbo].UserSystemRestriction res ON res.UstIdUser = rus.RusIdUser
																				  AND res.UstIdSystem = rus.RusIdSystem
								WHERE usr.UsrEmail = @UserName)

		IF @ValidaUsuario > 0 
		BEGIN
			--
			SET @IdUser	= ( SELECT usr.UsrIdUser
								FROM [dbo].RegisterUser usr
									 INNER JOIN [dbo].RolByUserBySystem rus ON rus.RusIdUser = usr.UsrIdUser
																			   AND rus.RusIdSystem = @IdSystem
									 LEFT JOIN [dbo].UserSystemRestriction res ON res.UstIdUser = rus.RusIdUser
																				  AND res.UstIdSystem = rus.RusIdSystem
								WHERE usr.UsrEmail = @UserName  AND usr.UsrRowStatus = 1 )


			INSERT INTO [dbo].[ResetPasswordVerification]
           ([UserId]
           ,[UserName]
           ,[GeneratedToken]
           ,[GeneratedDate]
		   ,[ExpirationDate]
           ,[Status]
           ,[VerificationStatus]
           ,[VerificationDate]
		   ,[ResetCounter]
		   )
			VALUES
			(
			  @IdUser
			 ,@UserName
			 ,@TokenId	
			 ,GETDATE()
			 ,DATEADD(DAY,1,GETDATE())
			 ,1				--TOKEN GENERADO
			 ,0				--VERIFICAR REINICIO  DE CONTRASEÑA (0 - NO VERIFICADA  1- VERIFICADA)
			 ,NULL			--FECHA VERIFICACION REINICIO  DE CONTRASEÑA 
			 ,(SELECT COUNT(ResetCounter) + 1 FROM ResetPasswordVerification WHERE UserName = @UserName)
			)

				set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":200'    +',' 
							+ '"Token":"' + @TokenId	  +'"}' 
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)

		END
		ELSE
		BEGIN
			set @jsonResult =(
			SELECT STUFF(( 
			SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
			+ '"Message":"' + Message + '"}' from #errormessage WHERE Id ='Invalid'		
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
					) 
			)
		END
			

		-- destruir tablas temporales
		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



