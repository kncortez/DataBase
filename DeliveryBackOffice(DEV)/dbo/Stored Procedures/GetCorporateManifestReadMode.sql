

-- =============================================
-- Author:		<Michael Espinoza>
-- Create date: <2022-04-18>
-- Description:	<Obtiene guias asociadas a un Manifiesto corporativos previamente generados en Hermes Web>
-- =============================================

CREATE PROCEDURE [dbo].[GetCorporateManifestReadMode]
  @ManifestSerie VARCHAR(MAX),-- Serie de manifiesto
  @ManifestNumber BIGINT,-- Numero de manifiesto
  @Token NVARCHAR(50) -- Token de usuario que consulta
	
AS

BEGIN

DECLARE @jsonResult NVARCHAR(MAX);
DECLARE @result NVARCHAR(MAX);

SET @result = (SELECT STUFF(
                  (
                  SELECT
						',{'+
						'"Guide":"'+CONCAT(cmd.GuideSerie,cmd.GuideNumber)+'",'+
						'"ServiceType":"'+(CASE WHEN do.TypeService = 'NDD' THEN 'NEXT DAY' 
						WHEN do.TypeService = 'TDA' THEN 'NEXT DAY' ELSE 'SAME DAY' END) +'",'+
						'"Receiver":"'+CONCAT (do.Receiver_FirstName,' ', do.Receiver_LastName)+'",'+
						'"ServicePrice":'+CAST(ISNULL(do.PriceShippment,0) AS NVARCHAR)+','+
						'"COD":'+CAST(ISNULL(do.Collect_OnDelivery,0) AS NVARCHAR)+','+
						'"TotalPieces":'+CAST(ISNULL(do.Pieces_Dry, 0)+ISNULL(do.Pieces_Cold, 0) AS NVARCHAR)+','+
						'"PiecesCold":'+CAST(ISNULL(do.Pieces_Cold,0) AS NVARCHAR)+','+
						'"PiecesDry":'+CAST(ISNULL(do.Pieces_Dry,0) AS NVARCHAR)+','+
						'"StatusDescription":"'+so.OrderDescription+'",'+
						'"StatusOrderId":'+CAST(do.StatusOrderId AS NVARCHAR)+'}'
						FROM DeliveryBackOffice.dbo.CorporateManifest cm WITH (NOLOCK)
						JOIN DeliveryBackOffice.dbo.CorporateManifestDetail cmd WITH (NOLOCK) ON cmd.ManifestId = cm.IdManifest AND cmd.RowStatus=1
						JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK) ON do.Guide_Serie = cmd.GuideSerie AND do.Guide_Number = cmd.GuideNumber
						JOIN DeliveryBackOffice.dbo.StatusOrder so ON so.StatusOrderId =  do.StatusOrderId
						WHERE cm.ManifestSerie = @ManifestSerie AND cm.IdManifest = @ManifestNumber

                  FOR XML PATH(''), TYPE
                  ).value('.', 'varchar(max)'),1,1,''
                  )
                  );



IF(@result IS NOT NULL)

BEGIN

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
								"Message":"No se encontraron guias asociadas a este manifiesto.",'+
								'"Status": 400'
								+ '}' 			
								FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,''
						)
						)
END

SELECT ('[' + @jsonResult +  ']') jsonResult

END;
