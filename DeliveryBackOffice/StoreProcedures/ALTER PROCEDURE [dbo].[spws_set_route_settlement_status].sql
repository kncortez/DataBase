USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_set_route_settlement_status]    Script Date: 4/02/2022 02:37:58 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-04>
-- Description:	<Cambia de estado de recolectado a ingreso a instalaciones>
-- =============================================

ALTER PROCEDURE [dbo].[spws_set_route_settlement_status]
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
    @GuidePiece SMALLINT,
    @Token NVARCHAR(100),
    @Route VARCHAR(100),
    @CountryId VARCHAR(2)
AS
BEGIN

    DECLARE @RModified INT;
    DECLARE @RModified2 INT;
    DECLARE @RModified3 INT;

    DECLARE @GModif INT = 0;

    BEGIN TRANSACTION;
    BEGIN TRY


        DECLARE @stattus INT = 11;

        /* Inserción en tabla TransactionalBackbone para guardar 
			un registro de las piezas que se estan liquidando de una ruta										 
		 */

        DECLARE @inBound INT =
                (
                    SELECT IdTranportationZone
                    FROM DeliveryBackOffice.dbo.CatTransportationZone
                    WHERE Name = 'Ruta de recolección'
                );

        DECLARE @outBound INT =
                (
                    SELECT IdTranportationZone
                    FROM DeliveryBackOffice.dbo.CatTransportationZone
                    WHERE Name = 'Bodega'
                );

        DECLARE @idTransactionType INT =
                (
                    SELECT IdTransactionType
                    FROM DeliveryBackOffice.dbo.TransactionType
                    WHERE Name = 'Liquidación de Recolección'
                );

        DECLARE @IdRoute INT =
                (
                    SELECT IdRoute
                    FROM DeliveryBackOffice.dbo.CatRoute
                    WHERE CodeRoute = @Route
                );

        INSERT INTO DeliveryBackOffice.dbo.TransactionalBackbone
        (
            GuideSerie,
            GuideNumber,
            GuidePiece,
            RouteId,
            InBound,
            OutBound,
            LineHaul,
            StatusComplete,
            TransactionTypeId,
            CountryId,
            RowStatus,
            TokenCreated,
            DateCreated
        )
        SELECT DISTINCT
               @GuideSerie,
               @GuideNumber,
               @GuidePiece,
               @IdRoute,
               @inBound,
               @outBound,
               0,
               0,
               @idTransactionType,
               @CountryId,
               1,
               @Token,
               GETDATE()
        FROM DeliveryOrderPiece ord
            LEFT JOIN DeliveryOrderPaymentDetail dopd
                ON dopd.GuideSerie = @GuideSerie
                   AND dopd.GuideNumber = @GuideNumber
            LEFT JOIN ServiceManagement sm
                ON sm.IdSchedulePickup = dopd.IdHeaderRecolection
            LEFT JOIN RouteAssigment ra
                ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
                   AND ra.IdRoute = @IdRoute
        WHERE (
                  ord.GuideNumber = @GuideNumber
                  AND ord.GuideSerie = @GuideSerie
                  AND ord.NoPiece = @GuidePiece
                  AND
                  (
                      ord.StatusOrderId NOT IN ( 7, 11, 5 )
                      OR ord.StatusOrderId IS NULL
                  )
              )
              --AND --YA NO APLICA PORQUE EN LIQUIDACIÓN DE RECOLECCIÓN SE PUEDE LIQUIDAR GUÍAS QUE NO TIENEN
			  --ASOCIADAS RECOLECCIONES
              --(
              --    dopd.DopId IS NULL -- No tiene asociada una solicitud de recolección, Ej. generada
              --    OR
              --    (
              --        dopd.DopId IS NOT NULL -- tiene una solicitud de recolección
              --        --AND ra.IdRouteAssigment IS NOT NULL --pero no tiene ruta asignada
              --    )
              --    OR dopd.IdHeaderRecolection IS NULL -- la guía se generó pero no se solicitó recolección
              --);

        SET @RModified3 = @@rowcount;

        IF @RModified3 > 0
        BEGIN
            UPDATE dbo.DeliveryOrderPiece
            SET StatusOrderId = @stattus
            FROM dbo.DeliveryOrderPiece ord
            WHERE (
                      ord.GuideNumber = @GuideNumber
                      AND ord.GuideSerie = @GuideSerie
                      AND ord.NoPiece = @GuidePiece
                      AND
                      (
                          ord.StatusOrderId NOT IN ( 7, 11, 5 )
                          OR ord.StatusOrderId IS NULL
                      )
                  );
            --inner join dbo.DeliveryOrderPaymentDetail dop on (ord.GuideNumber = dop.GuideNumber and ord.GuideSerie = dop.GuideSerie and  (ord.StatusOrderId = 15 and dop.ShipmentCompleted = 1))

            SET @RModified = @@rowcount;
        END;
        --end
        --else
        --begin 
        --		update  dbo.DeliveryOrderPiece set StatusOrderId =  @stattus
        --		from dbo.DeliveryOrderPiece ord
        --		 inner join #listGuides ls on (ord.GuideNumber = ls.ItemNumber and ord.GuideSerie = ls.ItemSerie)
        --end
        ---variable que cuenta cuantas piezas estan asociadas a las guias.
        DECLARE @val INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryOrderPiece
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                );
        ---variable que cuenta cuantas piezas ya cambiaron de estado arribo a instalaciones (11).
        DECLARE @valu INT =
                (
                    SELECT COUNT(1)
                    FROM DeliveryOrderPiece
                    WHERE GuideSerie = @GuideSerie
                          AND GuideNumber = @GuideNumber
                          AND StatusOrderId = @stattus
                );

        --declare @value int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides))

        ---	 insertar checkpoint de arribo a instalaciones.	
        INSERT INTO dbo.DeliveryOrderDetail
        (
            [Guide_Serie],
            [Guide_Number],
            [StatusOrderId],
            [UserCreated],
            [DateCreated],
            [DateCreatedInSystem],
            [Observations],
            [Temperature_Celsius],
            [PieceId]
        )
        VALUES
        (@GuideSerie, @GuideNumber, @stattus, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece);

        SET @RModified2 = @@rowcount;

        IF (@val = @valu)
        BEGIN
            UPDATE do
            SET do.StatusOrderId = @stattus
            FROM DeliveryOrder do
            WHERE do.Guide_Serie = @GuideSerie
                  AND do.Guide_Number = @GuideNumber;
            SET @GModif = @@rowcount;

        -- Activar bandera de proceso de SMS
        -- Se comenta porque no está en uso
        --IF (@stattus = 4) --En ruta, (11) Arribó a instalaciones
        --	IF ((SELECT TOP 1
        --				ue.UpdateStatus
        --			FROM [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
        --			WHERE ue.RowStatus = 1
        --			AND ue.ElementId = 1001)
        --		= 0)
        --	BEGIN
        --		UPDATE [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
        --		SET UpdateStatus = 1
        --		   ,UpdateDateTime = GETDATE()
        --		WHERE RowStatus = 1
        --		AND ElementId = 1001
        --	END

        END;

		--Se marca como recolectado el servicio
		UPDATE sm
		SET ServiceStatusId = 3
		FROM ServiceManagement sm
		JOIN DeliveryOrderPaymentDetail dopd
			ON dopd.IdHeaderRecolection = sm.IdSchedulePickup
		WHERE
			dopd.GuideSerie = @GuideSerie AND dopd.GuideNumber = @GuideNumber

		--Validar si pertenece a un punto de visita
		DECLARE @tiempo DATE = (SELECT
			CAST(GETDATE() AS DATE))
		DECLARE @hasIdHeaderRecolection BIT
		DECLARE @Sender_ID INT
		DECLARE @SchedulePickupId INT
		
		SELECT
			@hasIdHeaderRecolection = IIF(dopd.IdHeaderRecolection IS NULL, 0, 1)
		   ,@Sender_ID = do.Sender_ID
		FROM DeliveryOrderPaymentDetail dopd
		JOIN DeliveryOrder do
			ON do.Guide_Serie = dopd.GuideSerie
				AND do.Guide_Number = dopd.GuideNumber
		WHERE dopd.GuideSerie = @GuideSerie
		AND dopd.GuideNumber = @GuideNumber

		--Si no tiene asociado un servicio y si el Sender_ID no es 0
		IF
		 @hasIdHeaderRecolection = 0 AND @Sender_ID <> 0
		BEGIN
			SELECT
				@SchedulePickupId = sm.IdSchedulePickup
			FROM RouteAssigment ra
			JOIN ServiceManagement sm
				ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
			JOIN SchedulePickup sp
				ON sp.SchedulePickupId = sm.IdSchedulePickup
			WHERE ra.IdRoute= @IdRoute
			AND ra.DateOfRoute = @tiempo
			AND sp.SenderId = @Sender_ID
			
			--Si se encuentra el visit point entre los servicios de recolección se asigna
			IF @SchedulePickupId IS NOT NULL
			BEGIN
				UPDATE DeliveryOrderPaymentDetail 
				SET IdHeaderRecolection = @SchedulePickupId
				WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber

				UPDATE sm
				SET ServiceStatusId = 3
				FROM ServiceManagement sm
				WHERE
					sm.IdSchedulePickup = @SchedulePickupId

			END
		END

    END TRY
    BEGIN CATCH


        SELECT 0 AS 'StatusCode',

               --	ERROR_MESSAGE() AS 'Description', 
               --	CONVERT(BIGINT, 0) AS 'NumTransferID',
               CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',
               0 AS 'SubStatusCode';
        ROLLBACK TRANSACTION;

        SELECT 'No se guardo el registro' AS StatusCode;
    --select ERROR_MESSAGE()
    -- retornar mensaje de error


    END CATCH;
    IF @@trancount > 0
    BEGIN

        IF (@RModified > 0 AND @RModified2 > 0)
        BEGIN

            SELECT 1 AS 'StatusCode',

                   --	'Registro guardado correctamente' AS 'Description', 
                   --	@@TRANCOUNT AS 'NumTransferID',
                   CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',

                   --@Amount AS 'Amount',
                   0 AS 'SubStatusCode';

            SELECT @GModif AS CONT;

			SELECT
				(CASE
					WHEN do.Manifest_Serie IS NOT NULL AND
						do.Manifest_Number IS NOT NULL THEN CONCAT(do.Manifest_Serie, '-', do.Manifest_Number)
					ELSE ''
				END) MANIFIESTO
			   ,ISNULL(sp.SenderName, vpc.DescriptionOfClient) REMITENTE
			   ,ISNULL(do.Pieces_Dry, 0) + ISNULL(do.Pieces_Cold, 0) PIECE
			   --,vpc.CodeOfReference CodeOfReference
			FROM RouteAssigment ra
			JOIN ServiceManagement sm
				ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
			JOIN SchedulePickup sp
				ON sp.SchedulePickupId = sm.IdSchedulePickup
			JOIN VisitPointClient vpc
				ON vpc.CodeOfReference = sp.SenderId
			LEFT JOIN DeliveryOrderPaymentDetail dopd
				ON dopd.IdHeaderRecolection = sp.SchedulePickupId
			LEFT JOIN DeliveryOrder do
				ON do.Guide_Serie = dopd.GuideSerie
					AND do.Guide_Number = dopd.GuideNumber
			JOIN CatRoute cr
				ON cr.IdRoute = ra.IdRoute
			WHERE cr.CodeRoute = @Route
			AND ra.DateOfRoute = @tiempo

            COMMIT TRANSACTION;
        END;

        ELSE
        BEGIN
            SELECT 0 AS 'StatusCode',

                   --	'Registro no encontrado' AS 'Description', 
                   --	0 AS 'NumTransferID',
                   CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide',

                   --@Amount AS 'Amount',
                   0 AS 'SubStatusCode';
            ROLLBACK TRANSACTION;
        END;
    END;
END;