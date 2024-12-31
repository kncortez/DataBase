-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2024-12-30>
-- Description:	<Consulta del listado de poblados>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_list_settlement_by_header_code]
	-- Add the parameters for the stored procedure here
	@HeaderCodeTownship as nvarchar(10)  = '-1', --all
	@HeaderCode as  nvarchar(2) = '-1', --all
	@CountryId as nvarchar(2) = NULL
AS
BEGIN
	SELECT 	sett.Settlement AS [Settlement], 
			sett.IdSettlement AS [IdSettlement], 	
			ISNULL(sett.IdCountry, @CountryId) AS [IdCountry], 
			sett.IsSpecial AS [IsSpecial] 
	FROM [dbo].[Settlement] sett
	INNER JOIN 
			DeliveryBackOffice.dbo.Province depto ON sett.IdProvince = depto.IdProvince 
	INNER JOIN 
			DeliveryBackOffice.dbo.Township mun ON sett.IdTownship = mun.IdTownship
	WHERE 
		sett.SettlementSatus = 1
		AND depto.ProvinceStatus = 1 
		AND mun.TownshipStatus = 1 
		AND ISNULL(NULLIF(@CountryId,''), depto.IdCountry) = depto.IdCountry
		AND (@HeaderCodeTownship = '-1' OR mun.HeaderCode = @HeaderCodeTownship)
		AND (@HeaderCode = '-1' OR depto.LocalCode = @HeaderCode)
END
