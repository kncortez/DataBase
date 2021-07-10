USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_status_order_by_guide_linehauls]    Script Date: 9/07/2021 01:36:00 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--DECLARE @FECHA AS DATETIME = GETDATE();
--EXEC [sps_set_status_order_by_guide_linehauls] 'FD','FD200272-2',19,'MTIzMDYyMDIxMjMxOTMzMzg0MTky',@FECHA,'',NULL,'LQUE01','95','107',459,1

ALTER PROCEDURE [dbo].[sps_set_status_order_by_guide_linehauls] @Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
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
	DECLARE @HUB_Destino INT 
	DECLARE @HUB_Origen  INT 
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

SET @HUB_Destino = 0
SET @HUB_Origen  = 0

--===========SenderIdTownship NULL.INI ===========
IF ((SELECT
			COUNT(1)
		FROM DeliveryBackOffice.dbo.DeliveryOrder ord
		WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))
		AND ord.SenderIdTownship IS NULL
		AND EXISTS (SELECT
				CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS
			FROM DeliveryBackOffice.dbo.Township TW
			WHERE CONVERT(VARCHAR, UPPER(ord.Sender_Town)) = CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS))
	> 0)
BEGIN
PRINT 'SenderIdTownship = NULL'

UPDATE ord
SET SenderIdTownship = TW.IdTownship
FROM DeliveryBackOffice.dbo.DeliveryOrder ord
INNER JOIN DeliveryBackOffice.dbo.Township TW
	ON CONVERT(VARCHAR, UPPER(ord.Sender_Town)) = CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS
WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))


END
--===========SenderIdTownship NULL.FIN ===========


--===========ReceiverIdTownship NULL.INI ===========
IF ((SELECT
			COUNT(1)
		FROM DeliveryBackOffice.dbo.DeliveryOrder ord
		WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))
		AND ord.ReceiverIdTownship IS NULL
		AND EXISTS (SELECT
				CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS
			FROM DeliveryBackOffice.dbo.Township TW
			WHERE CONVERT(VARCHAR, UPPER(ord.Receiver_Town)) = CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS))
	> 0)
BEGIN
PRINT 'ReceiverIdTownship = NULL'

UPDATE ord
SET ReceiverIdTownship = TW.IdTownship
FROM DeliveryBackOffice.dbo.DeliveryOrder ord
INNER JOIN DeliveryBackOffice.dbo.Township TW
	ON CONVERT(VARCHAR, UPPER(ord.Receiver_Town)) = CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS
WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))

END
--===========ReceiverIdTownship NULL.FIN ===========



---===============ALMACENAR ID HUB DESTINO
IF ((SELECT
			COUNT(1)
		FROM DeliveryBackOffice.dbo.DeliveryOrder ord
		WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))
		AND ord.ReceiverIdTownship IS NULL)
	= 0)
BEGIN
PRINT 'ReceiverIdTownship != NULL'

SET @HUB_Destino = (SELECT
		ISNULL(hl_destino.IdHublogistic, 0) AS ID_HUB_DESTINO
	FROM DeliveryBackOffice.dbo.DeliveryOrder serv
	JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino
		ON serv.ReceiverIdTownship = tbh_destino.IdTownship
		AND tbh_destino.StatusTownshipHub = 1
	JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
		ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
	JOIN DeliveryOrderPiece pc
		ON serv.Guide_Number = pc.GuideNumber
		AND serv.Guide_Serie = pc.GuideSerie
	WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
	AND hl_destino.IdHublogistic IN (SELECT
			cl.IdHubDestination
		FROM CatLinehaul cl
		WHERE cl.IdRoute = @IdRoute))
END
 
 PRINT '@HUB_Destino'
 PRINT @HUB_Destino


---=============

---===============ALMACENAR ID HUB ORIGEN
IF ((SELECT
			COUNT(1)
		FROM DeliveryBackOffice.dbo.DeliveryOrder ord
		WHERE CONCAT(ord.Guide_Serie, CAST(ord.Guide_Number AS VARCHAR)) = CONCAT(SUBSTRING(@Guide_Number, 1, 2), SUBSTRING(@Guide_Number, 3, IIF(CHARINDEX('-', @Guide_Number) = 0, (LEN(@Guide_Number)), (CHARINDEX('-', @Guide_Number) - 3))))
		AND ord.SenderIdTownship IS NULL
		AND EXISTS (SELECT
				CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS
			FROM DeliveryBackOffice.dbo.Township TW
			WHERE CONVERT(VARCHAR, UPPER(ord.Sender_Town)) = CONVERT(VARCHAR, UPPER(tw.TownshipName)) COLLATE SQL_Latin1_General_Cp1251_CS_AS))
	> 0)
BEGIN
PRINT 'SenderIdTownship = NULL'

