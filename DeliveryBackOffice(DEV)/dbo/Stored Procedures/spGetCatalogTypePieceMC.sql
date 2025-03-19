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

	--DESCRIPCIÓN DE ARTICULOS IMPORTANTES PARA PORTALES INDIVIDUAL, EXPRESS CENTER y CORPORATIVO
	DECLARE @DescriptionAritcle TABLE (
    Id NVARCHAR(50),
    Description NVARCHAR(200),
    Country NVARCHAR(3),
	Main bit, --campo para saber el paquete estandar del país
	Label NVARCHAR(20),
	Width2 NVARCHAR(5),
	Dim NVARCHAR(50),
	IsOversized bit
);

INSERT INTO @DescriptionAritcle (Id, Description, Country, Main,Label,Width2,Dim,IsOversized)
VALUES
    ('Paquete pequeño', 'Si el lado más largo es menor o igual a 28 cm - Peso: 1 a 10 lbs.', 'HN',1,'Pequeño','60%','Máx: 28cm o 10lbs',0),
    ('Paquete mediano', 'Si el lado más largo mide entre 28.1 y 36 cm - Peso: 10.1 a 20 lbs.', 'HN',0,'Mediano','70%','Máx: 36cm o 20lbs',0),
    ('Paquete grande', 'Si el lado más largo mide entre 36.1 y 47 cm - Peso: 20.1 a 40 lbs.', 'HN',0,'Grande','80%','Máx: 47cm o 40lbs',0),
    ('Paquete extra grande', 'Si el lado más largo mide entre 47.1 y 51 cm - Peso: 40.1 a 59 lbs.', 'HN',0,'Extra Grande','90%','Máx: 51cm o 59lbs',0),
    ('Paquete sobredimensionado', 'Si el lado más largo es mayor a 51 cm - Peso: 60 lbs en adelante.', 'HN',0,'Sobredimensionado','100%','Min: 60lbs',1),
	('Paquete pequeño', 'Si el lado más largo es menor o igual a 28 cm - Peso: 1 a 10 lbs.', 'GT',1,'Pequeño','60%','Máx: 28cm o 10lbs',0),
    ('Paquete mediano', 'Si el lado más largo mide entre 28.1 y 36 cm - Peso: 10.1 a 20 lbs.', 'GT',0,'Mediano','70%','Máx: 36cm o 20lbs',0),
    ('Paquete grande', 'Si el lado más largo mide entre 36.1 y 47 cm - Peso: 20.1 a 40 lbs.', 'GT',0,'Grande','80%','Máx: 47cm o 40lbs',0),
    ('Paquete extra grande', 'Si el lado más largo mide entre 47.1 y 51 cm - Peso: 40.1 a 59 lbs.', 'GT',0,'Extra Grande','90%','Máx: 51cm o 59lbs',0),
    ('Paquete sobredimensionado', 'Si el lado más largo es mayor a 51 cm - Peso: 60 lbs en adelante.', 'GT',0,'Sobredimensionado','100%','Min: 60lbs',1);

	IF (@pType = 'GetTypePiece') --CARGA DE ARTICULOS
	BEGIN

		DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' AND RH.CountryId = @pCountryId );
		DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' AND RH.CountryId = @pCountryId );
		DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' AND RH.CountryId = @pCountryId );
		DECLARE @Others INT =(SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio interfer' AND RH.CountryId = @pCountryId)


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
			ISNULL(cd.Description,'') AS 'DescriptionLog',
			ISNULL(cd.Main,0) AS 'IsMainSTD',
			CONVERT(NVARCHAR, ISNULL(cd.MassWeight, 1)) AS 'Weight',
			ISNULL(cd.Description,'') AS 'DescriptionLog',
			ISNULL(cd.Main,0) AS 'IsMainSTD',
			ISNULL(cd.Label,'') AS 'Label',
			ISNULL(cd.Width2,'') AS 'Width2',
			ISNULL(cd.Dim,'') AS 'Dim',
			ISNULL(cd.IsOversized,0) AS 'IsOversized',
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
				d.Description,
				d.Main,
				d.Label,
				d.Width2,
				d.Dim,
				d.IsOversized,
				IIF(ra.RateId IN (@NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates, @Others), IIF(ra.TypeServiceId IS NOT NULL AND ra.TypeSegmentId IS NOT NULL, 1, 0), NULL) AS IsMainPackage
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
			LEFT JOIN @DescriptionAritcle d
				ON art.ArtName = d.Id AND d.Country = @pCountryId
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