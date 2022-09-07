-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <05-09-2022>
-- Description:	<Crea una nuevo registro en la tabla de direcciones confirmadas>
-- =============================================
CREATE PROCEDURE SetConfirmedAddress
	-- Add the parameters for the stored procedure here
	@IdTownship INT ,
	@IdAccount bigINT ,
	@IdCountry  nvarchar(10) = 'GT',
	@FullName  nvarchar(200) ,
	@Address1  nvarchar(600),
	@NirPhone  nvarchar(10) ,
	@Phone  nvarchar(50) ,
	@AdditionalInstructions  nvarchar(250) ,
	@Status INT = 1,
	@Token nvarchar(200),
	@IdCityPlace int = 31,
	@Latitude varchar(50)=NULL,
	@Longitude varchar(50)=NULL,
	@Neighborhood varchar(50) = NULL,
	@Zone smallint = NULL
	--@IdModule int = NULL
	
	
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
	DECLARE @HeaderCode VARCHAR(10)
	DECLARE @CityName VARCHAR(50)
	DEClARE @IdDepartment INT;

	DEClARE @ActionDone smallint=NULL;
		--0	DIRECCIÓN CREADA
		--1 DIRECCIÓN MODIFICADA
		--2 DIRECCIÓN WELIMINADA

		-- insertar en tabla temporal posbibles mensajes de respuesta

		IF OBJECT_ID('tempdb.dbo.#messagelist', 'U') IS NOT NULL DROP TABLE messagelist;
			select IdResult,Message,Id INTO #messagelist 
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
					,'Delete' as Id) as messagess

		-- obtener el id de usuarion con base al token

		declare @IdUser bigint  = (select t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)

		select RuaIdAccount  
		into #Access
		from dbo.RolByUserByAccount  rua
		where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser

	if(select count(RuaIdAccount) from #Access)>0 -- el usuario tiene acceso  a la cuenta indicada
	begin

		if @Status = 0
		begin 
				UPDATE [dbo].[ConfirmedAddress] SET
						   [TokenUpdate] =@Token
						   ,[DateUpdate] =getdate()
						   ,[RowStatus] =0
				WHERE NirPhone=@NirPhone AND Phone=@Phone			
		end
		else if @Status = 1
		begin 
			--Comprobar si existe el telefono
			if EXISTS(SELECT Phone FROM DBO.ConfirmedAddress WHERE NirPhone=@NirPhone AND Phone=@Phone)
			begin
				UPDATE [dbo].[ConfirmedAddress] SET
						   [NirPhone] =@NirPhone
						   ,[Phone] = @Phone
						   ,[TokenUpdate] =@Token
						   ,[DateUpdate] =getdate()
						   ,[RowStatus] =1
						   ,[AccountId] = @IdAccount
						   ,[TownshipId] = @IdTownship
						   ,[NameAddress] = @FullName
						   ,[Address] = @Address1 
						   ,[AdditionalInstructions] = @AdditionalInstructions
						   ,[CityPlaceId] = @IdCityPlace
						   ,[CodeOfReference] = @CodeOfReference
						   ,[DeliveryOptionId] = NULL
						   ,[Latitude] = @Latitude
						   ,[Longitude] = @Longitude
						   ,[Neighborhood] = @Neighborhood
						   ,[Zone] = @Zone
				WHERE NirPhone=@NirPhone AND Phone=@Phone;
			end
			else
			begin
				--Si no existe, crearlo
				INSERT INTO [dbo].[ConfirmedAddress]
					([NirPhone]
					,[Phone]
					,[TokenCreated]
					,[DateCreated]
					,[TokenUpdate]
					,[DateUpdate]
					,[RowStatus]
					,[AccountId]
					,[TownshipId]
					,[NameAddress]
					,[Address]
					,[AdditionalInstructions]
					,[CityPlaceId]
					,[CodeOfReference]
					,[DeliveryOptionId]
					,[Latitude]
					,[Longitude]
					,[Neighborhood]
					,[CatModuleId]
					,[StatusAddressId])
				VALUES
					(@NirPhone
					,@Phone
					,@Token
					,getdate()
					,NULL
					,NULL
					,1
					,@IdAccount
					,@IdTownship
					,@FullName
					,@Address1 
					,@AdditionalInstructions
					,@IdCityPlace
					,@CodeOfReference
					,NULL
					,@Latitude
					,@Longitude
					,@Neighborhood
					,@Zone
					,(select IdStatus from dbo.CatStateConfirmedAddress where NameState='CONFIRMADO'));
			end			
		end	

	end
	else
	begin
		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
					+ '"NirPhone":' + @NirPhone    +',' 
					+ '"Phone":' + @Phone +',' 
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