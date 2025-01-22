-- =============================================  
-- Author:    <Brandon, Pedroza>  
-- Create date: <2025-01-13>  
-- Description: <Contenerizacion guias - obtiene las guias por referencia y por contenedor>  
-- =============================================  
CREATE PROCEDURE [dbo].[GetGuidesByContainerByReference]
	@Container TblContainerList READONLY,
	@References TblReferencesList READONLY,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	DECLARE @StatusContainerPickUp INT;

	SET @StatusContainerPickUp = (
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
       )
	SELECT GuideSerie
		   ,GuideNumber
		   ,NoPiece
	FROM CTE_Ranked
	WHERE RowNum = 1
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
	 WHERE CT.IdStatusContainer = @StatusContainerPickUp
	   AND CTD.RowStatus = 1
	   AND CT.ReferenceContainer IN (
			SELECT ContainerReference
			FROM @Container
			)
END
