USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_set_route_settlement_status]    Script Date: 25/01/2022 08:25:05 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-03-04>
-- Description:	<Cambia de estado de recolectado a ingreso a instalaciones>
-- =============================================

ALTER PROCEDURE [dbo].[spws_set_route_settlement_status] @GuideSerie NVARCHAR(2)
, @GuideNumber INT
, @GuidePiece SMALLINT
, @Token NVARCHAR(100)
, @Route VARCHAR(100)
, @CountryId VARCHAR(2)
AS
BEGIN

	DECLARE @RModified INT
	DECLARE @RModified2 INT
	DECLARE @RModified3 INT

	DECLARE @GModif INT = 0

	BEGIN TRANSACTION
	BEGIN TRY


		DECLARE @stattus INT = 11

		/* Inserción en tabla TransactionalBackbone para guardar 
			un registro de las piezas que se estan liquidando de una ruta										 
		 */

		DECLARE @inBound INT = (SELECT
				IdTranportationZone
			FROM DeliveryBackOffice.dbo.CatTransportationZone
			WHERE Name = 'Ruta de recolección')

		DECLARE @outBound INT = (SELECT
				IdTranportationZone
			FROM DeliveryBackOffice.dbo.CatTransportationZone
			WHERE Name = 'Bodega')

		DECLARE @idTransactionType INT = (SELECT
				IdTransactionType
			FROM DeliveryBackOffice.dbo.TransactionType
			WHERE Name = 'Liquidación de Recolección')

		DECLARE @IdRoute INT = (SELECT
				IdRoute
			FROM DeliveryBackOffice.dbo.CatRoute
			WHERE CodeRoute = @Route)

		INSERT INTO DeliveryBackOffice.dbo.TransactionalBackbone (GuideSerie
		, GuideNumber
		, GuidePiece
		, RouteId
		, InBound
		, OutBound
		, LineHaul
		, StatusComplete
		, TransactionTypeId
		, CountryId
		, RowStatus
		, TokenCreated
		, DateCreated)
			SELECT DISTINCT
				@GuideSerie
			   ,@GuideNumber
			   ,@GuidePiece
			   ,@IdRoute
			   ,@inBound
			   ,@outBound
			   ,0
			   ,0
			   ,@idTransactionType
			   ,@CountryId
			   ,1
			   ,@Token
			   ,GETDATE()
			FROM DeliveryOrderPiece ord
			WHERE (ord.GuideNumber = @GuideNumber
			AND ord.GuideSerie = @GuideSerie
			AND ord.NoPiece = @GuidePiece
			AND (ord.StatusOrderId NOT IN (7, 11, 5)
			OR ord.StatusOrderId IS NULL))
			AND (SELECT
					COUNT(1)
				FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd
				WHERE dopd.GuideNumber = @GuideNumber
				AND dopd.GuideSerie = @GuideSerie)
			= 0
			OR ((SELECT
					COUNT(1)
				FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd
				WHERE dopd.GuideNumber = @GuideNumber
				AND dopd.GuideSerie = @GuideSerie)
			> 0
			AND (SELECT
					COUNT(1)
				FROM DeliveryBackOffice.dbo.ServiceManagement svm
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dop
					ON svm.IdSchedulePickup = dop.IdHeaderRecolection
				INNER JOIN DeliveryBackOffice.dbo.RouteAssigment rat
					ON svm.IdPuRouteAssigment = rat.IdRouteAssigment
				WHERE dop.GuideNumber = @GuideNumber
				AND dop.GuideSerie = @GuideSerie
				AND rat.IdRoute = @IdRoute)
			> 0)
			OR ((SELECT
					COUNT(1)
				FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail dopd
				WHERE dopd.GuideNumber = @GuideNumber
				AND dopd.GuideSerie = @GuideSerie
				AND dopd.IdHeaderRecolection IS NULL)
			> 0)



		SET @RModified3 = @@rowcount

		IF @RModified3 > 0
		BEGIN
			UPDATE dbo.DeliveryOrderPiece
			SET StatusOrderId = @stattus
			FROM dbo.DeliveryOrderPiece ord
			WHERE (ord.GuideNumber = @GuideNumber
			AND ord.GuideSerie = @GuideSerie
			AND ord.NoPiece = @GuidePiece
			AND (ord.StatusOrderId NOT IN (7, 11, 5)
			OR ord.StatusOrderId IS NULL))
			--inner join dbo.DeliveryOrderPaymentDetail dop on (ord.GuideNumber = dop.GuideNumber and ord.GuideSerie = dop.GuideSerie and  (ord.StatusOrderId = 15 and dop.ShipmentCompleted = 1))

			SET @RModified = @@rowcount
		END
		--end
		--else
		--begin 
		--		update  dbo.DeliveryOrderPiece set StatusOrderId =  @stattus
		--		from dbo.DeliveryOrderPiece ord
		--		 inner join #listGuides ls on (ord.GuideNumber = ls.ItemNumber and ord.GuideSerie = ls.ItemSerie)
		--end
		---variable que cuenta cuantas piezas estan asociadas a las guias.
		DECLARE @val INT = (SELECT
				COUNT(1)
			FROM DeliveryOrderPiece
			WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber)
		---variable que cuenta cuantas piezas ya cambiaron de estado arribo a instalaciones (11).
		DECLARE @valu INT = (SELECT
				COUNT(1)
			FROM DeliveryOrderPiece
			WHERE GuideSerie = @GuideSerie
			AND GuideNumber = @GuideNumber
			AND StatusOrderId = @stattus)

		--declare @value int = (select count (GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides))

		---	 insertar checkpoint de arribo a instalaciones.	
		INSERT INTO dbo.DeliveryOrderDetail ([Guide_Serie]
		, [Guide_Number]
		, [StatusOrderId]
		, [UserCreated]
		, [DateCreated]
		, [DateCreatedInSystem]
		, [Observations]
		, [Temperature_Celsius]
		, [PieceId])
			VALUES (@GuideSerie, @GuideNumber, @stattus, @Token, GETDATE(), GETDATE(), NULL, NULL, @GuidePiece)

		SET @RModified2 = @@rowcount

		IF (@val = @valu)
		BEGIN
			UPDATE do
			SET do.StatusOrderId = @stattus
			FROM DeliveryOrder do
			WHERE do.Guide_Serie = @GuideSerie
			AND do.Guide_Number = @GuideNumber
			SET @GModif = @@rowcount

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

		END

	END TRY
	BEGIN CATCH


		SELECT
			0 AS 'StatusCode'
		   ,
			--	ERROR_MESSAGE() AS 'Description', 
			--	CONVERT(BIGINT, 0) AS 'NumTransferID',
			CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide'
		   ,0 AS 'SubStatusCode'
		ROLLBACK TRANSACTION

		SELECT
			'No se guardo el registro' AS StatusCode
	--select ERROR_MESSAGE()
	-- retornar mensaje de error


	END CATCH;
	IF @@trancount > 0
	BEGIN
		COMMIT TRANSACTION;
		IF (@RModified > 0
			AND @RModified2 > 0)
		BEGIN

			SELECT
				1 AS 'StatusCode'
			   ,
				--	'Registro guardado correctamente' AS 'Description', 
				--	@@TRANCOUNT AS 'NumTransferID',
				CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide'
			   ,
				--@Amount AS 'Amount',
				0 AS 'SubStatusCode'

			SELECT
				@GModif AS CONT

		END

		ELSE
			SELECT
				0 AS 'StatusCode'
			   ,
				--	'Registro no encontrado' AS 'Description', 
				--	0 AS 'NumTransferID',
				CONCAT(@GuideSerie, @GuideNumber, '-', @GuidePiece) AS 'Guide'
			   ,
				--@Amount AS 'Amount',
				0 AS 'SubStatusCode'


	END
END