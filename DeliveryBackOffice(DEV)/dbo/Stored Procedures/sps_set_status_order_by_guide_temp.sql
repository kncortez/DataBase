

-- =============================================
-- Author:		<Carlos, Cano>
-- Create date: <2020-06-10>
-- Description:	<Cambiar el estado de una lista de guías>
-- =============================================
CREATE PROCEDURE [dbo].[sps_set_status_order_by_guide_temp]
		@Guide_Serie AS VARCHAR(2), -- same guide for all numbers provided
		@Guide_Number AS VARCHAR(MAX), -- a list of guides separated by comma
		@StatusId AS INT, -- status from StatusOrder
		@TokenId AS VARCHAR(50),
		@DateOfStatus DATETIME, -- datetime of event
		@Observations AS VARCHAR(200) = '', --Observations by checkpoint
		@Temperature_Celsius AS DECIMAL(5,2),
		@courierName as varchar(200) = '',
		@iduser as int =NULL
AS
BEGIN
	DECLARE @ValidateOperation BIGINT = 0
	DECLARE @RowUpdated INT
	DECLARE @ItemsTable AS TABLE (
		Guide_Number INT
	)
		-- control de guía a iterar
	DECLARE @GuideNumber INT
	--DECLARE @GuideSerie varchar(2) 
	-- CourierId de la guía a iterar
	DECLARE @CourierId INT
	-- CatModuleId del modulo
	DECLARE @CatModuleId INT

	BEGIN TRANSACTION

		BEGIN TRY
			
			-- Convertir la lista de guías separadas por coma en una tabla que permita adicionar columnas
			INSERT @ItemsTable
			SELECT CAST(Item AS INT) FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,',')

			-- Actualizar registro de guía a último estado 
			UPDATE DeliveryBackOffice.dbo.DeliveryOrder
			SET StatusOrderId = @StatusId
			WHERE Guide_Serie = @Guide_Serie AND Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))

			SET @RowUpdated = @@ROWCOUNT

			IF (@RowUpdated > 0)
			BEGIN
				-- Activar bandera de proceso de SMS
				IF (@StatusId = 4) -- En ruta | (11) Arribó a instalaciones
					IF((select top 1 ue.UpdateStatus
						from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue
						where ue.RowStatus=1
						and ue.ElementId=1001)=0)
					BEGIN
						update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
						set UpdateStatus=1, UpdateDateTime=GETDATE()
						where RowStatus=1
						and ElementId=1001
					END
			
				-- Insertar nuevo estado de guía en tabla histórica
				INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail ([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated], [DateCreatedInSystem], [Observations], [Temperature_Celsius])
				SELECT @Guide_Serie, it.Guide_Number, @StatusId, @TokenId, GETDATE(), GETDATE(), @Observations, @Temperature_Celsius
				FROM @ItemsTable it
				SET @ValidateOperation = COALESCE(@@ROWCOUNT,0)
				-----------------------------
				IF (SELECT OrderDescription FROM DBO.StatusOrder WHERE StatusOrderId=@StatusId)='En ruta'
				BEGIN 
					----------------
					--INICIO --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA				
					DECLARE @GuidesTableWithoutFailRetries AS TABLE (Guide_Serie NVARCHAR(MAX), Guide_Number INT,StatusOrderId INT, StatusCount INT)
					DECLARE @IDSTATUSINROUTE INT =(select StatusOrderId from dbo.StatusOrder where OrderDescription ='En ruta');
					DECLARE @IDSTATUSFAILEDDELIVERY INT =(select StatusOrderId from dbo.StatusOrder where OrderDescription ='Intento de entrega fallida');
					--Obtiene la lista de guías que ya salieron a ruta 2 o mas veces y que tienen 0 intentos de entrega fallida
					INSERT INTO @GuidesTableWithoutFailRetries	
					SELECT  @Guide_Serie, LG.Guide_Number,(DORD.StatusOrderId),COUNT(DORD.StatusOrderId)
					FROM @ItemsTable LG
						LEFT JOIN DeliveryOrder DOR ON DOR.Guide_Serie=@Guide_Serie AND LG.Guide_Number=DOR.Guide_Number
						LEFT JOIN DBO.DeliveryOrderDetail DORD  ON DOR.Guide_Serie=DORD.Guide_Serie AND DOR.Guide_Number=DORD.Guide_Number
						--LEFT JOIN DBO.Customer CU ON DOR.IdCustomer=CU.IdCustomer
						--LEFT JOIN DBO.RatebyCustomer RC ON CU.IdCustomer=RC.RbcIdCustomer
						--LEFT JOIN RateHeader RH ON RC.RbcIdRate=RH.RheId						
					GROUP BY LG.Guide_Number,DORD.StatusOrderId
					HAVING 
						(DORD.StatusOrderId=@IDSTATUSINROUTE AND COUNT(DORD.StatusOrderId)>=2)--CUANDO YA SALIERON A RUTA 2 O MAS VECES
						OR 
						(DORD.StatusOrderId=@IDSTATUSFAILEDDELIVERY AND COUNT(DORD.StatusOrderId)=0)-- CUANDO TIENEN 0 INTENTOS DE ENTREGA FALLIDA


				
					IF (SELECT COUNT(*) FROM @GuidesTableWithoutFailRetries)>0 and @iduser is not null
					BEGIN
						--Obreniendo lista de guias con el numero de veces que salieron a ruta
						DECLARE @GuidesTableWithRetriesDispatch AS TABLE (Guide_Number INT, RretriesMade INT);
						INSERT INTO @GuidesTableWithRetriesDispatch
						SELECT GTA.Guide_Number,GTA.StatusCount
							FROM @GuidesTableWithoutFailRetries  GTA
							where GTA.StatusOrderId=@IDSTATUSINROUTE

						--CREANDO ALERTA DE GUÍAS QUE NO POSEEN ALERTA Y QUE TIENEN MAS DE DOS SALIDAS A RUTA
						DECLARE @SERVICETYPE NVARCHAR(MAX)= (SELECT IdTypeServiceManagment FROM DBO.TypeServiceManagment WHERE NAME ='Entrega')
						INSERT INTO DBO.DeliveryOrderAlert 
							(
							GuideSerie,
							GuideNumber,
							ServiceTypeId,
							AlertDescription,
							AlertTypeId,
							RowStatus,
							TokenCreated,
							DateCreated,
							TokenUpdated,
							DateUpdated)						
						SELECT @Guide_Serie,
							GTWRD.Guide_Number,
							@SERVICETYPE,
							'El paquete ha salido a ruta 2 o mas veces',
							(SELECT IdCatTypeAlert FROM DBO.CatTypeAlert WHERE AlertName='Prioritario'),
							1,
							@TokenId,
							GETDATE(),
							NULL,
							NULL
							FROM @GuidesTableWithRetriesDispatch GTWRD LEFT JOIN DBO.DeliveryOrderAlert DOA 
								ON  DOA.GuideSerie=@Guide_Serie AND DOA.GuideNumber=GTWRD.Guide_Number
							WHERE DOA.IdDeliveryOrderAlert IS NULL;
				
						INSERT INTO DBO.DeliveryOrderAlertDetail
						(
							author,
							username,
							comment,
							DeliveryOrderAlertId,
							RowStatus,
							TokenCreated,
							DateCreated,
							TokenUpdated,
							DateUpdated
						)
						SELECT 
							@iduser,
							(SELECT Username FROM DBO.InternalUser WHERE IdUser=@iduser),
							'ALERTA: El paquete ya ha salido a ruta '+CONVERT(NVARCHAR,GTWRD.RretriesMade)+' veces sin intentos de entrega',
							DOA.IdDeliveryOrderAlert,
							1,
							@TokenId,
							GETDATE(),
							NULL,
							NULL
						FROM @GuidesTableWithRetriesDispatch GTWRD LEFT JOIN DBO.DeliveryOrderAlert DOA 
								ON  DOA.GuideSerie=@Guide_Serie AND DOA.GuideNumber=GTWRD.Guide_Number
					END
					--FIN --CREANDO ALERTA POR CADA GUÍA QUE HAYA SIDO PUESTO EN RUTA 2 O MAS VECES Y QUE NO POSEAN ALERTA				
					------------------------------------------------------------------------
				END
				-----------------------------
			END

			IF @StatusId = 4
			BEGIN
				UPDATE DeliveryBackOffice.dbo.DeliveryOrder
				SET Courier_Name = @courierName,
				Dispatched_Date = GETDATE()
				WHERE Guide_Serie = @Guide_Serie AND Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))
			END
			
			----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	

	--Buscar ID modulo liquidación Recolecciones
			SET @CatModuleId = ISNULL((SELECT ModIdModule
									FROM CatModule
									WHERE ModName = 'Liquidación (Recolecciones)'),0)

									SELECT * INTO #listGuidesTemp FROM @ItemsTable
				-- mientras la tabla no este vacía
			WHILE EXISTS(SELECT * FROM #listGuidesTemp)
			BEGIN
				-- se obtiene la guía a iterar
				SELECT TOP 1 @GuideNumber = Guide_Number
				FROM #listGuidesTemp

					-- se obtiene el id del courierman
					SELECT TOP 1 @CourierId = ID_Courier 
					FROM [dbo].[DeliveryAttempt] 
					WHERE [Guide_Serie] = @Guide_Serie
						AND [Guide_Number] = @GuideNumber

				-- se verifica que no exita en las guías procesadas
				IF NOT EXISTS 
					(SELECT 1
					FROM [dbo].[ProcessedGuideCOD]
					WHERE [GuideNumber] = @GuideNumber AND GuideSerie = @Guide_Serie
				)
				BEGIN
					INSERT INTO [dbo].[ProcessedGuideCOD]
					   ([GuideSerie]
					   ,[GuideNumber]
					   ,[CourierManId]
					   ,[Date]
					   ,[BatchCODId]
					   ,[BatchCODIdCommission]
					   ,[DataOriginId]
					   ,[Notificated]
					   ,[Token]
					   ,CustomerId)
				 SELECT do.[Guide_Serie]
						,do.[Guide_Number]
						,@CourierId
						,GETDATE()
						,NULL
						,NULL
						,@CatModuleId
						,0
						,@TokenId
						,cus.IdCustomer
					FROM [dbo].[DeliveryOrder] do						
						LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = do.Sender_ID
						LEFT JOIN dbo.Customer cus ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
						INNER JOIN dbo.DeliveryOrderPaymentDetail DOP 
					ON do.Guide_Serie = DOP.GuideSerie AND do.Guide_Number = DOP.GuideNumber
		
					WHERE do.[Guide_Number] = @GuideNumber
						AND do.[Guide_Serie] = @Guide_Serie				
						AND do.IsCollect = 'false'
						AND DOP.TimePlaId = 2
					--	AND LG.ItemNumber NOT IN (SELECT GuideNumber
					--FROM [dbo].[ProcessedGuideCOD]
					--WHERE [GuideNumber] = DO.Guide_Number AND GuideSerie = DO.Guide_Serie)
				END

				DELETE  #listGuidesTemp WHERE Guide_Number = @GuideNumber 
			END
			
			----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . FIN ----------------------		

	

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

				SELECT Guide_Serie + CAST(Guide_Number as varchar) Guide,Ticket_Number Ticket, Receiver_FirstName + ' '+ Receiver_LastName Name, Courier_Route Route, convert(varchar, Dispatched_Date, 103) RouteDate 
				FROM DeliveryBackOffice.dbo.DeliveryOrder
				WHERE Guide_Serie = @Guide_Serie and Guide_Number IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Guide_Number,','))
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
