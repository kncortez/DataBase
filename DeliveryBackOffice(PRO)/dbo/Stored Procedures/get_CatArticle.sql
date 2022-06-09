
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-25>
-- Description:	<Retorna las categor�as genericas de los articulos>
-- =============================================
CREATE PROCEDURE [dbo].[get_CatArticle]
	@guideNumber AS INT,
	@guideSerie AS NVARCHAR(2)
AS
BEGIN
	DECLARE @idCustomer AS INT
	SELECT @idCustomer=IdCustomer FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Number=@guideNumber AND Guide_Serie=@guideSerie

	IF EXISTS (SELECT abc.AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer abc WITH(NOLOCK) WHERE abc.AbcIdCustomer = @idCustomer)
	BEGIN
		SELECT art.ArtId,
			art.ArtName,
			abc.[Height],
			abc.[Width],
			abc.[Length],
			abc.[MassWeight]
		FROM DeliveryBackOffice.dbo.CatArticle art WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.ArticleByCustomer abc WITH(NOLOCK) ON abc.AbcIdArticle = art.ArtId
		JOIN DeliveryBackOffice.dbo.CatTypeArticle ctp WITH(NOLOCK) ON art.ArtIdTypeArticle = ctp.TarId
		WHERE ctp.TarName IN ('Standar','Caja','Sobre') OR art.ArtShowDefault =1 
		OR abc.AbcIdCustomer = @idCustomer AND art.ArtRowStatus = 1
	END
	ELSE
	BEGIN
		/*SELECT art.ArtId,
		art.ArtName
		FROM DeliveryBackOffice.dbo.CatPackage cp
		JOIN DeliveryBackOffice.dbo.CatTypeArticle ctp ON ctp.TarIdPackage = cp.PckId
		JOIN DeliveryBackOffice.dbo.CatArticle art ON art.ArtIdTypeArticle = ctp.TarId
		WHERE ctp.TarName IN ('Standar','Caja','Sobre') 
		OR art.ArtShowDefault=1 AND art.ArtRowStatus = 1 order by [ArtName]
*/
		SELECT art.ArtId,
			art.ArtName,
			art.ArtHeight AS "Height",
			art.ArtWidth AS "Width",
			art.ArtLength AS "Length",
			art.ArtMassWeight AS "MassWeight"
		FROM DeliveryBackOffice.dbo.CatPackage cp WITH(NOLOCK)
		JOIN DeliveryBackOffice.dbo.CatTypeArticle ctp WITH(NOLOCK) ON ctp.TarIdPackage = cp.PckId
		JOIN DeliveryBackOffice.dbo.CatArticle art WITH(NOLOCK) ON art.ArtIdTypeArticle = ctp.TarId
		WHERE 
		--ctp.TarName IN ('Standar','Caja','Sobre') 
		--OR art.ArtShowDefault=1 
		--AND 
		art.ArtRowStatus = 1 ORDER BY [ArtName]

	END
END
