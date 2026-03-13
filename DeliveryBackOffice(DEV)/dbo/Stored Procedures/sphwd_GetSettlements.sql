-- =============================================
-- Author:		<Mario, Herrarte>
-- Create date: <2026-03-12>
-- Description:	<Se filtra por el campo TypeSettlement para mostrar solo poblados publicos>
-- =============================================
CREATE PROCEDURE [dbo].[sphwd_GetSettlements]
  @IdCountry varchar(2) = 'GT'
AS 
BEGIN 

SELECT	
		st.IdSettlement [IdSettlement],
		CONCAT(st.Settlement,', ',tw.TownshipName,', ', pr.ProvinceName) [SettlementName],
		st.IdCountry [IdCountry],
		tw.IdTownship [IdTownship],
		tw.TownshipName [TownshipName],
		tw.HeaderCode [TownshipHeaderCode],
		pr.IdProvince [IdProvince],
		pr.ProvinceName [ProvinceName]		
FROM DeliveryBackOffice.dbo.Settlement st WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.Province pr WITH(NOLOCK) ON pr.IdProvince = st.IdProvince
INNER JOIN DeliveryBackOffice.dbo.Township tw WITH(NOLOCK) ON tw.IdTownship = st.IdTownship
WHERE ISNULL(st.IdCountry,'GT') = @IdCountry
AND st.SettlementSatus = 1
AND tw.TownshipStatus = 1
AND pr.ProvinceStatus = 1
AND st.IdTownship = tw.IdTownship
AND st.IdProvince = tw.IdProvince
AND st.TypeSettlement = 0
END;