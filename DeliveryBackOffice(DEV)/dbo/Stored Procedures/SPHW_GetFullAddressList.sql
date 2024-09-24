
-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-24>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetFullAddressList] 
@IdCountry NVARCHAR(2)
AS
BEGIN
	
	SET NOCOUNT ON;

	SELECT IdSettlement,Settlement +', '+ T.[TownshipName] +', '+ P.ProvinceName [Address]
	     FROM [dbo].[Township] T WITH(NOLOCK)
		    INNER JOIN [dbo].[Province] P WITH(NOLOCK)
		 ON T.IdProvince = P.IdProvince
		    INNER JOIN Settlement s WITH(NOLOCK)
		 ON T.IdTownship = s.IdTownship
	  WHERE P.IdCountry = @IdCountry
	  ORDER BY P.IdProvince ASC
END
GO



