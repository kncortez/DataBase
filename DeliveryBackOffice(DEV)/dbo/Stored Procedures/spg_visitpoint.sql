
-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <04/Agosto/2020>
-- Description:	<Listar sedes de clientes por país>
-- =============================================
CREATE PROCEDURE [dbo].[spg_visitpoint]
	-- Add the parameters for the stored procedure here
	@IdCountry VARCHAR(2)
	,@Active BIT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		SUBQ.ID
		,SUBQ.ID_Visitpoint_Delivery
		,UPPER(SUBQ.Visitpoint_Name) AS Visitpoint_Name
		,SUBQ.Active
		,SUBQ.ID_Country
		,SUBQ.ID_Visitpoint_Denarius
		,SUBQ.CODExcludedPriceShipping
		,SUBQ.CODExcludedCommission
	FROM
	(
	SELECT 
			IdVisitPointClient as ID
			,CodeOfReference as ID_Visitpoint_Delivery
			,c.[Name] + ' - [' + DescriptionOfClient + ']' as Visitpoint_Name
			,StatusClient as Active
			,IIF(vp.CountryId IS NULL, c.CountryId, vp.CountryId) as ID_Country
			,VisitPointId as ID_Visitpoint_Denarius,
			IIF(vp.ExcludePriceShippingCOD IS NULL, IIF(c.ExcludePriceShippingCOD = 'TRUE', c.ExcludePriceShippingCOD, 'FALSE'), IIF(vp.ExcludePriceShippingCOD = 'TRUE', vp.ExcludePriceShippingCOD, 'FALSE')) CODExcludedPriceShipping,
			IIF(vp.ExcludeCommissionCOD IS NULL, IIF(c.ExcludeCommissionCOD = 'TRUE', c.ExcludeCommissionCOD, 'FALSE'), IIF(vp.ExcludeCommissionCOD = 'TRUE', vp.ExcludeCommissionCOD, 'FALSE')) CODExcludedCommission
		FROM DeliveryBackOffice.dbo.VisitPointClient vp
		JOIN DeliveryBackOffice.dbo.Customer c ON c.IdCustomer = vp.CustomerID
		WHERE 
			vp.CountryId = @IdCountry
			AND StatusClient = 1 
			AND StatusClient = @Active
	) AS SUBQ
	ORDER BY SUBQ.Visitpoint_Name ASC
END