SET @HUB_Origen = (SELECT
		ISNULL(hl_origen.IdHublogistic, 0)
	FROM DeliveryBackOffice.dbo.DeliveryOrder serv
	JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_hl_origen
		ON serv.SenderIdTownship = tbh_hl_origen.IdTownship
		AND tbh_hl_origen.StatusTownshipHub = 1
	JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen
		ON tbh_hl_origen.IdHublogistic = hl_origen.IdHublogistic
	JOIN DeliveryOrderPiece pc
		ON serv.Guide_Number = pc.GuideNumber
		AND serv.Guide_Serie = pc.GuideSerie
	WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
	AND hl_origen.IdHublogistic IN (SELECT
			cl.IdHubOrigin
		FROM CatLinehaul cl
		WHERE cl.IdRoute = @IdRoute))

END			

		---=============
PRINT 'HUB DESTNO'
PRINT @HUB_Destino

--IF ISNULL(@HUB_Destino,0) <> 0  AND  ISNULL(@HUB_Origen,0) <> 0
IF ISNULL(@HUB_Destino, 0) <> 0
BEGIN

PRINT 'ENTRA'
SET @ExisteRuta = (SELECT
		COUNT(1)
	FROM RouteAssigment ra
	WHERE ra.IdRoute = @IdRoute
	AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))

			IF @ExisteRuta = 0
			BEGIN
			PRINT 'entra existe ruta = 0'
INSERT INTO RouteAssigment (IdRoute, IdCurrierMan, IdVehicle, DateOfRoute, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
	VALUES (@IdRoute, CAST(@courier AS INT), @IdVehicle, CONVERT(CHAR(10), GETDATE(), 126), 1, @TokenId, GETDATE(), '', NULL);
SET @IdRouteASG = SCOPE_IDENTITY();
			END
			ELSE
			BEGIN

SET @IdRouteASG = (SELECT
		ra.IdRouteAssigment
	FROM RouteAssigment ra
	WHERE ra.IdRoute = @IdRoute
	AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126))


SET @ExisteServicio = (SELECT
		COUNT(1)
	FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
	WHERE sm.IdPuRouteAssigment = @IdRouteASG
	AND sm.IdHubDestination = @HUB_Destino)

					




				IF @ExisteServicio > 0
				BEGIN
				PRINT 'entra en existe servicio > 0'
SET @IdServiceManagement = (SELECT
		sm.IdServiceManagement
	FROM ServiceManagement sm
	INNER JOIN RouteAssigment ra
		ON sm.IdPuRouteAssigment = ra.IdRouteAssigment
		AND ra.DateOfRoute = CONVERT(CHAR(10), GETDATE(), 126)
	WHERE sm.IdPuRouteAssigment = @IdRouteASG
	AND sm.IdHubDestination = @HUB_Destino)
				END
				ELSE
				BEGIN

---========= insert servicio
INSERT INTO dbo.ServiceManagement (IdPuCourrier, IdDlCourrier, CiPuDate, CoPuDate,
CiDlDate, CoDlDate, IdPuRouteAssigment, IdDlRouteAssigment, IdSchedulePickup,
IdProofOnDelivery, RowStatus, TokenCreated, DateCreated, TokenUpdated,
DateUpdated, ServiceStatusId, PuSignaturePath, DiSignaturePath,
SubTypeServiceManagmentId, IdHubDestination)
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
	   ,4
	   ,@HUB_Destino

SET @IdServiceManagement = SCOPE_IDENTITY();
				---====================================
				END

SET @ExistePiezaPorServicio = (SELECT
		COUNT(1)
	FROM dbo.PieceByService pbs
	INNER JOIN DeliveryOrderPiece pc
		ON pc.GuidePiece = pbs.GuidePieceId
	WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
	AND pbs.ServiceManagmentId = @IdServiceManagement)

					

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




