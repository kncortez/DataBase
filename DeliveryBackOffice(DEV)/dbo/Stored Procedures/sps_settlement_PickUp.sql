

-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-03-11>
-- Description:	<Inserta el manifiesto de recoleccion>
-- =============================================
CREATE PROCEDURE [dbo].[sps_settlement_PickUp]
		@Route NVARCHAR(100),
		@Token NVARCHAR(50),
		@PiecesDry SMALLINT,
		@PiecesCold SMALLINT,
		@GuidesQuantity SMALLINT,
		@InGuides   NVARCHAR(MAX) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
		@NotGuides  NVARCHAR(MAX) = 'FD22221-1,FD22361-1,FD22223-2,FD22359-1,FD22226-1',
		@IdCourier int

AS
BEGIN
	
		-- control de guía a iterar
	DECLARE @GuideNumber INT
	DECLARE @GuideSerie varchar(2) 
	-- CourierId de la guía a iterar
	DECLARE @CourierId INT
	-- CatModuleId del modulo
	DECLARE @CatModuleId INT
  -- Detecta si una guia tiene COD
  DECLARE @IsCOD BIT
	-- control de actualizaciones para transacción
	DECLARE @RUpdated INT

	BEGIN TRANSACTION

		BEGIN TRY
						IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
						IF OBJECT_ID('tempdb.dbo.#listNotGuides', 'U') IS NOT NULL DROP TABLE listNotGuides;
						IF OBJECT_ID('tempdb.dbo.#UpdOrd', 'U') IS NOT NULL DROP TABLE #UpdOrd;

								select SUBSTRING(Item, 1,2) ItemSerie,
								SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber,
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) ItemPiece
										into #listGuides
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

						--------------------------------------------------------------------------------------------------------------------------

								select SUBSTRING(Item, 1,2) ItemSerie,
								SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber,
								SUBSTRING(Item, CHARINDEX('-',Item)+1,len(item)) ItemPiece
										into #listNotGuides
										from DenariusDesktop_Dev.dbo.SplitUnlimited(@NotGuides,',')

				declare @Idd int

					insert into dbo.SettlementByPickup (RouteAssigmentId, 
					DatePrinted, 
					TokenCreated,
					DateCreated,
					PiecesDry, 
					PiecesCold,
					GuidesQuantity,
					PiecesDryReceived,
					PiecesColdReceived, 
					GuidesQuantityReceived
					,IdCourier)
					values(@Route, GETDATE(), @Token, GETDATE(),@PiecesDry, @PiecesCold, @GuidesQuantity,null, null,null, @IdCourier)

			SET @RUpdated = @@ROWCOUNT
			set @Idd = SCOPE_IDENTITY();

			if(@Idd > 0)
			begin
					insert into dbo.SettlementByPickupDetail( SettlementByPickupId,
					GuideSerie,
					GuideNumber,
					RowStatus,
					TokenCreated,
					DateCreated,
					TokenUpdated,
					DateUpdated,
					IsPieceLiquidaded,
					NoPiece)
					select 
					@Idd,
					ls.ItemSerie,
					ls.ItemNumber,
					1,
					@Token,
					GETDATE(),
					null,
					null,
					1,
					ls.ItemPiece
					from #listGuides ls
				---------------------------------------------------------------------------------------------------
				declare @validator int = (select top 1 ItemNumber from #listNotGuides)
					if (@validator >= 1)
					begin 	
						insert into dbo.SettlementByPickupDetail( SettlementByPickupId,
						GuideSerie,
						GuideNumber,
						RowStatus,
						TokenCreated,
						DateCreated,
						TokenUpdated,
						DateUpdated,
						IsPieceLiquidaded,
						NoPiece)
						select 
						@Idd,
						ls.ItemSerie,
						ls.ItemNumber,
						1,
						@Token,
						GETDATE(),
						null,
						null,
						0,
						ls.ItemPiece
						from #listNotGuides ls
					end
			end

			

	----------------------- PROCESSGUIDECOD- SE REGISTRA RECOLECCIÓN . INI ----------------------	

	


	--Buscar ID modulo liquidación Recolecciones
			SET @CatModuleId = ISNULL((SELECT ModIdModule
									FROM CatModule
									WHERE ModName = 'Liquidación COD'),0)

									SELECT * INTO #listGuidesTemp FROM #listGuides
				-- mientras la tabla no este vacía
			WHILE EXISTS(SELECT * FROM #listGuidesTemp)
			BEGIN
				-- se obtiene la guía a iterar
				SELECT TOP 1 @GuideNumber = ItemNumber , 
				@GuideSerie = ItemSerie
				FROM #listGuidesTemp

					-- se obtiene el id del courierman
					SELECT TOP 1 @CourierId = ID_Courier 
					FROM [dbo].[DeliveryAttempt] 
					WHERE [Guide_Serie] = @GuideSerie
						AND [Guide_Number] = @GuideNumber
					ORDER BY [Date_Created] DESC

				-- se verifica que no exita en las guías procesadas
				IF NOT EXISTS 
					(SELECT 1
					FROM [dbo].[ProcessedGuideCOD]
					WHERE [GuideNumber] = @GuideNumber AND GuideSerie = @GuideSerie
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
						,@Token
						,cus.IdCustomer
					FROM [dbo].[DeliveryOrder] do WITH (NOLOCK)						
						LEFT JOIN dbo.VisitPointClient vp ON vp.CodeOfReference = do.Sender_ID
						LEFT JOIN dbo.Customer cus ON cus.IdCustomer = ISNULL(do.IdCustomer, vp.CustomerID)
						INNER JOIN dbo.DeliveryOrderPaymentDetail DOP 
					ON do.Guide_Serie = DOP.GuideSerie AND do.Guide_Number = DOP.GuideNumber
		
					WHERE do.[Guide_Number] = @GuideNumber
						AND do.[Guide_Serie] = @GuideSerie				
						AND do.IsCollect = 'false'
						AND DOP.TimePlaId = 2
				END

				DELETE  #listGuidesTemp WHERE ItemNumber = @GuideNumber AND ItemSerie = @GuideSerie
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
			IF (@Idd > 0)
				SELECT			  
					@Idd AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'

END
