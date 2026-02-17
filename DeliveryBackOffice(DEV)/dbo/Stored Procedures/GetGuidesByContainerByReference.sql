/* =================================================
   SP:        [dbo].[GetGuidesByContainerByReference]
   Propósito: <Contenerizacion guias - obtiene las guias por referencia y por contenedor>
   Autor:     Brandon Pedroza
   Historia:  <>
   Fecha:     <2025-01-13>
   === CHANGELOG ============================
2025-02-04 | Historia/épica: <> | Autor: Brandon Pedroza | <Contenerizacion guias - aceptar paquete unicamente del cliente asignado a la recoleccion>  
2026-02-17 | Historia/épica: <FDAPI-5552> | Autor: Erick Hernandez | 
=========================================== */
CREATE PROCEDURE [dbo].[GetGuidesByContainerByReference]
	@Container TblContainerList READONLY,
	@References TblReferencesList READONLY,
	@IdCountry NVARCHAR(2) = 'GT',
	@IdPickup INT = NULL
AS
BEGIN
	DECLARE @StatusContainerCreated INT,@IdCustomerPickup INT;

	SET @StatusContainerCreated = (
			SELECT IdCatStatus
			FROM DeliveryBackOffice.dbo.CatShipContainerStatus WITH (NOLOCK)
			WHERE [Name] = 'Creado'
			);

	SET @IdCustomerPickup =(
		SELECT TOP 1 VPC.CustomerID
			FROM DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
						INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
						ON SP.SenderId = VPC.CodeOfReference
						WHERE SP.SchedulePickupStatus = 1
						AND SP.SchedulePickupId =@IdPickup
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
            AND DO.SenderCountryId = @IdCountry 
			AND DO.StatusOrderId IN (1,15,50)
			AND DO.IdCustomer =@IdCustomerPickup
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
		AND CT.IdCustomer = @IdCustomerPickup
END
