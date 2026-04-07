/* =================================================
   SP:        GetGuidesByContainerByReference_FDAPI-5679
   Propósito: Se crea SP para obtener todos los lotes de recolección Manual que aun no han sido procesados para el servicio
   Autor:     Caleb Loarca
   Historia:  ---
   Fecha:     2026-03-30

=== CHANGELOG ============================
2026-03-30 | Historia/épica: FDAPI-5679  | Autor: Caleb Loarca | Se usa de base GetGuidesByContainerByReference, Se obtienen todos los lotes que aun no han sido procesados para el servicio
=========================================== */

ALTER PROCEDURE [dbo].[GetGuidesByContainerByReference_FDAPI-5679]
	@Container TblContainerList READONLY,
	@References TblReferencesList READONLY,
	@IdCountry NVARCHAR(2) = 'GT'
	--@IdPickup INT = NULL
AS
BEGIN
	DECLARE 
	@StatusContainerCreated INT,
	@IdCustomerPickup INT;

	SET @StatusContainerCreated = (
			SELECT IdCatStatus
			FROM CatShipContainerStatus WITH (NOLOCK)
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
	        FROM DeliveryOrder DO WITH (NOLOCK)
	             INNER JOIN DeliveryOrderPiece DOP WITH(NOLOCK)
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
	UNION
	SELECT DOP.GuideSerie
	       ,DOP.GuideNumber
	       ,DOP.NoPiece
	  FROM ShippingContainer CT WITH (NOLOCK)
	       INNER JOIN ShippingContainerDetail CTD WITH (NOLOCK) 
              ON CT.IdContainer = CTD.IdContainer
	       INNER JOIN DeliveryOrderPiece DOP WITH (NOLOCK)
		   ON CTD.GuideSerie = DOP.GuideSerie
	   AND CTD.GuideNumber = DOP.GuideNumber
	 WHERE CT.IdStatusContainer = @StatusContainerCreated
	   AND CTD.RowStatus = 1
	   AND CT.ReferenceContainer IN (
			SELECT ContainerReference
			FROM @Container
			)

END

