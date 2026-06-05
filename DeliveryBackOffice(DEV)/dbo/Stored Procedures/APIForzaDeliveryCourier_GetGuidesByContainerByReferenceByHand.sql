/* =================================================
   SP:        APIForzaDeliveryCourier_GetGuidesByContainerByReferenceByHand
   Propósito: Contenerizacion guias - obtiene las guias por referencia y por contenedor para recolección Manual.
   Autor:     Caleb Loarca
   Historia:  JIRA/FDAPI-5679
   Fecha:     2025-06-30 
*/
/* === CHANGELOG ============================
2026-06-30 | Historia/épica: FDAPI-5679 | Autor: Caleb Loarca |

=========================================== */

CREATE PROCEDURE [dbo].[APIForzaDeliveryCourier_GetGuidesByContainerByReferenceByHand]
	@Container TblContainerList READONLY,
	@References TblReferencesList READONLY,
	@IdCountry NVARCHAR(2) = 'GT'

AS
BEGIN
	DECLARE 
	@StatusContainerCreated INT,
	@IdCustomerPickup INT;

	SET @StatusContainerCreated = (
			SELECT IdCatStatus
			FROM DeliveryBackOffice.dbo.CatShipContainerStatus WITH (NOLOCK)
			WHERE [Name] = 'Creado'
			);

            -- Consulta 2 
     WITH CTE_Ranked AS (    
          SELECT  DOP.GuideSerie,
                  DOP.GuideNumber
                  ,DOP.NoPiece
		          ,DO.Ticket_Number
		          ,ROW_NUMBER() OVER (
			                          PARTITION BY DO.Ticket_Number ORDER BY DOP.GuideSerie DESC
				                      ,DOP.GuideNumber DESC
			                         ) AS RowNum
		          ,DO.DateCreated
	        FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
	             INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
				 ON DO.Guide_Serie = DOP.GuideSerie
	                AND DO.Guide_Number = DOP.GuideNumber
	       WHERE DO.Ticket_Number IN
                 (
	              SELECT ReferenceGuide
	                FROM @References
					WHERE ReferenceGuide NOT IN ('','0')
	             )
            AND ISNULL(DO.SenderCountryId, 'GT') = @IdCountry 
			AND DO.StatusOrderId IN (1,15)			
       )
	SELECT GuideSerie
		   ,GuideNumber
		   ,NoPiece
	FROM CTE_Ranked
	--WHERE RowNum = 1
	UNION
	SELECT DOP.GuideSerie
	       ,DOP.GuideNumber
	       ,DOP.NoPiece
	  FROM DeliveryBackOffice.dbo.ShippingContainer CT WITH (NOLOCK)
	       INNER JOIN DeliveryBackOffice.dbo.ShippingContainerDetail CTD WITH (NOLOCK) 
              ON CT.IdContainer = CTD.IdContainer
	       INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
		   ON CTD.GuideSerie = DOP.GuideSerie
	   AND CTD.GuideNumber = DOP.GuideNumber
	 WHERE CT.IdStatusContainer = @StatusContainerCreated
	   AND CTD.RowStatus = 1
	   AND CT.ReferenceContainer IN (
			SELECT ContainerReference
			FROM @Container
			)		
END