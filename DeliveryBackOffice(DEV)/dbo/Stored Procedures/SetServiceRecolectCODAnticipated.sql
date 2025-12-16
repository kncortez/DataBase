/* =================================================
   SP:        [dbo].[SetServiceRecolectCODAnticipated]
   Propósito: Ingresión de datos de guía en AnticipatedCODDetail al momento determinar que una guía es COD Anticipado
   Autor:     Equipo Reclutamiento
   Historia:  <>
   Fecha:     <2024-12-05>
   === CHANGELOG ============================
2025-12-16 | Historia/épica: <FDAPI-4788> | Autor: Tito Garcia |
=========================================== */
CREATE PROCEDURE [dbo].[SetServiceRecolectCODAnticipated]
	@GuideSerie  NVARCHAR(3) = 'FD',  
	@GuideNumber INT = 955582,  
	@Token          NVARCHAR(50) = 'API-FORZA',  
	@IsProcessedGuideCOD INT = 0,
	@StationId INT
AS  
BEGIN  
  
 --INFORMACIÓN AH OBTENER DEL HEADER  
	DECLARE @IdAnticipatedCODHeader INT;
	DECLARE @PortfolioId	INT;
	DECLARE @IsOldest   INT;  
	DECLARE @MinGuidesPerMonth INT;  
	DECLARE @DailyAmount  DECIMAL(9,2);  
	DECLARE @IsCODAnticipatedValid INT;     
	--INFORMACIÓN QUE ES CONSTANTE  
	DECLARE @BalanceStatus NVARCHAR(16) = 'PENDIENTE';
	DECLARE @GuideStatus   NVARCHAR(16) = 'COD Anticipado';
	DECLARE @CustomerStatus NVARCHAR(16) = 'CORPORATIVO';
	-- INFORMACIÓN QUE SE CALCULARA EN EL CAMINO  
	DECLARE @CustomerId INT;
	DECLARE @CustomerTypeId INT;
	DECLARE @IdCountrySender NVARCHAR(4);    
	DECLARE @IdSegmentDefault INT;  
	DECLARE @CollectOnDelivery DECIMAL(9,2);  
	DECLARE @CollectOnDeliveryDaily DECIMAL(9,2);  
	DECLARE @CODExemptDefault DECIMAL(12, 2);     
    DECLARE @StatusOrderId           INT,
	        @CatModuleId             INT,
	        @RateHeaderId            INT,
	        @ReturnPercent           DECIMAL(18,2),
            @ReturnPercentConfig     DECIMAL(18,2),
            @ComissionToPay          DECIMAL(18,2);
	DECLARE @CODRateDefault DECIMAL(12, 2);  
	DECLARE @InitialRate DECIMAL(12, 2);  
	DECLARE @FinalRate DECIMAL(12, 2);    
	DECLARE @AnticipatedCODComissionId INT = 0;   
  
	--1. OBTENER EL CLIENTE QUE GENERA LA GUIA  
	SELECT   
		@CustomerId      = IdCustomer,
		@PortfolioId     = VisitPointClientPortfolioId,
		@IdCountrySender = SenderCountryId  
	FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)  
	WHERE Guide_Serie = @GuideSerie 
		AND Guide_Number = @GuideNumber;  

    --2. SE VERIFICA SI EL CLIENTE ESTA REGISTRADO, DE NO ESTARLO SE TERMINA EL PROCESO  
    --   SI EL CLIENTE ES DE CARTERA NO TIENE CODIGO DE CLIENTE, SOLAMENTE PORTAFOLIO

    IF NOT EXISTS(
                  SELECT TOP 1 1
                    FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK)
                         INNER JOIN DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
                            ON cus.idCustomer = ach.CustomerId
                   WHERE ach.CustomerId = @CustomerId
                     AND cus.IdCustomerType IN (1,3)
                  )
    BEGIN  
         IF NOT EXISTS(
                       SELECT TOP 1 1
                        FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
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
              SELECT 0 AS code,  
                     'No existe el cliente registrado para COD Anticipado ' AS [Message];  
              RETURN;
         END
    END

	--3. SE VERIFICA SI LA GUIA ESTA REGISTRADA, DE ESTARLO SOLO SE ACTUALIZA SU ESTADO  
	IF NOT EXISTS(SELECT 1 
                	FROM DeliveryBackOffice.dbo.AnticipatedCODDetail WITH(NOLOCK) 
                   	WHERE GuideSerie = @GuideSerie 
                    	AND GuideNumber = @GuideNumber)  
	BEGIN  
     
		--3.1 Se Obtienen datos de la tabla de encabezado
        IF EXISTS(
              SELECT TOP 1 1
                FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK)
                     INNER JOIN DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
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
                FROM DeliveryBackOffice.dbo.AnticipatedCODHeader WITH(NOLOCK)
               WHERE CustomerId = @CustomerId
                 AND RowStatus = 1
        END
        ELSE IF EXISTS (
                           SELECT TOP 1 1
                            FROM DeliveryBackOffice.dbo.AnticipatedCODHeader ach WITH(NOLOCK)
								INNER JOIN DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
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
            FROM DeliveryBackOffice.dbo.AnticipatedCODHeader WITH(NOLOCK)
            WHERE PortfolioId = @PortfolioId
            	AND RowStatus = 1
        END

		--3.2 Se Obtienen datos para poder realizar consulta de tarifario  
	   	SELECT TOP 1  
				@IdSegmentDefault = CrsId
		FROM DeliveryBackOffice.dbo.CatRateSegment WITH(NOLOCK)  
		WHERE CrsShortName = 'FOR'  
			AND CrsRowStatus = 1;  
		--3.3 Se Obtienen de tarifario del cliente
		SELECT  
			@CollectOnDelivery = DO.Collect_OnDelivery  --'AmountCOD'  
		  , @AnticipatedCODComissionId =  ACC.IdAnticipatedCodComission  
            , @ReturnPercentConfig = ISNULL(RH.ReturnPercent, CPv4.[Value])
			, @FinalRate = RH.GuideAmountCOD     -- 'MaxAmountCODAnticipated'  
			, @RateHeaderId = RH.RheId       -- 'RheId  
			, @CatModuleId = DO.CatModuleId  
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)  
			LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)  
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
				ON CPmin1.IdCountry = DO.ReceiverCountryId 
					AND CPmin1.Name = 'MinRangeCODComisison1Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmin2 WITH(NOLOCK)  
				ON CPmin2.IdCountry = DO.ReceiverCountryId 
					AND CPmin2.Name = 'MinRangeCODComisison2Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax1 WITH(NOLOCK)  
				ON CPmax1.IdCountry = DO.ReceiverCountryId 
					AND CPmax1.Name = 'MaxRangeCODComisison1Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPmax2 WITH(NOLOCK)  
				ON CPmax2.IdCountry = DO.ReceiverCountryId 
					AND CPmax2.Name = 'MaxRangeCODComisison2Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv1 WITH(NOLOCK)  
				ON CPv1.IdCountry = DO.ReceiverCountryId 
					AND CPv1.Name = 'ValueCODComisison1Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv2 WITH(NOLOCK)  
				ON CPv2.IdCountry = DO.ReceiverCountryId 
					AND CPv2.Name = 'ValueCODComisison2Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv3 WITH(NOLOCK)  
				ON CPv3.IdCountry = DO.ReceiverCountryId 
					AND CPv3.Name = 'ValueCODComisison3Param'  
			LEFT JOIN DeliveryBackOffice.dbo.ConfigParams CPv4 WITH(NOLOCK)  
				ON CPv4.IdCountry = DO.ReceiverCountryId 
					AND CPv4.Name = 'ReturnPercentParam'  
		WHERE DO.Guide_Serie = @GuideSerie 
			AND DO.Guide_Number = @GuideNumber  

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
					 INSERT INTO DeliveryBackOffice.dbo.AnticipatedCODDetail(AnticipatedCODHeaderId,GuideSerie,GuideNumber,IsOldest,MinGuidesPerMonth,DailyAmount,ReturnPercent,IsCODAnticipatedValid,CollectOnDelivery,AnticipatedCODComissionId,BalanceStatus,RowStatus,TokenCreated,DateCreated) 
					 VALUES(@IdAnticipatedCODHeader,@GuideSerie,@GuideNumber,@IsOldest,@MinGuidesPerMonth,@DailyAmount, @ReturnPercent,@IsCODAnticipatedValid,@CollectOnDelivery,@AnticipatedCODComissionId,@BalanceStatus,1,@Token,GETDATE())  
					 SELECT @StatusOrderId = StatusOrderId FROM DeliveryBackOffice.dbo.StatusOrder WHERE  OrderDescription = @GuideStatus

					 INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail(Guide_Serie,Guide_Number,StatusOrderId,UserCreated,DateCreated,DateCreatedInSystem,RowStatus,StationId)
					 VALUES(@GuideSerie,@GuideNumber,@StatusOrderId,@Token,GETDATE(),GETDATE(),1,@StationId);

                     DECLARE @AnticipatedCODDetail AS TblAnticipatedCODCustomerBalance

                     INSERT INTO @AnticipatedCODDetail
                     VALUES (@CustomerId, @PortfolioId)

                     EXEC spUpdateBalanceByIdClient @AnticipatedCODDetail
             
					 SELECT  200 AS code,  
					   'Proceso finalizado' AS [Message];  

					 COMMIT TRANSACTION InsertCODAnticipated  

					 UPDATE DeliveryBackOffice.dbo.ProcessedGuideCOD
					 SET IsCompleted = 1
					 WHERE  GuideSerie = @GuideSerie 
						AND GuideNumber = @GuideNumber

			  END TRY  
			  BEGIN CATCH  
					ROLLBACK TRANSACTION InsertCODAnticipated;  
            
					SELECT  0 AS code,  
					  'Existe errores al momento de registrar la Guia' AS [Message];  
			  END CATCH
			END  
		ELSE  
		BEGIN  
			PRINT 'Return Percent: ' + CONVERT(NVARCHAR(16),@ReturnPercent)  
        
			SELECT  0 AS code,  
			  'El monto no se encuentra dentro de los paramettros definidos' AS [Message];  
			RETURN;
		END  
		END  
		ELSE  
		BEGIN  
			PRINT  'LIMITE DIARIO: ' + CONVERT(NVARCHAR(12),@DailyAmount) + ' MONTO COD: ' + CONVERT(NVARCHAR(12),@collectOnDeliveryDaily);  
      
			SELECT  0AS code,  
			'Limite Diario COD Anticipado superado' AS [Message];  
			RETURN;  
		END    
	END  
	ELSE  
	BEGIN  

		BEGIN TRANSACTION  UpdateCOD  
  
		BEGIN TRY  
  
			UPDATE DeliveryBackOffice.dbo.AnticipatedCODDetail  
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
  
			SELECT  0 AS [code],  
			  'No es posible Actualizar la guía'  AS [Message];  
			RETURN;  
  
		END CATCH  
	 END  
END
