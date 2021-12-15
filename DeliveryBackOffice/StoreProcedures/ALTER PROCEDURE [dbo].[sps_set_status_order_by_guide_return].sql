USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_status_order_by_guide_return]    Script Date: 10/12/2021 14:50:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-29>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================


ALTER PROCEDURE [dbo].[sps_set_status_order_by_guide_return] 
@Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
@Guide_Number AS VARCHAR(MAX), -- a list of guides separated by comma
@StatusId AS INT, -- status from StatusOrder
@TokenId AS VARCHAR(50),
@DateOfStatus DATETIME, -- datetime of event
@Observations AS VARCHAR(200) = '', --Observations by checkpoint
@Temperature_Celsius AS DECIMAL(5, 2) = 0.00,
@Route AS NVARCHAR(50) = 'Devolución',
@IdRoute AS NVARCHAR(50) = 99999,
@IdVehicle AS INT = 222,
@courier AS NVARCHAR(50) = 'SYS-SYSTEM',
@OPTION AS INT = 2


AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ExisteRuta INT
	
	DECLARE @IdRouteASG INT
	DECLARE @ExisteServicio INT
	DECLARE @IdServiceManagement INT
	DECLARE @ExistePiezaPorServicio INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)

	BEGIN TRANSACTION

	BEGIN TRY

		IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;

		-- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
				SELECT
					SUBSTRING(Item, 1, 2) ItemSerie
				   ,SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(item)), (CHARINDEX('-', Item) - 3))) ItemNumber
				   ,SUBSTRING(Item, CHARINDEX('-', Item) + 1, LEN(item)) ItemPiece
				--, 
				--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
				--CHARINDEX('-',Item) charinde,  
				--len(Item) len
				INTO #listGuides
				FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number, ',')


			SET @ExisteRuta = (SELECT
					COUNT(1)
				FROM RouteAssigment ra
				WHERE ra.IdRoute = @IdRoute
				AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))
		PRINT @ExisteRuta
			IF @ExisteRuta = 0
			BEGIN
			PRINT 'entra existe ruta = 0'
				INSERT INTO RouteAssigment (IdRoute, IdCurrierMan, IdVehicle, DateOfRoute, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
					VALUES (@IdRoute, CAST(@courier AS INT), @IdVehicle, CONVERT(CHAR(10), GETDATE(), 126), 1, @TokenId, GETDATE(), '', NULL);
				SET @IdRouteASG = SCOPE_IDENTITY();
			END
			ELSE
			BEGIN
			PRINT 'entra existe ruta = 1'
		
				SET @IdRouteASG = (SELECT
						ra.IdRouteAssigment
					FROM RouteAssigment ra
					WHERE ra.IdRoute = @IdRoute
					AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))
				PRINT @IdRouteASG
			end 

		PRINT '@IdRouteASG'
		PRINT @IdRouteASG
			if @IdRouteASG <> 0
			begin

			declare @Addres nvarchar (600) = ( select do.Sender_Address from #listGuides ls
									join DeliveryOrder do on do.Guide_Serie = ls.ItemSerie and do.Guide_Number = ls.ItemNumber)
			PRINT @ExisteServicio
				SET @ExisteServicio = (SELECT
						COUNT(1)					
						FROM ServiceManagement sm
						INNER JOIN RouteAssigment ra ON sm.IdPuRouteAssigment = ra.IdRouteAssigment AND ra.DateOfRoute =  CONVERT(CHAR(10), GETDATE(), 126)
						inner join PieceByService pbs on pbs.ServiceManagmentId = sm.IdServiceManagement
						inner join DeliveryOrderPiece dop on dop.GuidePiece = pbs.GuidePieceId
						inner join DeliveryOrder do on dop.GuideNumber = do.Guide_Number and dop.GuideSerie = do.Guide_Serie
						WHERE do.Sender_Address = @Addres and sm.IdPuRouteAssigment = @IdRouteASG)

					


PRINT '@ExisteServicio'
PRINT @ExisteServicio


				IF @ExisteServicio > 0
				BEGIN
				PRINT 'entra en existe servicio > 0'
					SET @IdServiceManagement = (
					SELECT top(1) sm.IdServiceManagement FROM DeliveryBackOffice.dbo.ServiceManagement sm
							INNER JOIN RouteAssigment ra ON sm.IdDlRouteAssigment = ra.IdRouteAssigment AND ra.DateOfRoute =  CONVERT(CHAR(10), GETDATE(), 126)
							join PieceByService pbs on pbs.ServiceManagmentId = sm.IdServiceManagement
							join DeliveryOrderPiece dop on dop.GuidePiece = pbs.GuidePieceId
							inner join DeliveryOrder do on dop.GuideNumber = do.Guide_Number and dop.GuideSerie = do.Guide_Serie
						WHERE do.Sender_Address = @Addres and ra.IdRoute = @IdRoute
						 )
				END
				ELSE
				BEGIN
				PRINT 'entra en insert de servicio'
					---========= insert servicio
					INSERT INTO dbo.ServiceManagement (IdPuCourrier, IdDlCourrier, CiPuDate, CoPuDate,
					CiDlDate, CoDlDate, IdPuRouteAssigment, IdDlRouteAssigment, IdSchedulePickup,
					IdProofOnDelivery, RowStatus, TokenCreated, DateCreated, TokenUpdated,
					DateUpdated, ServiceStatusId, PuSignaturePath, DiSignaturePath,
					SubTypeServiceManagmentId,IdHubDestination)
						SELECT
							@courier
						   ,NULL
						   ,NULL
						   ,NULL
						   ,NULL
						   ,NULL
						   ,@IdRouteASG
						   ,NULL
						   ,NULL
						   ,NULL
						   ,1
						   ,@TokenId
						   ,GETDATE()
						   ,NULL
						   ,NULL
						   ,1
						   ,NULL
						   ,NULL
						   ,3
						   ,null	

					SET @IdServiceManagement = SCOPE_IDENTITY();
				---====================================
				END
				PRINT '@IdServiceManagement'
				PRINT Convert(varchar, @IdServiceManagement)
				SET @ExistePiezaPorServicio = (SELECT
						COUNT(1)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pc
						ON pc.GuidePiece = pbs.GuidePieceId
					WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
					AND pbs.ServiceManagmentId = @IdServiceManagement)

					

