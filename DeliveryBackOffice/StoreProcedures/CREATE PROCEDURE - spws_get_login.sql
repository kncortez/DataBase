USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sp_get_token_by_user_by_system_by_module_by_region]    Script Date: 30/12/2020 23:39:48 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-12-30>
-- Description:	<Login Portal Web>
-- =============================================


alter PROCEDURE [dbo].[spws_get_login]
	-- Add the parameters for the stored procedure here
	@Username VARCHAR(200),
	@Password VARCHAR(200),
	@IP VARCHAR(30),
	@IdSystem INT = 1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @StatusRestrinct as nvarchar(50)
	DECLARE @StatusUser as bit
	DECLARE @IdUser as bigint

	-- validar usuario y contraseña

		select isnull(res.UstStatus,'N/A') UstStatus , 
			isnull(usr.UsrRowStatus,0) UsrStatus,
			isnull(usr.UsrIdUser,0) IdUser
		into #User
		from [dbo].RegisterUser usr
		inner join [dbo].RolByUserBySystem rus on rus.RusIdUser = usr.UsrIdUser and rus.RusIdSystem = @IdSystem
		left join [dbo].UserSystemRestriction res on res.UstIdSystem = rus.RusIdUser and res.UstIdSystem = rus.RusIdSystem
		where usr.UsrEmail = @UserName
		and usr.UsrLastPassword = @Password

		-- insertar en tabla temporal posbibles mensajes de error

		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;
			select * INTO #errormessage from (SELECT  500 AS IdResult
					,'Usuario o contraseña invalida' AS Message
					,'Invalid' as Id 
			union
			SELECT  500 AS IdResult
					,'Usuario bloqueado' AS Message
					,'Blocked' as Id 
			union
			SELECT  500 AS IdResult
					,'Usuario inactivo' AS Message
					,'Inactive' as Id )  as errror

		if  (select count(*) from #User) >0  -- si encuentra registros quiere decir que hay conicidencia en usuario y contraseña
		begin
			-- validar que el usuario no este bloqueado 

			set @StatusRestrinct = (select  top 1 UPPER(UstStatus) from #User  )
			set @StatusUser = (select  top 1 UsrStatus from #User  )
			set @IdUser = (select  top 1 IdUser from #User  )

			if @StatusRestrinct = 'ACTIVE' --USUARIO sin restricciones
			begin
				if  @StatusUser = 1 -- usuario activo
				begin
					-- GENERAR TOKEN 
					DECLARE @Token as nvarchar(50) = ( select CONVERT(VARCHAR(32), HashBytes('MD5', CONCAT(@UserName,@Password,SYSDATETIME())), 2) as token)

					if(select count(*) from [dbo].TokenLog tkn where tkn.TknIdToken = @Token)=0 --si el token no exite crearlo 
					begin
					INSERT INTO [dbo].[TokenLog]
							   ([TknIdToken]
							   ,[TknIdUser]
							   ,[TknIdSystem]
							   ,[TknIdHub]
							   ,[TknIdModule]
							   ,[TknIdCountry]
							   ,[TknIP]
							   ,[TknRowStatus]
							   ,[TknTokenCreated]
							   ,[TknDateCreated]
							   ,[TknTokenUpdated]
							   ,[TknDateUpdated])
						 VALUES
							   (@Token
							   ,@IdUser
							   ,@IdSystem
							   ,0
							   ,0
							   ,'GT'
							   ,@IP
							   ,1
							   ,@Token
							   ,getdate()
							   ,null
							   ,null)
					end

					DECLARE @JsonModules NVARCHAR(MAX) 
					DECLARE @JsonAccounts NVARCHAR(MAX) 
					-- obtener modulos a los que tiene acceso el usuario logueado
					set @JsonModules =(SELECT STUFF(( 
										select 
										',{"Module":"' + cmo.ModName  + '",' +
										  '"Metadata":"' +cmo.ModMetadata + '",' +
										  '"Rol":"' +rol.RolName+ '"}' 
										 from RegisterUser us
										inner join [dbo].[RolByUserByAccount] rua on rua.RuaIdUser = us.UsrIdUser and rua.RuaRowStatus = 1
										inner join dbo.RolByModuleBySystem rms on  rms.RmsIdRol = rua.RuaIdRol and rms.RmsRowStatus = 1
										inner join [dbo].CatModule cmo on cmo.ModIdModule = rms.RmsIdModule and cmo.ModRowStatus = 1 -- and cmo.ModVisible = 1
										inner join [dbo].CatRol rol on rol.RolIdRol = rms.RmsIdRol
									where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
										  ) )

					set @JsonAccounts = (SELECT STUFF(( 
										select  
										',{"IdAccount":"' +   convert(varchar,ac.AccIdAccount) + '",' +
										  '"AccountName":"' + ac.AccName  + '",' +
										  '"TacName":"' +ta.TacName + '"}'
										from RegisterUser us
											inner join [dbo].Person pe on pe.PerIdPerson = us.UsrIdPerson and pe.PerRowStatus = 1
											inner join [dbo].[RolByUserByAccount] rua on rua.RuaIdUser = us.UsrIdUser and rua.RuaRowStatus =  1
											inner join [dbo].CatRol ro on ro.RolIdRol = rua.RuaIdRol 
											inner join [dbo].Account ac on ac.AccIdAccount =  rua.RuaIdAccount and ac.AccRowStatus = 1
											inner join [dbo].CatTypeAccount ta on ta.TacIdTypeAccount = ac.AccIdTypeAccount 
										where us.UsrEmail = @UserName and us.UsrRowStatus = 1
										FOR XML PATH(''), TYPE
										).value('.', 'varchar(max)'),1,1,''
											  ) )

					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":200'    +',' 
							+ '"Token":"' + @Token  +'",' 
							+ '"Modules":[' + @JsonModules+'],' 
							+ '"Accounts":[' + @JsonAccounts+']' 
							+ '}'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)

				end
				else
				begin
					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message + '"}' from #errormessage where Id ='Inactive'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
				end
			end
			else -- usuario bloqueado
			begin
				if((@StatusRestrinct = 'BLOCKED'))
				begin
					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message + '"}' from #errormessage where Id ='Blocked'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
				end
				else -- culaquier otro estado diferente de "ACTIVE" y "BLOCKED"
				begin 
				set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message + '"}' from #errormessage where Id ='Inactive'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
				end
			end
			
		end
		else -- usuario o contraseña invalido
		begin

		-- incrementar en 1 los intentos fallidos de inicio de sesion 

		update [dbo].UserSystemRestriction set UstRetries = (UstRetries +1 ), UstStatus = (iif(UstRetries +1 >= UstAccessRetries,'BLOCKED','ACTIVE'))
			from [dbo].RegisterUser usr
			left join [dbo].UserSystemRestriction res on res.UstIdSystem = usr.UsrIdUser and res.UstIdSystem =@IdSystem
			where usr.UsrEmail = @UserName

		-- retornar mensaje de error
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message + '"}' from #errormessage where Id ='Invalid'
		
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
		end


		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#User', 'U') IS NOT NULL DROP TABLE #User;
		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



