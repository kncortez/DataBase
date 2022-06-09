-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-01-11>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetCoverage]
AS
BEGIN

		SET NOCOUNT ON;
		SELECT 
                 cov.[HeaderCode] as Código_Cabecera,
				prov.[IdProvince],
				prov.[ProvinceName] as Departamento,
				towns.[IdTownship],  
				towns.[TownshipName] as Municipio,
				setl.[IdSettlement], 
				setl.[Settlement] as Poblado,
				cov.[Coverage] as DíasDeVisita,
				cov.[DeliveryTime] as Tiempo_Entrega,
				cov.[RouteCode] as Ruta,
				CASE WHEN 
				cov.[SDD]= 1 THEN '1' ELSE '0' END AS SDD, 
				CASE WHEN
				cov.[NDD]= 1 THEN '1' ELSE '0' END AS NDD,
				CASE WHEN
				cov.[TDA]= 1 THEN '1' ELSE '0' END AS TDA

		FROM dbo.DumpServiceCoverage cov  WITH (NOLOCK)
				INNER JOIN dbo.Settlement setl    WITH (NOLOCK)
				ON setl.IdSettlement=cov.IdSettlement 
				INNER JOIN dbo.Township towns     WITH (NOLOCK)
				ON towns.IdTownship=setl.IdTownship    
				INNER JOIN dbo.Province prov      WITH (NOLOCK) 
				ON prov.IdProvince=towns.IdProvince    
		WHERE  (cov.RowStatus=1)
		ORDER BY cov.HeaderCode
END



