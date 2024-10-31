-- =============================================
-- Author:		<Cristian Azurdia>
-- Create date: <2024-09-13>
-- Description:	<Obtiene información para la liquidación de rutas unificadas COD en desktop>
-- =============================================
CREATE PROCEDURE [dbo].[GetSettlementCODUnifiedRoute]
	@IdRoute INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DateProduction AS DATE = '2024-10-01'; -- Fecha de deploy a producción

    DECLARE @GuideSerie NVARCHAR(2);
    DECLARE @GuideNumber INT;

    DECLARE @GuidesFound TABLE
    (
		[Id]			 BIGINT,
        [Guide_Serie]	 NVARCHAR(2),
        [Guide_Number]	 INT,
		[Status]		 INT,
		[StatusDescription]     NVARCHAR(64)
    );

    DECLARE @StatusOrderValid TABLE
    (
        StatusCode BIT,
        [Description] VARCHAR(100)
    );

    INSERT INTO @GuidesFound
	SELECT	s.[id], 
			s.[Guide_Serie], 
			s.[Guide_Number], 
			s.[Status], 
			s.[StatusDescription]
	FROM
	(
		SELECT DISTINCT
			   dsd.ID_DeliveryOrderBySettlement [id]
			   ,dsd.Guide_Serie
			   ,dsd.Guide_Number
			   ,msi.CatManifestSettlementIncidenceTypeId  [Status]
			   ,CASE WHEN msi.CatManifestSettlementIncidenceTypeId IS NOT NULL AND msi.CatManifestSettlementIncidenceTypeId > 0 AND msi.isCOD = 1 THEN 'Liquidado con Incidencia'
					 WHEN dbs.User_Received_COD IS NOT NULL AND dbs.Date_Received_COD IS NOT NULL THEN 'Liquidado'
					 ELSE 'Pendiente'
				END AS [StatusDescription]
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK) 
				ON dsd.ID_DeliveryOrderBySettlement = dbs.ID
			LEFT JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence msi WITH(NOLOCK)
					ON dbs.ID = msi.ManifestNumber
			LEFT JOIN DeliveryBackOffice.dbo.CatStation cs
				ON cs.IdStation = dbs.DispatchedStationId
		WHERE CAST(dbs.Date_Dispatched AS DATE) = CAST(GETDATE() AS DATE)
		  AND dsd.RowStatus = 1   
		  AND dbs.CATRouteId = @IdRoute
		UNION
		SELECT DISTINCT
			   dsd.ID_DeliveryOrderBySettlement [id]
			   ,dsd.Guide_Serie
			   ,dsd.Guide_Number
			   ,msi.CatManifestSettlementIncidenceTypeId  [Status]
			   ,'Pendiente'  [StatusDescription]
		FROM DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs  WITH(NOLOCK) 
			INNER JOIN DeliveryBackOffice.dbo.DeliverySettlementDetail dsd  WITH(NOLOCK) 
				ON dsd.ID_DeliveryOrderBySettlement = dbs.ID
			LEFT JOIN DeliveryBackOffice.dbo.ManifestSettlementIncidence msi WITH(NOLOCK)
					ON dbs.ID = msi.ManifestNumber
			LEFT JOIN DeliveryBackOffice.dbo.CatStation cs
				ON cs.IdStation = dbs.DispatchedStationId
		WHERE CAST(dbs.Date_Dispatched AS DATE) > @DateProduction
		  AND dsd.RowStatus = 1
		  AND dbs.CATRouteId = @IdRoute
		  AND dbs.Date_Received_COD IS NULL
		  AND dbs.User_Received_COD IS NULL 
		  AND CAST(dbs.Date_Dispatched AS DATE) < CAST(GETDATE() AS DATE)  
	) AS s


    SELECT distinct
		   dbs.ID,
           dbs.Date_Dispatched,
           dbs.Pieces_Dry_Dispatched,
           dbs.Pieces_Cold_Dispatched,
           dbs.Guides_Dispatched,
           dbs.ID_Courier,
           ISNULL(sr.First_Name, '') + ' ' + ISNULL(sr.Last_Name, '') AS Courier_Name
    FROM  @GuidesFound gf
		INNER JOIN	DeliveryBackOffice.dbo.DeliveryOrderBySettlement dbs
			ON gf.Id = dbs.ID
        INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr
            ON sr.ID = dbs.ID_Courier
        --LEFT JOIN DeliveryBackOffice.dbo.CatStation cs
            --ON cs.IdStation = dbs.DispatchedStationId
    --WHERE dbs.CATRouteId = @IdRoute;

    DECLARE @GuidesDetail TABLE
    (
		id			INT,
        Guide		NVARCHAR(16),
        GuideSerie	NVARCHAR(2),
        GuideNumber INT,
        Delivered	BIT,
        Price		DECIMAL(18, 2),
        COD			DECIMAL(18, 2),
        Total		DECIMAL(18, 2),
        FEL			VARCHAR(251),
        StatusOrderId	 TINYINT,
        OrderDescription NVARCHAR(100),
        StatusOrderValid BIT,
        DescriptionStatusOrderValid VARCHAR(100)
    );

    INSERT INTO @GuidesDetail
    SELECT DISTINCT
		   gf.id id,
           do.Guide_Serie + CONVERT(VARCHAR, do.Guide_Number) AS Guide,
           do.Guide_Serie GuideSerie,
           do.Guide_Number GuideNumber,
           (ISNULL(
            (
                SELECT TOP 1
                       1
                FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod
                WHERE dod.Guide_Serie = gf.Guide_Serie
                      AND dod.Guide_Number = gf.Guide_Number
                      AND dod.StatusOrderId = 5
            ),
            0
                  )
           ) AS Delivered,
           CAST(IIF(do.IsCollect = 'TRUE', IIF(do.IsLastMileReturn = 1, ISNULL(CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE do.PriceShippment END, 0), do.PriceShippment), 0) AS DECIMAL(18, 2)) AS Price,
           CAST(ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0) AS DECIMAL(18, 2)) AS COD,
           CAST(IIF(do.IsCollect = 'TRUE',
                    (ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0) + IIF(do.IsLastMileReturn = 1, ISNULL(CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.PriceShippment / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.PriceShippment * c.codExchangeRate) * c.CODPaymentExchangeRate), do.PriceShippment) END, 0), do.PriceShippment)),
                    ISNULL((CASE WHEN [do].[IsLastMileReturn] = 1 THEN 0 ELSE IIF(do.GuideType = 'INT', IIF(c.CodCurrency = 1, (do.Collect_OnDelivery / c.codExchangeRate) * c.CODPaymentExchangeRate, (do.Collect_OnDelivery * c.codExchangeRate) * c.CODPaymentExchangeRate), do.Collect_OnDelivery) END), 0)) AS DECIMAL(18, 2)) AS Total,
           CASE
               WHEN invh.inv_serieFEL IS NULL
                    OR invh.inv_serieFEL = '' THEN
                   NULL
               ELSE
                   CONCAT(invh.inv_serieFEL, '-', invh.inv_numberFEL)
           END FEL,
           gf.[Status] StatusOrderId,
           gf.[StatusDescription] OrderDescription,
           0 StatusOrderValid,
           NULL DescriptionStatusOrderValid
    FROM @GuidesFound gf
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do  WITH(NOLOCK) 
            ON do.Guide_Serie = gf.Guide_Serie
            AND do.Guide_Number = gf.Guide_Number
        LEFT JOIN
        (
            SELECT MAX(invh1.inv_serieFEL) inv_serieFEL,
                   MAX(invh1.inv_numberFEL) inv_numberFEL,
                   invd.dti_fk_orderSerie dti_fk_orderSerie,
                   invd.dti_fk_orderNumber dti_fk_orderNumber
            FROM DeliveryBackOffice.dbo.invoiceDetail invd  WITH(NOLOCK) 
                INNER JOIN DeliveryBackOffice.dbo.invoiceHeader invh1  WITH(NOLOCK) 
                    ON invh1.inv_pk_id = invd.dti_fk_header
                       AND invh1.inv_descriptionFEL = 'PROCESO REALIZADO'
                       AND invh1.inv_invoiceOfCreditNote IS NULL
            GROUP BY invd.dti_fk_orderSerie,
                     invd.dti_fk_orderNumber
        ) invh
            ON invh.dti_fk_orderSerie = do.Guide_Serie
               AND invh.dti_fk_orderNumber = do.Guide_Number
        LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vp  WITH(NOLOCK) 
            ON do.Receiver_ID = vp.CodeOfReference
		LEFT JOIN [dbo].VisitPointClient vps WITH(NOLOCK)
			ON vps.CodeOfReference = do.Sender_ID
		LEFT JOIN [dbo].[Customer] cu WITH(NOLOCK)
			ON ISNULL(do.[IdCustomer], vps.CustomerID) = cu.[IdCustomer]
		LEFT JOIN [dbo].Cost c WITH(NOLOCK)
			ON c.GuideSerie = do.Guide_Serie 
			AND c.GuideNumber = do.Guide_Number
		LEFT JOIN dbo.CatConditionOfPayment cdp WITH (NOLOCK)
            ON cdp.IdConditionOfPayment = cu.ConditionOfPaymentID
               AND cdp.IdConditionOfPayment > 1
    WHERE (
              (CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END > 0)
              OR
              (
                  do.IsCollect = 1
                  AND IIF(do.IsLastMileReturn = 1, ISNULL(CASE WHEN ISNULL(cdp.IdConditionOfPayment, 1) > 1 THEN 0 ELSE do.PriceShippment END, 0), do.PriceShippment) + CASE WHEN do.IsLastMileReturn = 1 THEN 0 ELSE do.Collect_OnDelivery END > 0
              )
          )
          AND
          (
              vp.IdKindOfVPClient <> 1
              OR vp.IdKindOfVPClient IS NULL
          );


    --Validar el estado guía por guía
    -- mientras la tabla no este vacía
    WHILE EXISTS (SELECT 1 FROM @GuidesFound)
    BEGIN
        -- se obtiene la guía a iterar
        SELECT TOP 1
               @GuideSerie = Guide_Serie,
               @GuideNumber = Guide_Number
        FROM @GuidesFound;


        INSERT @StatusOrderValid
        EXEC GetStatusOrderValid @GuideSerie, @GuideNumber, @StatusOrderId = 24;


        UPDATE @GuidesDetail
        SET StatusOrderValid =
            (
                SELECT TOP 1 StatusCode FROM @StatusOrderValid
            ),
            DescriptionStatusOrderValid =
            (
                SELECT TOP 1 Description FROM @StatusOrderValid
            )
            /*,OrderDescription =
            (
                SELECT so.OrderDescription
                FROM StatusOrder so  WITH(NOLOCK) 
                WHERE so.StatusOrderId =
                (
                    SELECT StatusOrderId
                    FROM @GuidesDetail
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                )
            )*/
        WHERE GuideSerie = @GuideSerie
              AND GuideNumber = @GuideNumber;

        -- se elimina la guía de la tabla temporal
        DELETE @GuidesFound
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber;

        -- se elimina los datos en @StatusOrderValid
        DELETE FROM @StatusOrderValid;

    END;

    SELECT SUM(Total) AS COD_Manifest
    FROM @GuidesDetail;

    SELECT  id
			,Guide		
			,GuideSerie
			,GuideNumber
			,Delivered
			,Price
			,COD
			,Total
			,FEL
			,StatusOrderId
			,OrderDescription
			,StatusOrderValid
			,DescriptionStatusOrderValid
    FROM @GuidesDetail gd
    ORDER BY gd.id DESC;

END
