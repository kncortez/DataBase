

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-06>
-- Description:	<Obtiene Manifiestos corporativos previamente generados en Hermes Web>
-- =============================================

CREATE PROCEDURE [dbo].[GetCorporateManifestOverallData]
  @IdAccount BIGINT,-- Id Account por si se quisiera en un futuro buscar solo por usuario
  @Token NVARCHAR(50), -- Token de usuario que consulta
  @CodeOfReference VARCHAR(MAX),-- codigo de punto de visita
  @StartDate DATE, -- fecha de inicio de busqueda.
  @EndDate DATE -- fecha de finalizacion de busqueda.
	
AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);
DECLARE @result NVARCHAR(MAX);
DECLARE @Counter INT = (SELECT COUNT(*) FROM DeliveryBackOffice.dbo.CorporateManifest cm WHERE cm.CodeOfReferenceId= @CodeOfReference AND cm.RowStatus=1 AND (CONVERT(DATE, cm.DateCreated) between @StartDate and @EndDate))

IF(@Counter>0)

BEGIN

SET @result = (SELECT STUFF(
                  (
                  SELECT ',{'+
				  '"DateCreated":"'+CONVERT(NVARCHAR(100), DateCreated,23)+'",'+
                  '"IdManifest":'+CONVERT(NVARCHAR(MAX),cm.IdManifest)+','+
                  '"Manifest":"'+CONCAT(cm.ManifestSerie,CONVERT(NVARCHAR(MAX),cm.IdManifest))+'",'+
                  '"GuideCounter":'+CONVERT(NVARCHAR(MAX),(SELECT COUNT(*)
                    FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd WITH (NOLOCK)
                    WHERE cmd.ManifestId = cm.IdManifest))+','+
                  '"GuideStatusMonitor":['+
                  (SELECT STUFF(
                  (

                  SELECT ',{'+
                  '"StatusDescription":"'+so.OrderDescription+'",'+
                  '"Quantity":'+CONVERT(NVARCHAR(MAX), COUNT(do.Guide_Number))+'}'
                  FROM DeliveryBackOffice.dbo.CorporateManifestDetail cmd WITH (NOLOCK)
                  JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                  ON do.Guide_Serie = cmd.GuideSerie AND do.Guide_Number=cmd.GuideNumber
                  JOIN DeliveryBackOffice.dbo.StatusOrder so ON so.StatusOrderId = do.StatusOrderId
                  WHERE cmd.ManifestId=cm.IdManifest GROUP BY so.OrderDescription

                  FOR XML PATH(''), TYPE
                  ).value('.', 'varchar(max)'),1,1,''
                  ))
                  +'],'+
                  '"DocumentURL":"'+cm.ManifestURL+'"'+
                  '}'
                  FROM DeliveryBackOffice.dbo.CorporateManifest cm
                  WHERE cm.CodeOfReferenceId= @CodeOfReference
                  AND cm.RowStatus=1
                  AND (CONVERT(DATE, cm.DateCreated) between @StartDate and @EndDate)

                  FOR XML PATH(''), TYPE
                  ).value('.', 'varchar(max)'),1,1,''
                  )
                  );

SET @jsonResult = (SELECT STUFF(
						(
							select 
								',{									
								"Result":['+@result+'],'+
								'"Status": 200'
								+ '}' 			
								FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
						)
						)

END

ELSE

BEGIN

SET @jsonResult = (SELECT STUFF(
						(
							select 
								',{									
								"Message":"No se encontraron manifiestos asociados.",'+
								'"Status": 400'
								+ '}' 			
								FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
						)
						)
END

SELECT ('[' + @jsonResult +  ']') jsonResult

END;
