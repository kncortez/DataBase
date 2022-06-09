
-- =============================================
-- Author:		<Alejandro, Rodríguez>
-- Create date: <2022-05-25>
-- Description:	< Copia del método sps_set_finishService pero haciendolo transaccional con la lógica de los SP's SetRecolectionRequest y Set >
-- =============================================

CREATE PROCEDURE [dbo].[SetFinishService_temp] 
	
	--Campos de sps_set_finishService
	@InGuidesP VARCHAR(MAX),
	@TblListGuides AS TblListGuides READONLY,
	@TblDetail AS TblPaymentList READONLY,
	@IdModuleP INT,
	@TokenP VARCHAR(100),
	@ServiceType VARCHAR(100),
	@CUI VARCHAR(100),
	@Name VARCHAR(100),
	@TblPayment AS TblPayment READONLY,
	@TblExclusions AS TblExclusions READONLY,

	--Campos de SetRecolectionRequest
	@TblDeliveryOrdersList AS [TblDeliveryOrdersList2] READONLY,
	@Iscollected bit = true,
	@status int = 15,
	@ShipmentCompleted bit = true,
	@IdStatus as int = 15,
	@IdAccount as int = null,
	@InstructionsCurrier as nvarchar (300) = null,
	@PartDimensions as int  = 1,
	@Regularpiezer  as int  =  1,
	@StartDate as datetime = null,
	@EndDate as datetime  = null,
	@WeightEstimated as decimal (18,2) = null,
	@BigPackages as bit = false ,
	@ValidateFilter as int = 0,
	@RecollectionLatitude as decimal(18,15) = 0,
	@RecollectionLongitude as decimal(18,15) = 0,
	@DeliveryLatitude as decimal(18,15) = 0,
	@DeliveryLongitude as decimal(18,15) = 0,
	@IdUser INT = 0


