-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-08-05>
-- Description:	<Devuelve la opcion y precio shipping>
-- =============================================
CREATE PROCEDURE [dbo].[spws_set_customer_depot]	
		    @CodApp as nvarchar(50) = 'SILVBECOM120820200901',
			@IdSeller as varchar(100)  = '', --Seller
			@IdSource as bigint = 0, --Settlement			
			@CodeOfReference as varchar(100) = '', --Id Depot
			@DescriptionOfClient as varchar(100)='',
			@DescriptionOfDepot as varchar(100)='',
			@Address as nvarchar(200) = '',
			@Phone as nvarchar(50) = '',
			@ContactName as nvarchar(200) = '',
			@Status as bit = 1,
			@Country as nvarchar(50) = 'GT',
			@Email  as nvarchar(100) = 'test@corparative.com'
AS
BEGIN				
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	set @IdSeller =(select RTRIM(LTRIM(@IdSeller)))
	DECLARE @jsonResult NVARCHAR(MAX)
	DECLARE @IdentityDepot as bigint =-1
	DECLARE @KindBussiness as int = 9

set @KindBussiness = (SELECT Top 1 IdKindOfVPBusiness
  FROM [DeliveryBackOffice].[dbo].[KindOfVPBusiness]
  where ShortHand= 'BOD')


