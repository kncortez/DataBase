USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_address]    Script Date: 15/01/2021 23:19:35 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================


create PROCEDURE [dbo].[spws_get_address]
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdAccount bigint,
	@IdAddress bigint = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

	declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)


	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"IdAccount":"' +   convert(varchar,ua.UadIdAccount) + '",' +
							'"IdAddress":"' +  convert(varchar,ua.UadIdAddress)  + '",' +
							'"FullName":"' + ua.UadFullName  + '",' +
							'"Address1":"' + ua.UadAddress1 + '",' +
							'"Address2":"' + ua.UadAddress2  + '",' +
							'"NirPhone":"' + ua.UadNirPhone  + '",' +
							'"Phone":"' + ua.UadPhone   + '",' +
							'"AdditionalInstructions":"' + ua.UadAdditionalInstructions  + '",' +
							'"IdCountry":"' + ua.UadIdCountry  + '",' +
							'"Province":"' + prv.ProvinceName  + '",' +
							'"Township":"' + twn.TownshipName  + '",' +
							'"IdTownship":"' +  convert(varchar,ua.UadIdTownship)  + '",' +
							'"HeaderCode":"' + twn.HeaderCode   +
							+ '"}'

					from dbo.RolByUserByAccount  rua
						inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						join dbo.Township twn on twn.IdTownship = ua.UadIdTownship
						join dbo.Province prv on prv.IdProvince = twn.IdProvince
					where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser and ua.UadRowStatus = 1
						and (ua.UadIdAddress = @IdAddress or @IdAddress = -1)
					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

		-- retornar resultado en formato json
	If @jsonResult is null 
	begin

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end
	
		select ('[' + @jsonResult +  ']') jsonResult

	

END


