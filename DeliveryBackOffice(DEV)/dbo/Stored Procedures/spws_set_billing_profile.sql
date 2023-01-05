
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Administracion de perfiles de facturación >
-- ===========================================

--	Cambiar tabla temporal messagelist a variable tipo tabla @TblMessageList
--	Author: Jerson Ochoa - <05-01-2023>

CREATE PROCEDURE [dbo].[spws_set_billing_profile]
	-- Add the parameters for the stored procedure here

	@IdBilling bigINT,
	@IdAccount bigINT ,
	@Name  nvarchar(100) ,
	@Address  nvarchar(200),
	@TaxId  nvarchar(50),
	@Status INT = 1,
	@Token nvarchar(200),
	@IsDefault BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX);
	DECLARE @TblMessageList TABLE(IdResult INT, Message NVARCHAR(150), Id NVARCHAR(50));

	-- insertar en variable tipo tabla posibles mensajes de respuesta
	INSERT INTO @TblMessageList (IdResult, Message, Id) VALUES (200, 'Registro creado correctamente', 'Insert');
	INSERT INTO @TblMessageList (IdResult, Message, Id) VALUES (500, 'Usuario no asociado a cuenta', 'Access');
	INSERT INTO @TblMessageList (IdResult, Message, Id) VALUES (200, 'Registro actualizado correctamente', 'Update');
	INSERT INTO @TblMessageList (IdResult, Message, Id) VALUES (200, 'Registro eliminado', 'Delete');
	INSERT INTO @TblMessageList (IdResult, Message, Id) VALUES (501, 'Ocurrió una excepción', 'Exception');

	BEGIN TRY
		BEGIN TRANSACTION
		-- obtener el id de usuarion con base al token

		declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)

		if EXISTS (SELECT TOP 1 1 FROM RolByUserByAccount WHERE RuaIdAccount = @IdAccount AND RuaIdUser = @IdUser AND RuaRowStatus = 1) -- el usuario tiene acceso  a la cuenta indicada
		begin

			select top 1 blp.BlpIdBilling
			into #Billing
			from dbo.BillingProfile blp
			where blp.BlpIdBilling =  @IdBilling and blp.BlpIdAccount = @IdAccount
		

			if (select count(1) from #Billing) >0 -- verifica que la direccion exista
			begin 
				if @Status =0  -- se infiere que, se va a desctivar el registro
				begin
					-- desactivar registro (borrado logico)
					UPDATE [dbo].[BillingProfile]
					   SET [BlpRowStatus] = @Status
						  ,[BlpTokenUpdated] = @Token
						  ,[BlpDateUpdated] = GETDATE()
						  ,[IsDefault] = 0
					 WHERE [BlpIdBilling] =  @IdBilling

					 set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
						+ '"Message":"' + Message + '"}' from @TblMessageList where Id ='Delete'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)

				end
				else -- se va a actualizar el registro
				begin

				
					IF (@IsDefault = 1)
					BEGIN
						UPDATE BillingProfile
						SET IsDefault = 0
						WHERE BlpRowStatus = 1
						AND BlpIdAccount = @IdAccount
					END

					-- actualizar el registro con los datos proporcionado
					UPDATE [dbo].[BillingProfile]
					   SET [BlpIdAccount] =@IdAccount
						  ,[BlpName] =@Name
						  ,[BlpAddress] = @Address
						  ,[BlpTaxId] = @TaxId
						  ,[BlpTokenUpdated] = @Token
						  ,[BlpDateUpdated] = GETDATE()
						  ,[IsDefault] = @IsDefault
					 WHERE [BlpIdBilling] =  @IdBilling

					 set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
						+ '"Message":"' + Message + '"}' from @TblMessageList where Id ='Update'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)
				end
			end
			else -- la cuenta no existe, entonces se crea
			begin

				IF (@IsDefault = 1)
				BEGIN
					UPDATE BillingProfile
					SET IsDefault = 0
					WHERE BlpRowStatus = 1
					AND BlpIdAccount = @IdAccount
				END
				ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM BillingProfile WHERE BlpIdAccount = @IdAccount AND BlpRowStatus = 1)
				BEGIN
					SET @IsDefault = 1
				END

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
					   ,[BlpDateUpdated]
					   ,[IsDefault])
					 VALUES
						(@IdAccount
						,@Name
						,@Address
						,@TaxId
						,1 -- se crean los registros activos por default 
						,@Token
						,getdate()
						,null
						,null
						,@IsDefault)

				set @IdBilling = SCOPE_IDENTITY()
				set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
						+ '"Message":"' + Message + '"}' from @TblMessageList where Id ='Insert'
		
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
						+ '"Message":"' + Message + '"}' from @TblMessageList where Id ='Access'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)
		end

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
		
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"IdBilling":' + convert(varchar,@IdBilling)    +',' 
						+ '"Message":"' + Message + '"}' from @TblMessageList where Id ='Exception'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
						)

	END CATCH

	-- destruir tablas temporales

		IF OBJECT_ID('tempdb.dbo.#Billing', 'U') IS NOT NULL DROP TABLE #Billing;

	-- retornar resultado en formato json

			select ('[{' + @jsonResult +  ']') jsonResult
END



