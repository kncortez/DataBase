--EXEC  [dbo].[GetGeneratedBatchCODDaily] 33,'8'

-- =============================================
-- Author:		<Cristian Azurdia>
-- Update date: <2024-11-18>
-- Description:	<Se agrega la Campo IsCompleted em tabla ProcessedGuideCOD, así como actualizacion de campos en Commmit padre>
-- =============================================
-- Author:		<Oscar Rodriguez>
-- Update date: <2024-12-09>
-- Description:	<Separacion de flujos para generacion de lotes cod inmediato y cod anticipado>
-- =============================================

CREATE  PROCEDURE [dbo].[GetGeneratedBatchCODDaily]
    @IdBankParam INT,
    @BatchTimeRange VARCHAR(300) = '',
    @CoDProcessID INT,
	@IdCountrySender NVARCHAR(50) = N'GT'
AS
BEGIN

	IF OBJECT_ID ('tempdb.dbo.#GuidesProcessCOD') IS NOT NULL
	DROP TABLE #GuidesProcessCOD;
	--TABLA PARA PODER CONFIRMAR QUE LA TRANSACCCION COD HA SIDO REALIZADA CORRECTAMENTE
	CREATE TABLE #GuidesProcessCOD
	(
		GuideSerie NVARCHAR(8),
		GuideNumber INT,
		IdBatchDetailCOD INT
		--CONSTRAINT PK_sphw_generate_batch_cod_recolection_tmp PRIMARY KEY (GuideSerie, GuideNumber)
	);

	CREATE NONCLUSTERED INDEX INDX_GetGeneratedBatchCODDaily_tmp ON #GuidesProcessCOD (GuideSerie, GuideNumber)

    -- Micro transacción para indicar inicio de proceso de CoD ejecutado
    BEGIN TRANSACTION Started_CoD_Execution_Process;
    BEGIN TRY

        UPDATE [DeliveryBackOffice].[dbo].[CoDDailyExecution]
        SET ProcessStarted = 1,
            TokenUpdated = 'SYS-HERMESWIRETRANSFER',
            DateUpdated = GETDATE()
        WHERE IdCoDDailyExecution = @CoDProcessID;

        COMMIT TRANSACTION Started_CoD_Execution_Process;

    END TRY
    BEGIN CATCH

        ROLLBACK TRANSACTION Started_CoD_Execution_Process;

    END CATCH;

    DECLARE @TranCounter INT;
    SET @TranCounter = @@TRANCOUNT;
    PRINT @TranCounter;
    PRINT XACT_STATE();

    IF @TranCounter > 0
    BEGIN
        -- Procedure called when there is  
        -- an active transaction.  
        -- Create a savepoint to be able  
        -- to roll back only the work done  
        -- in the procedure if there is an  
        -- error.  
        SAVE TRANSACTION GetGeneratedBatchCODDaily_Save;
    END;
    ELSE
    BEGIN
        -- Procedure must start its own  
        -- transaction.  
        BEGIN TRANSACTION;
    END;

    BEGIN TRY
        --DECLARE @IdBankParam INT = 5;
        DECLARE @UpdateLast INT;
        DECLARE @ProductNumber VARCHAR(MAX);
        DECLARE @Reference INT;
        DECLARE @Token VARCHAR(50) = 'SYS.SERVICECOD';
        DECLARE @ModuleName NVARCHAR(50) = N'Courier App';
        DECLARE @IdModule INT =
                (
                    SELECT cm.ModIdModule
                    FROM DeliveryBackOffice.dbo.CatModule cm WITH (NOLOCK)
                    WHERE cm.ModName = @ModuleName
                );
        DECLARE @BankName NVARCHAR(50) = N'BANCO DE AMERICA CENTRAL';
        --DECLARE @IdCountry NVARCHAR(50) = N'GT';
        DECLARE @InAccount NVARCHAR(50) = N'CUENTAS INTERNAS BAC O BANCOR';
        DECLARE @OutAccount NVARCHAR(50) = N'CREDITOS ENVIAR FONDOS A OTROS BANCOS';
        DECLARE @AccountType NVARCHAR(50) = N'MONETARIA';
        DECLARE @ConceptCustomer NVARCHAR(50) = N'PAGO';
        DECLARE @CreditAccount NVARCHAR(50) = IIF(@IdCountrySender = 'GT', N'903666261', N'903666262');
        DECLARE @ConceptForza NVARCHAR(50) = N'COMISION';
        DECLARE @BankBAC INT =
                (
                    SELECT db.Id_bank
                    FROM DeliveryBackOffice.dbo.DeliveryBank db WITH (NOLOCK)
                    WHERE db.Name = @BankName
                          AND db.Id_status = 1
                          AND ISNULL(db.Id_country ,'GT')= @IdCountrySender
                );
        DECLARE @CreditAccountId INT;
        DECLARE @CreditAccountName NVARCHAR(2000);
        SELECT @CreditAccountId = DCBA_Id,
               @CreditAccountName = DCBA_Nom_account
        FROM DeliveryBackOffice.dbo.DeliveryCustomerBankAccount WITH (NOLOCK)
        WHERE DCBA_Bank_Id = @BankBAC
              AND DCBA_Num_account = @CreditAccount
              AND DCBA_Id_estado = 1;
        DECLARE @FrecuencyCOD INT =
                (
                    SELECT CatBatchFrequencyCODId
                    FROM CatBatchFrequencyCOD WITH (NOLOCK)
                    WHERE Name = 'Diaria'
                );

        IF (@IdBankParam IN
            (
                SELECT PayingBank
                FROM DeliveryBackOffice.dbo.DeliveryBank WITH (NOLOCK)
                WHERE ISNULL(Id_country,'GT') = @IdCountrySender
                      AND Id_status = 1
                      AND PayingBank <> @BankBAC
                GROUP BY PayingBank
            )
           )
        BEGIN
            SELECT @ProductNumber
                =
            (
                SELECT STUFF(
                       (
                           SELECT /*TOP 50*/ ',' + CONCAT(pg.GuideSerie, pg.GuideNumber)
                           FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg WITH (NOLOCK)
                               INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                                   ON do.Guide_Serie = pg.GuideSerie
                                      AND do.Guide_Number = pg.GuideNumber
                               LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
                                   ON dcba.DCBA_Id = do.DCBA_ID
                                      AND dcba.DCBA_Id_estado = 1
                               LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                                   ON vpc.CodeOfReference = do.Sender_ID
                               LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                   ON cus.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                               LEFT JOIN dbo.VisitPointConfiguration VPO WITH (NOLOCK)
                                   ON VPO.VisitPointID = vpc.CodeOfReference
                           WHERE pg.BatchCODId IS NULL
                                 AND pg.BatchCODIdCommission IS NULL
                                 AND pg.RowStatus = 1
                                 AND COALESCE(VPO.CODAccountBankID, cus.CODAccountBankID, dcba.DCBA_Bank_Id) = @IdBankParam
                                 --AND ISNULL(do.IdCustomer, vpc.CustomerID) IN ( 2548, 370, 826, 57, 5688,7937 )
                                 --AND cus.IdCustomer IN (7937)
                                 AND pg.Date > '2024-09-30 00:00:00.000'
                                 AND cus.CatBatchFrequencyCODId = @FrecuencyCOD
                                 AND do.StatusOrderId != 7
                                 AND do.StatusOrderId IN ( 5, 22, 24 )
								 AND ISNULL(do.IsLastMileReturn,0) =0
								 --AND IIF(do.SenderCountryId is null, 'GT', do.SenderCountryId) = @IdCountrySender
								 AND do.SenderCountryId = @IdCountrySender
								 AND ISNULL(pg.IsAnticipatedCOD,0) <> 1
                           FOR XML PATH('')
                       ),
                       1,
                       1,
                       ''
                            )
            );
        END;
        ELSE
        BEGIN
            SELECT @ProductNumber
                =
            (
                SELECT STUFF(
                       (
                           SELECT /*TOP 50*/ ',' + CONCAT(pg.GuideSerie, pg.GuideNumber)
                           FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg WITH (NOLOCK)
                               INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                                   ON do.Guide_Serie = pg.GuideSerie
                                      AND do.Guide_Number = pg.GuideNumber
                               LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
                                   ON dcba.DCBA_Id = do.DCBA_ID
                                      AND dcba.DCBA_Id_estado = 1
                               LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                                   ON vpc.CodeOfReference = do.Sender_ID
                               LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                                   ON cus.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                               LEFT JOIN dbo.VisitPointConfiguration VPO WITH (NOLOCK)
                                   ON VPO.VisitPointID = vpc.CodeOfReference
                           WHERE pg.BatchCODId IS NULL
                                 AND pg.BatchCODIdCommission IS NULL
                                 AND pg.RowStatus = 1
                                 AND
                                 (
                                     (COALESCE(VPO.CODAccountBankID, cus.CODAccountBankID, dcba.DCBA_Bank_Id)) NOT IN
            (
                SELECT PayingBank
                FROM DeliveryBackOffice.dbo.DeliveryBank WITH (NOLOCK)
                WHERE ISNULL(Id_country,'GT') = @IdCountrySender
                      AND Id_status = 1
                      AND PayingBank <> @BankBAC
                GROUP BY PayingBank
            )
                                     OR (COALESCE(VPO.CODAccountBankID, cus.CODAccountBankID, dcba.DCBA_Bank_Id)) IS NULL
                                 )
                                 --   AND cus.IdCustomer IN ( 2548, 370, 826, 57, 5688,7937 )
                                 --AND ISNULL(do.IdCustomer, vpc.CustomerID) IN (7937)
                                 AND pg.Date > '2024-09-30 00:00:00.000'
                                 AND cus.CatBatchFrequencyCODId = @FrecuencyCOD
                                 AND do.StatusOrderId != 7
                                 AND do.StatusOrderId IN ( 5, 22, 24 )
								 --AND IIF(do.SenderCountryId is null, 'GT', do.SenderCountryId) = @IdCountrySender
								 AND do.SenderCountryId = @IdCountrySender
								 AND ISNULL(pg.IsAnticipatedCOD,0) <> 1
                           FOR XML PATH('')
                       ),
                       1,
                       1,
                       ''
                            )
            );
        END;

        -- Insert statements for procedure here
        IF OBJECT_ID('tempdb.dbo.#listGuidesDaily', 'U') IS NOT NULL
            DROP TABLE #listGuidesDaily;
        IF OBJECT_ID('tempdb.dbo.#TempDataDaily', 'U') IS NOT NULL
            DROP TABLE #TempDataDaily;
        IF OBJECT_ID('tempdb.dbo.#CODDataDaily', 'U') IS NOT NULL
            DROP TABLE #CODDataDaily;
        IF OBJECT_ID('tempdb.dbo.#RevalueGuidesDaily', 'U') IS NOT NULL
            DROP TABLE #RevalueGuidesDaily;
        IF OBJECT_ID('tempdb.dbo.#PendingPaymentTempDaily', 'U') IS NOT NULL
            DROP TABLE #PendingPaymentTempDaily;
        IF OBJECT_ID('tempdb.dbo.#TableAmountCODDaily', 'U') IS NOT NULL
            DROP TABLE #TableAmountCODDaily;
        IF OBJECT_ID('tempdb.dbo.#TableAmountCODDailyTemp', 'U') IS NOT NULL
            DROP TABLE #TableAmountCODDailyTemp;
        IF OBJECT_ID('tempdb.dbo.#TableCustomerPaymentTempDaily', 'U') IS NOT NULL
            DROP TABLE #TableCustomerPaymentTempDaily;
        IF OBJECT_ID('tempdb.dbo.#TableForzaPaymentTempDaily', 'U') IS NOT NULL
            DROP TABLE #TableForzaPaymentTempDaily;

        IF @ProductNumber IS NOT NULL
        BEGIN
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- +++++++++++++++++++++++++++++++++ - COMIENZA EL BRAIN - ++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
            SET NOCOUNT ON;

            CREATE TABLE #listGuidesDaily
            (
                Guide_Serie NVARCHAR(2),
                Guide_Number INT
            );
            CREATE NONCLUSTERED INDEX tempSerieNumber ON #listGuidesDaily (Guide_Serie,Guide_Number);
            --CREATE NONCLUSTERED INDEX tempGuide ON #listGuidesDaily (Guide_Number);
            CREATE TABLE #RevalueGuidesDaily
            (
                fila INT,
                Guide_Serie NVARCHAR(2),
                Guide_Number INT
            );

            CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuidesDaily (fila);



            INSERT INTO #listGuidesDaily
            (
                Guide_Serie,
                Guide_Number
            )
            SELECT SUBSTRING(Item, 1, 2) ItemSerie,
                   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber
            FROM DeliveryBackOffice.dbo.SplitUnlimited(@ProductNumber, ',');

            DECLARE @IdRateDefault INT =
                    (
                        SELECT
                               rh.RheId
                        FROM DeliveryBackOffice.dbo.RateHeader rh WITH (NOLOCK)
                        WHERE rh.RheRowStatus = 1
                              AND rh.RheDefault = 1
							  AND rh.RateTypeId = 1
							  AND ISNULL(rh.CountryId,'GT') = @IdCountrySender
                    );
            DECLARE @IdRate INT;
            DECLARE @CODRateDefault DECIMAL(12, 2) =
                    (
                        SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
                        FROM DeliveryBackOffice.dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'CODRateDef'
                              AND Status = 1
							  AND ISNULL(cf.IdCountry,'GT') = @IdCountrySender
                    );
            DECLARE @CODExemptDefault DECIMAL(12, 2) =
                    (
                        SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
                        FROM DeliveryBackOffice.dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'CODExemptDef'
                              AND Status = 1
							  AND ISNULL(cf.IdCountry,'GT') = @IdCountrySender
                    );

            ---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------
            INSERT INTO #RevalueGuidesDaily
            (
                fila,
                Guide_Serie,
                Guide_Number
            )
            SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
                   ord.Guide_Serie,
                   ord.Guide_Number
            FROM #listGuidesDaily lst
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Number = lst.Guide_Number
                       AND ord.Guide_Serie = lst.Guide_Serie
                LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                    ON PC.GuideSerieDestination = ord.Guide_Serie
                       AND PC.GuideNumberDestination = ord.Guide_Number
                       AND PC.RowStatus = 1
            WHERE ISNULL(ord.PriceShippment, 0) = 0
                  AND PC.IdPromoCoupon IS NULL
				  --AND IIF(ord.SenderCountryId is null, 'GT', ord.SenderCountryId) = @IdCountrySender;
				  AND ord.SenderCountryId = @IdCountrySender;


            DECLARE @count INT = 1;
            DECLARE @RevalueSerie VARCHAR(10);
            DECLARE @RevalueGuide INT;
            DECLARE @IdMax INT =
                    (
                        SELECT MAX(fila)FROM #RevalueGuidesDaily
                    );
            DECLARE @RC INT;

            WHILE @count <= @IdMax
            BEGIN

                PRINT '************************revalue**********************';
                PRINT CONVERT(VARCHAR(100), GETDATE(), 9);
                PRINT @RevalueSerie;
                PRINT @RevalueGuide;
                PRINT @count;
                SELECT @RevalueSerie = rv.Guide_Serie,
                       @RevalueGuide = rv.Guide_Number
                FROM #RevalueGuidesDaily rv
                WHERE rv.fila = @count;

                EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide @GuideSerie = @RevalueSerie,
                                                                        @GuideNumber = @RevalueGuide,
                                                                        @CodeApp = '',
                                                                        @Format = 'Non',
                                                                        @CalculateTaxes = 'true',
                                                                        @IdModule = @IdModule,
                                                                        @SetUpdate = 'true',
                                                                        @Token = @Token,
                                                                        @IsReturn = 'false';
                SET @count = @count + 1;


            END;
            -----------------------------------------------------------------------------------------------------
            DECLARE @IdSegmentDefault INT =
                    (
                        SELECT TOP 1
                               CrsId
                        FROM dbo.CatRateSegment WITH (NOLOCK)
                        WHERE CrsShortName = 'FOR'
                              AND CrsRowStatus = 'true'
                    );
            SELECT ord.Guide_Serie,
                   ord.Guide_Number,
                   ord.Collect_OnDelivery,
                   ISNULL(ord.IdCustomer, vpc.CustomerID) IDCUSTOMER,
                   ISNULL(rco.CODRate, @CODRateDefault) CODRate,
                   ISNULL(rco.CODExempt, @CODExemptDefault) CODExempt,
                   IIF((ord.Collect_OnDelivery - ISNULL(rco.CODExempt, @CODExemptDefault)) > 0,
                       IIF(op.Deposit_Number IS NULL,
                           IIF(ISNULL(vpc.ExcludeCommissionCOD, ISNULL(cus.ExcludeCommissionCOD, 0)) = 1,
                               0,
                               (CONVERT(
                                           DECIMAL(12, 2),
                                           ((ord.Collect_OnDelivery
                                             - (IIF(
                                                    ISNULL(
                                                              vpc.ExcludePriceShippingCOD,
                                                              ISNULL(cus.ExcludePriceShippingCOD, 0)
                                                          ) = 1,
                                                    0,
                                                    IIF(ISNULL(ord.IsCollect, 0) = 1,
                                                        0,
                                                        IIF(pyt.TimePlaId = 2,
                                                            0,
                                                            IIF(pyt.TimePlaId = 1, 0, ord.PriceShippment))))
                                               )
                                            )
                                            * ISNULL(rco.CODRate, @CODRateDefault) / 100
                                           )
                                       )
                               )),
                           0),
                       0) Commision,
                   ord.PriceShippment DeliveryPrice,
                   .0 CODPaid,
                   0 ReturnRates,
                   0 CODIsPaid,
                   bk.Id_bank,
                   bk.Name,
                   dc.DCBA_Id,
                   --ISNULL(dc.DCBA_Num_account, ISNULL(VPO.CODAccountNumber, cus.CODAccountNumber)) DCBA_Num_account,
                   COALESCE(VPO.CODAccountNumber, cus.CODAccountNumber, dc.DCBA_Num_account) DCBA_Num_account,
                   --ISNULL(dc.DCBA_Nom_account, ISNULL(VPO.CODAccountName, cus.CODAccountName)) DCBA_Nom_account,
                   COALESCE(VPO.CODAccountName, cus.CODAccountName, dc.DCBA_Nom_account) DCBA_Nom_account,
                   UPPER(ISNULL(dc.DCBA_BankAccountType, btp.BankAccountType)) DCBA_BankAccountType,
                   ISNULL(dc.DCBA_Identification, '') DCBA_Identification,
                   op.Deposit_Number,
                   --, iif(op.Deposit_Number is null,( ord.Collect_OnDelivery - tp.Commission - ord.PriceShippment   ), 0) as CODtoPay
                   IIF(op.Deposit_Number IS NULL,
                       ord.Collect_OnDelivery
                       -- comi
                       - IIF((ord.Collect_OnDelivery - ISNULL(rco.CODExempt, @CODExemptDefault)) > 0,
                             (IIF(ISNULL(vpc.ExcludeCommissionCOD, ISNULL(cus.ExcludeCommissionCOD, 0)) = 1,
                                  0,
                                  (CONVERT(
                                              DECIMAL(12, 2),
                                              ((ord.Collect_OnDelivery
                                                - (IIF(
                                                       ISNULL(
                                                                 vpc.ExcludePriceShippingCOD,
                                                                 ISNULL(cus.ExcludePriceShippingCOD, 0)
                                                             ) = 1,
                                                       0,
                                                       IIF(ISNULL(ord.IsCollect, 0) = 1,
                                                           0,
                                                           IIF(pyt.TimePlaId = 2,
                                                               0,
                                                               IIF(pyt.TimePlaId = 1, 0, ord.PriceShippment))))
                                                  )
                                               )
                                               * ISNULL(rco.CODRate, @CODRateDefault) / 100
                                              )
                                          )
                                  ))
                             ),
                             0)
                       -- envio
                       - (IIF(ISNULL(vpc.ExcludePriceShippingCOD, ISNULL(cus.ExcludePriceShippingCOD, 0)) = 1,
                              0,
                              IIF(ISNULL(ord.IsCollect, 0) = 1,
                                  0,
                                  IIF(pyt.TimePlaId = 2, 0, IIF(pyt.TimePlaId = 1, 0, ord.PriceShippment))))
                         ),
                       0) CODtoPay,
                   (IIF(ISNULL(vpc.ExcludePriceShippingCOD, ISNULL(cus.ExcludePriceShippingCOD, 0)) = 1,
                        0,
                        IIF(ISNULL(ord.IsCollect, 0) = 1,
                            0,
                            IIF(pyt.TimePlaId = 2, 0, IIF(pyt.TimePlaId = 1, 0, ord.PriceShippment))))
                   ) Price
            INTO #TableAmountCODDaily
            FROM #listGuidesDaily lst
                INNER JOIN dbo.DeliveryOrder ord WITH(NOLOCK)
                    ON ord.Guide_Serie = lst.Guide_Serie
                       AND ord.Guide_Number = lst.Guide_Number
                LEFT JOIN dbo.VisitPointClient vpc WITH(NOLOCK)
                    ON vpc.CodeOfReference = ord.Sender_ID
                LEFT JOIN dbo.RatebyCustomer rc WITH(NOLOCK)
                    ON rc.RbcIdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
                       AND rc.RbcRowStatus = 'true'
                       AND rc.RbcCodeOfReference is NULL
                LEFT JOIN dbo.RatebyCustomer rcv WITH(NOLOCK)
                    ON rcv.RbcIdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
                       AND rcv.RbcRowStatus = 1
                       AND rcv.RbcCodeOfReference = ord.Sender_ID
                LEFT JOIN dbo.Township twn WITH(NOLOCK)
                    ON twn.IdTownship = ord.ReceiverIdTownship
                LEFT JOIN dbo.Township twnm WITH(NOLOCK)
                    ON twnm.TownshipName = ord.Receiver_Town
                LEFT JOIN
                (
                    SELECT HeaderCode,
                           MAX(Hub) Hub
                    FROM dbo.DumpServiceCoverage WITH(NOLOCK)
                    WHERE RowStatus = 'true'
                    GROUP BY HeaderCode
                ) hub
                    ON hub.HeaderCode = ISNULL(twn.HeaderCode, twnm.HeaderCode)
                LEFT JOIN dbo.HubLogistics hbl WITH(NOLOCK)
                    ON hbl.HubAbbreviation = hub.Hub
                LEFT JOIN dbo.VisitPointConfiguration VPO WITH(NOLOCK)
                    ON VPO.VisitPointID = vpc.CodeOfReference
                LEFT JOIN dbo.CatTypeService csv WITH(NOLOCK)
                    ON csv.CtsShortName = IIF(ord.TypeService = 'EXP', 'NDD', ISNULL(ord.TypeService, 'NDD'))
                       AND csv.CtsRowStatus = 'true'
                LEFT JOIN dbo.VisitPointCoverage cv WITH(NOLOCK)
                    ON cv.VisitPointId = ord.Sender_ID
                       AND cv.HubLogisticId = hbl.IdHubLogistic
                       AND cv.RowStatus = 'true'
                LEFT JOIN dbo.RateCOD rco WITH(NOLOCK)
                    ON rco.RateId = ISNULL(rcv.RbcIdRate, rc.RbcIdRate)
                       AND rco.TypeServiceId = csv.CtsId
                       AND rco.TypeSegmentId = ISNULL(cv.SegmentId, @IdSegmentDefault)
                       AND rco.RowStatus = 1
                LEFT JOIN dbo.Customer cus WITH(NOLOCK)
                    ON cus.IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
                LEFT JOIN dbo.DeliveryOrderPaid op WITH(NOLOCK)
                    ON op.Guide_Serie = ord.Guide_Serie
                       AND op.Guide_Number = ord.Guide_Number
                       AND op.IdStatus = 'true'
                LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH(NOLOCK)
                    ON dc.DCBA_Id = ord.DCBA_ID
                       AND dc.DCBA_Id_estado = 1
                LEFT JOIN dbo.DeliveryBank bk WITH(NOLOCK)
                    ON bk.Id_bank = ISNULL(ISNULL(VPO.CODAccountBankID, cus.CODAccountBankID), dc.DCBA_Bank_Id)
                LEFT JOIN dbo.CatBankAccountType btp WITH(NOLOCK)
                    ON btp.IdBankAccountType = ISNULL(VPO.CODAccountBankTypeID, cus.CODAccountTypeID)
                LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH(NOLOCK)
                    ON pyt.GuideSerie = ord.Guide_Serie
                       AND pyt.GuideNumber = ord.Guide_Number
            WHERE ord.Collect_OnDelivery > 0
					 --AND IIF(ord.SenderCountryId is null, 'GT', ord.SenderCountryId) = @IdCountrySender
					  AND ord.SenderCountryId = @IdCountrySender
            ORDER BY cus.IdCustomer,
                     ord.Guide_Serie,
                     ord.Guide_Number;

            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++ - TERMINA EL BRAIN - ++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            -- LIMPIEZA DE REGISTROS DUPLICADOS DE LA RESPUESTA DEL BRAIN
            SELECT Guide_Serie,
                   Guide_Number,
                   Collect_OnDelivery,
                   IDCUSTOMER,
                   CODRate,
                   CODExempt,
                   Commision,
                   SUM(DeliveryPrice) DeliveryPrice,
                   SUM(ISNULL(CODPaid, 0)) CODPaid,
                   ReturnRates,
                   Id_bank,
                   [Name],
                   DCBA_Id,
                   DCBA_Num_account,
                   DCBA_Nom_account,
                   DCBA_BankAccountType,
                   MIN(CODtoPay) CODtoPay,
                   MAX(Price) Price
            INTO #TableAmountCODDailyTemp
            FROM #TableAmountCODDaily
            GROUP BY Guide_Serie,
                     Guide_Number,
                     Collect_OnDelivery,
                     IDCUSTOMER,
                     CODRate,
                     CODExempt,
                     Commision,
                     ReturnRates,
                     Id_bank,
                     [Name],
                     DCBA_Id,
                     DCBA_Num_account,
                     DCBA_Nom_account,
                     DCBA_BankAccountType
            ORDER BY Guide_Number;

            CREATE NONCLUSTERED INDEX IX_TACT_ISINCTPCP_GuideSerie_GuideNumber
            ON #TableAmountCODDailyTemp (
                                            [Guide_Serie],
                                            [Guide_Number]
                                        );

			CREATE NONCLUSTERED INDEX IX_TACT_ISINCTPCP_CODtoPay
            ON #TableAmountCODDailyTemp (
                                           [CODtoPay]
                                        );

			 --CREATE NONCLUSTERED INDEX IX_TACT_ISINCTPCP
    --        ON #TableAmountCODDailyTemp (
    --                                        [Guide_Serie],
    --                                        [Guide_Number],
    --                                        [CODtoPay],
    --                                        Commision,
    --                                        [Price]
    --                                    );

            -- ASIGNACION DEL ROWSTATUS CERO 
            -- PARA LAS GUIAS QUE NO TIENE CODTOPAY EN LA TABLA PROCESSGUIDE
            -- PARA CONOCER QUE GUIAS NO SE TIENEN QUE REPROCESAR
            UPDATE pgc
            SET pgc.RowStatus = 0
            FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc WITH (NOLOCK)
                INNER JOIN #TableAmountCODDailyTemp tact
                    ON pgc.GuideSerie = tact.Guide_Serie
                       AND pgc.GuideNumber = tact.Guide_Number
                       --AND tact.CODtoPay <= 0
            WHERE pgc.BatchCODId IS NULL
                  AND pgc.BatchCODIdCommission IS NULL
                  AND pgc.RowStatus = 1
				  AND tact.CODtoPay <= 0 --BNHL 14/11/2024 
				  AND ISNULL(pgc.IsAnticipatedCOD,0) <> 1
				  ;

            -- OBTENCION DEL NUMERO DE REFERENCIA (CORRELATIVO) PARA BAC
            SELECT @Reference = Last
            FROM DeliveryBackOffice.dbo.CatCorrelativeCOD WITH (NOLOCK)
            WHERE BankId = @BankBAC
                  AND RowStatus = 1;

            -- CONSTRUCCION DE REGISTROS PARA EL PAGO A FORZA DE LAS COMISIONES Y ENVIOS
            SELECT tact.Guide_Serie GuideSerie,
                   tact.Guide_Number GuideNumber,
                   (
                       SELECT IdCatDebitAccountCOD
                       FROM DeliveryBackOffice.dbo.CatDebitAccountCOD WITH (NOLOCK)
                       WHERE BankId = @BankBAC
                             AND RowStatus = 1
                   ) CatDebitAccountCODId,
                   @CreditAccountId CreditAccountId,
                   (tact.Commision + tact.Price) Amount,
                   tact.Commision [Commision],
                   (
                       SELECT IdCatTransactionTypeCOD
                       FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD WITH (NOLOCK)
                       WHERE BankId = @BankBAC
                             AND RowStatus = 1
                             AND Description = @InAccount
                   ) CatTransactionTypeCODId,
                   @BankBAC BankId,
                   (
                       SELECT IdCatAccountTypeCOD
                       FROM DeliveryBackOffice.dbo.CatAccountTypeCOD WITH (NOLOCK)
                       WHERE RowStatus = 1
                             AND AccountType = UPPER(@AccountType)
                   ) CatAccountTypeCODId,
                   (
                       SELECT IdCatConceptCOD
                       FROM DeliveryBackOffice.dbo.CatConceptCOD WITH (NOLOCK)
                       WHERE RowStatus = 1
                             AND Concept LIKE (@ConceptForza + '%')
                   ) CatConceptCODId,
                   ((ROW_NUMBER() OVER (ORDER BY tact.Guide_Number)) + ISNULL(@Reference, 0)) Reference,
                   @BankName BankName,
                   UPPER(@AccountType) TypeAccountName,
                   @CreditAccount AccountNumber,
                   @CreditAccountName AccountName,
                   CODRate,
                   tact.Price DiscountPrice
            INTO #TableForzaPaymentTempDaily
            FROM #TableAmountCODDailyTemp tact
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON do.Guide_Serie = tact.Guide_Serie
                       AND do.Guide_Number = tact.Guide_Number
            WHERE (tact.Commision + tact.Price) > 0
                  AND tact.CODtoPay > 0
				  --AND IIF(do.SenderCountryId is null, 'GT', do.SenderCountryId) = @IdCountrySender
				  AND do.SenderCountryId = @IdCountrySender
            --AND tact.Id_bank IS NOT NULL
            ;

            CREATE NONCLUSTERED INDEX IX_TFPT_GSGNCABI
            ON #TableForzaPaymentTempDaily (
                                               [GuideSerie],
                                               [GuideNumber],
                                               [CreditAccountId],
                                               [BankId]
                                           );

            CREATE NONCLUSTERED INDEX IX_TFPTD_Guides
            ON #TableForzaPaymentTempDaily (
                                               [GuideSerie],
                                               [GuideNumber]
                                           );

            SET @Reference = @Reference +
                             (
                                 SELECT COUNT(1)FROM #TableForzaPaymentTempDaily
                             );

            -- CONSTRUCCION DE REGISTROS PARA EL PAGO A LOS CLIENTES DE COD
            -- SIN IMPORTAR EL BANCO AL QUE PERTENECE LA CUENTA DEL CLIENTE
            SELECT tact.Guide_Serie GuideSerie,
                   tact.Guide_Number GuideNumber,
                   (
                       SELECT IdCatDebitAccountCOD
                       FROM DeliveryBackOffice.dbo.CatDebitAccountCOD WITH (NOLOCK)
                       WHERE BankId = IIF(@BankBAC <> @IdBankParam, tact.Id_bank, @BankBAC)
                             AND RowStatus = 1
                   ) CatDebitAccountCODId,
                   tact.DCBA_Id CreditAccountId,
                   tact.CODtoPay Amount,
                   tact.Commision [Commision],
                   IIF(
                       tact.Id_bank NOT IN
                       (
                           SELECT PayingBank
                           FROM DeliveryBackOffice.dbo.DeliveryBank WITH (NOLOCK)
                           WHERE ISNULL(Id_country,'GT') = @IdCountrySender
                                 AND Id_status = 1
                                 AND PayingBank <> @BankBAC
                           GROUP BY PayingBank
                       ),
                       IIF(tact.Id_bank = @BankBAC,
                       (
                           SELECT IdCatTransactionTypeCOD
                           FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD WITH (NOLOCK)
                           WHERE BankId = tact.Id_bank
                                 AND RowStatus = 1
                                 AND Description = @InAccount
                       ),
                       (
                           SELECT IdCatTransactionTypeCOD
                           FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD WITH (NOLOCK)
                           WHERE BankId = @BankBAC
                                 AND RowStatus = 1
                                 AND Description = @OutAccount
                       )),
                       NULL) CatTransactionTypeCODId,
                   tact.Id_bank BankId,
                   (
                       SELECT IdCatAccountTypeCOD
                       FROM DeliveryBackOffice.dbo.CatAccountTypeCOD WITH (NOLOCK)
                       WHERE RowStatus = 1
                             AND AccountType = UPPER(tact.DCBA_BankAccountType)
                   ) CatAccountTypeCODId,
                   (
                       SELECT IdCatConceptCOD
                       FROM DeliveryBackOffice.dbo.CatConceptCOD WITH (NOLOCK)
                       WHERE RowStatus = 1
                             AND Concept LIKE (@ConceptCustomer + '%')
                   ) CatConceptCODId,
                   ((ROW_NUMBER() OVER (ORDER BY tact.Guide_Number))
                    + IIF(@IdBankParam = @BankBAC, ISNULL(@Reference, 0), 0)
                   ) Reference,
                   tact.Name BankName,
                   UPPER(tact.DCBA_BankAccountType) TypeAccountName,
                   tact.DCBA_Num_account AccountNumber,
                   tact.DCBA_Nom_account AccountName,
                   CODRate,
                   tact.Price DiscountPrice
            INTO #TableCustomerPaymentTempDaily
            FROM #TableAmountCODDailyTemp tact
            WHERE tact.CODtoPay > 0;
            --AND tact.Id_bank IS NOT NULL
            ;

            CREATE NONCLUSTERED INDEX IX_TCPT_GSGNCABI
            ON #TableCustomerPaymentTempDaily (
                                                  [GuideSerie],
                                                  [GuideNumber],
                                                  [CreditAccountId],
                                                  [BankId]
                                              );

            IF (@IdBankParam = @BankBAC)
            BEGIN
                SET @Reference = @Reference +
                                 (
                                     SELECT COUNT(1)FROM #TableCustomerPaymentTempDaily
                                 );
            END;

            -- ACTUALIZA EL CORRELATIVO PARA LA PROXIMA GENERACION DE LOTES
            UPDATE DeliveryBackOffice.dbo.CatCorrelativeCOD
            SET Last = ISNULL(@Reference, Last)
            WHERE BankId = @BankBAC
                  AND RowStatus = 1;

            -- SECCION PARA LA CREACION DEL LOTE PARA EL PAGO A CLIENTES
            DECLARE @MaxBatchNumber INT = 1 +
                                          (
                                              SELECT ISNULL(MAX(IdBatchCOD), 0)FROM DeliveryBackOffice.dbo.BatchCOD WITH (NOLOCK)
                                          );
            DECLARE @NewIdBatchCODCustomer INT;

            IF ((SELECT COUNT(1)FROM #TableCustomerPaymentTempDaily) > 0)
            BEGIN
                -- SE CREA EL LOTE PARA EL PAGO A CLIENTES
                INSERT INTO DeliveryBackOffice.dbo.BatchCOD
                (
                    BankId,
                    BatchNumber,
                    BatchTimeRange
                )
                VALUES
                (@IdBankParam, @MaxBatchNumber, @BatchTimeRange);

                -- OBTENCION DEL ID QUE CORRESPONDE AL LOTE CREADO
                SELECT @NewIdBatchCODCustomer = SCOPE_IDENTITY();

                IF (
                       (@NewIdBatchCODCustomer IS NOT NULL)
                       AND (@NewIdBatchCODCustomer > 0)
                       AND (@NewIdBatchCODCustomer <> @MaxBatchNumber)
                   )
                BEGIN
                    UPDATE DeliveryBackOffice.dbo.BatchCOD
                    SET BatchNumber = IdBatchCOD
                    WHERE IdBatchCOD = @NewIdBatchCODCustomer;

                    SET @MaxBatchNumber = @NewIdBatchCODCustomer;
                END;

                IF ((@NewIdBatchCODCustomer IS NOT NULL) AND (@NewIdBatchCODCustomer > 0))
                BEGIN
                    -- SE CREA EL DETALLE DEL LOTE PARA EL PAGO A CLIENTES
                    INSERT INTO DeliveryBackOffice.dbo.BatchDetailCOD
                    (
                        BatchCODId,
                        GuideSerie,
                        GuideNumber,
                        CatDebitAccountCODId,
                        CreditAccountId,
                        Amount,
                        Commission,
                        CatTransactionTypeCODId,
					    CatCurrencyCODId,
                        BankId,
                        CatAccountTypeCODId,
                        CatConceptCODId,
                        Reference,
                        Excluded,
                        Comments,
                        BankName,
                        TypeAccountName,
                        AccountNumber,
                        AccountName,
                        CODCommissionPercentage,
                        DiscountPrice,
						IdCountry
                    )
					OUTPUT						
						INSERTED.GuideSerie,
						INSERTED.GuideNumber,
						INSERTED.IdBatchDetailCOD
					INTO #GuidesProcessCOD
                    SELECT @NewIdBatchCODCustomer,
                           tcpt.GuideSerie,
                           tcpt.GuideNumber,
                           tcpt.CatDebitAccountCODId,
                           tcpt.CreditAccountId,
                           tcpt.Amount,
                           tcpt.Commision,
                           tcpt.CatTransactionTypeCODId,
						   IIF(c.CodCurrency is null, 1, c.CodCurrency),
                           tcpt.BankId,
                           tcpt.CatAccountTypeCODId,
                           tcpt.CatConceptCODId,
                           tcpt.Reference,
                           IIF(
                               DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
                                                                                           tcpt.AccountNumber,
                                                                                           tcpt.BankId,
                                                                                           tcpt.CatAccountTypeCODId,
                                                                                           tcpt.AccountName
                                                                                       ) IS NULL,
                               'FALSE',
                               'TRUE') Excluded,
                           DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
                                                                                       tcpt.AccountNumber,
                                                                                       tcpt.BankId,
                                                                                       tcpt.CatAccountTypeCODId,
                                                                                       tcpt.AccountName
                                                                                   ) Comments,
                           tcpt.BankName,
                           tcpt.TypeAccountName,
                           tcpt.AccountNumber,
                           tcpt.AccountName,
                           CODRate,
                           DiscountPrice,
						   @IdCountrySender
                    FROM #TableCustomerPaymentTempDaily tcpt
					LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK) 
					--ON c.ProductNumber = CONCAT(tcpt.GuideSerie, tcpt.GuideNumber)
					ON c.GuideSerie = tcpt.GuideSerie
					AND c.GuideNumber =  tcpt.GuideNumber --CAMBIO BNHL 14/11/2024
                    WHERE NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.BatchDetailCOD bdcod WITH (NOLOCK)
                        WHERE bdcod.GuideSerie = tcpt.GuideSerie
                              AND bdcod.GuideNumber = tcpt.GuideNumber
                              AND bdcod.CreditAccountId = tcpt.CreditAccountId
                              AND bdcod.BankId = tcpt.BankId
                    );
                END;
            END;

            -- SECCION PARA LA CREACION DEL LOTE PARA EL PAGO A FORZA DE LAS COMISIONES Y ENVIOS
            SET @MaxBatchNumber = 1 + @MaxBatchNumber;
            DECLARE @NewIdBatchCODForza INT;

            IF ((SELECT COUNT(1)FROM #TableForzaPaymentTempDaily) > 0)
            BEGIN
                -- SE CREA EL LOTE PARA EL PAGO A FORZA DE LAS COMISIONES Y ENVIOS
                INSERT INTO DeliveryBackOffice.dbo.BatchCOD
                (
                    BankId,
                    BatchNumber,
                    BatchTimeRange
                )
                VALUES
                (@BankBAC, @MaxBatchNumber, @BatchTimeRange);

                -- OBTENCION DEL ID QUE CORRESPONDE AL LOTE CREADO
                SELECT @NewIdBatchCODForza = SCOPE_IDENTITY();

                IF (
                       (@NewIdBatchCODForza IS NOT NULL)
                       AND (@NewIdBatchCODForza > 0)
                       AND (@NewIdBatchCODForza <> @MaxBatchNumber)
                   )
                BEGIN
                    UPDATE DeliveryBackOffice.dbo.BatchCOD
                    SET BatchNumber = IdBatchCOD
                    WHERE IdBatchCOD = @NewIdBatchCODForza;
                END;

                IF ((@NewIdBatchCODForza IS NOT NULL) AND (@NewIdBatchCODForza > 0))
                BEGIN
                    -- SE CREA EL DETALLE DEL LOTE PARA EL PAGO A FORZA DE LAS COMISIONES Y ENVIOS
                    INSERT INTO DeliveryBackOffice.dbo.BatchDetailCOD
                    (
                        BatchCODId,
                        GuideSerie,
                        GuideNumber,
                        CatDebitAccountCODId,
                        CreditAccountId,
                        Amount,
                        Commission,
                        CatTransactionTypeCODId,
					    CatCurrencyCODId,
                        BankId,
                        CatAccountTypeCODId,
                        CatConceptCODId,
                        Reference,
                        Excluded,
                        Comments,
                        BankName,
                        TypeAccountName,
                        AccountNumber,
                        AccountName,
                        CODCommissionPercentage,
                        DiscountPrice,
						IdCountry
                    )
					OUTPUT						
						INSERTED.GuideSerie,
						INSERTED.GuideNumber,
						INSERTED.IdBatchDetailCOD
					INTO #GuidesProcessCOD
                    SELECT @NewIdBatchCODForza,
                           tfpt.GuideSerie,
                           tfpt.GuideNumber,
                           tfpt.CatDebitAccountCODId,
                           tfpt.CreditAccountId,
                           tfpt.Amount,
                           tfpt.Commision,
                           tfpt.CatTransactionTypeCODId,
						   IIF(c.CodCurrency is null, 1, c.CodCurrency),
                           tfpt.BankId,
                           tfpt.CatAccountTypeCODId,
                           tfpt.CatConceptCODId,
                           tfpt.Reference,
                           IIF(
                               DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
                                                                                           tfpt.AccountNumber,
                                                                                           tfpt.BankId,
                                                                                           tfpt.CatAccountTypeCODId,
                                                                                           tfpt.AccountName
                                                                                       ) IS NULL,
                               'FALSE',
                               'TRUE') AS Excluded,
                           DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
                                                                                       tfpt.AccountNumber,
                                                                                       tfpt.BankId,
                                                                                       tfpt.CatAccountTypeCODId,
                                                                                       tfpt.AccountName
                                                                                   ) Comments,
                           tfpt.BankName,
                           tfpt.TypeAccountName,
                           tfpt.AccountNumber,
                           tfpt.AccountName,
                           CODRate,
                           DiscountPrice,
						   @IdCountrySender
                    FROM #TableForzaPaymentTempDaily tfpt
					LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK) 
					--ON c.ProductNumber = CONCAT(tfpt.GuideSerie, tfpt.GuideNumber)
					ON  c.GuideSerie  =  tfpt.GuideSerie
					AND c.GuideNumber =  tfpt.GuideNumber --CAMBIO BNHL 14/11/2024
                    WHERE NOT EXISTS
                    (
                        SELECT 1
                        FROM DeliveryBackOffice.dbo.BatchDetailCOD bdcod WITH (NOLOCK)
                        WHERE bdcod.GuideSerie = tfpt.GuideSerie
                              AND bdcod.GuideNumber = tfpt.GuideNumber
                              AND bdcod.CreditAccountId = tfpt.CreditAccountId
                              AND bdcod.BankId = tfpt.BankId
                    );
                END;
            END;

            IF (
                   (@NewIdBatchCODCustomer IS NOT NULL)
                   AND (@NewIdBatchCODForza IS NOT NULL)
                   AND (@NewIdBatchCODCustomer > 0)
                   AND (@NewIdBatchCODForza > 0)
               )
            BEGIN
                -- ASIGNACION DEL ID DE LOTE
                -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
                -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
                -- ESTAS GUIAS CREAN REGISTRO DE PAGO A CLIENTE Y DE COMISION Y ENVIO
                UPDATE pgc
                SET pgc.BatchCODId = @NewIdBatchCODCustomer,
                    pgc.BatchCODIdCommission = @NewIdBatchCODForza
                FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc WITH (NOLOCK)
                    INNER JOIN #TableCustomerPaymentTempDaily tcpt
                        ON pgc.GuideSerie = tcpt.GuideSerie
                           AND pgc.GuideNumber = tcpt.GuideNumber
                    INNER JOIN #TableForzaPaymentTempDaily tfpt
                        ON pgc.GuideSerie = tfpt.GuideSerie
                           AND pgc.GuideNumber = tfpt.GuideNumber
                WHERE pgc.BatchCODId IS NULL
                      AND pgc.BatchCODIdCommission IS NULL
                      AND pgc.RowStatus = 1
					  AND ISNULL(pgc.IsAnticipatedCOD,0) <> 1;
            END;

            IF ((@NewIdBatchCODCustomer IS NOT NULL) AND (@NewIdBatchCODCustomer > 0))
            BEGIN
                -- ASIGNACION DEL ID DE LOTE
                -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
                -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
                -- ESTAS GUIAS CREAN SOLO EL REGISTRO DE PAGO A CLIENTE
                UPDATE pgc
                SET pgc.BatchCODId = @NewIdBatchCODCustomer
                FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc WITH (NOLOCK)
                    INNER JOIN #TableCustomerPaymentTempDaily tcpt
                        ON pgc.GuideSerie = tcpt.GuideSerie
                           AND pgc.GuideNumber = tcpt.GuideNumber
                WHERE pgc.BatchCODId IS NULL
                      AND pgc.RowStatus = 1
					  AND ISNULL(pgc.IsAnticipatedCOD,0) <> 1;
            END;

            IF ((@NewIdBatchCODForza IS NOT NULL) AND (@NewIdBatchCODForza > 0))
            BEGIN
                -- ASIGNACION DEL ID DE LOTE
                -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
                -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
                -- ESTAS GUIAS CREAN SOLO EL REGISTRO DE COMISION Y ENVIO
                UPDATE pgc
                SET pgc.BatchCODIdCommission = @NewIdBatchCODForza
                FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc WITH (NOLOCK)
                    INNER JOIN #TableForzaPaymentTempDaily tfpt
                        ON pgc.GuideSerie = tfpt.GuideSerie
                           AND pgc.GuideNumber = tfpt.GuideNumber
                WHERE pgc.BatchCODIdCommission IS NULL
                      AND pgc.RowStatus = 1
					  AND ISNULL(pgc.IsAnticipatedCOD,0) <> 1;
            END;
        END;
        ELSE
        BEGIN

            -- Micro transacción para indicar inicio de proceso de CoD ejecutado
            BEGIN TRANSACTION Completed_CoD_Execution_Process;
            BEGIN TRY

                UPDATE [DeliveryBackOffice].[dbo].[CoDDailyExecution]
                SET ProcessFinished = 1,
                    TokenUpdated = 'SYS-HERMESWIRETRANSFER',
                    DateUpdated = GETDATE()
                WHERE IdCoDDailyExecution = @CoDProcessID;

                COMMIT TRANSACTION Completed_CoD_Execution_Process;

            END TRY
            BEGIN CATCH

                ROLLBACK TRANSACTION Completed_CoD_Execution_Process;

            END CATCH;

            SELECT 0 PayingBank,
                   0 IdBatchCOD,
                   0 AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'NO HAY GUIAS PARA PROCESAR' Comment;

            --IF @TranCounter = 0 
            --BEGIN
            -- @TranCounter = 0 means no transaction was  
            -- started before the procedure was called.  
            -- The procedure must commit the transaction  
            -- it started.  
            COMMIT TRANSACTION;

			UPDATE bdc
            SET bdc.IsCompleted = 1 
            FROM DeliveryBackOffice.dbo.BatchDetailCOD bdc WITH (NOLOCK)
                INNER JOIN #GuidesProcessCOD gpc
                    ON bdc.GuideSerie = gpc.GuideSerie
                    AND bdc.GuideNumber = gpc.GuideNumber
					AND bdc.IdBatchDetailCOD = gpc.IdBatchDetailCOD;
        --END
        END;
    END TRY
    BEGIN CATCH

        -- Micro transacción para indicar inicio de proceso de CoD ejecutado
        BEGIN TRANSACTION Retry_CoD_Execution_Process;
        BEGIN TRY

            UPDATE [DeliveryBackOffice].[dbo].[CoDDailyExecution]
            SET ProcessRetries = ISNULL(ProcessRetries, 0) + 1,
                ProcessError = ERROR_MESSAGE(),
                TokenUpdated = 'SYS-HERMESWIRETRANSFER',
                DateUpdated = GETDATE()
            WHERE IdCoDDailyExecution = @CoDProcessID;

            COMMIT TRANSACTION Retry_CoD_Execution_Process;

        END TRY
        BEGIN CATCH

            ROLLBACK TRANSACTION Retry_CoD_Execution_Process;

        END CATCH;

        SELECT 'RollBackTransaction' AS message,
               'FALSE' blnResult,
               CAST(-1 AS VARCHAR(5)) IdResult,
               CAST(500 AS VARCHAR(5)) StatusResult,
               CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

        IF @TranCounter = 0
        BEGIN
            -- Transaction started in procedure.  
            -- Roll back complete transaction.
            PRINT 'ROLLBACK INTERNO';
            ROLLBACK TRANSACTION;
        END;
        ELSE
        BEGIN
            -- Transaction started before procedure  
            -- called, do not roll back modifications  
            -- made before the procedure was called.  
            IF XACT_STATE() <> -1
            BEGIN
                -- If the transaction is still valid, just  
                -- roll back to the savepoint set at the  
                -- start of the stored procedure.  
                PRINT 'ROLLBACK SAVEPOINT';
                ROLLBACK TRANSACTION GetGeneratedBatchCODDaily_Save;
            -- If the transaction is uncommitable, a  
            -- rollback to the savepoint is not allowed  
            -- because the savepoint rollback writes to  
            -- the log. Just return to the caller, which  
            -- should roll back the outer transaction. 
            END;
        END;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        --SELECT * FROM #TableAmountCODDailyTemp;
        --SELECT * FROM #TableCustomerPaymentTempDaily;
        --SELECT * FROM #TableForzaPaymentTempDaily;

        -- Micro transacción para indicar inicio de proceso de CoD ejecutado
        BEGIN TRANSACTION Completed_CoD_Execution_Process;
        BEGIN TRY

            UPDATE [DeliveryBackOffice].[dbo].[CoDDailyExecution]
            SET ProcessFinished = 1,
                TokenUpdated = 'SYS-HERMESWIRETRANSFER',
                DateUpdated = GETDATE()
            WHERE IdCoDDailyExecution = @CoDProcessID;

            COMMIT TRANSACTION Completed_CoD_Execution_Process;

        END TRY
        BEGIN CATCH

            ROLLBACK TRANSACTION Completed_CoD_Execution_Process;

        END CATCH;

        IF ((@NewIdBatchCODCustomer IS NULL) AND (@NewIdBatchCODForza IS NULL))
        BEGIN
            SELECT 0 PayingBank,
                   0 IdBatchCOD,
                   0 AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'NO SE GENERO NINGUN LOTE' Comment;
        END;
        ELSE IF (@NewIdBatchCODCustomer IS NULL)
        BEGIN
            SELECT @BankBAC PayingBank,
                   @NewIdBatchCODForza IdBatchCOD,
                   @NewIdBatchCODForza AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'SOLO SE GENERO LOTE DE COMISIONES Y ENVIOS' Comment;
        END;
        ELSE IF (@NewIdBatchCODForza IS NULL)
        BEGIN
            SELECT @IdBankParam PayingBank,
                   @NewIdBatchCODCustomer IdBatchCOD,
                   @NewIdBatchCODCustomer AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'SOLO SE GENERO LOTE DE PAGO A CLIENTES' Comment;
        END;
        ELSE
        BEGIN
            SELECT @IdBankParam PayingBank,
                   @NewIdBatchCODCustomer IdBatchCOD,
                   @NewIdBatchCODCustomer AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'LOTE DE PAGO A CLIENTES Y LOTE DE COMISIONES Y ENVIOS - PAGO A CLIENTES' Comment
            UNION
            SELECT @BankBAC PayingBank,
                   @NewIdBatchCODForza IdBatchCOD,
                   @NewIdBatchCODForza AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'LOTE DE PAGO A CLIENTES Y LOTE DE COMISIONES Y ENVIOS - COMISIONES Y ENVIOS' Comment;
        END;

        --IF @TranCounter = 0  
        -- BEGIN
        -- @TranCounter = 0 means no transaction was  
        -- started before the procedure was called.  
        -- The procedure must commit the transaction  
        -- it started.
		-- END
        COMMIT TRANSACTION;

		UPDATE bdc
        SET bdc.IsCompleted = 1 
        FROM DeliveryBackOffice.dbo.BatchDetailCOD bdc WITH (NOLOCK)
            INNER JOIN #GuidesProcessCOD gpc
                ON bdc.GuideSerie = gpc.GuideSerie
                AND bdc.GuideNumber = gpc.GuideNumber
				AND bdc.IdBatchDetailCOD = gpc.IdBatchDetailCOD;

		IF OBJECT_ID('tempdb.dbo.#GuidesProcessCOD', 'U') IS NOT NULL
		DROP TABLE #GuidesProcessCOD;
  
    END;
END;