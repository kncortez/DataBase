USE [DeliveryBackOffice]
GO
/* =================================================
   SP:        [dbo].[GetPickupManifestInfoByHand]
   Propósito: <Se obtiene la información de manifiesto de un IdPickup dado.>
   Autor:     Erick Guerra
   Historia:  <FDAPI-6324>
   Fecha:     <2026-05-21>
   === CHANGELOG ============================
   =========================================== */

CREATE OR ALTER PROCEDURE [dbo].[GetPickupManifestInfoByHand]
(
 @IdPickup INT
)
AS
BEGIN
    DECLARE @Guides NVARCHAR(MAX),
            @Token VARCHAR(200),
            @PickUpEmail NVARCHAR(200);

    IF EXISTS
    (
        SELECT TOP 1 1
            FROM DeliveryBackOffice.dbo.FinishPickUpHeader WITH (NOLOCK)
            WHERE SchedulePickupId = @IdPickup
            AND RowStatus = 1
    )
    BEGIN
        SELECT @Token = TokenCreated,
                @PickUpEmail = PickupEmail
            FROM DeliveryBackOffice.dbo.FinishPickUpHeader WITH (NOLOCK)
            WHERE SchedulePickupId = @IdPickup
                AND RowStatus = 1;

        SELECT 200 AS StatusCode,
            'Información obtenida correctamente' AS [Message],
            @Token AS Token,
            @PickUpEmail AS Email

        SELECT @Guides = STRING_AGG(CAST(Guide AS NVARCHAR(MAX)), ',')
            FROM (
                SELECT (CONCAT(GuideSerie, GuideNumber, '-', GuidePiece)) AS Guide
                    FROM DeliveryBackOffice.dbo.FinishPickUpDetail WITH (NOLOCK)
                    WHERE SchedulePickupId = @IdPickup
                    
                UNION ALL
                    
                SELECT (CONCAT(C.GuideSerie, C.GuideNumber, '-', C.NoPiece))
                    FROM   DeliveryBackOffice.dbo.FinishPickUpReferenceDetail A WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder B  WITH (NOLOCK)
                            ON A.Reference = B.Ticket_Number
                        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece C WITH (NOLOCK)
                            ON  B.Guide_Serie = C.GuideSerie AND
                                B.Guide_Number = C.GuideNumber
                    WHERE SchedulePickupId = @IdPickup
                        AND B.StatusOrderId <> 7 --Quitar guías anuladas
                        AND NOT EXISTS(
                            SELECT 1
                                FROM DeliveryBackOffice.dbo.DeliveryOrderDetail A1 WITH(NOLOCK)
                                WHERE A1.Guide_Serie = B.Guide_Serie
                                    AND  A1.Guide_Number = B.Guide_Number
                                    AND A1.StatusOrderId = 2 --No volver a marcar como recolectada una guía
                        )

                UNION ALL
                    
                SELECT (CONCAT(D.GuideSerie, D.GuideNumber, '-', D.NoPiece))
                    FROM DeliveryBackOffice.dbo.FinishPickUpContainerDetail A WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.ShippingContainer B WITH (NOLOCK)
                            ON A.Container = B.ReferenceContainer
                        INNER JOIN DeliveryBackOffice.dbo.ShippingContainerDetail C WITH (NOLOCK)
                            ON B.IdContainer = C.IdContainer
                        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece D WITH (NOLOCK)
                            ON  D.GuideSerie = C.GuideSerie AND
                                D.GuideNumber = C.GuideNumber
                        WHERE SchedulePickupId = @IdPickup
            ) [Data]

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;

        CREATE TABLE #listGuides
        (
            ItemSerie NVARCHAR(2),
            ItemNumber INT,
            ItemPiece INT,
			Sender_Mail NVARCHAR(100),
			CustomerId INT,
			IdCustomerType INT
        );

        INSERT INTO #listGuides
        (
            ItemSerie,
            ItemNumber,
            ItemPiece
        )

        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               ISNULL(
                (CASE
                    WHEN LEN(SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))) > 1
                        THEN 1
                    ELSE SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))
                    END
                ),
               0
               ) ItemPiece
            FROM DeliveryBackOffice.dbo.SplitUnlimited(@Guides, ',');

        CREATE NONCLUSTERED INDEX templistGuides_Piece495
            ON #listGuides
            (
                ItemSerie,
                ItemNumber
            );

        CREATE NONCLUSTERED INDEX templistGuides_4444
            ON #listGuides
            (
                ItemSerie,
                ItemNumber,
                ItemPiece
            );

        CREATE NONCLUSTERED INDEX templistGuides_4466
            ON #listGuides
            (
                ItemPiece
            );

        UPDATE [#listGuides]
            SET [ItemPiece] = 1
            WHERE [ItemPiece] = 0;


		UPDATE lg
			SET lg.[Sender_Mail] = COALESCE
            (
                NULLIF(NULLIF(c.OperationContactEmail, ''), ' '),  -- 1 opcion: email del contacto
				NULLIF(NULLIF(do.Sender_Mail, ''), ' '),            -- 2 opcion: email del remitente
				(                                                   -- 3 opcion: email de config
					SELECT [value] 
					FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
					WHERE [Name] = CONCAT('EmailByPickup', do.SenderCountryId)
				)
		    ),
            lg.[CustomerId] = do.IdCustomer,
			lg.[IdCustomerType] = c.IdCustomerType
			FROM [#listGuides] lg				 
			INNER JOIN DeliveryBackOffice.dbo.deliveryOrder do WITH (NOLOCK)
				ON do.Guide_Serie = lg.ItemSerie and 
				    do.Guide_Number = lg.ItemNumber
			INNER JOIN DeliveryBackOffice.dbo.Customer c WITH (NOLOCK)
				ON c.IdCustomer = do.IdCustomer

        SELECT distinct								
		       cpm.IdManifest AS  'IdManifest',
		       cpm.ManifestSerie AS  'Manifest_Serie',
		       cpmd.ManifestId AS  'Manifest_Number',
		       do.Sender_FirstName AS  'Sender_FirstName',
		       do.Sender_Address AS  'Sender_Address',
		       do.Sender_Zone AS  'Sender_Zone',
		       do.Sender_Town AS  'Sender_Town',
		       do.Sender_Department AS  'Sender_Department',
		       '0' AS  'Consolidated_Number',
		       ISNULL( lp.Sender_Mail, '' ) AS  'Sender_Email',
		       do.IdCustomer AS 'IdCustomer'
		    FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK) 
                INNER JOIN #listGuides lp
                    ON lp.ItemSerie = do.Guide_Serie
                            AND lp.ItemNumber = do.Guide_Number
                INNER JOIN DeliveryBackOffice.dbo.CourierPickupManifestDetail cpmd WITH (NOLOCK)
                    ON do.Guide_Serie = cpmd.GuideSerie
                            AND do.Guide_Number = cpmd.GuideNumber
				INNER JOIN DeliveryBackOffice.dbo.CourierPickupManifest cpm WITH (NOLOCK)
                    ON cpmd.ManifestId = cpm.IdManifest                                  
			GROUP BY                                
			    cpm.IdManifest,
			    cpm.ManifestSerie,
			    cpmd.ManifestId, 
			    do.Sender_FirstName,
			    do.Sender_Address, 
			    do.Sender_Zone, 
			    do.Sender_Town,
			    do.Sender_Department,
			    lp.Sender_Mail,
			    do.IdCustomer
			ORDER BY do.IdCustomer ASC;

        WITH GUIDEMONITOR 
        (
            GuideNumber,
            PiecesColdCounter,
            PiecesDryCounter,
            TotalPieces,
            Sender_Email,
            IdCustomer
        ) AS 
        (
            SELECT COALESCE(dop.GuideNumber, dop2.GuideNumber) GuideNumber,
                   COUNT(dop.GuideNumber) 'PiecesColdCounter',
                   COUNT(dop2.GuideNumber) 'PiecesDryCounter',
                   COUNT(dop.NoPiece) + COUNT(dop2.NoPiece) 'TotalPieces',
			       ISNULL(lp.Sender_Mail,'0') 'Sender_Email',
		           do.IdCustomer as 'IdCustomer'								 
                FROM #listGuides lp
                    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
                        ON lp.ItemSerie = dop.GuideSerie
                            AND lp.ItemNumber = dop.GuideNumber
                            AND lp.ItemPiece = dop.NoPiece
                            AND dop.IsDry = 0
                    LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop2 WITH (NOLOCK)
                        ON lp.ItemSerie = dop2.GuideSerie
                            AND lp.ItemNumber = dop2.GuideNumber
                            AND lp.ItemPiece = dop2.NoPiece
                            AND dop2.IsDry = 1
					LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
						ON lp.ItemSerie = do.Guide_Serie
						    AND lp.ItemNumber = do.Guide_Number							   
				GROUP BY dop.GuideNumber,
			  			 dop2.GuideNumber,
						 lp.Sender_Mail,
						 do.IdCustomer
        )

        SELECT COUNT(GM.GuideNumber) 'GuidesCounter',
               SUM(GM.PiecesColdCounter) 'PiecesColdCounter',
               SUM(GM.PiecesDryCounter) 'PiecesDryCounter',
               SUM(GM.TotalPieces) 'TotalPieces',
			   GM.Sender_Email,
			   GM.IdCustomer
            FROM GUIDEMONITOR GM
			GROUP BY GM.Sender_Email, GM.IdCustomer
			ORDER BY GM.IdCustomer ASC

        SELECT CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece) [Piece],
               CONCAT(do.Receiver_FirstName, ' ', do.Receiver_LastName)  [ReceiverName],
               LEFT(do.Receiver_Address, 200)                             [ReceiverAddress],
               do.ReceiverCountryId                                       [ReceiverCountryId],
               do.IndicationsToSendDestination                            [AdditionalIndications],
               ISNULL(dop.Detail, ca.ArtName)                             [Article],
			   ISNULL( lp.Sender_Mail,'0') as [Sender_Mail],
			   do.IdCustomer
             FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
                INNER JOIN #listGuides lp
                    ON lp.ItemSerie = dop.GuideSerie
                        AND lp.ItemNumber = dop.GuideNumber
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON do.Guide_Serie = dop.GuideSerie
                        AND do.Guide_Number = dop.GuideNumber
                LEFT JOIN DeliveryBackOffice.dbo.ArticleByCustomer abc WITH(NOLOCK)
                    ON dop.ParcelCode = abc.Code
                LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca WITH(NOLOCK)
                    ON ca.ArtId = abc.AbcIdArticle
            GROUP BY dop.GuideNumber,
                     dop.GuideSerie,
                     dop.NoPiece,
                     do.Receiver_FirstName,
                     do.Receiver_LastName,
                     do.Receiver_Address,
                     do.ReceiverCountryId,
                     do.IndicationsToSendDestination,
                     dop.Detail,
                     ca.ArtName,
			 		 lp.Sender_Mail,
		 			 do.IdCustomer
            ORDER BY do.IdCustomer ASC;
    END
    ELSE
    BEGIN
        SELECT 0 AS StatusCode,
                'No se encontro la recoleccion en los lotes' AS [Message],
                '' Token,
                '' Email
    END
END