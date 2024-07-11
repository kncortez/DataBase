-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-06-11>
-- Description:	<Crear Guias - Crear nuevo método en lugar de Catalog/GetDynamicCatalog para carga de Artículos.>
-- =============================================

CREATE PROCEDURE [dbo].[spGetCatalogTypePieceMC]
    -- Add the parameters for the stored procedure here
	@pIdAccount INT = 1,
    @pToken VARCHAR(100) = '0BE2F8F3BD53652635746ACD069954B5',
    @pCountryId NVARCHAR(3) = 'GT',
    @pType NVARCHAR(30) = 'GetCorporateArticles' -- GetCorporateArticles o GetTypePiece
AS
BEGIN
	
	IF (@pType = 'GetTypePiece') --CARGA DE ARTICULOS
	BEGIN

		DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);
		DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI);

		SELECT
			CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) AS 'Id',
			ISNULL(cd.[Code], '') AS 'Code',
			CASE
				WHEN cd.IsMainPackage IS NOT NULL AND cd.IsMainPackage = 1 THEN cd.ArtName
				ELSE ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '')
			END AS 'Description',
			CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) AS 'Height',
			CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) AS 'Width',
			CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) AS 'Length',
			CONVERT(NVARCHAR, ISNULL(cd.MassWeight, 1)) AS 'Weight',
			IIF(cd.IsMainPackage IS NOT NULL,IIF(cd.IsMainPackage = 1, 'true', 'false'), '') AS 'IsMainPackage'
		FROM (
			SELECT DISTINCT
				abc.Code,
				abc.AbcId,
				ta.TarName,
				art.ArtName,
				abc.Height,
				abc.Width,
				abc.Length,
				abc.MassWeight,
				IIF(ra.RateId IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates), IIF(ra.TypeServiceId IS NOT NULL AND ra.TypeSegmentId IS NOT NULL, 1, 0), NULL) AS IsMainPackage
			FROM dbo.CatArticle art WITH(NOLOCK)
			INNER JOIN dbo.ArticleByCustomer abc WITH(NOLOCK)
				ON abc.AbcIdArticle = art.ArtId
			LEFT JOIN CatTypeArticle ta WITH(NOLOCK)
				ON ta.TarId = art.ArtIdTypeArticle
			INNER JOIN RateData ra WITH(NOLOCK)
				ON ra.ArticleId = abc.AbcId
			INNER JOIN RatebyCustomer rbc WITH(NOLOCK)
				ON rbc.RbcIdRate = ra.RateId
			INNER JOIN Account ac WITH(NOLOCK)
				ON ac.IdCustomer = rbc.RbcIdCustomer
			WHERE ac.AccIdAccount = @pIdAccount
			AND (art.IdCountry = @pCountryId OR (art.IdCountry IS NULL AND @pCountryId = 'GT'))
			AND art.ArtRowStatus	= 'TRUE'
			AND abc.AbcRowStatus	= 'TRUE'
			AND ra.RowStatus		= 'TRUE'
			AND rbc.RbcRowStatus	= 'TRUE'
			AND ac.AccRowStatus		= 'TRUE'
		) cd
		ORDER BY cd.AbcId;

	END;
	ELSE --CARGA DE ARTICULOS PARA CLIENTES CORPORATIVOS
	BEGIN
		
		SELECT 
			CONVERT(NVARCHAR, ISNULL(cd.[AbcId], 0)) AS 'Id',
			ISNULL(cd.[Code], '') AS 'Code',
			ISNULL(CONCAT(cd.[Code], '  -  ', cd.[TarName], '-', cd.[ArtName]), '') AS 'Description',
			CONVERT(NVARCHAR, ISNULL(cd.[Height], 30)) AS 'Height',
			CONVERT(NVARCHAR, ISNULL(cd.[Width], 30)) AS 'Width',
			CONVERT(NVARCHAR, ISNULL(cd.[Length], 30)) AS 'Length'
		FROM
		(
			SELECT DISTINCT
					ac.Code,
					ac.AbcId,
					ta.TarName,
					ca.ArtName,
					ac.Height,
					ac.Width,
					ac.Length
			FROM DeliveryBackOffice.dbo.RatebyCustomer rc WITH(NOLOCK)
				LEFT JOIN DeliveryBackOffice.dbo.RateData rd WITH(NOLOCK)
					ON rd.RateId = rc.RbcIdRate
				INNER JOIN DeliveryBackOffice.dbo.ArticleByCustomer ac WITH(NOLOCK)
					ON ac.AbcId = rd.ArticleId
				LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca WITH(NOLOCK)
					ON ca.ArtId = ac.AbcIdArticle
				LEFT JOIN DeliveryBackOffice.dbo.CatTypeArticle ta WITH(NOLOCK)
					ON ta.TarId = ca.ArtIdTypeArticle
						AND ta.TarRowStatus = 'TRUE'
						AND ca.ArtRowStatus = 'TRUE'
			WHERE rc.RbcIdCustomer = @pIdAccount
				AND (ca.IdCountry = @pCountryId OR (ca.IdCountry IS NULL AND @pCountryId = 'GT'))
				AND rc.RbcRowStatus = 'true'
		) cd
		ORDER BY cd.AbcId

	END;
	
END;