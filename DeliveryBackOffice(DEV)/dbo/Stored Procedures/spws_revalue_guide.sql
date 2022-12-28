
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-28>
-- Description:	<Revaloriza una guia de transporte>
-- =============================================
-- =============================================
-- Author:		<Edelman,Vasquez>
-- Create date: <2022-06-16>
-- Description:	< Adicionar lógica para tarifarios alternos cuando destino es EXC >
-- =============================================

CREATE PROCEDURE [dbo].[spws_revalue_guide]
    @GuideSerie varchar(2) = 'FD',
    @GuideNumber int = 200307,
    @CodeApp varchar(50) = '',
    @Format as nvarchar(20) = 'Datatable',
    @CalculateTaxes bit = 'true',
    @IdModule int = 1,
    @SetUpdate bit = 'false',
    @Token varchar(50) = 'spws_revalue_guide',
    @ParIsCollect bit = null,
    @ParIsInsurance bit = null,
    @ParInsuranceAmount decimal(12, 2) = null,
    @ParIsCreditCard bit = null,
    @ParPesos varchar(400) = null,
    @IsReturn bit = 'false',
	@UseMembership bit=0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Variables "estaticas"
    DECLARE @NewMainRates INT = (
                                    SELECT TOP 1
                                        RH.RheId
                                    FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                                    WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI
                                );
    DECLARE @NewAlternativeRates INT
        =   (
                SELECT TOP 1
                    RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewAutoSalesMainRates INT
        =   (
                SELECT TOP 1
                    RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI
            );

    -- Variables de control
    DECLARE @IdCustomer as int
    DECLARE @IdSettlement as int
    DECLARE @HeaderCodeSource varchar(5)
    DECLARE @HeaderCodeDestiny varchar(5)
    DECLARE @VisitPointClient int
    DECLARE @VisitPointClientDestiny int
    DECLARE @IsCollect bit
    declare @IsInsurance bit
    declare @InsuranceAmount decimal(12, 2)
    DECLARE @IdSalePipeLine as int
    DECLARE @AddressParse as varchar(200)
    DECLARE @ServiceShortName as varchar(10)
    DECLARE @DateCreated DATETIME

    declare @PiecesInOrder as int


    declare @OldPrice decimal(12, 2)
    print 'inicio carga inicial'
    ------ Carga inicial de datos ----------------------------------------------------------------------------
    select @IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID),
           @VisitPointClient = ord.Sender_ID,
           @VisitPointClientDestiny = ISNULL(ord.Receiver_ID, 0),
           @IdSettlement = isnull(ord.ReceiverIdSettlement, 0),
           @HeaderCodeSource = stwn.HeaderCode,
           @HeaderCodeDestiny = rtwn.HeaderCode,
           @IsCollect = isnull(@ParIsCollect, isnull(ord.IsCollect, 'false')),
           @IsInsurance = isnull(@ParIsInsurance, isnull(ord.IsInsuarance, 'false')),
           @InsuranceAmount = isnull(@ParInsuranceAmount, isnull(ord.InsuranceAmount, 0)),
           @AddressParse = isnull(ord.Receiver_Address, ''),
           @IdSalePipeLine = isnull(ord.SalePipeLineId, 0),
           @PiecesInOrder = (isnull(ord.Pieces_Dry, 0) + isnull(ord.Pieces_Cold, 0)),
           @OldPrice = isnull(ord.PriceShippment, 0),
           @ServiceShortName = isnull(ord.TypeService, 'NDD'),
           @DateCreated = ord.DateCreated
    from dbo.DeliveryOrder ord WITH (NOLOCK)
        left join dbo.Township stwn WITH (NOLOCK)
            on stwn.IdTownship = ord.SenderIdTownship
        left join dbo.Township rtwn WITH (NOLOCK)
            on rtwn.IdTownship = ord.ReceiverIdTownship
        left join dbo.VisitPointClient vpc WITH (NOLOCK)
            on vpc.CodeOfReference = ord.Sender_ID
    WHERE ord.Guide_Serie = @GuideSerie
          AND ord.Guide_Number = @GuideNumber

    print 'fin carga inicial'
    print CONVERT(VARCHAR, GETDATE(), 9)

    --print 'fin carga inicial'
    ------------------ fin Carga de datos ---------------------------------------------------------------------

    ---------------------Determinar Visit Point ---------------------------------------------------------------

    if @VisitPointClient is null
    begin
        select top 1
            vpc.CodeOfReference
        from dbo.VisitPointClient vpc WITH (NOLOCK)
        where vpc.CustomerID = @IdCustomer
    END

    print 'Fin determinar vp'
    print CONVERT(VARCHAR, GETDATE(), 9)
    ---------------------Fin determinar vp---------------------------------------------------------------------
    -------------------- Determinar HeaderCode de Origen y Destino --------------------------------------------

    if @HeaderCodeSource is null
    begin
        select @HeaderCodeSource = twn.HeaderCode
        from dbo.VisitPointClient vpc WITH (NOLOCK)
            left join dbo.Township twn
                on twn.IdTownship = vpc.IdTownship
        where vpc.CodeOfReference = @VisitPointClient

        IF @HeaderCodeSource IS NULL
        begin
            select @HeaderCodeSource = twn.HeaderCode
            from dbo.DeliveryOrder ord
                left join dbo.Township twn
                    on twn.TownshipName = ord.Sender_Town
            where ord.Guide_Number = @GuideNumber
        end
    end

    IF @HeaderCodeDestiny IS NULL
    begin
        if @HeaderCodeDestiny is null
        begin
            select @HeaderCodeDestiny = twn.HeaderCode
            from dbo.DeliveryOrder ord WITH (NOLOCK)
                left join dbo.Township twn WITH (NOLOCK)
                    on twn.TownshipName = ord.Receiver_Town
            where ord.Guide_Number = @GuideNumber
        end
    end
    print 'origen'
    print @HeaderCodeSource
    print 'destino'
    print @HeaderCodeDestiny

    print 'Fin HeaderCodes'
    print CONVERT(VARCHAR, GETDATE(), 9)
    -------------------- Fin HeaderCodes ----------------------------------------------------------------------

    IF OBJECT_ID('tempdb.dbo.#Pieces', 'U') IS NOT NULL
        DROP TABLE #Pieces;

    select ROW_NUMBER() OVER (ORDER BY ps.DateCreated) Id,
           isnull(ps.ParcelCode, ' ') [ParcelCode],
           isnull(ps.PiecePhysicalWeight, 0) [MassWeight],
           isnull(ps.PieceWeight, 0) [VolumetricWeight],
           isnull(ps.MassWeight, 0) [MassWeightChecked],
           isnull(ps.volumetricWeight, 0) [VolumetricWeightChecked]
    Into #Pieces
    from dbo.DeliveryOrderPiece ps WITH (NOLOCK)
    where ps.GuideSerie = @GuideSerie
          AND ps.GuideNumber = @GuideNumber

    CREATE NONCLUSTERED INDEX IX_Pieces_ParcelCode ON #Pieces (ParcelCode);

    DECLARE @count INT;
    SET @count = 1;

    declare @PiecesCount as int = (
                                      SELECT iif(isnull(COUNT(*), 0) = 0, @PiecesInOrder, count(*))
                                      FROM #Pieces
                                  )

    DECLARE @Pesos as nvarchar(MAX) = null
    declare @Parcel as nvarchar(MAX) = null

    declare @MassWeight decimal(12, 2) = 0
    declare @VolumetricWeight decimal(12, 2) = 0
    declare @MassWeightChecked decimal(12, 2) = 0
    declare @VolumetricWeightChecked decimal(12, 2) = 0
    declare @PCode varchar(10) = ''

    declare @WeightDeclare decimal(12, 2) = 0
    declare @WeightChecked decimal(12, 2) = 0
    declare @WeightMax decimal(12, 2) = 0
    PRINT '@count'
    PRINT @count

    PRINT '@@ParPesos'
    PRINT @ParPesos
    if ISNULL(LTRIM(RTRIM(@ParPesos)), '') = ''
    BEGIN
        PRINT '@@ParPesos null'
        PRINT @ParPesos
        --select * from #Pieces
        WHILE @count <= @PiecesCount
        BEGIN
            select @MassWeight = pc.MassWeight,
                   @VolumetricWeight = pc.VolumetricWeight,
                   @MassWeightChecked = pc.MassWeightChecked,
                   @VolumetricWeightChecked = pc.VolumetricWeightChecked,
                   @PCode = pc.ParcelCode
            from #Pieces pc
            WHERE pc.Id = @count

            --print @MassWeight
            --print @VolumetricWeight
            --print @MassWeightChecked
            --print @VolumetricWeightChecked 
            --print @PCode 

            if @MassWeight > @VolumetricWeight
                set @WeightDeclare = @MassWeight
            else
                set @WeightDeclare = @VolumetricWeight

            if @MassWeightChecked > @VolumetricWeightChecked
                set @WeightChecked = @MassWeightChecked
            else
                set @WeightChecked = @VolumetricWeightChecked

            if @WeightDeclare > @WeightChecked
                set @WeightMax = @WeightDeclare
            else
                set @WeightMax = @WeightChecked

            --print 'peso maximo'
            --print @WeightMax

            --print 'pesosnull'
            --print @Pesos
            PRINT 'pesosnull1'
            print @Pesos
            if (ISNULL(@Pesos, '') = '')
            begin
                set @Parcel = @PCode
                set @Pesos = CONVERT(varchar, @WeightMax)


                PRINT 'pesosnull2'
                print @Pesos
            end
            else
            begin
                --print 'pesos else'
                set @Pesos = @Pesos + ',' + CONVERT(varchar, @WeightMax)
                set @Parcel = @Parcel + ',' + CONVERT(varchar, @PCode)
            end

            --print 'pesos'
            --print @Pesos
            --print 'parcel'
            --print @Parcel

            DELETE FROM #Pieces
            WHERE Id = @count;
            set @count = @count + 1

        END;
    END;
    ELSE
    BEGIN
        SET @Pesos = @ParPesos;
    END;

    print 'Fin Pesos'
    print CONVERT(VARCHAR, GETDATE(), 9)

    DECLARE @IsCreditCard bit = 'false'
    if @ParIsCreditCard IS NULL
    begin
        set @IsCreditCard =
        (
            select iif(count(*) > 0, 'true', 'false') as result
            from dbo.Cost cst WITH (NOLOCK)
                LEFT join dbo.BreakdownOfPayment br WITH (NOLOCK)
                    on br.IdCost = cst.IdCost
            WHERE cst.IdProduct = 1
                  AND cst.ProductNumber = concat('FD', @GuideNumber)
                  and br.Description = 'Recargo por pago con tarjeta'
                  and br.RowStatus = 'true'
                  and br.Amount > 0
        )
    end
    else
    begin
        set @IsCreditCard = @ParIsCreditCard
    end
    print 'Fin credit card'
    print CONVERT(VARCHAR, GETDATE(), 9)

    --select @IsCreditCard as IsCreditCard


    print 'cliente'
    print @idCustomer

    print 'consultando datos'
    print CONVERT(VARCHAR, GETDATE(), 9)



    DECLARE @TempRate TABLE
    (
        TypeRate varchar(50),
        Segment varchar(50),
        Service varchar(50),
        Price decimal(12, 2),
        BaseRate decimal(12, 2),
        Discount decimal(12, 2),
        DiscountName varchar(100),
        FragilRate decimal(12, 2),
        CollectedRate decimal(12, 2),
        InsuranceRate decimal(12, 2),
        OverWeightRate decimal(12, 2),
        IrregularPieceRate decimal(12, 2),
        CreditCardRate decimal(12, 2),
        Taxes decimal(12, 2),
        FechaCompra datetime,
        Currency varchar(10),
        ReturnRate decimal(12, 2)
    );

    PRINT 'pesos'
    PRINT @Pesos

    --- Validar la tarifa del usuario antes de realizar cambios
    DECLARE @CustomerIdRate INT = 0;
    SELECT TOP 1
        @CustomerIdRate = RBC.RbcIdRate
    FROM [DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH (NOLOCK)
    WHERE RBC.RbcIdCustomer = @IdCustomer
          AND RBC.RbcRowStatus = 1

    PRINT 'Tarifario'
    PRINT @CustomerIdRate
    IF (@CustomerIdRate IN ( @NewMainRates, @NewAutoSalesMainRates ))
    BEGIN

        PRINT 'Piezas'
        PRINT @Parcel

        PRINT 'Pesos de piezas'
        PRINT @Pesos
        IF (LTRIM(RTRIM(REPLACE(@Parcel, ',', ''))) = '')
        BEGIN

            DECLARE @DataCounter INT = 1;

            SET @Parcel = 'EXP076';
            SET @Pesos = '10';

            IF (@DataCounter < @PiecesCount)
            BEGIN
                WHILE @DataCounter < @PiecesCount
                BEGIN

                    SET @Parcel = CONCAT(@Parcel, ',EXP076');
                    SET @Pesos = CONCAT(@Pesos, ',10');

                    SET @DataCounter = @DataCounter + 1;

                END;
            END;

        END;

    END;
    --- Fin de validaciónes de tarifa y tipo de pieza vacio

    --select @Pesos , @Parcel
    INSERT INTO @TempRate
    EXECUTE [dbo].[spws_get_delivery_rate] @CodApp = @CodeApp,
                                           @IdCustomerParams = @IdCustomer,
                                           @HeaderCodeDestiny = @HeaderCodeDestiny,
                                           @HeaderCodeSource = @HeaderCodeSource,
                                           @Country = 'GT',
                                           @CountPiecesParams = @PiecesCount,
                                           @IsFragile = 'false',
                                           @IsCollected = @IsCollect,
                                           @IsInsurance = @IsInsurance,
                                           @WeigthParcels = @Pesos,
                                           @InsuranceAmount = @InsuranceAmount,
                                           @IsCreditCardPayment = @IsCreditCard,
                                           @ParcelCode = @Parcel,
                                           @Zone = 0,
                                           @AddressParse = @AddressParse,
                                           @IdSettlementSource = @IdSettlement,
                                           @IdSettlementDestiny = 0,
                                           @CodeOfReferenceSource = @VisitPointClient,
                                           @CodeOfReferenceDestiny = @VisitPointClientDestiny,
                                           @IdSalePipeLine = @IdSalePipeLine,
                                           @FormatResponse = 'DataTable',
                                           @CalculateTaxes = @CalculateTaxes,
                                           @CalculateMembership = 'false'
    --select tp.* from @TempRate tp
	
	 IF(@UseMembership = 1)
	 BEGIN
    /* Membresias y Suscripciones */
    -- Oscar Morales 2022-07-21
    DECLARE @PriceShippment DECIMAL(14, 2)
    DECLARE @MembershipId INT
    DECLARE @ServiceValue DECIMAL(14, 2) = 0
    DECLARE @DiscountMembership DECIMAL(18, 2) = 0
    DECLARE @NewPriceShippment DECIMAL(14, 2)
    DECLARE @CatMembershipStatusId INT
    DECLARE @DecriptionDiscount NVARCHAR(300)
    DECLARE @SubscriptionId INT
    DECLARE @ServiceValueSubscription DECIMAL(14, 2) = 0
    DECLARE @DiscountValue DECIMAL(5, 2)
    DECLARE @Type NVARCHAR(50)
    DECLARE @ServiceAppliedType INT -- 1 MEMBRESÍA, 2 SUSCRIPCIÓN
    DECLARE @ServiceAppliedCount INT
    DECLARE @MembershipSubscriptionLogId BIGINT
    --DECLARE @DiscountDescription2 VARCHAR(100)
    --DECLARE @DiscountAnt DECIMAL(12,2)

    SELECT @PriceShippment = tr.Price + ABS(ISNULL(tr.Discount, 0)) --si tiene otro descuento
    FROM @TempRate tr
    WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
          OR @ServiceShortName = 'EXP'

    --buscar si ya se aplicó un descuento
    SELECT TOP 1
        @MembershipSubscriptionLogId = IdMembershipSubscriptionLog,
        @MembershipId = MembershipId,
        @SubscriptionId = SubscriptionId,
        @ServiceAppliedCount = LogServiceNumber
    FROM MembershipSubscriptionLog
    WHERE LogGuideSerie = @GuideSerie
          AND LogGuideNumber = @GuideNumber
          AND RowStatus = 1
    ORDER BY DateCreated DESC

    --si ya existe registro
    IF @MembershipSubscriptionLogId IS NOT NULL
    BEGIN

        IF @SubscriptionId IS NULL
        BEGIN

            SELECT @ServiceValue
                = IIF(@ServiceAppliedCount <= ms.MembershipMaxServiceFixedValue, ms.MembershipFixedValue, -1)
            FROM Membership ms
            WHERE ms.IdMembership = @MembershipId

            --Si es tarifa fija
            IF @ServiceValue >= 0
            BEGIN

                SET @DiscountMembership = @PriceShippment - @ServiceValue
                SET @NewPriceShippment = @ServiceValue
            END
            ELSE
            BEGIN

                --Se busca por rango de servicios
                SELECT TOP 1
                    @DiscountValue = DiscountValue,
                    @Type = cvt.ValueTypeName
                FROM MembershipDiscountRange mdr
                    INNER JOIN Membership ms
                        ON ms.IdMembership = mdr.MembershipId
                    INNER JOIN CatValueType cvt
                        ON mdr.ValueTypeId = cvt.IdCatValueType
                WHERE mdr.MembershipId = @MembershipId
                      AND (
                              (@ServiceAppliedCount
                      BETWEEN mdr.DiscountLowServiceRange AND mdr.DiscountTopServiceRange
                              )
                              OR @ServiceAppliedCount >= mdr.DiscountLowServiceRange
                                 AND mdr.DiscountTopServiceRange IS NULL
                          )
                      AND mdr.RowStatus = 1
                ORDER BY mdr.DateCreated DESC

                IF @DiscountValue IS NOT NULL
                BEGIN

                    IF @Type = 'Porcentaje'
                    BEGIN
                        SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100)
                    END
                    ELSE IF @Type = 'Monto'
                    BEGIN
                        SET @DiscountMembership = @DiscountValue
                    END
                    ELSE IF @Type = 'Servicio'
                    BEGIN
                        SET @DiscountMembership = @PriceShippment
                    END

                    SET @NewPriceShippment = @PriceShippment - @DiscountMembership

                    IF @NewPriceShippment < 0
                    BEGIN
                        SET @DiscountMembership = @PriceShippment
                        SET @NewPriceShippment = 0
                    END
                END
            END
        END
        ELSE
        BEGIN

            SELECT TOP 1
                @ServiceValueSubscription
                    = IIF(@ServiceAppliedCount <= sc.SubscriptionMaxServiceFixedValue, sc.SubscriptionFixedValue, -1)
            FROM Subscription sc
            WHERE sc.IdSubscription = @SubscriptionId

            --Si es tarifa fija
            IF @ServiceValueSubscription >= 0
            BEGIN

                SET @DiscountMembership = @PriceShippment - @ServiceValueSubscription
                SET @NewPriceShippment = @ServiceValueSubscription
            END
            ELSE
            BEGIN

                --Se busca por rango de servicios
                SELECT TOP 1
                    @DiscountValue = DiscountValue,
                    @Type = cvt.ValueTypeName
                FROM SubscriptionDiscountRange sdr
                    INNER JOIN Subscription sc
                        ON sc.IdSubscription = sdr.SubscriptionId
                    INNER JOIN CatValueType cvt
                        ON sdr.ValueTypeId = cvt.IdCatValueType
                WHERE sdr.SubscriptionId = @SubscriptionId
                      AND (
                              (@ServiceAppliedCount
                      BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange
                              )
                              OR @ServiceAppliedCount >= sdr.DiscountLowServiceRange
                                 AND sdr.DiscountTopServiceRange IS NULL
                          )
                      AND sdr.RowStatus = 1
                ORDER BY sdr.DateCreated DESC

                IF @DiscountValue IS NOT NULL
                BEGIN

                    IF @Type = 'Porcentaje'
                    BEGIN
                        SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100)
                    END
                    ELSE IF @Type = 'Monto'
                    BEGIN
                        SET @DiscountMembership = @DiscountValue
                    END
                    ELSE IF @Type = 'Servicio'
                    BEGIN
                        SET @DiscountMembership = @PriceShippment
                    END

                    SET @NewPriceShippment = @PriceShippment - @DiscountMembership

                    IF @NewPriceShippment < 0
                    BEGIN
                        SET @DiscountMembership = @PriceShippment
                        SET @NewPriceShippment = 0
                    END
                END
            END
        END

        IF @DiscountMembership > 0
        BEGIN

            SET @DiscountMembership = @DiscountMembership * -1


            UPDATE tr
            SET Discount = @DiscountMembership,
                DiscountName = 'Descuento membresía',
                Price = @NewPriceShippment
            FROM @TempRate tr
            WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                  OR @ServiceShortName = 'EXP'

            IF @SetUpdate = 'true'
            BEGIN
                UPDATE MembershipSubscriptionLog
                SET LogGuideOriginalValue = @PriceShippment,
                    LogGuideNewValue = @NewPriceShippment,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId
            END

        END
    END
    ELSE
    BEGIN

        --Se busca si existe una membresía activa
        SELECT TOP 1
            @MembershipId = ms.IdMembership,
            @CatMembershipStatusId = ms.CatMembershipStatusId,
            @ServiceValue
                = IIF(ms.ActualServiceCount + 1 <= ms.MembershipMaxServiceFixedValue, ms.MembershipFixedValue, -1)
        FROM Membership ms
            INNER JOIN CatSalesPackageStatus csps
                ON csps.IdCatSalesPackageStatus = ms.CatMembershipStatusId
        WHERE ms.CustomerId = @Idcustomer
              AND @DateCreated <= ms.ExpirationDate
              AND ms.RowStatus = 1
              AND csps.SalesPackageStatusName = 'Activa'
        ORDER BY ms.DateCreated DESC

        --Si existe una membresía y la guía tiene precio
        IF @MembershipId IS NOT NULL
           AND @PriceShippment IS NOT NULL
           AND @PriceShippment > 0
        BEGIN

            --Si es tarifa fija
            IF @ServiceValue >= 0
            BEGIN

                SET @DiscountMembership = @PriceShippment - @ServiceValue
                SET @NewPriceShippment = @ServiceValue
                SET @DecriptionDiscount = CONCAT('Tarifa fija membresía a ', @ServiceValue)
                SET @ServiceAppliedType = 1
            END
            ELSE
            BEGIN

                --Se busca suscripciones
                SELECT TOP 1
                    @SubscriptionId = sc.IdSubscription,
                    @ServiceValueSubscription
                        = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue,
                              sc.SubscriptionFixedValue,
                              -1)
                FROM Subscription sc
                    INNER JOIN CatSalesPackageStatus csps
                        ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
                WHERE sc.CustomerId = @Idcustomer
                      AND @DateCreated <= sc.ExpirationDate
                      AND sc.RowStatus = 1
                      AND csps.SalesPackageStatusName = 'Activa'
                ORDER BY sc.ExpirationDate

                --Si existe una suscripción
                IF @SubscriptionId IS NOT NULL
                BEGIN

                    --Si es tarifa fija
                    IF @ServiceValueSubscription >= 0
                    BEGIN

                        SET @DiscountMembership = @PriceShippment - @ServiceValueSubscription
                        SET @NewPriceShippment = @ServiceValueSubscription
                        SET @DecriptionDiscount = CONCAT('Tarifa fija suscripción a ', @ServiceValueSubscription)
                        SET @ServiceAppliedType = 2
                    END
                    ELSE
                    BEGIN

                        --Se busca por rango de servicios
                        SELECT TOP 1
                            @DiscountValue = DiscountValue,
                            @Type = cvt.ValueTypeName
                        FROM SubscriptionDiscountRange sdr
                            INNER JOIN Subscription sc
                                ON sc.IdSubscription = sdr.SubscriptionId
                            INNER JOIN CatValueType cvt
                                ON sdr.ValueTypeId = cvt.IdCatValueType
                        WHERE sdr.SubscriptionId = @SubscriptionId
                              AND (
                                      (sc.ActualServiceCount + 1
                              BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange
                                      )
                                      OR sc.ActualServiceCount + 1 >= sdr.DiscountLowServiceRange
                                         AND sdr.DiscountTopServiceRange IS NULL
                                  )
                              AND sdr.RowStatus = 1
                        ORDER BY sdr.DateCreated DESC

                        IF @DiscountValue IS NOT NULL
                        BEGIN

                            IF @Type = 'Porcentaje'
                            BEGIN
                                SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100)
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios suscripción, porcentaje ', @DiscountValue)
                                SET @ServiceAppliedType = 2
                            END
                            ELSE IF @Type = 'Monto'
                            BEGIN
                                SET @DiscountMembership = @DiscountValue
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios suscripción, monto ', @DiscountValue)
                                SET @ServiceAppliedType = 2
                            END
                            ELSE IF @Type = 'Servicio'
                            BEGIN
                                SET @DiscountMembership = @PriceShippment
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios suscripción, servicio ', @PriceShippment)
                                SET @ServiceAppliedType = 2
                            END

                            SET @NewPriceShippment = @PriceShippment - @DiscountMembership

                            IF @NewPriceShippment < 0
                            BEGIN
                                SET @DiscountMembership = @PriceShippment
                                SET @NewPriceShippment = 0
                            END
                        END
                    END
                END

                IF @SubscriptionId IS NULL
                   OR @ServiceAppliedType IS NULL
                BEGIN

                    SET @DiscountValue = NULL
                    SET @Type = NULL

                    --Se busca por rango de servicios
                    SELECT TOP 1
                        @DiscountValue = DiscountValue,
                        @Type = cvt.ValueTypeName
                    FROM MembershipDiscountRange mdr
                        INNER JOIN Membership ms
                            ON ms.IdMembership = mdr.MembershipId
                        INNER JOIN CatValueType cvt
                            ON mdr.ValueTypeId = cvt.IdCatValueType
                    WHERE mdr.MembershipId = @MembershipId
                          AND (
                                  (ms.ActualServiceCount + 1
                          BETWEEN mdr.DiscountLowServiceRange AND mdr.DiscountTopServiceRange
                                  )
                                  OR ms.ActualServiceCount + 1 >= mdr.DiscountLowServiceRange
                                     AND mdr.DiscountTopServiceRange IS NULL
                              )
                          AND mdr.RowStatus = 1
                    ORDER BY mdr.DateCreated DESC

                    IF @DiscountValue IS NOT NULL
                    BEGIN

                        IF @Type = 'Porcentaje'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100)
                            SET @DecriptionDiscount
                                = CONCAT('Por rango de servicios membresía, porcentaje ', @DiscountValue)
                            SET @ServiceAppliedType = 1
                        END
                        ELSE IF @Type = 'Monto'
                        BEGIN
                            SET @DiscountMembership = @DiscountValue
                            SET @DecriptionDiscount
                                = CONCAT('Por rango de servicios membresía, monto ', @DiscountValue)
                            SET @ServiceAppliedType = 1
                        END
                        ELSE IF @Type = 'Servicio'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment
                            SET @DecriptionDiscount
                                = CONCAT('Por rango de servicios membresía, servicio ', @PriceShippment)
                            SET @ServiceAppliedType = 1
                        END

                        SET @NewPriceShippment = @PriceShippment - @DiscountMembership

                        IF @NewPriceShippment < 0
                        BEGIN
                            SET @DiscountMembership = @PriceShippment
                            SET @NewPriceShippment = 0
                        END
                    END
                END
            END

            IF @DiscountMembership > 0
            BEGIN
                SET @DiscountMembership = @DiscountMembership * -1

                UPDATE tr
                SET Discount = @DiscountMembership,
                    DiscountName = 'Descuento membresía',
                    Price = @NewPriceShippment
                FROM @TempRate tr
                WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                      OR @ServiceShortName = 'EXP'

                IF @SetUpdate = 'true'
                BEGIN

                    IF @ServiceAppliedType = 1
                    BEGIN
                        --Actualizar contador membresía
                        UPDATE Membership
                        SET ActualServiceCount = ActualServiceCount + 1,
                            @ServiceAppliedCount = ActualServiceCount + 1,
                            TokenUpdated = @Token,
                            DateUpdated = GETDATE()
                        WHERE IdMembership = @MembershipId
                    END
                    ELSE
                    BEGIN
                        --Actualizar contador sucripción
                        UPDATE Subscription
                        SET ActualServiceCount = ActualServiceCount + 1,
                            @ServiceAppliedCount = ActualServiceCount + 1,
                            TokenUpdated = @Token,
                            DateUpdated = GETDATE()
                        WHERE IdSubscription = @SubscriptionId
                    END

                    SET @DecriptionDiscount
                        = CONCAT('Se aplicó descuento de membresía y suscripción (', @DecriptionDiscount, ')')
                    --Insertar log
                    INSERT INTO [dbo].[MembershipSubscriptionLog]
                    (
                        [SystemId],
                        [ModuleId],
                        [MembershipId],
                        [SubscriptionId],
                        [SalesPackageStatusId],
                        [StationId],
                        [CustomerId],
                        [AccountId],
                        [VisitPointClientId],
                        [LogActionDescription],
                        [LogGuideSerie],
                        [LogGuideNumber],
                        [LogGuideOriginalValue],
                        [LogGuideNewValue],
                        [RowStatus],
                        [TokenCreated],
                        [DateCreated],
                        [TokenUpdated],
                        [DateUpdated],
                        [LogServiceNumber]
                    )
                    VALUES
                    (
                        (
                            SELECT TOP 1 SysIdSystem FROM CatSystem WHERE SysNameSystem = 'Parser'
                        ),
                        (
                            SELECT TOP 1 ModIdModule FROM CatModule WHERE ModPath = 'Parser'
                        ),
                        @MembershipId,
                        IIF(@ServiceAppliedType = 1, NULL, @SubscriptionId),
                        @CatMembershipStatusId,
                        NULL,
                        @Idcustomer,
                        NULL,
                        NULL,
                        @DecriptionDiscount,
                        @GuideSerie,
                        @GuideNumber,
                        @PriceShippment,
                        @NewPriceShippment,
                        1,
                        @Token,
                        GETDATE(),
                        NULL,
                        NULL,
                        @ServiceAppliedCount
                    )
                END
            END
        END
    END

	END
    /* Termina membresías y suscripciones */

    print 'inicio de actualizacion de datos'
    print CONVERT(VARCHAR, GETDATE(), 9)
    if @SetUpdate = 'true' -- indica que se guardaran los cambios en la guia de trasporte
    begin

        Declare @NewPrice decimal(12, 2) = 0
        DECLARE @BaseRate decimal(12, 2) = 0
        DECLARE @Discount decimal(12, 2) = 0
        DECLARE @DiscountDescription varchar(100) = ''
        DECLARE @FragilRate decimal(12, 2) = 0
        DECLARE @CollectedRate decimal(12, 2) = 0
        DECLARE @InsuranceRate decimal(12, 2) = 0
        DECLARE @OverWeightRate decimal(12, 2) = 0
        DECLARE @IrregularPiece decimal(12, 2) = 0
        DECLARE @CreditCardRate decimal(12, 2) = 0
        DECLARE @Taxes decimal(12, 2) = 0
        DECLARE @ReturnAmount decimal(12, 2)

        DECLARE @RESULT AS NVARCHAR(MAX)
        print 'precio'
        print @NewPrice

        print 'servicio'
        print @ServiceShortName

        select @NewPrice = isnull(tr.Price, 0),
               @BaseRate = isnull(tr.BaseRate, 0),
               @Discount = isnull(tr.Discount, 0),
               @DiscountDescription = isnull(tr.DiscountName, ''),
               @FragilRate = isnull(tr.FragilRate, 0),
               @CollectedRate = isnull(tr.CollectedRate, 0),
               @InsuranceRate = isnull(tr.InsuranceRate, 0),
               @OverWeightRate = isnull(tr.OverWeightRate, 0),
               @IrregularPiece = isnull(tr.IrregularPieceRate, 0),
               @CreditCardRate = isnull(tr.CreditCardRate, 0),
               @Taxes = isnull(tr.Taxes, 0),
               @ReturnAmount = IIF(@IsReturn = 'TRUE', (tr.Price * isnull(tr.ReturnRate, 0) / 100), 0)
        from @TempRate tr
        where tr.Service = isnull(@ServiceShortName, 'NDD')
              or @ServiceShortName = 'EXP'
        print 'precio devolucion '
        print @ReturnAmount

        print 'precio'
        print @NewPrice
        if @NewPrice = 0
        begin
            select top 1
                @NewPrice = isnull(tr.Price, 0),
                @BaseRate = isnull(tr.BaseRate, 0),
                @Discount = isnull(tr.Discount, 0),
                @DiscountDescription = isnull(tr.DiscountName, ''),
                @FragilRate = isnull(tr.FragilRate, 0),
                @CollectedRate = isnull(tr.CollectedRate, 0),
                @InsuranceRate = isnull(tr.InsuranceRate, 0),
                @OverWeightRate = isnull(tr.OverWeightRate, 0),
                @IrregularPiece = isnull(tr.IrregularPieceRate, 0),
                @CreditCardRate = isnull(tr.CreditCardRate, 0),
                @Taxes = isnull(tr.Taxes, 0)
            from @TempRate tr
            order by tr.Price asc

        end


        -- Actualizar campos de delivery order
        update DeliveryOrder
        set IsCollect = @IsCollect,
            IsInsuarance = @IsInsurance,
            InsuranceAmount = @InsuranceAmount,
            PriceShippment = @NewPrice
        where Guide_Serie = @GuideSerie
              and Guide_Number = @GuideNumber

        -- Actualizar pesos de piezas
        print 'guardando  tabla costos'
        print CONVERT(VARCHAR, GETDATE(), 9)
        -- Guardar Costos

        declare @TblCost [dbo].[TblChangeList]

        insert into @TblCost
        (
            RowNumber,
            [Description],
            [Amount],
            [ModIdModule],
            [RowStatus],
            [TokenCreated]
        )
        values
        (1, 'Servicio', (@BaseRate + @IrregularPiece), @IdModule, 'true', @Token),
        (2, 'Frágil', @FragilRate, @IdModule, 'true', @Token),
        (3, 'Seguro', @InsuranceRate, @IdModule, 'true', @Token),
        (4, 'Pago en Destino', @CollectedRate, @IdModule, 'true', @Token),
        (5, 'Recargo por Peso', @OverWeightRate, @IdModule, 'true', @Token),
        (6, 'Otros recargos', @CreditCardRate, @IdModule, 'true', @Token),
        (7, @DiscountDescription, @Discount, @IdModule, 'true', @Token),
        (8, 'IVA', @Taxes, @IdModule, 'true', @Token)

        declare @ProdctNumber varchar(49) = @GuideSerie + CONVERT(varchar, @GuideNumber)
        --select * from @TblCost	
        DECLARE @TBLRESULT TABLE (RESULT NVARCHAR(MAX))

        --	INSERT INTO @TBLRESULT

        print 'guardando costos'
        print CONVERT(VARCHAR, GETDATE(), 9)

        --EXECUTE [dbo].[SetProductCost] 
        --	@IdProduct = 1 -- 1 guia de transporte
        --	,@IdTypeCharge = 1 -- 1 costo de envio
        --	,@ProductNumber = @ProdctNumber
        --	,@Amount =@NewPrice -- nuevo precio
        --	,@AmountPaid =0 --- registrar sin pago
        --	,@IdModule = @IdModule
        --	,@PaymentType= null
        --	,@Voucher =null
        --	,@Token = @Token
        --	,@PaymentDate= null
        --	,@TblDetail = @TblCost
        --	,@ReturnAmount = @ReturnAmount
        --	,@Format ='Non'
        DECLARE @IdCost INT;

        IF EXISTS
        (
            SELECT TOP 1
                cst.ProductNumber
            FROM dbo.Cost cst WITH (NOLOCK)
            WHERE cst.IdProduct = 1
                  AND cst.ProductNumber = @ProdctNumber
                  AND ISNULL(cst.TotalAmountPaid, 0) = 0
        )
        BEGIN
            print 'existe'
            print CONVERT(VARCHAR, GETDATE(), 9)
            SET @IdCost =
            (
                SELECT TOP 1
                    cst.IdCost
                FROM dbo.Cost cst WITH (NOLOCK)
                WHERE cst.IdProduct = 1
                      AND cst.ProductNumber = @ProdctNumber
                      AND ISNULL(cst.TotalAmountPaid, 0) = 0
            );

            print 'Actualizando costo'
            print CONVERT(VARCHAR, GETDATE(), 9)
            UPDATE dbo.Cost
            SET TotalAmount = @NewPrice,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            WHERE IdCost = @IdCost;
            print 'guardando en breackdown'
            print CONVERT(VARCHAR, GETDATE(), 9)
            INSERT INTO [dbo].[BreakdownOfPayment]
            (
                [IdCost],
                [Description],
                [Amount],
                [ModIdModule],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            SELECT @IdCost,
                   det.Description,
                   det.Amount,
                   det.ModIdModule,
                   1, -- crear registro activo por default
                   det.TokenCreated,
                   GETDATE()
            FROM @TblCost det
                LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                    ON bk.IdCost = @IdCost
                       AND bk.Description = det.Description COLLATE Latin1_General_CI_AI
            WHERE bk.IdBreakdownOfPayment IS NULL
                  AND ABS(det.Amount) > 0;


            print 'actualizando en breackdown'
            print CONVERT(VARCHAR, GETDATE(), 9)
            -- actualizar los registros que si existen 
            UPDATE dbo.BreakdownOfPayment
            SET Amount = det.Amount,
                RowStatus = det.RowStatus,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            FROM dbo.Cost cs
                INNER JOIN dbo.BreakdownOfPayment bk
                    ON bk.IdCost = cs.IdCost
                INNER JOIN @TblCost det
                    ON det.Description = bk.Description
            WHERE cs.IdCost = @IdCost

            -- actualizar los registros que no existen 
            UPDATE dbo.BreakdownOfPayment
            SET RowStatus = 0,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            FROM dbo.Cost cs
                INNER JOIN dbo.BreakdownOfPayment bk
                    ON bk.IdCost = cs.IdCost
                LEFT JOIN @TblCost det
                    ON det.Description = bk.Description
            WHERE cs.IdCost = @IdCost
                  AND det.RowNumber IS NULL;

        END;
        ELSE
        BEGIN
            PRINT 'registro no existe , hay que crearlo';
            INSERT INTO dbo.Cost
            (
                IdProduct,
                ProductNumber,
                IdTypeCharge,
                TotalAmount,
                IdModule,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            VALUES
            (   1,
                @ProdctNumber,
                1, -- costo de envio
                @NewPrice,
                @IdModule,
                1, -- guardar los registros como activos 
                @Token,
                GETDATE()
            );

            SET @IdCost = SCOPE_IDENTITY();

            INSERT INTO [dbo].[BreakdownOfPayment]
            (
                [IdCost],
                [Description],
                [Amount],
                [ModIdModule],
                [RowStatus],
                [TokenCreated],
                [DateCreated]
            )
            SELECT @IdCost,
                   det.Description,
                   det.Amount,
                   det.ModIdModule,
                   1, -- crear registro activo por default
                   det.TokenCreated,
                   GETDATE()
            FROM @TblCost det
            WHERE ABS(det.Amount) > 0;
        END;




        print 'costos guardados'
        print CONVERT(VARCHAR, GETDATE(), 9)

    end
    print 'format'
    print @Format
    if @Format = 'json'
    begin
        declare @jsonResult as nvarchar(max)

        set @jsonResult =
        (
            SELECT STUFF(
                            (
                                select ',{"Title":"' + isnull(tr.Service, '') + '",' + '"Service":"'
                                       + isnull(tr.Segment, '') + '",' + '"ServiceDescription":"'
                                       + isnull(tr.Service, '') + '",' + '"ServiceShortName":"'
                                       + isnull(tr.Service, '') + '",' + '"DeliveryDate":"'
                                       + Convert(varchar(24), tr.FechaCompra, 120) + '",' + '"Price":"'
                                       + convert(
                                                    varchar(20),
                                                    convert(
                                                               decimal(12, 2),
                                                               (tr.BaseRate + tr.Discount + tr.FragilRate
                                                                + tr.CollectedRate + tr.InsuranceRate
                                                                + tr.CreditCardRate + tr.OverWeightRate
                                                                + tr.IrregularPieceRate
                                                               )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '",' + '"OldPrice":"'
                                       + CONVERT(varchar(20), @OldPrice) + '",' + '"Integration":[{"Description":"'
                                       + 'Servicio' + '",' + '"Price":"'
                                       + convert(
                                                    varchar(20),
                                                    CONVERT(
                                                               decimal(12, 2),
                                                               dbo.fnt_Iva_Calculator(
                                                                                         @CalculateTaxes,
                                                                                         'GT',
                                                                                         tr.BaseRate
                                                                                         + tr.IrregularPieceRate,
                                                                                         'false'
                                                                                     )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                       + iif(tr.FragilRate > 0,
                                             ',{"Description":"' + 'Frágil' + '",' + '"Price":"'
                                             + convert(
                                                          varchar(20),
                                                          convert(
                                                                     decimal(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.FragilRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + iif(tr.InsuranceRate > 0,
                                             ',{"Description":"' + 'Seguro' + '",' + '"Price":"'
                                             + convert(
                                                          varchar(20),
                                                          convert(
                                                                     decimal(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.InsuranceRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + iif(tr.CollectedRate > 0,
                                             ',{"Description":"' + 'Pago en Destino' + '",' + '"Price":"'
                                             + convert(
                                                          varchar(20),
                                                          convert(
                                                                     decimal(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.CollectedRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + iif((tr.OverWeightRate) > 0,
                                             ',{"Description":"' + 'Recargo por Peso' + '",' + '"Price":"'
                                             + convert(
                                                          varchar(20),
                                                          convert(
                                                                     decimal(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.OverWeightRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + iif((tr.CreditCardRate) > 0,
                                             ',{"Description":"' + 'Recargo por pago con tarjeta' + '",' + '"Price":"'
                                             + convert(
                                                          varchar(20),
                                                          dbo.fnt_Iva_Calculator(
                                                                                    @CalculateTaxes,
                                                                                    'GT',
                                                                                    tr.CreditCardRate,
                                                                                    'false'
                                                                                )
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}',
                                             ' ')
                                       + iif((ABS(isnull(tr.Discount, 0))) > 0,
                                             ',{"Description":"' + isnull(tr.DiscountName, '') + '",' + '"Price":"'
                                             + CONVERT(
                                                          varchar,
                                                          CAST((dbo.fnt_Iva_Calculator(
                                                                                          @CalculateTaxes,
                                                                                          'GT',
                                                                                          (tr.Discount),
                                                                                          'false'
                                                                                      )
                                                               ) AS decimal(18, 2))
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}',
                                             ' ') + ',{"Description":"' + 'IVA' + '",' + '"Price":"'
                                       + convert(
                                                    varchar(20),
                                                    convert(
                                                               decimal(12, 2),
                                                               dbo.fnt_Iva_Calculator(
                                                                                         @CalculateTaxes,
                                                                                         'GT',
                                                                                         (tr.BaseRate - tr.Discount
                                                                                          + tr.FragilRate
                                                                                          + tr.CollectedRate
                                                                                          + tr.InsuranceRate
                                                                                          + tr.CreditCardRate
                                                                                          + tr.OverWeightRate
                                                                                          + tr.IrregularPieceRate
                                                                                         ),
                                                                                         'true'
                                                                                     )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '"' + '}' + ' ]}'
                                from @TempRate tr
                                where tr.Service = isnull(@ServiceShortName, 'NDD')
                                      or @ServiceShortName = 'EXP'
                                --	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        )

        select '[' + @jsonResult + ']'
    end
    if @Format = 'datatable'
    begin

        select isnull(tr.Price, 0) [Price],
               isnull(tr.BaseRate, 0) [BaseRate],
               isnull(tr.Discount, 0) [Discount],
               isnull(tr.DiscountName, '') [DiscountName],
               isnull(tr.FragilRate, 0) [FragilRate],
               isnull(tr.CollectedRate, 0) [CollectedRate],
               isnull(tr.InsuranceRate, 0) [InsuranceRate],
               isnull(tr.OverWeightRate, 0) [OverWeightRate],
               isnull(tr.IrregularPieceRate, 0) [IrregularPieceRate],
               isnull(tr.CreditCardRate, 0) [CreditCardRate],
               isnull(tr.Taxes, 0) [Taxes],
               isnull(@OldPrice, 0) [OldPrice],
               isnull(tr.ReturnRate, 0) [ReturnRate]
        --	, TR.TypeRate
        INTO #TempResult
        from @TempRate tr
        where tr.Service = isnull(@ServiceShortName, 'NDD')
              or @ServiceShortName = 'EXP'

        declare @HasData int = (
                                   select count(*) from #TempResult
                               )
        print 'precio'
        print @HasData
        if @HasData = 0
        begin
            select top 1
                isnull(tr.Price, 0) [Price],
                isnull(tr.BaseRate, 0) [BaseRate],
                isnull(tr.Discount, 0) [Dicount],
                isnull(tr.DiscountName, '') [DiscountName],
                isnull(tr.FragilRate, 0) [FragilRate],
                isnull(tr.CollectedRate, 0) [CollectedRate],
                isnull(tr.InsuranceRate, 0) [InsuranceRate],
                isnull(tr.OverWeightRate, 0) [OverWeightRate],
                isnull(tr.IrregularPieceRate, 0) [IrregularPieceRate],
                isnull(tr.CreditCardRate, 0) [CreditCardRate],
                isnull(tr.Taxes, 0) [Taxes],
                isnull(@OldPrice, 0) [OldPrice],
                isnull(tr.ReturnRate, 0) [ReturnRate]
            from @TempRate tr
            order by tr.Price asc
        end
        else
        begin
            select *
            from #TempResult
        end
    end



    IF OBJECT_ID('tempdb.dbo.#TempResult', 'U') IS NOT NULL
        DROP TABLE #TempResult;
END
