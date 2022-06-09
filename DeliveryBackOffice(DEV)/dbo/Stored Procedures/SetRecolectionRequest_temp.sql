-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recoleccion de guias, su funcion es insertaFr y actualizar informacion de las tablas DeliveryOrder, DeliveryOrderPaymentDetail y SchedulePickup >
-- =============================================
CREATE PROCEDURE [dbo].[SetRecolectionRequest_temp]
	@TblDeliveryOrdersList AS [TblDeliveryOrdersList2] READONLY,
	@Iscollected bit = true,
	@status int = 15,
	@ShipmentCompleted bit = true,
	@IdStatus as int = 15,
	@Token as nvarchar(100),
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
        SAVE TRANSACTION ProcedureSave;  
    ELSE  
        BEGIN TRANSACTION;  
    -- Modify database.  


    BEGIN TRY  
        --DELETE HumanResources.JobCandidate  
            --WHERE JobCandidateID = @InputCandidateID;  
		--SELECT 1/0;
		--SELECT 'hOLA';



			

        -- Get here if no errors; must commit  
        -- any transaction started in the  
        -- procedure, but not commit a transaction  
        -- started before the transaction was called.  
			SELECT
				'SUCESS' AS message
			   ,'TRUE' blnResult
			   ,419 StatusResult
			   ,0 AS ErrorNumber
			   ,0 AS ErrorSeverity
			   ,0 AS ErrorState
			   ,0 AS ErrorProcedure
			   ,0 AS ErrorLine
			   ,0 AS ResultMessage;
        IF @TranCounter = 0  
            -- @TranCounter = 0 means no transaction was  
            -- started before the procedure was called.  
            -- The procedure must commit the transaction  
            -- it started.  
            COMMIT TRANSACTION;  

			SELECT 'TABLA1';
			SELECT 'TABLA2';
			SELECT 'TABLA3';

		RETURN 0;
    END TRY  
	
	BEGIN CATCH
		SELECT '=====> CATH DEL INNER';
		--INSERT INTO #SalesByStore (STS) VALUES ('FALLA')	
		--SELECT * FROM #SalesByStore
		--ROLLBACK TRANSACTION TRAN2
		--;THROW 99001, 'O associated with the given Q Id already exists 222222222', 1;
		--RETURN 0
		--ROLLBACK TRAN TRAN2
		 --EXECUTE usp_GetErrorInfo;  
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
				SELECT 'ROLLBACK TRANSACTION';
                ROLLBACK TRANSACTION ProcedureSave;  
                -- If the transaction is uncommitable,			
				END
	--IF @@TRANCOUNT > 0
	--BEGIN
	--	--COMMIT TRANSACTION TRAN2;
		
	--	--SELECT 'CORRECTO';
	--	--RETURN -1;
	--END
        DECLARE @ErrorMessage NVARCHAR(4000);  
        DECLARE @ErrorSeverity INT;  
        DECLARE @ErrorState INT;  
  
        SELECT @ErrorMessage = ERROR_MESSAGE();  
        SELECT @ErrorSeverity = ERROR_SEVERITY();  
        SELECT @ErrorState = ERROR_STATE();  
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
	        RAISERROR (@ErrorMessage, -- Message text.  
                   @ErrorSeverity, -- Severity.  
                   @ErrorState -- State.  
                   ); 
				   		RETURN -1;
	END CATCH;	




END
