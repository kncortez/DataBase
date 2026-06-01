/* =================================================
   SP:        [dbo].[spws_get_validate_guides_pickupByHand]
   Propósito: <Verifica si existen guias si estan en estado 15 (generado) o 1(solicitado) Si no estan asignadas a otra recolección manual (IdPickup) >
   Autor:     Caleb Loarca
   Historia:  <FDAPI-5679>
   Fecha:     <2026-03-30>
   === CHANGELOG ============================
2026-03-30 | Historia/épica: <FDAPI-5679> | Autor: Caleb Loarca | Se usa de base SP dbo.spws_get_validate_guides_pickup, para uso en recolecciones manuales
=========================================== */
CREATE PROCEDURE [dbo].[spws_get_validate_guides_pickupByHand]
    -- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(MAX) = 'FD138515,FD138513,FD13852,FD138514,FD138545,FD135539',   
    @Token NVARCHAR(50),
    @ReferencesGuide TblReferencesList READONLY,  
	@ContainerReferences TblContainerList READONLY,  
	@IdCountry NVARCHAR(2)= 'GT' 
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#ErrorGuides', 'U') IS NOT NULL
            DROP TABLE #ErrorGuides;

        DECLARE @StatusContainerPickUp INT;

	    SET @StatusContainerPickUp = (SELECT IdCatStatus
									    FROM DeliveryBackOffice.dbo.CatShipContainerStatus WITH(NOLOCK)
									    WHERE [Name]= 'Creado');

			 CREATE TABLE #listGuides
                (
                    ItemSerie NVARCHAR(2),
                    ItemNumber INT,
                    ItemPiece INT,
					charinde NVARCHAR(10),
					Item INT
                );
            -- BUSCAR GUIAS POR REFERENCIA Y CONTENEDOR  
        WITH CTE_Ranked AS (
		        SELECT  DOP.GuideSerie, 
			            DOP.GuideNumber, 
			            DOP.NoPiece,
			            DO.Ticket_Number,
			            ROW_NUMBER() OVER (PARTITION BY DO.Ticket_Number ORDER BY DOP.GuideSerie DESC, DOP.GuideNumber DESC) AS RowNum,
			            DO.DateCreated
		        FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
		        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH(NOLOCK)
			        ON DO.Guide_Serie = DOP.GuideSerie
			        AND DO.Guide_Number = DOP.GuideNumber
		        WHERE DO.Ticket_Number IN (SELECT ReferenceGuide FROM @ReferencesGuide WHERE ReferenceGuide NOT IN ('','0'))
			        AND ISNULL(DO.SenderCountryId, 'GT') = @IdCountry
	    )
		INSERT INTO #listGuides
		(
			ItemSerie,
			ItemNumber,
			ItemPiece,
			charinde,
			Item
		)
       SELECT   GuideSerie, 
		        GuideNumber, 
		        NoPiece,
		        '',
		        1
	    FROM CTE_Ranked
	    WHERE RowNum = 1
	    UNION
	    SELECT  DOP.GuideSerie, 
			    DOP.GuideNumber, 
			    DOP.NoPiece, 
			    '',
			    1
	    FROM DeliveryBackOffice.dbo.ShippingContainer CT WITH (NOLOCK)
	    INNER JOIN DeliveryBackOffice.dbo.ShippingContainerDetail CTD WITH (NOLOCK)
		    ON CT.IdContainer = CTD.IdContainer
	    INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
		    ON CTD.GuideSerie = DOP.GuideSerie
		    AND CTD.GuideNumber = DOP.GuideNumber
	    WHERE CT.IdStatusContainer = @StatusContainerPickUp
		    AND CTD.RowStatus = 1
		    AND CT.ReferenceContainer IN (SELECT ContainerReference FROM  @ContainerReferences)
	    UNION
        SELECT SUBSTRING(Item, 1, 2) ItemSerie,
               SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
               ISNULL(   (CASE
										WHEN LEN(SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))) > 1 THEN
											1
										ELSE
											SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(Item))
									END
									),
									0
								) ItemPiece,
               CHARINDEX('-', Item) charinde,
               LEN(Item) len
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

		CREATE NONCLUSTERED INDEX IX_listGuides_Pickup
            ON #listGuides (ItemSerie, ItemNumber);
			
        --Se inserta log de cambio de recolección a un servicio
        INSERT INTO DeliveryBackOffice.dbo.ServicePickupLog
        (
            GuideSerie,
            GuideNumber,
            OldIdHeaderRecolection,
            NewIdHeaderRecolection,
            RowStatus,
            TokenCreated,
            DateCreated,
            TokenUpdated,
            DateUpdated
        )
        SELECT DISTINCT
               g.ItemSerie,
               g.ItemNumber,
               COALESCE(dopd.IdHeaderRecolection, -1),
               COALESCE(dopd.IdHeaderRecolection, -1),-- @IdPickup,
               1,
               @Token,
               GETDATE(),
               NULL,
               NULL
        FROM #listGuides g
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd WITH(NOLOCK)
                ON dopd.GuideSerie = g.ItemSerie
                   AND dopd.GuideNumber = g.ItemNumber
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
                ON do.Guide_Serie = g.ItemSerie
                   AND do.Guide_Number = g.ItemNumber
        WHERE do.StatusOrderId IN ( 16, 15, 1,21,20, 10 );  
			  

        SELECT DISTINCT
               lst.ItemSerie,
               lst.ItemNumber,
               ISNULL(dr.Guide_Number, 0) exist,              
               IIF(dr.StatusOrderId IN ( 16, 15, 1,21,20, 10 ), 1, 0) status,
               st.OrderDescription,			   
               1 samecountry,
			   DR.SenderCountryId guidecountry			           
        INTO #ErrorGuides
        FROM #listGuides lst
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder dr WITH(NOLOCK)
                ON dr.Guide_Serie = lst.ItemSerie
                   AND dr.Guide_Number = lst.ItemNumber
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail pyt WITH(NOLOCK)
                ON pyt.GuideSerie = dr.Guide_Serie
                   AND pyt.GuideNumber = dr.Guide_Number
            LEFT JOIN DeliveryBackOffice.dbo.StatusOrder st WITH(NOLOCK)
                ON st.StatusOrderId = dr.StatusOrderId
				WHERE
	      dr.StatusOrderId IN ( SELECT
									SO.[StatusOrderId]
								FROM
									DeliveryBackOffice.dbo.[StatusOrder] SO  WITH(NOLOCK)
								WHERE
									[CatCheckpointTypeId] = 3 And SO.RowStatus =1
							)

		CREATE NONCLUSTERED INDEX IX_ErrorGuides_Exist
            ON #ErrorGuides (exist);

		CREATE NONCLUSTERED INDEX IX_ErrorGuides_status
            ON #ErrorGuides (status);
			        

        SELECT CONCAT(er.ItemSerie, er.ItemNumber) Guide,
			(
			CASE 
				WHEN er.exist = 0 THEN
					'Servicio no existe'
				ELSE
					er.OrderDescription
				END
			) Mensaje            
        FROM #ErrorGuides er
        WHERE (er.exist = 0
              OR er.status = 0 OR ER.samecountry=0);

    END TRY
    BEGIN CATCH
        SELECT CAST(ERROR_NUMBER() AS NVARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS NVARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS NVARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS NVARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS NVARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS NVARCHAR(500)) AS ErrorMessage;

    END CATCH;

END;