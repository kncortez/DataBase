-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-01-11>
-- Description:	<Retorna los tipos de una ruta>
-- =============================================
CREATE PROCEDURE [dbo].[get_Coverage]
AS
BEGIN

		SET NOCOUNT ON;

		SELECT  a.[HeaderCode] as Código_Cabecera,
				c.[IdProvince],
				b.[HubName] as Departamento,
				c.[IdTownship],  
				c.[TownshipName] as Municipio,
				a.[IdSettlement], 
				d.[Settlement] as Poblado,
				A.[Coverage] as Cobertura,
				a.[DeliveryTime] as Tiempo_Entrega,
				a.[RouteCode],
				CASE WHEN 
				a.[SDD]= 1 THEN '1' ELSE '0' END AS SSD, 
				CASE WHEN
				a.[NDD]= 1 THEN '1' ELSE '0' END AS NDD,
				CASE WHEN
				a.[TDA]= 1 THEN '1' ELSE '0' END AS TDA
		FROM DeliveryBackOffice.dbo.DumpServiceCoverage a          WITH (NOLOCK)
				 LEFT JOIN DeliveryBackOffice.dbo.HubLogistics b   WITH (NOLOCK)
			 ON a.Hub=b.HubAbbreviation
				 LEFT JOIN DeliveryBackOffice.dbo.Township c      WITH (NOLOCK)
			 ON a.HeaderCode=c.HeaderCode
				 LEFT JOIN DeliveryBackOffice.dbo.Settlement d    WITH (NOLOCK)
			 ON a.IdSettlement=d.IdSettlement
		WHERE   a.RowStatus=1
		ORDER BY a.HeaderCode
END

