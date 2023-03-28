--EXEC  [dbo].[sphw_generate_batch_cod_collect] 31,'8_00'
CREATE PROCEDURE [dbo].[sphw_generate_batch_cod_collect]
    @IdBankParam INT,
    @BatchTimeRange VARCHAR(300) = '',
    @CoDProcessID INT
AS
BEGIN

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
    SET @TranCounter = @@trancount;
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
        SAVE TRANSACTION generate_batch_cod_collect_Save;
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
        DECLARE @IdCountry NVARCHAR(50) = N'GT';
        DECLARE @InAccount NVARCHAR(50) = N'CUENTAS INTERNAS BAC O BANCOR';
        DECLARE @OutAccount NVARCHAR(50) = N'CREDITOS ENVIAR FONDOS A OTROS BANCOS';
        DECLARE @AccountType NVARCHAR(50) = N'MONETARIA';
        DECLARE @ConceptCustomer NVARCHAR(50) = N'PAGO';
        DECLARE @CreditAccount NVARCHAR(50) = N'903666261';
        DECLARE @ConceptForza NVARCHAR(50) = N'COLLECT';
        DECLARE @BankBAC INT =
                (
                    SELECT db.Id_bank
                    FROM DeliveryBackOffice.dbo.DeliveryBank db WITH (NOLOCK)
                    WHERE db.Name = @BankName
                          AND db.Id_status = 1
                          AND db.Id_country = @IdCountry
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
                    WHERE Name = 'Inmediata'
                );

        --IF (@IdBankParam IN
        --    (
        --        SELECT PayingBank
        --        FROM DeliveryBackOffice.dbo.DeliveryBank
        --        WHERE Id_country = @IdCountry
        --              AND Id_status = 1
        --              AND PayingBank <> @BankBAC
        --        GROUP BY PayingBank
        --    )
        --   )
        --BEGIN
        --    SELECT @ProductNumber
        --        =
        --    (
        --        SELECT STUFF(
        --               (
        --                   SELECT /*TOP 50*/ ',' + CONCAT(pg.GuideSerie, pg.GuideNumber)
        --                   FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg
        --                       JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
        --                           ON do.Guide_Serie = pg.GuideSerie
        --                              AND do.Guide_Number = pg.GuideNumber
        --                       LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba
        --                           ON dcba.DCBA_Id = do.DCBA_ID
        --                              AND dcba.DCBA_Id_estado = 1
        --                       LEFT JOIN dbo.VisitPointClient vpc
        --                           ON vpc.CodeOfReference = do.Sender_ID
        --                       LEFT JOIN dbo.Customer cus
        --                           ON cus.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
        --                   WHERE pg.BatchCODId IS NULL
        --                         AND pg.BatchCODIdCommission IS NULL
        --                         AND pg.RowStatus = 1
        --                         AND ISNULL(dcba.DCBA_Bank_Id, cus.CODAccountBankID) = @IdBankParam
        --                         AND pg.Date > '2021-11-08 01:00:00.000'
        --                         AND ISNULL(cus.CatBatchFrequencyCODId, @FrecuencyCOD) = @FrecuencyCOD
        --                         --AND ( cus.IdCustomerType IN(2,3)
        --                         --	  OR( ISNULL(do.IdCustomer, vpc.CustomerID) IN ( 370, 826, 57, 5688, 7937, 1038, 6900, 3267, 527, 7025, 4851 )))
        --                         AND do.StatusOrderId != 7
        --                   FOR XML PATH('')
        --               ),
        --               1,
        --               1,
        --               ''
        --                    )
        --    );
        --END;
        --ELSE
        --BEGIN
        SELECT @ProductNumber
            =
        (
            SELECT STUFF(
                   (
                       SELECT /*TOP 50*/
                           ',' + CONCAT(pg.GuideSerie, pg.GuideNumber)
                       FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pg WITH (NOLOCK)
                           JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                               ON do.Guide_Serie = pg.GuideSerie
                                  AND do.Guide_Number = pg.GuideNumber
                           LEFT JOIN DeliveryBackOffice.dbo.DeliveryCustomerBankAccount dcba WITH (NOLOCK)
                               ON dcba.DCBA_Id = do.DCBA_ID
                                  AND dcba.DCBA_Id_estado = 1
                           LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                               ON vpc.CodeOfReference = do.Sender_ID
                           LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                               ON cus.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerId)
                       WHERE pg.BatchCODId IS NULL
                             AND (do.IsLastMileReturn = 1 OR do.Collect_OnDelivery = 0)
                             AND do.IsCollect = 'true'
                             AND pg.BatchCODIdCommission IS NULL
                             AND pg.RowStatus = 1
                             --AND
                             --                     (
                             --                         ISNULL(dcba.DCBA_Bank_Id, cus.CODAccountBankID) NOT IN
                             --(
                             --    SELECT PayingBank
                             --    FROM DeliveryBackOffice.dbo.DeliveryBank
                             --    WHERE Id_country = @IdCountry
                             --          AND Id_status = 1
                             --          AND PayingBank <> @BankBAC
                             --    GROUP BY PayingBank
                             --)
                             --                         OR ISNULL(dcba.DCBA_Bank_Id, cus.CODAccountBankID) IS NULL
                             --                     )
                             --AND ( cus.IdCustomerType IN(2,3)
                             --OR( ISNULL(do.IdCustomer, vpc.CustomerID) IN ( 370, 826, 57, 5688, 7937, 1038, 6900, 3267, 527, 7025, 4851 )))						

                             AND pg.Date > '2022-03-14 22:00:00.000'
                             -- AND ISNULL(cus.CatBatchFrequencyCODId, @FrecuencyCOD) = @FrecuencyCOD
                             AND do.StatusOrderId != 7
                       FOR XML PATH('')
                   ),
                   1,
                   1,
                   ''
                        )
        );
        -- END;

        -- Insert statements for procedure here
        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#TempData', 'U') IS NOT NULL
            DROP TABLE #TempData;
        IF OBJECT_ID('tempdb.dbo.#CODData', 'U') IS NOT NULL
            DROP TABLE #CODData;
        IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
            DROP TABLE #RevalueGuides;
        IF OBJECT_ID('tempdb.dbo.#PendingPaymentTemp', 'U') IS NOT NULL
            DROP TABLE #PendingPaymentTemp;
        IF OBJECT_ID('tempdb.dbo.#TableAmountCOD', 'U') IS NOT NULL
            DROP TABLE #TableAmountCOD;
        IF OBJECT_ID('tempdb.dbo.#TableAmountCODTemp', 'U') IS NOT NULL
            DROP TABLE #TableAmountCODTemp;
        IF OBJECT_ID('tempdb.dbo.#TableCustomerPaymentTemp', 'U') IS NOT NULL
            DROP TABLE #TableCustomerPaymentTemp;
        IF OBJECT_ID('tempdb.dbo.#TableForzaPaymentTemp', 'U') IS NOT NULL
            DROP TABLE #TableForzaPaymentTemp;
        PRINT '@ProductNumber';
        PRINT @ProductNumber;
        IF @ProductNumber IS NOT NULL
        BEGIN
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- +++++++++++++++++++++++++++++++++ - COMIENZA EL BRAIN - ++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
            -- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

            -- SET NOCOUNT ON added to prevent extra result sets from interfering with SELECT statements.
            SET NOCOUNT ON;

            CREATE TABLE #listGuides
            (
                Guide_Serie NVARCHAR(2),
                Guide_Number INT
            );
            CREATE NONCLUSTERED INDEX tempSerie ON #listGuides (Guide_Serie);
            CREATE NONCLUSTERED INDEX tempGuide ON #listGuides (Guide_Number);
            CREATE TABLE #RevalueGuides
            (
                fila INT,
                Guide_Serie NVARCHAR(2),
                Guide_Number INT
            );

            CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuides (fila);



            INSERT INTO #listGuides
            (
                Guide_Serie,
                Guide_Number
            )
            SELECT SUBSTRING(Item, 1, 2) ItemSerie,
                   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) ItemNumber
            FROM DeliveryBackOffice.dbo.SplitUnlimited(@ProductNumber, ',');

            DECLARE @IdRateDefault INT =
                    (
                        SELECT TOP 1
                               rh.RheId
                        FROM DeliveryBackOffice.dbo.RateHeader rh WITH (NOLOCK)
                        WHERE rh.RheRowStatus = 1
                              AND rh.RheDefault = 1
                    );
            DECLARE @IdRate INT;
            DECLARE @CODRateDefault DECIMAL(12, 2) =
                    (
                        SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
                        FROM DeliveryBackOffice.dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'CODRateDef'
                              AND Status = 1
                    );
            DECLARE @CODExemptDefault DECIMAL(12, 2) =
                    (
                        SELECT CONVERT(DECIMAL(12, 2), ISNULL(cf.Value, '0')) val
                        FROM DeliveryBackOffice.dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'CODExemptDef'
                              AND Status = 1
                    );

            ---- Revalorizar guias que no tengan un precio asociado ---------------------------------------------
            INSERT INTO #RevalueGuides
            (
                fila,
                Guide_Serie,
                Guide_Number
            )
            SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
                   ord.Guide_Serie,
                   ord.Guide_Number
            FROM #listGuides lst
                JOIN DeliveryBackOffice.dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Number = lst.Guide_Number
                       AND ord.Guide_Serie = lst.Guide_Serie
                LEFT JOIN [DeliveryBackOffice].[dbo].[PromoCoupon] PC WITH (NOLOCK)
                    ON lst.Guide_Serie = PC.GuideSerieDestination
                       AND lst.Guide_Number = PC.GuideNumberDestination
                       AND PC.RowStatus = 1
            WHERE ISNULL(ord.PriceShippment, 0) = 0
                  AND PC.IdPromoCoupon IS NULL;


            DECLARE @count INT = 1;
            DECLARE @RevalueSerie VARCHAR(10);
            DECLARE @RevalueGuide INT;
            DECLARE @IdMax INT =
                    (
                        SELECT MAX(fila)FROM #RevalueGuides
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
                FROM #RevalueGuides rv
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
                        FROM dbo.CatRateSegment
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
                   ISNULL(dc.DCBA_Num_account, ISNULL(VPO.CODAccountNumber, cus.CODAccountNumber)) DCBA_Num_account,
                   ISNULL(dc.DCBA_Nom_account, ISNULL(VPO.CODAccountName, cus.CODAccountName)) DCBA_Nom_account,
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
            --,
            --            ISNULL(csg.CrsId, @IdSegmentDefault)

            INTO #TableAmountCOD
            FROM #listGuides lst
                JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
                    ON ord.Guide_Serie = lst.Guide_Serie
                       AND ord.Guide_Number = lst.Guide_Number
                LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = ord.Sender_ID
                LEFT JOIN dbo.RatebyCustomer rc WITH (NOLOCK)
                    ON rc.RbcIdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
                       AND rc.RbcRowStatus = 'true'
                       AND rc.RbcCodeOfReference IS NULL
                LEFT JOIN dbo.RatebyCustomer rccr WITH (NOLOCK)
                    ON rccr.RbcCodeOfReference = ord.Sender_ID
                       AND rccr.RbcRowStatus = 'true'
                LEFT JOIN dbo.Township twn WITH (NOLOCK)
                    ON twn.IdTownship = ord.ReceiverIdTownship
                LEFT JOIN dbo.Township twnm WITH (NOLOCK)
                    ON twnm.TownshipName = ord.Receiver_Town
                LEFT JOIN
                (
                    SELECT HeaderCode,
                           MAX(Hub) Hub
                    FROM dbo.DumpServiceCoverage WITH (NOLOCK)
                    WHERE RowStatus = 'true'
                    GROUP BY HeaderCode
                ) hub
                    ON hub.HeaderCode = ISNULL(twn.HeaderCode, twnm.HeaderCode)
                LEFT JOIN dbo.HubLogistics hbl WITH (NOLOCK)
                    ON hbl.HubAbbreviation = hub.Hub
                LEFT JOIN dbo.VisitPointConfiguration VPO WITH (NOLOCK)
                    ON VPO.VisitPointID = vpc.CodeOfReference
                LEFT JOIN dbo.CatTypeService csv WITH (NOLOCK)
                    ON csv.CtsShortName = IIF(ord.TypeService = 'EXP', 'NDD', ISNULL(ord.TypeService, 'NDD'))
                       AND csv.CtsRowStatus = 'true'
                LEFT JOIN dbo.CatRateSegment csg WITH (NOLOCK)
                    ON csg.CrsShortName = dbo.fn_get_segment(ord.Guide_Serie, ord.Guide_Number)
                       AND csg.CrsRowStatus = 'true'
                --LEFT JOIN dbo.VisitPointCoverage cv
                --	ON cv.VisitPointId = ord.Sender_ID
                --	   AND cv.HubLogisticId  = hbl.IdHubLogistic
                --	   AND cv.RowStatus = 'true'
                LEFT JOIN dbo.RateCOD rco WITH (NOLOCK)
                    ON rco.RateId = COALESCE(rccr.RbcIdRate, rc.RbcIdRate)
                       AND rco.TypeServiceId = csv.CtsId
                       AND rco.TypeSegmentId = ISNULL(csg.CrsId, @IdSegmentDefault)
                       AND rco.RowStatus = 1
                LEFT JOIN dbo.Customer cus WITH (NOLOCK)
                    ON cus.IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
                LEFT JOIN dbo.DeliveryOrderPaid op WITH (NOLOCK)
                    ON op.Guide_Serie = ord.Guide_Serie
                       AND op.Guide_Number = ord.Guide_Number
                       AND op.IdStatus = 'true'
                LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
                    ON dc.DCBA_Id = ord.DCBA_ID
                       AND dc.DCBA_Id_estado = 1
                LEFT JOIN dbo.DeliveryBank bk WITH (NOLOCK)
                    ON bk.Id_bank = ISNULL(dc.DCBA_Bank_Id, ISNULL(VPO.CODAccountBankID, cus.CODAccountBankID))
                LEFT JOIN dbo.CatBankAccountType btp WITH (NOLOCK)
                    ON btp.IdBankAccountType = ISNULL(VPO.CODAccountBankTypeID, cus.CODAccountTypeID)
                LEFT JOIN dbo.DeliveryOrderPaymentDetail pyt WITH (NOLOCK)
                    ON pyt.GuideSerie = ord.Guide_Serie
                       AND pyt.GuideNumber = ord.Guide_Number
            WHERE ISNULL(ord.Collect_OnDelivery, 0) = 0
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
            INTO #TableAmountCODTemp
            FROM #TableAmountCOD
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

            CREATE NONCLUSTERED INDEX IX_TACT_ISINCTPCP
            ON #TableAmountCODTemp (
                                       [Guide_Serie],
                                       [Guide_Number],
                                       [CODtoPay],
                                       Commision,
                                       [Price]
                                   );

            -- ASIGNACION DEL ROWSTATUS CERO 
            -- PARA LAS GUIAS QUE NO TIENE CODTOPAY EN LA TABLA PROCESSGUIDE
            -- PARA CONOCER QUE GUIAS NO SE TIENEN QUE REPROCESAR
            --UPDATE pgc
            --SET pgc.RowStatus = 0
            --FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc
            --    INNER JOIN #TableAmountCODTemp tact
            --        ON pgc.GuideSerie = tact.Guide_Serie
            --           AND pgc.GuideNumber = tact.Guide_Number
            --           AND tact.CODtoPay <= 0
            --WHERE pgc.BatchCODId IS NULL
            --      AND pgc.BatchCODIdCommission IS NULL
            --      AND pgc.RowStatus = 1;
            --HW-66

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
                   (IIF(do.IsCollect = 'true', ISNULL(do.PriceShippment, 0), tact.Price)) Amount,
                   0 [Commision],
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
            INTO #TableForzaPaymentTemp
            FROM #TableAmountCODTemp tact
                INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
                    ON do.Guide_Serie = tact.Guide_Serie
                       AND do.Guide_Number = tact.Guide_Number
            WHERE (
                      ISNULL(tact.Price, 0) > 0
                      OR do.IsCollect = 'true'
                  )
                  AND ISNULL(tact.CODtoPay, 0) = 0
            --AND tact.Id_bank IS NOT NULL
            ;

            CREATE NONCLUSTERED INDEX IX_TFPT_GSGNCABI
            ON #TableForzaPaymentTemp (
                                          [GuideSerie],
                                          [GuideNumber],
                                          [CreditAccountId],
                                          [BankId]
                                      );

            SET @Reference = @Reference +
                             (
                                 SELECT COUNT(1)FROM #TableForzaPaymentTemp
                             );

            ---- CONSTRUCCION DE REGISTROS PARA EL PAGO A LOS CLIENTES DE COD
            ---- SIN IMPORTAR EL BANCO AL QUE PERTENECE LA CUENTA DEL CLIENTE
            --SELECT tact.Guide_Serie GuideSerie,
            --       tact.Guide_Number GuideNumber,
            --       (
            --           SELECT IdCatDebitAccountCOD
            --           FROM DeliveryBackOffice.dbo.CatDebitAccountCOD
            --           WHERE BankId = IIF(@BankBAC <> @IdBankParam, tact.Id_bank, @BankBAC)
            --                 AND RowStatus = 1
            --       ) CatDebitAccountCODId,
            --       tact.DCBA_Id CreditAccountId,
            --       tact.CODtoPay Amount,
            --       tact.Commision [Commision],
            --       IIF(
            --           tact.Id_bank NOT IN
            --           (
            --               SELECT PayingBank
            --               FROM DeliveryBackOffice.dbo.DeliveryBank
            --               WHERE Id_country = @IdCountry
            --                     AND Id_status = 1
            --                     AND PayingBank <> @BankBAC
            --               GROUP BY PayingBank
            --           ),
            --           IIF(tact.Id_bank = @BankBAC,
            --           (
            --               SELECT IdCatTransactionTypeCOD
            --               FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD
            --               WHERE BankId = tact.Id_bank
            --                     AND RowStatus = 1
            --                     AND Description = @InAccount
            --           ),
            --           (
            --               SELECT IdCatTransactionTypeCOD
            --               FROM DeliveryBackOffice.dbo.CatTransactionTypeCOD
            --               WHERE BankId = @BankBAC
            --                     AND RowStatus = 1
            --                     AND Description = @OutAccount
            --           )),
            --           NULL) CatTransactionTypeCODId,
            --       tact.Id_bank BankId,
            --       (
            --           SELECT IdCatAccountTypeCOD
            --           FROM DeliveryBackOffice.dbo.CatAccountTypeCOD
            --           WHERE RowStatus = 1
            --                 AND AccountType = UPPER(tact.DCBA_BankAccountType)
            --       ) CatAccountTypeCODId,
            --       (
            --           SELECT IdCatConceptCOD
            --           FROM DeliveryBackOffice.dbo.CatConceptCOD
            --           WHERE RowStatus = 1
            --                 AND Concept LIKE (@ConceptCustomer + '%')
            --       ) CatConceptCODId,
            --       ((ROW_NUMBER() OVER (ORDER BY tact.Guide_Number))
            --        + IIF(@IdBankParam = @BankBAC, ISNULL(@Reference, 0), 0)
            --       ) Reference,
            --       tact.Name BankName,
            --       UPPER(tact.DCBA_BankAccountType) TypeAccountName,
            --       tact.DCBA_Num_account AccountNumber,
            --       tact.DCBA_Nom_account AccountName,
            --       CODRate,
            --       tact.Price DiscountPrice
            --INTO #TableCustomerPaymentTemp
            --FROM #TableAmountCODTemp tact
            --WHERE tact.CODtoPay > 0;
            ----AND tact.Id_bank IS NOT NULL
            --;

            --CREATE NONCLUSTERED INDEX IX_TCPT_GSGNCABI
            --ON #TableCustomerPaymentTemp (
            --                                 [GuideSerie],
            --                                 [GuideNumber],
            --                                 [CreditAccountId],
            --                                 [BankId]
            --                             );

            --IF (@IdBankParam = @BankBAC)
            --BEGIN
            --    SET @Reference = @Reference +
            --                     (
            --                         SELECT COUNT(1)FROM #TableCustomerPaymentTemp
            --                     );
            --END;

            -- ACTUALIZA EL CORRELATIVO PARA LA PROXIMA GENERACION DE LOTES
            UPDATE DeliveryBackOffice.dbo.CatCorrelativeCOD
            SET Last = ISNULL(@Reference, Last)
            WHERE BankId = @BankBAC
                  AND RowStatus = 1;

            ---- SECCION PARA LA CREACION DEL LOTE PARA EL PAGO A CLIENTES
            DECLARE @MaxBatchNumber INT = 1 +
                                          (
                                              SELECT ISNULL(MAX(IdBatchCOD), 0)
                                              FROM DeliveryBackOffice.dbo.BatchCOD WITH (NOLOCK)
                                          );
            --DECLARE @NewIdBatchCODCustomer INT;

            --IF ((SELECT COUNT(1)FROM #TableCustomerPaymentTemp) > 0)
            --BEGIN
            --    -- SE CREA EL LOTE PARA EL PAGO A CLIENTES
            --    INSERT INTO DeliveryBackOffice.dbo.BatchCOD
            --    (
            --        BankId,
            --        BatchNumber,
            --        BatchTimeRange
            --    )
            --    VALUES
            --    (@IdBankParam, @MaxBatchNumber, @BatchTimeRange);

            --    -- OBTENCION DEL ID QUE CORRESPONDE AL LOTE CREADO
            --    SELECT @NewIdBatchCODCustomer = SCOPE_IDENTITY();

            --    IF (
            --           (@NewIdBatchCODCustomer IS NOT NULL)
            --           AND (@NewIdBatchCODCustomer > 0)
            --           AND (@NewIdBatchCODCustomer <> @MaxBatchNumber)
            --       )
            --    BEGIN
            --        UPDATE DeliveryBackOffice.dbo.BatchCOD
            --        SET BatchNumber = IdBatchCOD
            --        WHERE IdBatchCOD = @NewIdBatchCODCustomer;

            --        SET @MaxBatchNumber = @NewIdBatchCODCustomer;
            --    END;

            --    IF ((@NewIdBatchCODCustomer IS NOT NULL) AND (@NewIdBatchCODCustomer > 0))
            --    BEGIN
            --        -- SE CREA EL DETALLE DEL LOTE PARA EL PAGO A CLIENTES
            --        INSERT INTO DeliveryBackOffice.dbo.BatchDetailCOD
            --        (
            --            BatchCODId,
            --            GuideSerie,
            --            GuideNumber,
            --            CatDebitAccountCODId,
            --            CreditAccountId,
            --            Amount,
            --            Commission,
            --            CatTransactionTypeCODId,
            --            BankId,
            --            CatAccountTypeCODId,
            --            CatConceptCODId,
            --            Reference,
            --            Excluded,
            --            Comments,
            --            BankName,
            --            TypeAccountName,
            --            AccountNumber,
            --            AccountName,
            --            CODCommissionPercentage,
            --            DiscountPrice
            --        )
            --        SELECT @NewIdBatchCODCustomer,
            --               tcpt.GuideSerie,
            --               tcpt.GuideNumber,
            --               tcpt.CatDebitAccountCODId,
            --               tcpt.CreditAccountId,
            --               tcpt.Amount,
            --               tcpt.Commision,
            --               tcpt.CatTransactionTypeCODId,
            --               tcpt.BankId,
            --               tcpt.CatAccountTypeCODId,
            --               tcpt.CatConceptCODId,
            --               tcpt.Reference,
            --               IIF(
            --                   DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
            --                                                                               tcpt.AccountNumber,
            --                                                                               tcpt.BankId,
            --                                                                               tcpt.CatAccountTypeCODId,
            --                                                                               tcpt.AccountName
            --                                                                           ) IS NULL,
            --                   'FALSE',
            --                   'TRUE') Excluded,
            --               DeliveryBackOffice.dbo.fn_validate_customer_bank_account(
            --                                                                           tcpt.AccountNumber,
            --                                                                           tcpt.BankId,
            --                                                                           tcpt.CatAccountTypeCODId,
            --                                                                           tcpt.AccountName
            --                                                                       ) Comments,
            --               tcpt.BankName,
            --               tcpt.TypeAccountName,
            --               tcpt.AccountNumber,
            --               tcpt.AccountName,
            --               CODRate,
            --               DiscountPrice
            --        FROM #TableCustomerPaymentTemp tcpt
            --        WHERE NOT EXISTS
            --        (
            --            SELECT 1
            --            FROM DeliveryBackOffice.dbo.BatchDetailCOD bdcod
            --            WHERE bdcod.GuideSerie = tcpt.GuideSerie
            --                  AND bdcod.GuideNumber = tcpt.GuideNumber
            --                  AND bdcod.CreditAccountId = tcpt.CreditAccountId
            --                  AND bdcod.BankId = tcpt.BankId
            --        );
            --    END;
            --END;

            -- SECCION PARA LA CREACION DEL LOTE PARA EL PAGO A FORZA DE LAS COMISIONES Y ENVIOS
            SET @MaxBatchNumber = 1 + @MaxBatchNumber;
            DECLARE @NewIdBatchCODForza INT;

            IF ((SELECT COUNT(1)FROM #TableForzaPaymentTemp) > 0)
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
                        DiscountPrice
                    )
                    SELECT @NewIdBatchCODForza,
                           tfpt.GuideSerie,
                           tfpt.GuideNumber,
                           tfpt.CatDebitAccountCODId,
                           tfpt.CreditAccountId,
                           tfpt.Amount,
                           tfpt.Commision,
                           tfpt.CatTransactionTypeCODId,
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
                           DiscountPrice
                    FROM #TableForzaPaymentTemp tfpt
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

            IF ((@NewIdBatchCODForza IS NOT NULL) AND (@NewIdBatchCODForza > 0))
            BEGIN
                -- ASIGNACION DEL ID DE LOTE
                -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
                -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
                -- ESTAS GUIAS CREAN REGISTRO DE PAGO A CLIENTE Y DE COMISION Y ENVIO
                UPDATE pgc
                SET --pgc.BatchCODId = @NewIdBatchCODCustomer,
                    pgc.BatchCODIdCommission = @NewIdBatchCODForza
                FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc
                    INNER JOIN #TableForzaPaymentTemp tfpt
                        ON pgc.GuideSerie = tfpt.GuideSerie
                           AND pgc.GuideNumber = tfpt.GuideNumber
                WHERE pgc.BatchCODId IS NULL
                      AND pgc.BatchCODIdCommission IS NULL
                      AND pgc.RowStatus = 1;
            END;

            --IF ((@NewIdBatchCODCustomer IS NOT NULL) AND (@NewIdBatchCODCustomer > 0))
            --BEGIN
            --    -- ASIGNACION DEL ID DE LOTE
            --    -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
            --    -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
            --    -- ESTAS GUIAS CREAN SOLO EL REGISTRO DE PAGO A CLIENTE
            --    UPDATE pgc
            --    SET pgc.BatchCODId = @NewIdBatchCODCustomer
            --    FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc
            --        INNER JOIN #TableCustomerPaymentTemp tcpt
            --            ON pgc.GuideSerie = tcpt.GuideSerie
            --               AND pgc.GuideNumber = tcpt.GuideNumber
            --    WHERE pgc.BatchCODId IS NULL
            --          AND pgc.RowStatus = 1;
            --END;

            IF ((@NewIdBatchCODForza IS NOT NULL) AND (@NewIdBatchCODForza > 0))
            BEGIN
                -- ASIGNACION DEL ID DE LOTE
                -- EN LAS COLUMNAS BATCHCODID Y BATCHCODIDCOMMISION EN LA TABLA PROCESSGUIDE
                -- PARA CONOCER QUE GUIA PARTICIPA EN QUE LOTES
                -- ESTAS GUIAS CREAN SOLO EL REGISTRO DE COMISION Y ENVIO
                UPDATE pgc
                SET pgc.BatchCODIdCommission = @NewIdBatchCODForza
                FROM DeliveryBackOffice.dbo.ProcessedGuideCOD pgc
                    INNER JOIN #TableForzaPaymentTemp tfpt
                        ON pgc.GuideSerie = tfpt.GuideSerie
                           AND pgc.GuideNumber = tfpt.GuideNumber
                WHERE pgc.BatchCODIdCommission IS NULL
                      AND pgc.RowStatus = 1;
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
                ROLLBACK TRANSACTION generate_batch_cod_collect_Save;
            -- If the transaction is uncommitable, a  
            -- rollback to the savepoint is not allowed  
            -- because the savepoint rollback writes to  
            -- the log. Just return to the caller, which  
            -- should roll back the outer transaction. 
            END;
        END;
    END CATCH;

    IF @@trancount > 0
    BEGIN
        --SELECT * FROM #TableAmountCODTemp;
        --SELECT * FROM #TableCustomerPaymentTemp;
        --SELECT * FROM #TableForzaPaymentTemp;

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

        IF ((@NewIdBatchCODForza IS NULL))
        BEGIN
            SELECT 0 PayingBank,
                   0 IdBatchCOD,
                   0 AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'NO SE GENERO NINGUN LOTE' Comment;
        END;
        ELSE IF (@NewIdBatchCODForza IS NOT NULL)
        BEGIN
            SELECT @BankBAC PayingBank,
                   @NewIdBatchCODForza IdBatchCOD,
                   @NewIdBatchCODForza AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'SE GENERO LOTE DE ENVIOS COLLECT' Comment;
        END;
        --ELSE IF (@NewIdBatchCODForza IS NULL)
        --BEGIN
        --    SELECT @IdBankParam PayingBank,
        --           @NewIdBatchCODCustomer IdBatchCOD,
        --           @NewIdBatchCODCustomer AS BATCHNUMBER,
        --           'TRUE' AS blnResult,
        --           'SOLO SE GENERO LOTE DE PAGO A CLIENTES' Comment;
        --END;
        ELSE
        BEGIN

            SELECT @BankBAC PayingBank,
                   @NewIdBatchCODForza IdBatchCOD,
                   @NewIdBatchCODForza AS BATCHNUMBER,
                   'TRUE' AS blnResult,
                   'LOTE DE ENVIOS COLLECT' Comment;
        END;

        --IF @TranCounter = 0  
        --BEGIN
        -- @TranCounter = 0 means no transaction was  
        -- started before the procedure was called.  
        -- The procedure must commit the transaction  
        -- it started.
        COMMIT TRANSACTION;
    --END
    END;
END;
