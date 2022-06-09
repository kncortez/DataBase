-- =============================================
-- Author:		<Marco Jimenez>
-- Create date: <2021-01-19>
-- Update date: <2021-01-27>
-- Description:	<Confirmar Cuenta Portal Web>
-- =============================================


CREATE PROCEDURE [dbo].[spws_get_EmailTokenValidator]
	@UserName  VARCHAR(200),
	@IdAccount VARCHAR(200),	
	@TokenId   NVARCHAR(MAX),
	@IP        VARCHAR(200),
	@IdSystem  INT = 1
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @jsonResult				NVARCHAR(MAX) 
	DECLARE @StatusRestrinct		NVARCHAR(50)
	DECLARE @StatusUser				BIT
	DECLARE @IdUser					BIGINT
	DECLARE @ValidaUsuario			INT
	DECLARE @ValidarCuenta			INT
	DECLARE @TokensActivos			INT
	DECLARE @MinutosExpToken		INT = 12; --Modificación para expirar el token al superar los 12 minutos de haber sido generado.


	-- insertar en tabla temporal posbibles mensajes de error

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;
			select * INTO #errormessage from (SELECT  500 AS IdResult
					,'Cuenta no Existe' AS Message
					,'Invalid' as Id )  as errror

	-- validar que exista la cuenta y usuario
		SELECT @ValidaUsuario = COUNT(us.UsrIdUser) , 
			   @ValidarCuenta = COUNT(ac.AccIdAccount),
			   @IdUser        = us.UsrIdUser
		FROM RegisterUser us
			 INNER JOIN [dbo].[RolByUserByAccount] rua ON rua.RuaIdUser = us.UsrIdUser
														  AND rua.RuaRowStatus = 1
			 INNER JOIN [dbo].Account ac ON ac.AccIdAccount = rua.RuaIdAccount
											AND ac.AccRowStatus = 1
			 INNER JOIN dbo.Customer c ON c.IdCustomer = ac.IdCustomer
		WHERE ac.AccIdAccount = @IdAccount  OR us.UsrEmail	=  @UserName	
		GROUP BY us.UsrIdUser

		IF @ValidaUsuario > 0 AND @ValidarCuenta > 0
		BEGIN
		SET @TokensActivos = (SELECT  COUNT(TokenId)
		FROM GeneratedTokens 
		WHERE UserId = @IdUser
		AND [VerificationStatus] = 1 )

		IF @TokensActivos > 0
		BEGIN
		UPDATE GeneratedTokens 
		SET VerificationStatus = 0 
		WHERE UserId = @IdUser
		END

			--Guardar Token para Verificación de Correo Electrónico			
			INSERT INTO [dbo].[GeneratedTokens]
           ([UserId]
           ,[UserName]
           ,[GeneratedToken]
           ,[GeneratedDate]
		   ,[ExpirationDate]
           ,[Status]
           ,[VerificationStatus]
           ,[DateOfTokenUse]
		   ,[TokenType]
		   ,[ResetCounter]
		   ,[IP]
		   ,[IdSystem]
		   )
			VALUES
			(
			  @IdUser
			 ,@UserName
			 ,@TokenId	
			 ,GETDATE()
			 ,DATEADD(MI,@MinutosExpToken,GETDATE())
			 ,0				--Estatus TOKEN GENERADO Reset Passworsd (0 - DESCATIVADO  1- ACTIVO)
			 ,1				--Estatus Token Generado para VERIFICAR EMAIL (0 - DESCATIVADO  1- ACTIVO)
			 ,NULL			--FECHA VERIFICACION TOkEN
			 ,'V'			-- R = Reset    /    V=  Validation
			 ,0
			 ,@IP
			 ,@IdSystem
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



