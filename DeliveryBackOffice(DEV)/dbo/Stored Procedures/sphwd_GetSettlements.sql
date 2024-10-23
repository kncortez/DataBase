CREATE PROCEDURE [dbo].[sphwd_GetSettlements]
  @IdCountry varchar(2) = 'GT'
AS 
BEGIN 

SELECT	st.IdSettlement [IdSettlement],
		st.Settlement [SettlementName],
		st.IdCountry [IdCountry],
		tw.IdTownship [IdTownship],
		tw.TownshipName [TownshipName],
		tw.HeaderCode [TownshipHeaderCode],
		pr.IdProvince [IdProvince],
		pr.ProvinceName [ProvinceName]
FROM DeliveryBackOffice.dbo.Settlement st
LEFT JOIN DeliveryBackOffice.dbo.Township tw ON tw.IdTownship = st.IdTownship
LEFT JOIN DeliveryBackOffice.dbo.Province pr ON pr.IdProvince = st.IdProvince
WHERE ISNULL(st.IdCountry,'GT') = @IdCountry
 
END;