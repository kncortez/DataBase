-- =============================================
-- Author:		<Cristian, Azurdia>
-- Create date: <2024-12-05>
-- Description:	< Ingresión de datos de guía en AnticipatedCODDetail al momento determinar que una guía es COD Anticipado >
-- =============================================

CREATE PROCEDURE [dbo].[SetServiceRecolectCODAnticipated]
-- Add the parameters for the stored procedure here
	@GuideSerie  NVARCHAR(3) = 'FT',  
	@GuideNumber INT = 955582,  
	@Token          NVARCHAR(50) = 'API-FORZA',  
	@IsProcessedGuideCOD INT = 0,  
	@Code           SMALLINT OUTPUT,  
	@Message        NVARCHAR(3000) OUTPUT  
AS  
BEGIN  
  
 --INFORMACIÓN AH OBTENER DEL HEADER  
	DECLARE @IdAnticipatedCODHeader INT;
	DECLARE @PortfolioId	INT
	DECLARE @IsOldest   INT;  
	DECLARE @MinGuidesPerMonth INT;  
	DECLARE @DailyAmount  DECIMAL(9,2);  
	DECLARE @IsCODAnticipatedValid INT;  
   
	--INFORMACIÓN QUE ES CONSTANTE  
	DECLARE @BalanceStatus NVARCHAR(16) = 'PENDIENTE';
	DECLARE @GuideStatus   NVARCHAR(16) = 'COD Anticipado';
	DECLARE @CustomerStatus NVARCHAR(16) = 'CORPORATIVO'
   
	-- INFORMACIÓN QUE SE CALCULARA EN EL CAMINO  
	DECLARE @CustomerId INT;
	DECLARE @CustomerTypeId INT;
	DECLARE @IdCountrySender NVARCHAR(4)  
  
	DECLARE @IdSegmentDefault INT  
	DECLARE @CollectOnDelivery DECIMAL(9,2);  
	DECLARE @CollectOnDeliveryDaily DECIMAL(9,2);  
	DECLARE @CODExemptDefault DECIMAL(12, 2)  
   
    DECLARE @StatusOrderId           INT,
	        @CatModuleId             INT,
	        @RateHeaderId            INT,
	        @ReturnPercent           DECIMAL(18,2),
            @ReturnPercentConfig     DECIMAL(18,2),
            @ComissionToPay          DECIMAL(18,2)

	DECLARE @CODRateDefault DECIMAL(12, 2);  
	DECLARE @InitialRate DECIMAL(12, 2);  
	DECLARE @FinalRate DECIMAL(12, 2);  
  
	DECLARE @AnticipatedCODComissionId INT = 0;  
  
	--1. OBTENER EL CLIENTE QUE GENERA LA GUIA  
	SELECT   
		@CustomerId      = IdCustomer,
		@PortfolioId     = VisitPointClientPortfolioId,
		@IdCountrySender = SenderCountryId  
	FROM DeliveryOrder WITH(NOLOCK)  
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber  

    --PRINT 'Cliente: ' + CONVERT(NVARCHAR(8),@CustomerId) + ' Tipo Cliente: ' + CONVERT(NVARCHAR(8),@CustomerTypeId) + ' PortFolio: ' + CONVERT(NVARCHAR(8),@PortfolioId)
    --2. SE VERIFICA SI EL CLIENTE ESTA REGISTRADO, DE NO ESTARLO SE TERMINA EL PROCESO  
    --   SI EL CLIENTE ES DE CARTERA NO TIENE CODIGO DE CLIENTE, SOLAMENTE PORTAFOLIO

    IF NOT EXISTS(
                  SELECT TOP 1 1
                    FROM AnticipatedCODHeader ach WITH(NOLOCK)
                         INNER JOIN Customer cus WITH(NOLOCK)
                            ON cus.idCustomer = ach.CustomerId
                   WHERE ach.CustomerId = @CustomerId
                     AND cus.IdCustomerType IN (1,3)
                  )
    BEGIN  
         IF NOT EXISTS(
                       SELECT TOP 1 1
                         FROM AnticipatedCODHeader ach WITH(NOLOCK)
                              INNER JOIN Customer cus WITH(NOLOCK)
                                 ON cus.idCustomer = ach.CustomerId
                              INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
                                  ON VP.CustomerID = cus.IdCustomer
                                -- AND VP.StatusClient = 1
                              INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                                  ON ISNULL(VPP.VisitPointId,0) = ISNULL(VP.IdVisitPointClient,0)
                                 AND VPP.RowStatus = 1
                        WHERE cus.IdCustomerType IN (2)
                          AND VPP.IdVisitPointByClientPortfolio = @PortfolioId
						   AND VP.StatusClient = 1
                       )
         BEGIN 
              SELECT @Code = 0,  
                     @Message = 'No existe el cliente registrado para COD Anticipado '  

              SELECT @Code AS code,  
                     @Message AS [Message];  
              RETURN;
         END
    END

	--3. SE VERIFICA SI LA GUIA ESTA REGISTRADA, DE ESTARLO SOLO SE ACTUALIZA SU ESTADO  
	IF NOT EXISTS(SELECT 1 
                    FROM AnticipatedCODDetail WITH(NOLOCK) 
                   WHERE GuideSerie = @GuideSerie 
                     and GuideNumber = @GuideNumber)  
	BEGIN  
     
		--3.1 Se Obtienen datos de la tabla de encabezado
        IF EXISTS(
              SELECT TOP 1 1
                FROM AnticipatedCODHeader ach WITH(NOLOCK)
                     INNER JOIN Customer cus WITH(NOLOCK)
                        ON cus.idCustomer = ach.CustomerId
               WHERE ach.CustomerId = @CustomerId
                 AND cus.IdCustomerType IN (1,3)
              )
        BEGIN  
              SELECT @IdAnticipatedCODHeader = IdAnticipatedCODHeader,
                     @IsOldest = IsOldest,
                     @MinGuidesPerMonth = MinGuidesPerMonth,
                     @DailyAmount = DailyAmount,
                     @ReturnPercent = ReturnPercent,
                     @IsCODAnticipatedValid = IsCODAnticipatedValid  
                FROM AnticipatedCODHeader WITH(NOLOCK)
               WHERE CustomerId = @CustomerId
                 AND RowStatus = 1
        END
        ELSE IF EXISTS (
                           SELECT TOP 1 1
                             FROM AnticipatedCODHeader ach WITH(NOLOCK)
                                  INNER JOIN Customer cus WITH(NOLOCK)
                                     ON cus.idCustomer = ach.CustomerId
                                  INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
                                      ON VP.CustomerID = cus.IdCustomer
                                     AND VP.StatusClient = 1
                                  INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
                                      ON ISNULL(VPP.VisitPointId,0) = ISNULL(VP.IdVisitPointClient,0)
                                     AND VPP.RowStatus = 1
                            WHERE cus.IdCustomerType IN (2)
                              AND VPP.IdVisitPointByClientPortfolio = @PortfolioId
                           )
        BEGIN 
             SELECT @IdAnticipatedCODHeader = IdAnticipatedCODHeader,
                    @IsOldest = IsOldest,
                    @MinGuidesPerMonth = MinGuidesPerMonth,
                    @DailyAmount = DailyAmount,
                    @ReturnPercent = ReturnPercent,
                    @IsCODAnticipatedValid = IsCODAnticipatedValid  
               FROM AnticipatedCODHeader WITH(NOLOCK)
              WHERE PortfolioId = @PortfolioId
                AND RowStatus = 1
        END

		--PRINT 'AnticipatedCODHeader: ' + CONVERT(NVARCHAR(16),@IdAnticipatedCODHeader) + ' IsOldest: ' + CONVERT(NVARCHAR(16),@IsOldest) + ' MinGuidesPerMonth: ' + CONVERT(NVARCHAR(16),@MinGuidesPerMonth) + ' ReturnPercent: ' + CONVERT(NVARCHAR(16),@ReturnPercent)  + ' IsCODAnticipatedValid: ' + CONVERT(NVARCHAR(16), @IsCODAnticipatedValid)
		--3.2 Se Obtienen datos para poder realizar consulta de tarifario  
	   SELECT TOP 1  
				@IdSegmentDefault = CrsId
		FROM dbo.CatRateSegment WITH(NOLOCK)  
		WHERE CrsShortName = 'FOR'  
		AND CrsRowStatus = 'true';  
		--3.3 Se Obtienen de tarifario del cliente
		SELECT  
			@CollectOnDelivery = DO.Collect_OnDelivery  --'AmountCOD'  
		  , @AnticipatedCODComissionId =  ACC.IdAnticipatedCodComission  
		  --, @ComissionToPay = CASE  
			 --                     WHEN   
			 --                     	(ACC.AnticipatedCODComission IS NOT NULL AND ACC.AnticipatedCODComission > 0.00)  
			 --                     	AND (ACC.InitialRange <= DO.Collect_OnDelivery AND DO.Collect_OnDelivery <= ACC.FinalRange)  
			 --                        THEN  
			 --                        	ACC.AnticipatedCODComission  
			 --                     ELSE  
			 --                         CASE  
			 --                            WHEN CPmin1.Value >= DO.Collect_OnDelivery 
    --                                          AND DO.Collect_OnDelivery <= CPmax1.Value  
			 --                                 THEN CAST(CPv1.value AS DECIMAL)  
			 --                            WHEN CPmin2.Value >= DO.Collect_OnDelivery 
    --                                          AND DO.Collect_OnDelivery <= CPmax2.Value  
			 --                                 THEN CAST(CPv2.value AS DECIMAL)  
			 --                            ELSE CAST(CPv3.value AS DECIMAL)  
			 --                     END
			 --                 END            -- 'ComisionCODAnticipated'  
            , @ReturnPercentConfig = ISNULL(RH.ReturnPercent, CPv4.[Value])
			, @FinalRate = RH.GuideAmountCOD     -- 'MaxAmountCODAnticipated'  
			, @RateHeaderId = RH.RheId       -- 'RheId  
			, @CatModuleId = DO.CatModuleId  
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)  
		   LEFT JOIN dbo.VisitPointClient            VPC WITH (NOLOCK)  
			ON VPC.CodeOfReference = DO.Sender_ID  
		   LEFT JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)  
			ON RBC.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)  
			 AND RBC.RbcRowStatus = 1 AND RBC.RbcCodeOfReference IS NULL  
		   LEFT JOIN dbo.RatebyCustomer RBC2 WITH (NOLOCK)  
			ON RBC2.RbcIdCustomer = ISNULL(DO.IdCustomer, VPC.CustomerID)  
			 AND RBC2.RbcRowStatus = 1 AND RBC2.RbcCodeOfReference = DO.Sender_ID  
		   LEFT JOIN DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)  
			ON RBC.RbcIdRate = RH.RheId  
		   LEFT JOIN DeliveryBackOffice.dbo.AnticipatedCODComission ACC WITH(NOLOCK)  
			ON RH.RheId = ACC.RateHeaderId   
		   --Son rangos por default que tenemos si en dado caso el tarifario no cumple su rango  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin1 WITH(NOLOCK)  
			ON CPmin1.IdCountry = DO.ReceiverCountryId AND CPmin1.Name = 'MinRangeCODComisison1Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin2 WITH(NOLOCK)  
			ON CPmin2.IdCountry = DO.ReceiverCountryId AND CPmin2.Name = 'MinRangeCODComisison2Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax1 WITH(NOLOCK)  
			ON CPmax1.IdCountry = DO.ReceiverCountryId AND CPmax1.Name = 'MaxRangeCODComisison1Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax2 WITH(NOLOCK)  
			ON CPmax2.IdCountry = DO.ReceiverCountryId AND CPmax2.Name = 'MaxRangeCODComisison2Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv1 WITH(NOLOCK)  
			ON CPv1.IdCountry = DO.ReceiverCountryId AND CPv1.Name = 'ValueCODComisison1Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv2 WITH(NOLOCK)  
			ON CPv2.IdCountry = DO.ReceiverCountryId AND CPv2.Name = 'ValueCODComisison2Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv3 WITH(NOLOCK)  
			ON CPv3.IdCountry = DO.ReceiverCountryId AND CPv3.Name = 'ValueCODComisison3Param'  
		   LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv4 WITH(NOLOCK)  
			ON CPv4.IdCountry = DO.ReceiverCountryId AND CPv4.Name = 'ReturnPercentParam'  
		   WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber  

		--3.4 VAlidar que no se exceda del monto diario
		IF(@DailyAmount >=  @CollectOnDelivery)  
		BEGIN  
			--3.4.1 VAlidar que el porcentaje de retorno sea mayor a 0
			IF(@ReturnPercent < @ReturnPercentConfig)  
			BEGIN        
			  BEGIN TRANSACTION InsertCODAnticipated  
			  BEGIN TRY         
					--INSERTAR VALORES EN LA TABLA DE PROCESAMIENTO DE GUIAS COD (NO APLICA SI ENVIA PARAMETRO) 
					 IF(@IsProcessedGuideCOD = 1)  
					 BEGIN  
						IF NOT EXISTS(SELECT TOP 1 1 FROM DeliveryBackOffice.dbo.ProcessedGuideCOD WITH(NOLOCK) WHERE GuideSerie = @GuideSerie AND GuideNumber = @GuideNumber)  
						BEGIN  
							 INSERT INTO DeliveryBackOffice.dbo.ProcessedGuideCOD(GuideSerie,GuideNumber,DataOriginId,Token,CustomerId,IsAnticipatedCOD)  
							 VALUES(@GuideSerie,@GuideNumber,@CatModuleId,@Token,@CustomerId,1);  
						END  
					 END  

					 --INSERTAR VALORES EN EL DETALLLE DE COD ANTICIPADO  
					 INSERT INTO AnticipatedCODDetail(AnticipatedCODHeaderId,GuideSerie,GuideNumber,IsOldest,MinGuidesPerMonth,DailyAmount,ReturnPercent,IsCODAnticipatedValid,CollectOnDelivery,AnticipatedCODComissionId,BalanceStatus,RowStatus,TokenCreated,DateCreated) 
					 VALUES(@IdAnticipatedCODHeader,@GuideSerie,@GuideNumber,@IsOldest,@MinGuidesPerMonth,@DailyAmount, @ReturnPercent,@IsCODAnticipatedValid,@CollectOnDelivery,@AnticipatedCODComissionId,@BalanceStatus,1,@Token,GETDATE())  
					 SELECT @StatusOrderId = StatusOrderId FROM StatusOrder WHERE  OrderDescription = @GuideStatus

					 INSERT INTO DeliveryOrderDetail(Guide_Serie,Guide_Number,StatusOrderId,UserCreated,DateCreated,DateCreatedInSystem,RowStatus)
					 VALUES(@GuideSerie,@GuideNumber,@StatusOrderId,@Token,GETDATE(),GETDATE(),1);

                     DECLARE @AnticipatedCODDetail AS TblAnticipatedCODCustomerBalance

                     INSERT INTO @AnticipatedCODDetail
                     VALUES (@CustomerId, @PortfolioId)

                     EXEC spUpdateBalanceByIdClient @AnticipatedCODDetail

					 SELECT  @Code = 200,  
					   @Message = 'Proceso finalizado'  
             
					 SELECT  @Code AS code,  
					   @Message AS [Message];  

					 COMMIT TRANSACTION InsertCODAnticipated  

					 UPDATE DeliveryBackOffice.dbo.ProcessedGuideCOD
					 SET IsCompleted = 1
					 WHERE  GuideSerie = @GuideSerie 
						AND GuideNumber = @GuideNumber

			  END TRY  
			  BEGIN CATCH  
  
					ROLLBACK TRANSACTION InsertCODAnticipated;  
					SELECT  @Code = 0,  
					  @Message = 'Existe errores al momento de registrar la Guia'  
            
					SELECT  @Code AS code,  
					  @Message AS [Message];  
			  END CATCH
		END  
		ELSE  
		BEGIN  
			PRINT 'Return Percent: ' + CONVERT(NVARCHAR(16),@ReturnPercent)  
			SELECT  @Code = 0,  
			 @Message = 'El monto no se encuentra dentro de los paramettros definidos'  
        
			SELECT  @Code AS code,  
			  @Message AS [Message];  
		END  
		RETURN;
		END  
		ELSE  
		BEGIN  
			PRINT  'LIMITE DIARIO: ' + CONVERT(NVARCHAR(12),@DailyAmount) + ' MONTO COD: ' + CONVERT(NVARCHAR(12),@collectOnDeliveryDaily);  
			SELECT  @Code = 0,  
			@Message = 'Limite Diario COD Anticipado superado'  
      
			SELECT  @Code AS code,  
			@Message AS [Message];  
			RETURN;  
		END  
  
	END  
	ELSE  
	BEGIN  

		BEGIN TRANSACTION  UpdateCOD  
  
		BEGIN TRY  
  
			UPDATE AnticipatedCODDetail  
				SET RowStatus =   
				CASE   
				 WHEN RowStatus = 1 THEN 0  
				 ELSE 1  
				 END,  
				TokenUpdated = @Token,  
				DateUpdated  = GETDATE()  
			WHERE GuideSerie = @GuideSerie 
			 AND GuideNumber = @GuideNumber;  
     
		    COMMIT TRANSACTION UpdateCOD  
     
		END TRY  
		BEGIN CATCH  
    
			ROLLBACK TRANSACTION UpdateCOD;  
  
			SELECT  @Code = 0,  
			  @Message = 'No es posible Actualizar la guía'  
  
			SELECT  @Code AS code,  
			  @Message AS [Message];  
			RETURN;  
  
		END CATCH  
	 END
  
END