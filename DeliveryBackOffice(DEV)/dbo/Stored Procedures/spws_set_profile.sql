
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-11>
-- Description:	<Actualizacion de datos de perfil de usuario>
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_profile]
	-- Add the parameters for the stored procedure here
	@FirstName VARCHAR(200),
	@LastName  VARCHAR(200) ,
	@Gender  VARCHAR(200),
	@Birthdate  DATE,
	@Identification  VARCHAR(200),
	@Nationality  VARCHAR(200),
	@NickName VARCHAR(200),
	@Language  VARCHAR(2) = 'ES', -- ESPAÑOL
	@Currency VARCHAR(10),
	@Token VARCHAR(200),
	@IdSystem INT = 1,
	@Phone NVARCHAR(15) = '+502',
	@VerifiedPhone NVARCHAR(10) = '',
	@UrlFacebook NVARCHAR(10)= '',
	@UrlInstagram NVARCHAR(10)= '',
	@UrlEcommerce NVARCHAR(10)= '',
	@UrlWebsite NVARCHAR(10)= ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--select * from Person

		-- insertar en tabla temporal posbibles mensajes de error

	IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;
		select * INTO #errormessage from (
		SELECT  500 AS IdResult
				,'Token Inválido' AS Message
				,'Token' as Id 
		union
		SELECT  500 AS IdResult
				,'Error fatal intente de nuevo mas tarde' AS Message
				,'Transaction' as Id 
		union
		SELECT  200 AS IdResult
				,'Perfil Actualizado correctamente' AS Message
				,'Ok' as Id )  as errror

	
	
	DECLARE @jsonResult NVARCHAR(MAX) 

	declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)
	PRINT @@TRANCOUNT  
	
	if @IdUser>0
	begin 
		BEGIN TRANSACTION
		BEGIN TRY
		PRINT @@TRANCOUNT  
					update dbo.Person
				set  PerFirstName = @FirstName,
					PerLastName = @LastName,
					PerGender = @Gender,
					PerBirthdate = @Birthdate,
					PerIdentification = @Identification,
					PerNationality = @Nationality,
					PerTokenUpdated = @Token,
					PerDateUpdated = getdate()
				from dbo.RegisterUser usr
					inner join dbo.Person per on per.PerIdPerson = usr.UsrIdPerson
				where usr.UsrIdUser = @IdUser

				update dbo.RegisterUser 
				set 
				UsrNickName =@NickName,
				UsrLang = @Language,
				UsrCurrency = @Currency,
				UsrTokenUpdated = @Token,
				UsrDateUpdated =  getdate(),
				PrefixCallingCode = '+502',
				Phone = @Phone

				where UsrIdUser = @IdUser	
				
		END TRY
		BEGIN CATCH
				
			set @jsonResult =(
			SELECT STUFF(( 
			SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
			+ '"Message":"' + Message + '"}' from #errormessage where Id ='Transaction'
		
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
					) 
			)
			ROLLBACK TRANSACTION
		END CATCH;
		PRINT @@TRANCOUNT  
		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
			set @jsonResult =(
			SELECT STUFF(( 
			SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
			+ '"Message":"' + Message + '"}' from #errormessage where Id ='Ok'
		
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
					) 
			)
		END
		-- destruir tablas temporales
	end
	else
	begin
		set @jsonResult =(
			SELECT STUFF(( 
			SELECT '{"IdResult":' + convert(varchar,IdResult)    +',' 
			+ '"Message":"' + Message + '"}' from #errormessage where Id ='Token'
		
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
					) 
			)
	end
		IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;

		-- retornar resultado en formato json

				select ('[{' + @jsonResult +  ']') jsonResult

END