PRINT '@ExistePiezaPorServicio'
PRINT @ExistePiezaPorServicio
				IF @ExistePiezaPorServicio = 0
				BEGIN
					--========================== Se registra en una tabla de control el id de servicio y de piezas ======
					PRINT 'dentro @ExistePiezaPorServicio'

					INSERT INTO dbo.PieceByService (ServiceManagmentId, GuidePieceId, RowStatus,
					TokenCreated, DateCreated, TokenUpdated, DateUpdated)
						SELECT
							@IdServiceManagement
						   ,pc.GuidePiece
						   ,1
						   ,@TokenId
						   ,GETDATE()
						   ,NULL
						   ,NULL
						FROM DeliveryOrderPiece pc
						WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number

				END
				





			




				-- Actualizar registro de guía a último estado 
				UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
				SET StatusOrderId = 18
				WHERE GuideNumber IN (SELECT
						ItemNumber
					FROM #listGuides)
				AND NoPiece IN (SELECT
						ItemPiece
					FROM #listGuides)




				-- Actualizar registro de guía a último estado 
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET StatusOrderId = 18
				   ,Courier_Route = @Route
				   ,Courier_Name = @courier
				WHERE Guide_Serie = @Guide_Serie
				AND Guide_Number IN (SELECT
						ItemNumber
					FROM #listGuides)

				SET @RowUpdated = @@rowcount

				IF (@RowUpdated > 0)
				BEGIN
					---- Activar bandera de proceso de SMS
					--IF (@StatusId = 11)
					--	IF((select top 1 ue.UpdateStatus
					--		from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
					--		where ue.RowStatus=1
					--		and ue.ElementId=1001)=0)
					--	BEGIN
					--		update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
					--		set UpdateStatus=1, UpdateDateTime=GETDATE()
					--		where RowStatus=1
					--		and ElementId=1001
					--	END

					-- Insertar nuevo estado de guía en tabla histórica

					INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem], [Observations], [Temperature_Celsius], [PieceId])
						SELECT
							@Guide_Serie
						   ,it.ItemNumber
						   ,18
						   ,@TokenId
						   ,@DateOfStatus
						   ,GETDATE()
						   ,@Observations
						   ,@Temperature_Celsius
						   ,it.ItemPiece
						FROM #listGuides it

						SET @ValidateOperation = COALESCE(@@rowcount, 0)

				PRINT 'dentro @ValidateOperation'



					PRINT  @ValidateOperation
				END
			END

	END TRY

	BEGIN CATCH
		SELECT
			0 AS 'StatusCode'
		   ,ERROR_MESSAGE() AS 'Description'
		   ,CONVERT(BIGINT, 0) AS 'NumTransferID'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@trancount > 0
	BEGIN
	
			IF (@ValidateOperation > 0)
			BEGIN

				SELECT 
					CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA
				   ,CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA
				   ,ISNULL(serv.Ticket_Number, ' ') AS Ticket_Number
				   ,ISNULL(serv.Sender_FirstName, ' ') + ' ' + ISNULL(serv.Sender_LastName, '') NAME
				   ,serv.Sender_Address AS HUB_ORIGEN
				   ,serv.Sender_Address AS HUB_DESTINO
				   ,(SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR))
					AND pbs.ServiceManagmentId = @IdServiceManagement) PIEZAS_PROCESADAS
				   ,	CASE WHEN	(CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR))
					AND pbs.ServiceManagmentId = @IdServiceManagement)
					AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))) THEN
					1
					ELSE 
					0
					END  AS CANT_PIEZAS_TOTAL
				   ,CAST((SELECT
							ISNULL(COUNT(1),0)
					FROM dbo.PieceByService pbs
					INNER JOIN DeliveryOrderPiece pci
						ON pci.GuidePiece = pbs.GuidePieceId
					WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR))
					AND pbs.ServiceManagmentId = @IdServiceManagement)
					AS VARCHAR(50)) + ' de ' + CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50)) AS PIEZAS_PENDIENTES
				-- ,1 as RUTA
				-- ,getdate() as FechaRuta
				--,200 as StatusCode
				FROM DeliveryBackOffice.dbo.DeliveryOrder serv
				JOIN DeliveryOrderPiece pc

					ON serv.Guide_Number = pc.GuideNumber
						AND serv.Guide_Serie = pc.GuideSerie
				WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
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