-- Actualizar registro de guía a último estado 
UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
SET StatusOrderId = 19
WHERE GuideNumber IN (SELECT
		ItemNumber
	FROM #listGuides)
AND NoPiece IN (SELECT
		ItemPiece
	FROM #listGuides)




-- Actualizar registro de guía a último estado 
UPDATE DeliveryBackOffice.dbo.DeliveryOrder
SET StatusOrderId = 19
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
	   ,19
	   ,@TokenId
	   ,@DateOfStatus
	   ,GETDATE()
	   ,@Observations
	   ,@Temperature_Celsius
	   ,it.ItemPiece
	FROM #listGuides it



SET @ValidateOperation = COALESCE(@@rowcount, 0)

				END
			END
		END
	
ELSE 
BEGIN
PRINT ''
SET @ValidateOperation = 0
END
	
	END TRY

	BEGIN CATCH
	PRINT 'ERROR'
SELECT
	0 AS 'StatusCode'
   ,ERROR_MESSAGE() AS 'Description'
   ,CONVERT(BIGINT, 0) AS 'NumTransferID'
ROLLBACK TRANSACTION
END CATCH;
PRINT @@trancount

PRINT @HUB_Destino



IF @@trancount > 0
BEGIN
IF (@ValidateOperation > 0)
BEGIN

DECLARE @RouteValidator AS INT = (SELECT
		COUNT(cl.IdHubDestination) AS CANT
	FROM CatLinehaul cl
	WHERE cl.IdRoute = @IdRoute)

IF (@RouteValidator > 0)
BEGIN

SELECT
	CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA
   ,CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA
   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
   ,hl_origen.HubAbbreviation AS HUB_ORIGEN
   ,hl_destino.HubAbbreviation AS HUB_DESTINO
   ,(SELECT
			ISNULL(COUNT(1), 0)
		FROM dbo.PieceByService pbs
		INNER JOIN DeliveryOrderPiece pci
			ON pci.GuidePiece = pbs.GuidePieceId
		WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR))
		AND pbs.ServiceManagmentId = @IdServiceManagement)
	PIEZAS_PROCESADAS
   ,CASE
		WHEN (CAST((SELECT
					ISNULL(COUNT(1), 0)
				FROM dbo.PieceByService pbs
				INNER JOIN DeliveryOrderPiece pci
					ON pci.GuidePiece = pbs.GuidePieceId
				WHERE CONCAT(pci.GuideSerie, CAST(pci.GuideNumber AS VARCHAR)) = CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR))
				AND pbs.ServiceManagmentId = @IdServiceManagement)
			AS VARCHAR(50)) = CAST(serv.Pieces_Dry + serv.Pieces_Cold AS VARCHAR(50))) THEN 1
		ELSE 0
	END AS CANT_PIEZAS_TOTAL
   ,CAST((SELECT
			ISNULL(COUNT(1), 0)
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
JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_origen
	ON serv.SenderIdTownship = tbh_origen.IdTownship
		AND tbh_origen.StatusTownshipHub = 1
JOIN DeliveryBackOffice.dbo.TownshipByHubLogistic tbh_destino
	ON serv.ReceiverIdTownship = tbh_destino.IdTownship
		AND tbh_destino.StatusTownshipHub = 1
JOIN DeliveryBackOffice.dbo.HubLogistics hl_origen
	ON tbh_origen.IdHublogistic = hl_origen.IdHublogistic
JOIN DeliveryBackOffice.dbo.HubLogistics hl_destino
	ON tbh_destino.IdHublogistic = hl_destino.IdHublogistic
JOIN DeliveryOrderPiece pc
	ON serv.Guide_Number = pc.GuideNumber
		AND serv.Guide_Serie = pc.GuideSerie
WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number
AND hl_destino.IdHublogistic IN (SELECT
		cl.IdHubDestination
	FROM CatLinehaul cl
	WHERE cl.IdRoute = @IdRoute)
--AND @ExistePiezaPorServicio = 0


END

END
ELSE
IF (@HUB_Destino = 0)
BEGIN
PRINT 'NO TIENE HUB _1'
PRINT 'GUIA'
PRINT @Guide_Number
SELECT
	CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA
   ,CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA
   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
   ,'N/A' AS HUB_ORIGEN
   ,'N/A' AS HUB_DESTINO
   ,0 AS PIEZAS_PROCESADAS
   ,0 AS CANT_PIEZAS_TOTAL
   ,0 AS PIEZAS_PENDIENTES
-- ,1 as RUTA
-- ,getdate() as FechaRuta
--,200 as StatusCode
FROM DeliveryBackOffice.dbo.DeliveryOrder serv
JOIN DeliveryOrderPiece pc
	ON serv.Guide_Number = pc.GuideNumber
		AND serv.Guide_Serie = pc.GuideSerie
WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number

END
COMMIT TRANSACTION;
END
ELSE
IF (@HUB_Destino = 0)
BEGIN
PRINT 'NO TIENE HUB _2'
SELECT
	CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR)) AS NUMGUIA
   ,CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) GUIA
   ,ISNULL(serv.Ticket_Number, '') AS Ticket_Number
   ,ISNULL(serv.Receiver_FirstName, '') + ' ' + ISNULL(serv.Receiver_LastName, '') NAME
   ,'N/A' AS HUB_ORIGEN
   ,'N/A' AS HUB_DESTINO
   ,0 AS PIEZAS_PROCESADAS
   ,0 AS CANT_PIEZAS_TOTAL
   ,0 AS PIEZAS_PENDIENTES
-- ,1 as RUTA
-- ,getdate() as FechaRuta
--,200 as StatusCode
FROM DeliveryBackOffice.dbo.DeliveryOrder serv
JOIN DeliveryOrderPiece pc
	ON serv.Guide_Number = pc.GuideNumber
		AND serv.Guide_Serie = pc.GuideSerie
WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number

END

END