AS
BEGIN

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        -- Procedure called when there is  
        -- an active transaction.  
        -- Create a savepoint to be able  
        -- to roll back only the work done  
        -- in the procedure if there is an  
        -- error.  
        SAVE TRANSACTION ProcedureSave2;  
    ELSE  
        -- Procedure must start its own  
        -- transaction.  
        BEGIN TRANSACTION;  


		DECLARE @Output VARCHAR(MAX);
		BEGIN TRY
			--SAVE TRANSACTION TRAN1
			--BEGIN TRANSACTION TRAN1
			
			--EXEC DeliveryBackOffice.dbo.SetRecolectionRequest	@TblDeliveryOrdersList = @TblDeliveryOrdersList,
			SELECT '=====> INICIANDO OUTER SP';
			DECLARE @storevalue VARCHAR(MAX);
			SELECT '=====> LLAMANDO A INNERSP ';
			--EXEC @storevalue = DeliveryBackOffice.dbo.SetRecolectionRequest_temp	@TblDeliveryOrdersList = @TblDeliveryOrdersList,
			   CREATE TABLE #SalesByStore(STS NVARCHAR(MAX));
			


		   EXEC @storevalue = DeliveryBackOffice.dbo.SetRecolectionRequest_temp	@TblDeliveryOrdersList = @TblDeliveryOrdersList,
			--EXEC DeliveryBackOffice.dbo.SetRecolectionRequest_temp	@TblDeliveryOrdersList = @TblDeliveryOrdersList,
																@Iscollected = @Iscollected,
																@status = @status,
																@ShipmentCompleted = @ShipmentCompleted,
																@IdStatus =  @IdStatus,
																@Token = @TokenP,
																@IdAccount = @IdAccount,
																@InstructionsCurrier = @InstructionsCurrier,
																@PartDimensions = @PartDimensions,
																@Regularpiezer = @Regularpiezer,
																@StartDate = @StartDate,
																@EndDate = @EndDate,
																@WeightEstimated = @WeightEstimated,
																@BigPackages = @BigPackages,
																@ValidateFilter = @ValidateFilter,
																@RecollectionLatitude = @RecollectionLatitude,
																@RecollectionLongitude = @RecollectionLongitude,
																@DeliveryLatitude = @DeliveryLatitude,
																@DeliveryLongitude = @DeliveryLongitude,
																@IdUser = @IdUser;
		---
			if @storevalue<>0
			begin
        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  
  
        SELECT @ErrorMessage = ERROR_MESSAGE();  
        SELECT @ErrorSeverity = ERROR_SEVERITY();  
        SELECT @ErrorState = ERROR_STATE();  
			SELECT
				'HUBO UN ERROR EN LA LLAMADA DEL SP REQUEST' AS message
			   ,'FALSE' blnResult
			   ,CAST(500 AS VARCHAR(5)) StatusResult
			   ,CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber
			   ,CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity
			   ,CAST(ERROR_STATE() AS VARCHAR) AS ErrorState
			   ,CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure
			   ,CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine
			   ,CAST(ERROR_MESSAGE() AS VARCHAR(max)) AS ResultMessage;
	        RAISERROR (@ErrorMessage, -- Message text.  
                   @ErrorSeverity, -- Severity.  
                   @ErrorState -- State.  
                   ); 				
			end;

			--SELECT 1/0;
			--SELECT '=====> EVALUEANDO SALIDA';
			--SELECT @storevalue;
			--SELECT STS FROM #SalesByStore
			--IF (@storevalue) <>1
			--BEGIN
				--SELECT '=====> GENERANDO ERROR';
				--;THROW 99001, 'O associated with the given Q Id already exists ssss', 1;
			--END
			SELECT '=====> AQUI NO DEBERIA SEGUIR EJECUTANDO EN EL OUTER';
			--if @@TRANCOUNT>0
			--COMMIT TRAN TRAN1
			--COMMIT TRANSACTION TRAN1;
		IF @TranCounter = 0  
            -- @TranCounter = 0 means no transaction was  
            -- started before the procedure was called.  
            -- The procedure must commit the transaction  
            -- it started.  
            COMMIT TRANSACTION;  


		END TRY
		BEGIN CATCH

        IF @TranCounter = 0  
			BEGIN
            -- Transaction started in procedure.  
            -- Roll back complete transaction.  
			SELECT 'ROLLBACK TRANSACTION';
            ROLLBACK TRANSACTION;  
			END
        ELSE  
            -- Transaction started before procedure  
            -- called, do not roll back modifications  
            -- made before the procedure was called.  
            IF XACT_STATE() <> -1  
				BEGIN
                -- If the transaction is still valid, just  
                -- roll back to the savepoint set at the  
                -- start of the stored procedure.  
                ROLLBACK TRANSACTION ProcedureSave2;  
                -- If the transaction is uncommitable,			
				END

			SELECT '=====> SALIDA DEL CATCH OUTER';
			SELECT
				'ERROR' AS message
			   ,'FALSE' blnResult
			   ,CAST(500 AS VARCHAR(5)) StatusResult
			   ,CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber
			   ,CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity
			   ,CAST(ERROR_STATE() AS VARCHAR) AS ErrorState
			   ,CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure
			   ,CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine
			   ,CAST(ERROR_MESSAGE() AS VARCHAR(max)) AS ResultMessage;
			   

			--ROLLBACK TRANSACTION TRAN1;

			--IF XACT_STATE() <> 0
			--ROLLBACK TRANSACTION ;
		END CATCH;


		--IF @@trancount > 0
		--BEGIN

		--	COMMIT TRANSACTION TRAN1;

		--END;
		--ELSE
		--BEGIN
		--	SELECT 'ELSE TRANCOUNT <=0';

		--	--SET @Output
		--	--= SUBSTRING(@Output, 1, (LEN(@Output) - 7)) + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));
		--	--SELECT
		--	--	@Output 'RESPUETAFormatJson';
		--END;

	--END;
END;