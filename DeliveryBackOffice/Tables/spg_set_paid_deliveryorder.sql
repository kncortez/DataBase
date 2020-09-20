---- ================================================
---- Template generated from Template Explorer using:
---- Create Procedure (New Menu).SQL
----
---- Use the Specify Values for Template Parameters 
---- command (Ctrl-Shift-M) to fill in the parameter 
---- values below.
----
---- This block of comments will not be included in
---- the definition of the procedure.
---- ================================================
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
---- =============================================
---- Author:		<Edwin,Ramirez>-+
---- Create date: <2020-18-09>
---- Description:	<Asignar deposito de pago a guia transporte>
---- =============================================
ALTER PROCEDURE spg_set_paid_deliveryorder
	-- Add the parameters for the stored procedure here
		--DECLARE
				--@Opcion AS INT = 1 ,
		        @DeliveryOrders AS NVARCHAR(MAX) = 'FD1453,FD1454,FD1455',
				@DepositNumber AS NVARCHAR(50) = '55555655',
				@IdStatus AS BIT = 'TRUE',
				@Token AS NVARCHAR(50) = 'SYS-ERAMIREZ'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		--declare @DeliveryOrders as nvarchar(max)
		--set @DeliveryOrders = RTRIM(LTRIM('FD1453,FD1454,FD1455'))
	
	BEGIN TRY
	IF (@DeliveryOrders != '')
	BEGIN 
		IF (@Token != '')
		BEGIN
			IF (@DepositNumber != '')
			BEGIN
				select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@DeliveryOrders,',')


				UPDATE
				Table_A
				SET
					Table_A.[Guide_Collected] = @IdStatus,
					Table_A.[TokenUpdated] = @Token,
					Table_A.[Deposit_Number] = @DepositNumber,
					Table_A.[DateUpdated] = GETDATE()
				FROM
					DeliveryBackOffice.dbo.DeliveryOrder AS Table_A
					INNER JOIN #listGuides AS Table_B
						ON Table_A.Guide_Serie = Table_B.ItemSerie 
						and Table_A.Guide_Number = Table_B.ItemNumber	


					declare @_exist int = 0;
		
					set @_exist = (
							select  isnull(count(*),0) 
							from DeliveryBackOffice.dbo.DeliveryOrderPaid guidepaids
							join #listGuides guides on  guidepaids.Guide_Serie = guides.ItemSerie
													and guidepaids.Guide_Number = guides.ItemNumber
							where guidepaids.IdStatus = 'TRUE'
							--guidepaids.Deposit_Number = @DepositNumber
					)

					if (@_exist > 0 )
					begin
						update DeliveryBackOffice.DBO.DeliveryOrderPaid 
							set TokenUpdate = @Token,
							DateUpdate  = GETDATE(),
							IdStatus = 'FALSE'
						FROM
						(
							select guides.ItemSerie,
								   guides.ItemNumber
							from #listGuides guides 
						) GuidesTP
						where Guide_Serie = GuidesTP.ItemSerie
						and Guide_Number =  GuidesTP.ItemNumber
						--and Deposit_Number = @DepositNumber
						and IdStatus = 'TRUE'
					end
					-- INSERTAR EL CONTROL DEL PAGO DE LA GUIA COD
					INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderPaid]
									([Guide_Serie]
									,[Guide_Number]
									,[Deposit_Number]
									,[IsVirtualDeposit]
									,[IdStatus]
									,[TokenCreated]
									,[DateCreated]
									,[TokenUpdate]
									,[DateUpdate]
									)
					 SELECT 
						Table_A.Guide_Serie,
						Table_A.Guide_Number,
						@DepositNumber,
						'TRUE',
						@IdStatus,
						@Token,
						GETDATE(),
						NULL,
						NULL
					FROM
						DeliveryBackOffice.dbo.DeliveryOrder Table_A
						INNER JOIN #listGuides AS Table_B
							ON Table_A.Guide_Serie  = Table_B.ItemSerie
							and Table_A.Guide_Number = Table_B.ItemNumber	
							--AND NOT EXISTS(
							--				select guidepaids.IdStatus 
							--				from DeliveryBackOffice.dbo.DeliveryOrderPaid guidepaids
							--				join #listGuides guides on  guidepaids.Guide_Serie = guides.ItemSerie
							--											and guidepaids.Guide_Number = guides.ItemNumber
							--				where Deposit_Number = @DepositNumber
							--				and IdStatus = 'TRUE'
							--			  )

		
					--SELECT * FROM DeliveryBackOffice.DBO.DeliveryOrderPaid 
					  SELECT SCOPE_IDENTITY() AS IDResult,
							 200 AS CODE, 
							 'SUCCESS' AS [MESSAGE],
							 '' AS [ErrorNumber]  
							,'' AS [ErrorSeverity]  
							,'' AS [ErrorState]  
							,'' AS [ErrorProcedure]  
							,'' AS [ErrorLine]  
							,'' AS [ErrorMessage]; 

						DROP TABLE IF EXISTS #listGuides
				END
				ELSE
					BEGIN
						SELECT  0 AS IDResult,
						        404 AS CODE, 
							    'Unable to assign - Deposit number is empty' AS [MESSAGE],
							    '' AS [ErrorNumber]  
							   ,'' AS [ErrorSeverity]  
							   ,'' AS [ErrorState]  
							   ,'' AS [ErrorProcedure]  
							   ,'' AS [ErrorLine]  
							   ,'' AS [ErrorMessage]; 
					END
			END
			ELSE
				BEGIN
						SELECT 0   AS IDResult,
							   404 AS CODE, 
							   'Unable to assign - Token is empty' AS [MESSAGE],
							   '' AS ErrorNumber  
							  ,'' AS ErrorSeverity  
							  ,'' AS ErrorState  
							  ,'' AS ErrorProcedure  
							  ,'' AS ErrorLine  
							  ,'' AS ErrorMessage; 
				END
			END
			ELSE
				BEGIN
						SELECT 0 AS IDResult,
							   404 AS CODE, 
							   'Unable to assign - DeliveryOrders is empty' AS [MESSAGE],
							    '' AS [ErrorNumber]  
							   ,'' AS [ErrorSeverity]  
							   ,'' AS [ErrorState]  
							   ,'' AS [ErrorProcedure]  
							   ,'' AS [ErrorLine]  
							   ,'' AS ErrorMessage; 
				END
		END TRY  
		BEGIN CATCH  
			SELECT   0 AS IDResult,
					 500 AS CODE, 
					 'Internal Exception Error' AS [MESSAGE]
					 ,Cast(ERROR_NUMBER() as varchar) AS [ErrorNumber]
					 ,Cast(ERROR_SEVERITY() as varchar) AS [ErrorSeverity]
					 ,Cast(ERROR_STATE() as varchar) AS [ErrorState]
					 ,Cast(ERROR_PROCEDURE() as varchar) AS [ErrorProcedure]  
					 ,Cast(ERROR_LINE() as varchar) AS [ErrorLine]  
					 ,Cast(ERROR_MESSAGE() as varchar) AS [ErrorMessage];  
		END CATCH;

	--IF (@@ROWCOUNT > 0 OR SCOPE_IDENTITY() > 0)
	--			SELECT 1 AS Result


END



