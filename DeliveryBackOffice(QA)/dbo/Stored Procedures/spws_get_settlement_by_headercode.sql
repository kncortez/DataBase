
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-20>
-- Description:	<Devuelve el listado Settlement asociados a un código de cabecera>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_settlement_by_headercode]
	-- Add the parameters for the stored procedure here
	@HeaderCode VARCHAR(10) ='-1'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"HeaderCode":"' +   isnull(twn.HeaderCode,'') + '",' +
							'"IdSettlement":"' +   convert(varchar,isnull(st.IdSettlement,0))  + '",' +
							'"SettlementName":"' +  dbo.fnt_String_Escape(  isnull(st.Settlement,''),'json') + 
							+ '"}'

					from dbo.Township twn WITH (NOLOCK)
						inner join dbo.Settlement st on st.IdTownship = twn.IdTownship AND st.SettlementSatus=1
					where twn.TownshipStatus=1 AND twn.HeaderCode = @HeaderCode OR @HeaderCode = '-1' 
					ORDER BY TWN.HeaderCode
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


