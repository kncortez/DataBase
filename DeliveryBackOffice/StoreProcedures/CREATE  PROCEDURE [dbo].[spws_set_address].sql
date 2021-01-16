USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_set_address]    Script Date: 15/01/2021 23:19:41 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Login Portal Web>
-- =============================================


create PROCEDURE [dbo].[spws_set_address]
	-- Add the parameters for the stored procedure here

	@IdAddress bigINT,
	@IdTownship INT ,
	@IdAccount bigINT ,
	@IdCountry  nvarchar(10) = 'GT',
	@FullName  nvarchar(200) ,
	@Address1  nvarchar(250),
	@Address2  nvarchar(250),
	@NirPhone  nvarchar(10) ,
	@Phone  nvarchar(50) ,
	@AdditionalInstructions  nvarchar(250) ,
	@Status INT = 1,
	@Token nvarchar(200)

	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 
	DECLARE @CodeOfReference INT
	DECLARE @IdCustomer INT
	DECLARE @TownshipName NVARCHAR(200)
	DECLARE @Department NVARCHAR(100)
	DECLARE @IdKindOfVPBusiness INT
	DECLARE @IdVisitPointClient INT

		-- insertar en tabla temporal posbibles mensajes de respuesta

		IF OBJECT_ID('tempdb.dbo.#messagelist', 'U') IS NOT NULL DROP TABLE messagelist;
			select * INTO #messagelist 
			from (SELECT  200 AS IdResult
					,'Registro creado correctamente' AS Message
					,'Insert' as Id 
			union
			SELECT  500 AS IdResult
					,'Usuario no asociado a cuenta' AS Message
					,'Access' as Id 
			union
			SELECT  200 AS IdResult
					,'Registro actualizado correctamente' AS Message
					,'Update' as Id 
			union
			SELECT  200 AS IdResult
					,'Registro Eliminado' AS Message
					,'Delete' as Id )  as messagess

		-- obtener el id de usuarion con base al token

		declare @IdUser bigint  = (select t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)

		select * 
		into #Access
		from dbo.RolByUserByAccount  rua
		where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser

	if(select count(*) from #Access)>0 -- el usuario tiene acceso  a la cuenta indicada
	begin

		select uad.UadIdAddress
		into #Address
		from dbo.UserAddress uad
		where uad.UadIdAddress =  @IdAddress and uad.UadIdAccount = @IdAccount
		

		if (select count(*) from #Address) >0 -- verifica que la direccion exista
		begin 
			if @Status =0  -- se infiere que, se va a desctivar el registro
			begin
				-- desactivar registro (borrado logico)
				UPDATE [dbo].[UserAddress]
				   SET [UadRowStatus] = @Status
					  ,[UadTokenUpdated] = @Token
					  ,[UadDateUpdated] = GETDATE()
				 WHERE [UadIdAddress] =  @IdAddress

				 set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Delete'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)

			end
			else -- se va a actualizar el registro
			begin 
				-- actualizar el registro con los datos proporcionado
				UPDATE [dbo].[UserAddress]
				   SET [UadIdTownship] = @IdTownship
					  ,[UadIdAccount] =@IdAccount
					  ,[UadIdCountry] = @IdCountry
					  ,[UadFullName] =@FullName
					  ,[UadAddress1] = @Address1
					  ,[UadAddress2] = @Address2
					  ,[UadNirPhone] = @NirPhone
					  ,[UadPhone] = @Phone
					  ,[UadAdditionalInstructions] = @AdditionalInstructions
					  ,[UadTokenUpdated] = @Token
					  ,[UadDateUpdated] = GETDATE()
				 WHERE [UadIdAddress] =  @IdAddress

				 set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Update'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
			end
		end
		else -- la cuenta no existe, entonces se crea
		begin
			SET @CodeOfReference = (SELECT MAX(CodeOfReference) + 1 FROM VisitPointClient)
			SET @IdCustomer      = (SELECT IdCustomer FROM Account WHERE AccIdAccount = @IdAccount)
			SET @TownshipName    = (SELECT TownshipName FROM Township WHERE IdTownship = @IdTownship)
			SET @Department    = (SELECT ProvinceName FROM Province PV 
								  INNER JOIN Township TS ON PV.IdProvince = TS.IdProvince
								  WHERE TS.IdTownship = @IdTownship)
			SET @IdKindOfVPBusiness = (SELECT IdKindOfVPBusiness  FROM KindOfVPBusiness WHERE Shorthand = 'HUB')
			--Inserta Visit Point en la tabla VisitPointClient
			INSERT INTO [dbo].[VisitPointClient]
           ([CodeOfReference]
           ,[DescriptionOfClient]
           ,[StatusClient]
           ,[CountryId]
           ,[VisitPointId]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[CustomerID]
           ,[Address]
           ,[Zone]
           ,[Town]
           ,[Department]
           ,[Phone]
           ,[ContactName]
           ,[IdKindOfVPClient]
           ,[IdKindOfVPBusiness]
           ,[IdSettlement]
           ,[Email]
           ,[IdTownship])
     VALUES
           (
		    @CodeOfReference
		   ,@FullName
		   ,@Status
		   ,@IdCountry
		   ,NULL
		   ,@Token
		   ,GETDATE()
		   ,NULL
		   ,NULL
		   ,@IdCustomer
		   ,CAST((@Address1 + @Address2) AS NVARCHAR(200))
		   ,NULL
		   ,@TownshipName
		   ,@Department
		   ,@Phone
		   ,NULL
		   ,6
		   ,@IdKindOfVPBusiness
		   ,NULL
		   ,NULL
		   ,@IdTownship
		   )

		   set @IdVisitPointClient = SCOPE_IDENTITY()


			-- insertar nueva direccion

			INSERT INTO [dbo].[UserAddress]
					([UadIdTownship]
					,[UadIdAccount]
					,[UadIdCountry]
					,[UadFullName]
					,[UadAddress1]
					,[UadAddress2]
					,[UadNirPhone]
					,[UadPhone]
					,[UadAdditionalInstructions]
					,[UadRowStatus]
					,[UadTokenCreated]
					,[UadDateCreated]
					,[UadTokenUpdated]
					,[UadDateUpdated]
					,CodeOfReference)
				 VALUES
					(@IdTownship
					,@IdAccount
					,@IdCountry
					,@FullName
					,@Address1
					,@Address2
					,@NirPhone
					,@Phone
					,@AdditionalInstructions
					,1 -- se crean los registros activos por default 
					,@Token
					,getdate()
					,null
					,null
					,@IdVisitPointClient)

			set @IdAddress = SCOPE_IDENTITY()
			set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
					+ '"IdVisitPointClient":' + convert(varchar,@IdVisitPointClient)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Insert'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
		end
	end
	else
	begin
		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdAddress":' + convert(varchar,@IdAddress)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Access'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#Address', 'U') IS NOT NULL DROP TABLE #Address;
		IF OBJECT_ID('tempdb.dbo.#messagelist', 'U') IS NOT NULL DROP TABLE #messagelist;
		IF OBJECT_ID('tempdb.dbo.#Access', 'U') IS NOT NULL DROP TABLE .#Access;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END

