USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_set_status_order_by_guide]    Script Date: 20/04/2021 09:56:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-20>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================
ALTER PROCEDURE [dbo].[sps_set_status_order_by_guide_return]
		@Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
		@Guide_Number AS VARCHAR(MAX), -- a list of guides separated by comma
		@StatusId AS INT, -- status from StatusOrder
		@TokenId AS VARCHAR(50),
		@DateOfStatus DATETIME, -- datetime of event
		@Observations AS VARCHAR(200) = '', --Observations by checkpoint
		@Temperature_Celsius AS DECIMAL(5,2) = 0.00,
		@Route as nvarchar (50) ='Devolución' ,
		@IdRoute as nvarchar (50) = 99999,
		@IdVehicle as int = 222,
		@courier as nvarchar(50) = 'SYS-SYSTEM'
		

AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)

	BEGIN TRANSACTION

		BEGIN TRY

				IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
			
				-- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
				select SUBSTRING(Item, 1,2) ItemSerie,
								SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber,
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) ItemPiece
								 --, 
								--SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
								--CHARINDEX('-',Item) charinde,  
								--len(Item) len
										into #listGuides
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,',')






			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrderPiece
			SET StatusOrderId = 18
			WHERE  GuideNumber IN (SELECT ItemNumber FROM #listGuides) and NoPiece in (SELECT ItemPiece FROM #listGuides)


			

			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET StatusOrderId = 18, Courier_Route = @Route, Courier_Name = @courier
			WHERE Guide_Serie = @Guide_Serie AND Guide_Number IN (SELECT ItemNumber FROM #listGuides)

			SET @RowUpdated = @@ROWCOUNT

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

				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem], [Observations], [Temperature_Celsius],[PieceId])
				SELECT @Guide_Serie, it.ItemNumber, 18, @TokenId, @DateOfStatus, GETDATE(), @Observations, @Temperature_Celsius, it.ItemPiece
				FROM #listGuides it



				SET @ValidateOperation = COALESCE(@@ROWCOUNT,0)
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
					1 AS 'StatusCode',
					'Registros guardados correctamente' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'

					declare @val as int  = (select COUNT(GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides) and GuideSerie in (select ItemSerie from #listGuides) and StatusOrderId <> 18) 
					declare @val1 as int  = (select COUNT(GuideNumber) from DeliveryOrderPiece where GuideNumber in (select ItemNumber from #listGuides) and GuideSerie in (select ItemSerie from #listGuides))
			
				SELECT Guide_Serie Serie , CAST(Guide_Number as varchar(50)) Numero, Ticket_Number Ticket, Receiver_FirstName + ' '+ Receiver_LastName Name, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate, CAST( @val as nvarchar(50)) + ' de ' + CAST( @val1 as varchar (50)) Piece
				FROM DeliveryBackOffice.dbo.DeliveryOrder 
			--	inner join DeliveryBackOffice.dbo.DeliveryOrderPiece pc on do.Guide_Number = pc.GuideNumber and do.Guide_Serie = pc.GuideSerie
				WHERE Guide_Serie = @Guide_Serie and Guide_Number IN (SELECT ItemNumber FROM #listGuides) --and pc.NoPiece = (SELECT ItemPiece FROM #listGuides)
			END
			ELSE
			BEGIN
				SELECT 
					0 AS 'StatusCode',
					'El registro no existe' AS 'Description', 
					@ValidateOperation AS 'NumTransferID'
			END
			COMMIT TRANSACTION;			
		END
END
