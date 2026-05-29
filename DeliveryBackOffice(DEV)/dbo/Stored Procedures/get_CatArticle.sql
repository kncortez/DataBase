
-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-02-25>
-- Description:	<Retorna las categor�as genericas de los articulos>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se agrega parametro para filtrar por pais de origen. Por defecto 'GT'>
-- =============================================


CREATE PROCEDURE [dbo].[get_CatArticle]
	@guideNumber AS INT,
	@guideSerie AS NVARCHAR(2),
	@IdCountry AS NVARCHAR(2)='GT'
AS
BEGIN
	DECLARE @idCustomer AS INT
	SELECT @idCustomer=IdCustomer FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK) WHERE Guide_Serie=@guideSerie AND Guide_Number=@guideNumber AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry

	IF EXISTS (SELECT abc.AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer abc WITH(NOLOCK) WHERE abc.AbcIdCustomer = @idCustomer)
	BEGIN
		SELECT art.ArtId,
			ISNULL(art.ArtName, '') AS ArtName,
			ISNULL(abc.AbcIdArticle,0) AS AbcIdArticle,
			ISNULL(abc.Code,'') AS Code,
			ISNULL(abc.PriceDefault,0.0) AS PriceDefault,
			ISNULL(abc.[Height],0.0) AS [Height],
			ISNULL(abc.[Width],0.0) AS [Width],
			ISNULL(abc.[Length],0.0) AS [Length],
			ISNULL(abc.[MassWeight],0.0) AS [MassWeight],
			ISNULL(abc.VolumetricWeight,0.0) AS VolumetricWeight
		FROM DeliveryBackOffice.dbo.CatArticle art WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.ArticleByCustomer abc WITH(NOLOCK) ON abc.AbcIdArticle = art.ArtId
		INNER JOIN DeliveryBackOffice.dbo.CatTypeArticle ctp WITH(NOLOCK) ON art.ArtIdTypeArticle = ctp.TarId
		WHERE ctp.TarName IN ('Standar','Caja','Sobre') OR art.ArtShowDefault =1 
		OR abc.AbcIdCustomer = @idCustomer AND art.ArtRowStatus = 1 AND IIF(art.IdCountry IS NULL, 'GT',art.IdCountry) = @IdCountry
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
			ISNULL(art.ArtName,'') AS ArtName,
			ISNULL(art.ArtId, 0)AS AbcIdArticle,
			ISNULL(art.ArtId,0) AS Code,
			0 AS PriceDefault,
			ISNULL(art.ArtHeight,0.0) AS "Height",
			ISNULL(art.ArtWidth,0.0) AS "Width",
			ISNULL(art.ArtLength,0.0) AS "Length",
			ISNULL(art.ArtMassWeight,0.0) AS "MassWeight",
			ISNULL(art.ArtMassWeight,0.0) AS "VolumetricWeight"
		FROM DeliveryBackOffice.dbo.CatPackage cp WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.CatTypeArticle ctp WITH(NOLOCK) ON ctp.TarIdPackage = cp.PckId
		INNER JOIN DeliveryBackOffice.dbo.CatArticle art WITH(NOLOCK) ON art.ArtIdTypeArticle = ctp.TarId
		WHERE 
		--ctp.TarName IN ('Standar','Caja','Sobre') 
		--OR art.ArtShowDefault=1 
		--AND 
		art.ArtRowStatus = 1 AND IIF(art.IdCountry IS NULL, 'GT',art.IdCountry) = @IdCountry 
		ORDER BY [ArtName]

	END
END