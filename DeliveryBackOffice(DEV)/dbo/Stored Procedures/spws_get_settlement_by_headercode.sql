-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-20>
-- Description:	<Devuelve el listado Settlement asociados a un código de cabecera>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_settlement_by_headercode]
	-- Add the parameters for the stored procedure here
	@pHeaderCode VARCHAR(10) ='-1',
	@pIdCountry NVARCHAR(3) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT  
		ISNULL(twn.HeaderCode,'')									'HeaderCode',
		CONVERT(VARCHAR,ISNULL(st.IdSettlement,0))					'IdSettlement',
		dbo.fnt_String_Escape(ISNULL(st.Settlement,''),'json')		'SettlementName'
	FROM dbo.Township twn WITH (NOLOCK)
	INNER JOIN dbo.Settlement st ON st.IdTownship = twn.IdTownship 
	WHERE twn.TownshipStatus=1 
		AND (st.IdCountry = @pIdCountry OR (st.IdCountry IS NULL AND  @pIdCountry = 'GT'))
		AND (twn.HeaderCode = @pHeaderCode 
		OR @pHeaderCode = '-1')
		AND st.SettlementSatus=1
	ORDER BY TWN.HeaderCode

END
