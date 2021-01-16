USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Administracion de perfiles de facturación >
-- ===========================================


CREATE PROCEDURE [dbo].[spws_set_billing_profile]
	-- Add the parameters for the stored procedure here

	@IdBilling bigINT,
	@IdAccount bigINT ,
	@Name  nvarchar(100) ,
	@Address  nvarchar(200),
	@TaxId  nvarchar(50),
	@Status INT = 1,
	@Token nvarchar(200)

	
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

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

		declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)

		select * 
		into #Access
		from dbo.RolByUserByAccount  rua
		where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser

	if(select count(*) from #Access)>0 -- el usuario tiene acceso  a la cuenta indicada
	begin

		select top 1 blp.BlpIdBilling
		into #Billing
		from dbo.BillingProfile blp
		where blp.BlpIdBilling =  @IdBilling and blp.BlpIdAccount = @IdAccount
		

		if (select count(*) from #Billing) >0 -- verifica que la direccion exista
		begin 
			if @Status =0  -- se infiere que, se va a desctivar el registro
			begin
				-- desactivar registro (borrado logico)
				UPDATE [dbo].[BillingProfile]
				   SET [BlpRowStatus] = @Status
					  ,[BlpTokenUpdated] = @Token
					  ,[BlpDateUpdated] = GETDATE()
				 WHERE [BlpIdBilling] =  @IdBilling

				 set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Delete'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)

			end
			else -- se va a actualizar el registro
			begin 
				-- actualizar el registro con los datos proporcionado
				UPDATE [dbo].[BillingProfile]
				   SET [BlpIdAccount] =@IdAccount
					  ,[BlpName] =@Name
					  ,[BlpAddress] = @Address
					  ,[BlpTaxId] = @TaxId
					  ,[BlpTokenUpdated] = @Token
					  ,[BlpDateUpdated] = GETDATE()
				 WHERE [BlpIdBilling] =  @IdBilling

				 set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Update'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
			end
		end
		else -- la cuenta no existe, entonces se crea
		begin
			-- insertar nueva direccion

			INSERT INTO [dbo].[BillingProfile]
				   ([BlpIdAccount]
				   ,[BlpName]
				   ,[BlpAddress]
				   ,[BlpTaxId]
				   ,[BlpRowStatus]
				   ,[BlpTokenCreated]
				   ,[BlpDateCreated]
				   ,[BlpTokenUpdated]
				   ,[BlpDateUpdated])
				 VALUES
					(@IdAccount
					,@Name
					,@Address
					,@TaxId
					,1 -- se crean los registros activos por default 
					,@Token
					,getdate()
					,null
					,null)

			set @IdBilling = SCOPE_IDENTITY()
			set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
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
					+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
					+ '"Message":"' + Message + '"}' from #messagelist where Id ='Access'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#Billing', 'U') IS NOT NULL DROP TABLE #Billing;
		IF OBJECT_ID('tempdb.dbo.#messagelist', 'U') IS NOT NULL DROP TABLE #messagelist;
		IF OBJECT_ID('tempdb.dbo.#Access', 'U') IS NOT NULL DROP TABLE .#Access;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



