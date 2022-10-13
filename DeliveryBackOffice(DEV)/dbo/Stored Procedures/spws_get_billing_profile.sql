
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado perfiles de facturacion>
-- =============================================


CREATE PROCEDURE [dbo].[spws_get_billing_profile]
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdAccount bigint,
	@IdBilling bigint = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

	declare @IdUser bigint  = (select top 1 RuaIdUser FROM dbo.RolByUserByAccount WITH (NOLOCK) WHERE RuaIdAccount = @IdAccount)


	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"IdAccount":"' +   convert(varchar,bp.BlpIdAccount) + '",' +
							'"IdBilling":"' +  convert(varchar,bp.BlpIdBilling)  + '",' +
							'"Name":"' + bp.BlpName  + '",' +
							'"Address":"' + bp.BlpAddress + '",' +
							'"TaxId":"' + bp.BlpTaxId + '",' +
							'"IsDefault":"' + IIF(bp.IsDefault = 1, 'true', 'false') +
							+ '"}'

					from dbo.RolByUserByAccount  rua WITH (NOLOCK)
						inner join dbo.BillingProfile bp WITH (NOLOCK) on bp.BlpIdAccount= rua.RuaIdAccount
					where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser and bp.BlpRowStatus = 1
						and (bp.BlpIdBilling = @IdBilling or @IdBilling = -1)
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




