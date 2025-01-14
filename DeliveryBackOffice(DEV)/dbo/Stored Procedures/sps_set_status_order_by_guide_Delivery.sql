

-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2021-05-14>
-- Description:	<Se crea un servicio de entrega>
-- =============================================
-- Author:		<Tito Garcia>
-- Updated date:<18-12-2024>
-- Description:	<Se realizan optimizaciones recomendadas por DBA>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_status_order_by_guide_Delivery]
		@Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
		@Guide_Number AS VARCHAR(MAX), -- a list of guides separated by comma
		@StatusId AS INT, -- status from StatusOrder
		@TokenId AS VARCHAR(50),
		@DateOfStatus DATETIME, -- datetime of event
		@Observations AS VARCHAR(200) = '', --Observations by checkpoint
		@Temperature_Celsius AS DECIMAL(5,2) = 0.00,
		@courierName as varchar(200) = '',

		@IdRoute as int,
		@cuiCourier as varchar(200) = '',
		@idVehicle as int
AS
BEGIN
	DECLARE @IdRouteASG INT
	DECLARE @IdServiceManagement INT
	DECLARE @ExistePiezaPorServicio INT
	DECLARE @route varchar(100)

	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	Declare @idCourier int

	BEGIN TRANSACTION

		BEGIN TRY
			IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

			-- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
			SELECT
				SUBSTRING(Item, 1, 2) ItemSerie,
				SUBSTRING(Item, 3, 
				IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber,
				SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
				--, 
				--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
				--CHARINDEX('-',Item) charinde,  
				--len(Item) len
			INTO #listGuides
			FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number, ',')

			SET @idCourier = (select ID from DeliveryBackOffice.dbo.SenderReceiver snr where snr.CUI = @cuiCourier)
			SET @route = (select ctr.CodeRoute from DeliveryBackOffice.dbo.CatRoute ctr where ctr.IdRoute = @IdRoute)

			IF EXISTS (SELECT * FROM RouteAssigment ra
						WHERE ra.IdRoute = @IdRoute AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))
			BEGIN
				PRINT 'entra si existe ruta'

				SET @IdRouteASG = (SELECT ra.IdRouteAssigment
									FROM RouteAssigment ra
									WHERE ra.IdRoute = @IdRoute AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))
				
			END
			ELSE
			BEGIN

				PRINT 'entra no existe ruta'

				INSERT INTO RouteAssigment (
					IdRoute, 
					IdCurrierMan, 
					IdVehicle, 
					DateOfRoute, 
					RowStatus, 
					TokenCreated, 
					DateCreated, 
					TokenUpdated, 
					DateUpdated)
				VALUES (
					@IdRoute, 
					@idCourier, 
					@IdVehicle, 
					CONVERT(CHAR(10), GETDATE(), 126), 
					1, 
					@TokenId, 
					GETDATE(), 
					NULL, 
					NULL);
			
				SET @IdRouteASG = SCOPE_IDENTITY();

			END
				
			declare @Addres nvarchar (600) = (select do.Receiver_Address 
												from #listGuides ls
												join DeliveryOrder do on do.Guide_Serie = ls.ItemSerie and do.Guide_Number = ls.ItemNumber)

			IF EXISTS (SELECT top(1) sm.IdServiceManagement FROM DeliveryBackOffice.dbo.ServiceManagement sm
							INNER JOIN RouteAssigment ra ON sm.IdDlRouteAssigment = ra.IdRouteAssigment AND ra.DateOfRoute =  CONVERT(CHAR(10), GETDATE(), 126)
							join PieceByService pbs on pbs.ServiceManagmentId = sm.IdServiceManagement
							join DeliveryOrderPiece dop on dop.GuidePiece = pbs.GuidePieceId
							inner join DeliveryOrder do on dop.GuideNumber = do.Guide_Number and dop.GuideSerie = do.Guide_Serie
						WHERE do.Receiver_Address = @Addres and ra.IdRoute = @IdRoute)
			BEGIN		
				PRINT 'entra existe servicio'
				
				SET @IdServiceManagement = (SELECT top(1) sm.IdServiceManagement
											FROM ServiceManagement sm
												INNER JOIN RouteAssigment ra ON sm.IdDlRouteAssigment = ra.IdRouteAssigment AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
											WHERE sm.IdDlRouteAssigment = @IdRouteASG)
			END
			ELSE
			BEGIN
				PRINT 'entra no existe servicio'

				---========= insert servicio
				INSERT INTO dbo.ServiceManagement (
					IdDlCourrier,
					IdDlRouteAssigment,
					RowStatus, 
					TokenCreated, 
					DateCreated, 						
					ServiceStatusId, 
					SubTypeServiceManagmentId
				)
				VALUES(
					@idCourier,
					@IdRouteASG,
					1,
					@TokenId,
					GETDATE(),
					1,
					2
				)

				SET @IdServiceManagement = SCOPE_IDENTITY();

			END

			IF NOT EXISTS (SELECT * FROM DeliveryBackOffice.dbo.PieceByService pbs
							INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece dop ON dop.GuidePiece = pbs.GuidePieceId
							WHERE CONCAT(dop.GuideSerie, CAST(dop.GuideNumber as varchar), '-', CAST (dop.NoPiece as varchar)) = @Guide_Number and pbs.ServiceManagmentId = @IdServiceManagement)
			BEGIN
				--========================== Se registra en una tabla de control el id de servicio y de piezas ======
				PRINT 'dentro @ExistePiezaPorServicio'

				INSERT INTO dbo.PieceByService (
					ServiceManagmentId, 
					GuidePieceId, 
					RowStatus,
					TokenCreated, 
					DateCreated, 
					TokenUpdated, 
					DateUpdated
				)
				SELECT
					@IdServiceManagement,
					pc.GuidePiece,
					1,
					@TokenId,
					GETDATE(),
					NULL,
					NULL
				FROM DeliveryOrderPiece pc
				WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
			END
				
			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece			
				SET StatusOrderId = @StatusId
			WHERE GuideNumber IN (SELECT ItemNumber FROM #listGuides)
				AND NoPiece IN (SELECT ItemPiece FROM #listGuides)

			-- Actualizar registro de guía a último estado 

			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET 
					StatusOrderId = @StatusId,
					Courier_Route = @route,
					Courier_Name = @courierName,
					Dispatched_Date = GETDATE()
			WHERE Guide_Serie = @Guide_Serie
				AND Guide_Number IN (SELECT ItemNumber FROM #listGuides)

			SET @RowUpdated = @@rowcount
				
			IF (@RowUpdated > 0)
			BEGIN
				-- Insertar nuevo estado de guía en tabla histórica
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail (
					[Guide_Serie], 
					[Guide_Number], 
					[StatusOrderId], 
					[UserCreated], 
					[DateCreated], 
					[DateCreatedInSystem], 
					[Observations], 
					[Temperature_Celsius],
					[PieceId])
				SELECT 
					@Guide_Serie, 
					it.ItemNumber, 
					@StatusId, 
					@TokenId, 
					@DateOfStatus, 
					GETDATE(), 
					@Observations, 
					@Temperature_Celsius,
					it.ItemPiece
				FROM #listGuides it

				SET @ValidateOperation = COALESCE(@@rowcount, 0)

			END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@ValidateOperation > 0)
			BEGIN
				SELECT
					CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR)) AS NUMGUIA,
					CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR), '-', CAST(dop.NoPiece AS VARCHAR)) GUIA,
					ISNULL(dod.Ticket_Number, ' ') AS Ticket_Number,
					ISNULL(dod.Sender_FirstName, ' ') + ' ' + ISNULL(dod.Sender_LastName, '') NAME,
					dod.Sender_Address AS HUB_ORIGEN,
					dod.Sender_Address AS HUB_DESTINO,
	
					(SELECT ISNULL(COUNT(1),0) 
					FROM dbo.PieceByService pbs
						INNER JOIN DeliveryOrderPiece pci ON pci.GuidePiece = pbs.GuidePieceId
					WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR))
						AND pbs.ServiceManagmentId = @IdServiceManagement) PIEZAS_PROCESADAS,
	
					CASE WHEN (CAST((SELECT ISNULL(COUNT(1),0)
								FROM dbo.PieceByService pbs
									INNER JOIN DeliveryOrderPiece pci ON pci.GuidePiece = pbs.GuidePieceId
								WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR))
									AND pbs.ServiceManagmentId = @IdServiceManagement)
								AS VARCHAR(50)) = CAST(dod.Pieces_Dry + dod.Pieces_Cold AS VARCHAR(50))) THEN
									1
								ELSE 
									0
								END  AS CANT_PIEZAS_TOTAL,
	
					CAST((SELECT ISNULL(COUNT(1),0)
							FROM dbo.PieceByService pbs
								INNER JOIN DeliveryOrderPiece pci ON pci.GuidePiece = pbs.GuidePieceId
							WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR))
								AND pbs.ServiceManagmentId = @IdServiceManagement)
							AS VARCHAR(50)) + ' de ' + CAST(dod.Pieces_Dry + dod.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES
							-- ,1 as RUTA
							-- ,getdate() as FechaRuta
							--,200 as StatusCode
				FROM DeliveryBackOffice.dbo.DeliveryOrder dod
					JOIN DeliveryOrderPiece dop ON dod.Guide_Number = dop.GuideNumber AND dod.Guide_Serie = dop.GuideSerie
				WHERE CONCAT(dop.GuideSerie, CAST(dop.GuideNumber AS VARCHAR), '-', CAST(dop.NoPiece AS VARCHAR)) = @Guide_Number
				--AND @ExistePiezaPorServicio = 0
			END
			--ELSE
			--BEGIN
				--	SELECT
				--		0 AS 'StatusCode'
				--	   ,'El registro no existe' AS 'Description'
				--	   ,@ValidateOperation AS 'NumTransferID'
			--END
			COMMIT TRANSACTION;			
		END
END