--se identifica el Ecommerce con base al CodeApp enviado 
		select  IdEcommerce,
				EcomerceName,	
				IdCountry,	
				UserKey,	
				Passkey,	
				SecretKey,	
				EcommerceStatus,	
				IdCustomer
		into #Ecommrce
		from DeliveryBackOffice.[dbo].[Ecommerce] eco 
		where eco.UserKey = @CodApp 
		and eco.EcommerceStatus = 'TRUE'

		
		declare @IdEcommerce as int = -1		
		set @IdEcommerce  = (select top 1 ec.IdEcommerce from #Ecommrce ec where ec.EcommerceStatus = 'TRUE')
	if @IdSeller is not null or @IdSeller != '' begin
		if @IdEcommerce is null or @IdEcommerce = -1
		BEGIN
			IF OBJECT_ID('tempdb.dbo.#respuesta', 'U') IS NOT NULL DROP TABLE #respuesta;
			SELECT  500 AS IdResult
					,'Ecommerce inexistente' AS Message
					,'Ecommerce' as type 
			INTO #respuesta

			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message + '"}' from #respuesta where type ='Ecommerce'
		
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
		END
		else 
		begin
			-- verificar si exite el seller
			declare @CustomerID as int = -1	
			set @CustomerID  = (select top 1 ec.IdCustomer from #Ecommrce ec where ec.EcommerceStatus = 'TRUE')		

			select  
			sel.IdSeller
			,sel.IdCustomer
			,sel.Name
			,sel.CodeOfReference
			into #seller
			from DeliveryBackOffice.dbo.Seller sel where sel.IdCustomer = @CustomerID  and sel.CodeOfReference = @IdSeller


			declare @identySeller as int = -1
			set @identySeller = ( select top 1 s.IdSeller  from #seller s)

			if @identySeller is null or @identySeller = -1 -- si el seller no exite insertar
			begin
			
				if @DescriptionOfClient is null or @DescriptionOfClient = ''
				begin
					IF OBJECT_ID('tempdb.dbo.#respuesta2', 'U') IS NOT NULL DROP TABLE #respuesta2;
					SELECT  500 AS IdResult
						,'El código de cliente no existe por favor ingrese nombre de cliente para poder crearlo' AS Message
						,'SellerName' as type 
					INTO #respuesta2

					set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"Message":"' + Message + '"}' from #respuesta2 where type ='SellerName'
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
				end
				else
				begin
					insert into DeliveryBackOffice.dbo.Seller 
					 ([IdCustomer]
					   ,[Name]
					   ,[CodeOfReference]
					   ,[IsPrincipal]
					   ,[Status]
					   ,[DateCreated])
					values (
					@CustomerID
					,@DescriptionOfClient
					,@IdSeller --CodeOfReference
					,1 --IsPrincipal
					,1 --Status
					,getdate()
					)
					set @identySeller = SCOPE_IDENTITY();
				end
			end
			
		if @identySeller>0 begin	
			declare @IdDepot as int = -1
			set @IdDepot = (select sdp.IdSellerDepot from DeliveryBackOffice.dbo.SellerDepot sdp where sdp.CodeOfReference = @CodeOfReference and sdp.IdSeller = @identySeller)
			if @IdDepot is  null or @IdDepot =  -1 -- no existe bodega
			begin
			-- crear bodega
			print @identySeller
				declare @mensajedepot varchar(100) = ''
				if @CodeOfReference=''begin
					set @mensajedepot += 'El campo codigo de bodega es obligatorio' end
				if @IdSource<=0 begin
					set @mensajedepot += 'No ingresó un visit point válido.' end
				if @Address=''begin
					set @mensajedepot += 'El campo dirección es obligatorio' end
				if @mensajedepot='' -- no hay error por lo tanto insertar depot
				begin

				-- generar CodeOfReference para VisitPointClient
				declare @CodeOfReferenceVP  as bigint =-1
				set @CodeOfReferenceVP = (select max(isnull(CodeOfReference,0)) +1 from DeliveryBackOffice.dbo.VisitPointClient)

				-- obtener el IdTowship y el IdProvince con base a IdSettlement
				IF OBJECT_ID('tempdb.dbo.#SettlementData', 'U') IS NOT NULL DROP TABLE #SettlementData;
				select IdTownship, IdProvince,IdSettlement 
					into #SettlementData
				from DeliveryBackOffice.dbo.Settlement
				where IdSettlement = @IdSource

				declare @IdTowship  as int = -1
				declare @IdProvince as int = -1

				set @IdTowship = (select top 1 IdTownship from #SettlementData where IdSettlement =@IdSource)
				set @IdProvince = (select top 1 IdProvince from #SettlementData where IdSettlement =@IdSource)


				-- insertar visit point 
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
			   ,[Email])
				VALUES
				   (@CodeOfReferenceVP
				   ,@DescriptionOfDepot
				   ,1 -- crear registros siempre activos
				   ,@Country
				   ,NULL
				   ,@CodApp
				   , GETDATE()
				   ,NULL
				   ,NULL
				   ,@CustomerID
				   ,@Address
				   ,0
				   ,@IdTowship
				   ,@IdProvince
				   , @Phone
				   ,@ContactName
				   ,5 -- ApiClient
				   ,@KindBussiness -- BODEGA
				   , @IdSource
				   ,@Email)

				 
				   -- crear bodega
					insert into DeliveryBackOffice.dbo.SellerDepot 
					([IdSeller]
					   ,[IdSettlement]
					   ,[CodeOfReference]
					   ,[DescriptionOfClient]
					   ,[Address]
					   ,[Phone]
					   ,[ContactName]
					   ,[Status]
					   ,[DateCreated]
					   ,[DateUpdated]
					   ,[IdVisitPointClient])
					values(
					@identySeller
					,@IdSource
					,@CodeOfReference
					,@DescriptionOfDepot
					,@Address
					,@Phone
					,@ContactName
					,1 -- crear registros siempre activos
					,GETDATE()
					,null
					,@CodeOfReferenceVP
					)

					set @IdDepot = SCOPE_IDENTITY();

					IF OBJECT_ID('tempdb.dbo.#suceess', 'U') IS NOT NULL DROP TABLE #suceess;
					SELECT  200 AS IdResult
							,'Bodega creada correctamente' AS Message
							,'Success' as type 
							,convert(varchar,@IdDepot) as Depot
					INTO #suceess

					
					set @jsonResult =(
						SELECT STUFF(( 
						SELECT '""IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"Message":"' + Message 
						+ '","IdWarehouse":"' + Depot + '"}' from #suceess where type ='Success'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
					)
				end
				else -- hay errores de campos obligatorios
				begin
					IF OBJECT_ID('tempdb.dbo.#errordepot', 'U') IS NOT NULL DROP TABLE #errordepot;
					SELECT  500 AS IdResult
							,@mensajedepot AS Message
							,'Depot' as type 
					INTO #errordepot

					set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"Message":"' + Message + '"}' from #errordepot where type ='Depot'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
					)

				end

			end
			else
			begin
				update DeliveryBackOffice.dbo.SellerDepot 
				set IdSettlement = @IdSource
				,CodeOfReference = @CodeOfReference
				,DescriptionOfClient = @DescriptionOfDepot
				,Address = @Address
				,Phone = @Phone
				,ContactName = @ContactName
				,Status = @Status
				,DateUpdated = GETDATE()
				where IdSellerDepot = @IdDepot
				if @Status = 1 
				
				begin
					IF OBJECT_ID('tempdb.dbo.#updatedepot', 'U') IS NOT NULL DROP TABLE #updatedepot;
						SELECT  200 AS IdResult
								,'Bodega actualizada Correctamente' AS Message
								,convert(varchar,@IdDepot) as Depot
								,'Update' as type 
						INTO #updatedepot

						set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"Message":"' + Message 
						+ '","IdWarehouse":"' + Depot + '"}' from #updatedepot where type ='Update'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
					)
				end
				else
				begin
				IF OBJECT_ID('tempdb.dbo.#deletedepot', 'U') IS NOT NULL DROP TABLE #deletedepot;
					SELECT  200 AS IdResult
								,'Bodega eliminada correctamente' AS Message
								,'Delete' as type 
						INTO #deletedepot

						set @jsonResult =(
						SELECT STUFF(( 
						SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
						+ '"Message":"' + Message + '"}' from #deletedepot where type ='Delete'
		
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
							  ) 
					)
				end

					
			end
			end
		end
	end
	else begin
		IF OBJECT_ID('tempdb.dbo.#erroseller', 'U') IS NOT NULL DROP TABLE #erroseller;
			SELECT  500 AS IdResult
					,'El idSeller es un campo obligatorio' AS Message
					,'Seller' as type 
			INTO #erroseller

			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
				+ '"Message":"' + Message + '"}' from #erroseller where type ='Seller'
		
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
	end
		
		IF OBJECT_ID('tempdb.dbo.#erroseller', 'U') IS NOT NULL DROP TABLE #erroseller;
		IF OBJECT_ID('tempdb.dbo.#updatedepot', 'U') IS NOT NULL DROP TABLE #updatedepot;
		IF OBJECT_ID('tempdb.dbo.#errordepot', 'U') IS NOT NULL DROP TABLE #errordepot;
		IF OBJECT_ID('tempdb.dbo.#suceess', 'U') IS NOT NULL DROP TABLE #suceess;
		IF OBJECT_ID('tempdb.dbo.#respuesta', 'U') IS NOT NULL DROP TABLE #respuesta;
		IF OBJECT_ID('tempdb.dbo.#respuesta2', 'U') IS NOT NULL DROP TABLE #respuesta2;
		IF OBJECT_ID('tempdb.dbo.#seller', 'U') IS NOT NULL DROP TABLE #seller;
		IF OBJECT_ID('tempdb.dbo.#Ecommrce', 'U') IS NOT NULL DROP TABLE #Ecommrce;
		IF OBJECT_ID('tempdb.dbo.#SettlementData', 'U') IS NOT NULL DROP TABLE #SettlementData;

		select ('[{' + @jsonResult +  ']') jsonResult
   
END