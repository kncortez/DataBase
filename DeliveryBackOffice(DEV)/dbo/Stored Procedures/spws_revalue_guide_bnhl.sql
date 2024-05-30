
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
-- =============================================
-- Author:		<Edelman,Vasquez>
-- Create date: <2023-07-25>
-- Description:	<Validar que se envíaron los campos  @UseMembership y @TypeSubscriptionId, buscarlos em el log para aplciar descuento que aplique >
-- =============================================

CREATE PROCEDURE [dbo].[spws_revalue_guide_bnhl]
    @GuideSerie VARCHAR(2) = 'FD'
  , @GuideNumber INT = 200307
  , @CodeApp VARCHAR(50) = ''
  , @Format AS NVARCHAR(20) = 'Datatable'
  , @CalculateTaxes BIT = 'true'
  , @IdModule INT = 1
  , @SetUpdate BIT = 'false'
  , @Token VARCHAR(50) = 'spws_revalue_guide'
  , @ParIsCollect BIT = NULL
  , @ParIsInsurance BIT = NULL
  , @ParInsuranceAmount DECIMAL(12, 2) = NULL
  , @ParIsCreditCard BIT = NULL
  , @ParPesos VARCHAR(400) = NULL
  , @IsReturn BIT = 'false'
  , @UseMembership BIT = 0
  , @TypeSubscriptionId AS INT= 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

		IF(@UseMembership = 0 OR @TypeSubscriptionId = 0 )
	  BEGIN
			----Obtener bandera de tipo de suscripcion para enviar a sp revalorizador----
			DECLARE @TypeSubsId INT;
			DECLARE @RevaluedGuide BIT = 0;
			SET @TypeSubsId = (SELECT sb.CatTypeSubscriptionId FROM MembershipSubscriptionLog sbl WITH (NOLOCK)
			INNER JOIN Subscription sb WITH (NOLOCK)
			ON sbl.SubscriptionId = sb.IdSubscription
			WHERE sbl.LogGuideNumber = @GuideNumber And 
				  sbl.LogGuideSerie  = @GuideSerie And 
				  sbl.RowStatus=1)

			IF(@TypeSubsId IS NULL)
				BEGIN
					SET @TypeSubsId = 0
				END
				ELSE
				SET @TypeSubscriptionId = @TypeSubsId
				SET @RevaluedGuide = 1
				
       END

	



    -- Variables "estaticas"
    DECLARE @NewMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewAlternativeRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewAutoSalesMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI
            );

    -- Variables de control
    DECLARE @IdCustomer AS INT;
    DECLARE @IdSettlement AS INT;
    DECLARE @HeaderCodeSource VARCHAR(5);
    DECLARE @HeaderCodeDestiny VARCHAR(5);
    DECLARE @VisitPointClient INT;
    DECLARE @VisitPointClientDestiny INT;
    DECLARE @IsCollect BIT;
    DECLARE @IsInsurance BIT;
    DECLARE @InsuranceAmount DECIMAL(12, 2);
    DECLARE @IdSalePipeLine AS INT;
    DECLARE @AddressParse AS VARCHAR(200);
    DECLARE @ServiceShortName AS VARCHAR(10);
    DECLARE @DateCreated DATETIME;

    DECLARE @PiecesInOrder AS INT;
    DECLARE @PriceWithCreditCard AS INT = 0;


    DECLARE @OldPrice DECIMAL(12, 2);
    PRINT 'inicio carga inicial';
    ------ Carga inicial de datos ----------------------------------------------------------------------------
    SELECT @IdCustomer              = ISNULL(ord.IdCustomer, vpc.CustomerID)
         , @VisitPointClient        = ord.Sender_ID
         , @VisitPointClientDestiny = ISNULL(ord.Receiver_ID, 0)
         , @IdSettlement            = ISNULL(ord.ReceiverIdSettlement, 0)
         , @HeaderCodeSource        = stwn.HeaderCode
         , @HeaderCodeDestiny       = rtwn.HeaderCode
         , @IsCollect               = ISNULL(@ParIsCollect, ISNULL(ord.IsCollect, 'false'))
         , @IsInsurance             = ISNULL(@ParIsInsurance, ISNULL(ord.IsInsuarance, 'false'))
         , @InsuranceAmount         = ISNULL(@ParInsuranceAmount, ISNULL(ord.InsuranceAmount, 0))
         , @AddressParse            = ISNULL(ord.Receiver_Address, '')
         , @IdSalePipeLine          = ISNULL(ord.SalePipeLineId, 0)
         , @PiecesInOrder           = (ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0))
         , @OldPrice                = ISNULL(ord.PriceShippment, 0)
         , @ServiceShortName        = ISNULL(ord.TypeService, 'NDD')
         , @DateCreated             = ord.DateCreated
    FROM dbo.DeliveryOrder             ord WITH (NOLOCK)
        LEFT JOIN dbo.Township         stwn WITH (NOLOCK)
            ON stwn.IdTownship = ord.SenderIdTownship
        LEFT JOIN dbo.Township         rtwn WITH (NOLOCK)
            ON rtwn.IdTownship = ord.ReceiverIdTownship
        LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
            ON vpc.CodeOfReference = ord.Sender_ID
    WHERE ord.Guide_Serie = @GuideSerie
          AND ord.Guide_Number = @GuideNumber;

    PRINT 'fin carga inicial';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);

    --print 'fin carga inicial'
    ------------------ fin Carga de datos ---------------------------------------------------------------------

    ---------------------Determinar Visit Point ---------------------------------------------------------------

    IF @VisitPointClient IS NULL
    BEGIN
        SELECT TOP 1
               vpc.CodeOfReference
        FROM dbo.VisitPointClient vpc WITH (NOLOCK)
        WHERE vpc.CustomerID = @IdCustomer;
    END;

    PRINT 'Fin determinar vp';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    ---------------------Fin determinar vp---------------------------------------------------------------------
    -------------------- Determinar HeaderCode de Origen y Destino --------------------------------------------

    IF @HeaderCodeSource IS NULL
    BEGIN
        SELECT @HeaderCodeSource = twn.HeaderCode
        FROM dbo.VisitPointClient  vpc WITH (NOLOCK)
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = vpc.IdTownship
        WHERE vpc.CodeOfReference = @VisitPointClient;

        IF @HeaderCodeSource IS NULL
        BEGIN
            SELECT @HeaderCodeSource = twn.HeaderCode
            FROM dbo.DeliveryOrder     ord WITH (NOLOCK)
                LEFT JOIN dbo.Township twn WITH (NOLOCK)
                    ON twn.TownshipName = ord.Sender_Town
            WHERE ord.Guide_Number = @GuideNumber;
        END;
    END;

    IF @HeaderCodeDestiny IS NULL
    BEGIN
        IF @HeaderCodeDestiny IS NULL
        BEGIN
            SELECT @HeaderCodeDestiny = twn.HeaderCode
            FROM dbo.DeliveryOrder     ord WITH (NOLOCK)
                LEFT JOIN dbo.Township twn WITH (NOLOCK)
                    ON twn.TownshipName = ord.Receiver_Town
            WHERE ord.Guide_Number = @GuideNumber;
        END;
    END;
    PRINT 'origen';
    PRINT @HeaderCodeSource;
    PRINT 'destino';
    PRINT @HeaderCodeDestiny;

    PRINT 'Fin HeaderCodes';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    -------------------- Fin HeaderCodes ----------------------------------------------------------------------

    IF OBJECT_ID('tempdb.dbo.#Pieces', 'U') IS NOT NULL
        DROP TABLE #Pieces;

    SELECT ROW_NUMBER() OVER (ORDER BY ps.DateCreated) Id
         , ISNULL(ps.ParcelCode, ' ')                  [ParcelCode]
         , ISNULL(ps.PiecePhysicalWeight, 0)           [MassWeight]
         , ISNULL(ps.PieceWeight, 0)                   [VolumetricWeight]
         , ISNULL(ps.MassWeight, 0)                    [MassWeightChecked]
         , ISNULL(ps.volumetricWeight, 0)              [VolumetricWeightChecked]
    INTO #Pieces
    FROM dbo.DeliveryOrderPiece ps WITH (NOLOCK)
    WHERE ps.GuideSerie = @GuideSerie
          AND ps.GuideNumber = @GuideNumber;

    CREATE NONCLUSTERED INDEX IX_Pieces_ParcelCode ON #Pieces (ParcelCode);

    DECLARE @count INT;
    SET @count = 1;

    DECLARE @PiecesCount AS INT =
            (
                SELECT IIF(ISNULL(COUNT(*), 0) = 0, @PiecesInOrder, COUNT(*))
                FROM #Pieces
            );

    DECLARE @Pesos AS NVARCHAR(MAX) = NULL;
    DECLARE @Parcel AS NVARCHAR(MAX) = NULL;

    DECLARE @MassWeight DECIMAL(12, 2) = 0;
    DECLARE @VolumetricWeight DECIMAL(12, 2) = 0;
    DECLARE @MassWeightChecked DECIMAL(12, 2) = 0;
    DECLARE @VolumetricWeightChecked DECIMAL(12, 2) = 0;
    DECLARE @PCode VARCHAR(10) = '';

    DECLARE @WeightDeclare DECIMAL(12, 2) = 0;
    DECLARE @WeightChecked DECIMAL(12, 2) = 0;
    DECLARE @WeightMax DECIMAL(12, 2) = 0;
    PRINT '@count';
    PRINT @count;

    PRINT '@@ParPesos';
    PRINT @ParPesos;
    IF ISNULL(LTRIM(RTRIM(@ParPesos)), '') = ''
    BEGIN
        PRINT '@@ParPesos null';
        PRINT @ParPesos;
        --select * from #Pieces
        WHILE @count <= @PiecesCount
        BEGIN
            SELECT @MassWeight              = pc.MassWeight
                 , @VolumetricWeight        = pc.VolumetricWeight
                 , @MassWeightChecked       = pc.MassWeightChecked
                 , @VolumetricWeightChecked = pc.VolumetricWeightChecked
                 , @PCode                   = pc.ParcelCode
            FROM #Pieces pc
            WHERE pc.Id = @count;

            --print @MassWeight
            --print @VolumetricWeight
            --print @MassWeightChecked
            --print @VolumetricWeightChecked 
            --print @PCode 

            IF @MassWeight > @VolumetricWeight
                SET @WeightDeclare = @MassWeight;
            ELSE
                SET @WeightDeclare = @VolumetricWeight;

            IF @MassWeightChecked > @VolumetricWeightChecked
                SET @WeightChecked = @MassWeightChecked;
            ELSE
                SET @WeightChecked = @VolumetricWeightChecked;

            IF @WeightDeclare > @WeightChecked
                SET @WeightMax = @WeightDeclare;
            ELSE
                SET @WeightMax = @WeightChecked;

            --print 'peso maximo'
            --print @WeightMax

            --print 'pesosnull'
            --print @Pesos
            PRINT 'pesosnull1';
            PRINT @Pesos;
            IF (ISNULL(@Pesos, '') = '')
            BEGIN
                SET @Parcel = @PCode;
                SET @Pesos = CONVERT(VARCHAR, @WeightMax);


                PRINT 'pesosnull2';
                PRINT @Pesos;
            END;
            ELSE
            BEGIN
                --print 'pesos else'
                SET @Pesos = @Pesos + N',' + CONVERT(VARCHAR, @WeightMax);
                SET @Parcel = @Parcel + N',' + CONVERT(VARCHAR, @PCode);
            END;

            --print 'pesos'
            --print @Pesos
            --print 'parcel'
            --print @Parcel

            DELETE FROM #Pieces
            WHERE Id = @count;
            SET @count = @count + 1;

        END;
    END;
    ELSE
    BEGIN
        SET @Pesos = @ParPesos;
    END;

    PRINT 'Fin Pesos';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);

    DECLARE @IsCreditCard BIT = 'false';
    IF @ParIsCreditCard IS NULL
    BEGIN
        SET @IsCreditCard =
        (
            SELECT IIF(COUNT(*) > 0, 'true', 'false') AS result
            FROM dbo.Cost                        cst WITH (NOLOCK)
                LEFT JOIN dbo.BreakdownOfPayment br WITH (NOLOCK)
                    ON br.IdCost = cst.IdCost
            WHERE (
                      (
                          cst.GuideSerie = ISNULL(@GuideSerie, 'FD')
                          AND cst.GuideNumber = @GuideNumber
                      )
                      OR
                      (
                          cst.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                          AND cst.GuideSerie IS NULL
                          AND cst.GuideNumber IS NULL
                      )
                  )
                  AND
                  (
                      br.Description = 'Recargo por pago con tarjeta'
                      OR br.Description = 'Otros recargos'
                      OR br.Description = 'Otros cargos'
                  )
                  AND br.RowStatus = 'true'
                  AND br.Amount > 0
        );
    END;
    ELSE
    BEGIN
        SET @IsCreditCard = @ParIsCreditCard;
    END;
    PRINT 'Fin credit card';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);

    --select @IsCreditCard as IsCreditCard


    PRINT 'cliente';
    PRINT @IdCustomer;

    PRINT 'consultando datos';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);



    DECLARE @TempRate TABLE
    (
        TypeRate VARCHAR(50)
      , Segment VARCHAR(50)
      , Service VARCHAR(50)
      , Price DECIMAL(12, 2)
      , BaseRate DECIMAL(12, 2)
      , Discount DECIMAL(12, 2)
      , DiscountName VARCHAR(100)
      , FragilRate DECIMAL(12, 2)
      , CollectedRate DECIMAL(12, 2)
      , InsuranceRate DECIMAL(12, 2)
      , OverWeightRate DECIMAL(12, 2)
      , IrregularPieceRate DECIMAL(12, 2)
      , CreditCardRate DECIMAL(12, 2)
      , Taxes DECIMAL(12, 2)
      , FechaCompra DATETIME
      , Currency VARCHAR(10)
      , ReturnRate DECIMAL(12, 2)
    );

    PRINT 'pesos';
    PRINT @Pesos;

    --- Validar la tarifa del usuario antes de realizar cambios
    DECLARE @CustomerIdRate INT = 0;
    SELECT TOP 1
           @CustomerIdRate = RBC.RbcIdRate
    FROM [DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH (NOLOCK)
    WHERE RBC.RbcIdCustomer = @IdCustomer
          AND RBC.RbcRowStatus = 1;

    PRINT 'Tarifario';
    PRINT @CustomerIdRate;
    IF (@CustomerIdRate IN ( @NewMainRates, @NewAutoSalesMainRates ))
    BEGIN

        PRINT 'Piezas';
        PRINT @Parcel;

        PRINT 'Pesos de piezas';
        PRINT @Pesos;
        IF (LTRIM(RTRIM(REPLACE(@Parcel, ',', ''))) = '')
        BEGIN

            DECLARE @DataCounter INT = 1;

            SET @Parcel = N'EXP076';
            SET @Pesos = N'10';

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
    -- Verificar si la guía uso membresia
    IF (ISNULL(@UseMembership, 0) = 0) -- Se indica no usar membresia
    BEGIN
        -- Corroborar si guía si utilizo una membresia al ser generada
        SELECT @UseMembership = 1
        FROM [DeliveryBackOffice].[dbo].[MembershipSubscriptionLog] MSL WITH (NOLOCK)
        WHERE MSL.LogGuideNumber = @GuideNumber
              AND MSL.LogGuideSerie = @GuideSerie
              AND MSL.RowStatus = 1;
        -- Se considera que no se usa membresia
        IF (ISNULL(@UseMembership, 0) = 0)
            SET @UseMembership = 0;
    END;

	--select @CodeApp
 --                                        ,   @IdCustomer
 --                                        ,   @HeaderCodeDestiny
 --                                        ,   @HeaderCodeSource
 --                                        ,   'GT'
 --                                        ,   @PiecesCount
 --                                        ,   'false'
 --                                        ,   @IsCollect
 --                                        ,   @IsInsurance
 --                                        ,   @Pesos
 --                                        ,   @InsuranceAmount
 --                                        ,   @IsCreditCard
 --                                        ,   @Parcel
 --                                        ,   0
 --                                        ,   @AddressParse
 --                                        ,   @IdSettlement
 --                                        ,   0
 --                                        ,   @VisitPointClient
 --                                        ,   @VisitPointClientDestiny
 --                                        ,   @IdSalePipeLine
 --                                        ,   'DataTable'
 --                                        ,   @CalculateTaxes
 --                                        ,   @UseMembership
 --                                        ,   @TypeSubscriptionId
	--									 ,   @RevaluedGuide

    --select @Pesos , @Parcel
    INSERT INTO @TempRate
    EXECUTE [dbo].[spws_get_delivery_rate] @CodApp = @CodeApp
                                         , @IdCustomerParams = @IdCustomer
                                         , @HeaderCodeDestiny = @HeaderCodeDestiny
                                         , @HeaderCodeSource = @HeaderCodeSource
                                         , @Country = 'GT'
                                         , @CountPiecesParams = @PiecesCount
                                         , @IsFragile = 'false'
                                         , @IsCollected = @IsCollect
                                         , @IsInsurance = @IsInsurance
                                         , @WeigthParcels = @Pesos
                                         , @InsuranceAmount = @InsuranceAmount
                                         , @IsCreditCardPayment = @IsCreditCard
                                         , @ParcelCode = @Parcel
                                         , @Zone = 0
                                         , @AddressParse = @AddressParse
                                         , @IdSettlementSource = @IdSettlement
                                         , @IdSettlementDestiny = 0
                                         , @CodeOfReferenceSource = @VisitPointClient
                                         , @CodeOfReferenceDestiny = @VisitPointClientDestiny
                                         , @IdSalePipeLine = @IdSalePipeLine
                                         , @FormatResponse = 'DataTable'
                                         , @CalculateTaxes = @CalculateTaxes
                                         , @CalculateMembership = @UseMembership
                                         , @TypeSubscriptionId  = @TypeSubscriptionId
										 , @RevaluedGuide = @RevaluedGuide
  ---- select tp.*,@IdCustomer from @TempRate tp

    IF (@UseMembership = 1)
    BEGIN
        /* Membresias y Suscripciones */
        -- Oscar Morales 2022-07-21
        /* Actualización: Aplicar descuento únicamente a costo base 30-12-2022
		   Actualización: Aplicar descuento a (costo base + cobro por pago con tarjeta de crédito) cuando descuento por precio fijo sea = 0
		   Autor: Jerson Ochoa 
		   */
        DECLARE @PriceShippment DECIMAL(14, 2);
        DECLARE @MembershipId INT;
        DECLARE @ServiceValue DECIMAL(14, 2) = 0;
        DECLARE @DiscountMembership DECIMAL(18, 2) = 0;
        DECLARE @NewPriceShippment DECIMAL(14, 2);
        DECLARE @CatMembershipStatusId INT;
        DECLARE @DecriptionDiscount NVARCHAR(300);
        DECLARE @SubscriptionId INT;
        DECLARE @ServiceValueSubscription DECIMAL(14, 2) = 0;
        DECLARE @DiscountValue DECIMAL(5, 2);
        DECLARE @Type NVARCHAR(50);
        DECLARE @ServiceAppliedType INT; -- 1 MEMBRESÍA, 2 SUSCRIPCIÓN
        DECLARE @ServiceAppliedCount INT;
        DECLARE @MembershipSubscriptionLogId BIGINT;
        --DECLARE @DiscountDescription2 VARCHAR(100)
        --DECLARE @DiscountAnt DECIMAL(12,2)

        SELECT @PriceShippment = tr.Price + ABS(ISNULL(tr.Discount, 0)) --si tiene otro descuento
        FROM @TempRate tr
        WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
              OR @ServiceShortName = 'EXP';

        --buscar si ya se aplicó un descuento
        SELECT TOP 1
               @MembershipSubscriptionLogId = IdMembershipSubscriptionLog
             , @MembershipId                = MembershipId
             , @SubscriptionId              = SubscriptionId
             , @ServiceAppliedCount         = LogServiceNumber
        FROM MembershipSubscriptionLog
        WHERE LogGuideSerie = @GuideSerie
              AND LogGuideNumber = @GuideNumber
              AND RowStatus = 1
        ORDER BY DateCreated DESC;

        --si ya existe registro
        IF @MembershipSubscriptionLogId IS NOT NULL
        BEGIN
            IF @SubscriptionId IS NULL
            BEGIN
                SELECT @ServiceValue
                    = IIF(@ServiceAppliedCount <= ms.MembershipMaxServiceFixedValue, ms.MembershipFixedValue, -1)
                FROM Membership ms
                WHERE ms.IdMembership = @MembershipId;
				PRINT 'bidcar'
				PRINT @ServiceValue
                --Si es tarifa fija
                IF @ServiceValue >= 0
                BEGIN
                    SET @DiscountMembership = @PriceShippment - @ServiceValue;
                    SET @NewPriceShippment = @ServiceValue;

                    IF (@ServiceValue = 0)
                    BEGIN
                        SET @PriceWithCreditCard = 1;
                    END;
                END;
                ELSE
                BEGIN
                    --Se busca por rango de servicios
                    SELECT TOP 1
                           @DiscountValue = DiscountValue
                         , @Type          = cvt.ValueTypeName
                    FROM MembershipDiscountRange mdr
                        INNER JOIN Membership    ms
                            ON ms.IdMembership = mdr.MembershipId
                        INNER JOIN CatValueType  cvt
                            ON mdr.ValueTypeId = cvt.IdCatValueType
                    WHERE mdr.MembershipId = @MembershipId
                          AND
                          (
                              (@ServiceAppliedCount
                          BETWEEN mdr.DiscountLowServiceRange AND mdr.DiscountTopServiceRange
                              )
                              OR @ServiceAppliedCount >= mdr.DiscountLowServiceRange
                                 AND mdr.DiscountTopServiceRange IS NULL
                          )
                          AND mdr.RowStatus = 1
                    ORDER BY mdr.DateCreated DESC;

                    IF @DiscountValue IS NOT NULL
                    BEGIN
                        IF @Type = 'Porcentaje'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100);
                        END;
                        ELSE IF @Type = 'Monto'
                        BEGIN
                            SET @DiscountMembership = @DiscountValue;
                        END;
                        ELSE IF @Type = 'Servicio'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment;
                        END;

                        SET @NewPriceShippment = @PriceShippment - @DiscountMembership;

                        IF @NewPriceShippment < 0
                        BEGIN
                            SET @DiscountMembership = @PriceShippment;
                            SET @NewPriceShippment = 0;
                        END;
                    END;
                END;
            END;
            ELSE
            BEGIN
                SELECT TOP 1
                       @ServiceValueSubscription = scr.DiscountValue
                           --= IIF(@ServiceAppliedCount <= sc.SubscriptionMaxServiceFixedValue,
                           --   sc.SubscriptionFixedValue,
                           --   -1)
                FROM Subscription sc
				INNER JOIN  SubscriptionDiscountRange scr
				ON sc.IdSubscription = scr.SubscriptionId
                WHERE sc.IdSubscription = @SubscriptionId
				      And sc.RowStatus = 1
					  And sc.CatTypeSubscriptionId = @TypeSubscriptionId
					  AND @DateCreated <= sc.ExpirationDate
				PRINT 'bidcar2'
				PRINT @ServiceValueSubscription
				PRINT @TypeSubscriptionId
				PRINT @DateCreated
				PRINT @SubscriptionId

                --Si es tarifa fija
                IF @ServiceValueSubscription >= 0
                BEGIN
				DECLARE @NameTypeSubscrition2 VARCHAR(50);
					SET @NameTypeSubscrition2 =(SELECT CatTypeSubscriptionName FROM CatTypeSubscription WHERE IdCatTypeSubscription = @TypeSubscriptionId)
                    SET @DiscountMembership = @PriceShippment*(@ServiceValueSubscription/100)--@PriceShippment - @ServiceValueSubscription;
						IF(@NameTypeSubscrition2 = 'Porcentaje')
							BEGIN
							SET @NewPriceShippment = @PriceShippment-(@PriceShippment*(@ServiceValueSubscription/100));
							END
						ELSE IF (@NameTypeSubscrition2 = 'Monto Fijo')
							BEGIN
							SET @NewPriceShippment = @ServiceValueSubscription;
							END
					 --SET @NewPriceShippment = @ServiceValueSubscription;
                   
                    IF (@ServiceValueSubscription = 0)
                    BEGIN
                        SET @PriceWithCreditCard = 1;
                    END;
                END;
                ELSE
                BEGIN
                    --Se busca por rango de servicios
                    SELECT TOP 1
                           @DiscountValue = DiscountValue
                         , @Type          = cvt.ValueTypeName
                    FROM SubscriptionDiscountRange sdr
                        INNER JOIN Subscription    sc
                            ON sc.IdSubscription = sdr.SubscriptionId
                        INNER JOIN CatValueType    cvt
                            ON sdr.ValueTypeId = cvt.IdCatValueType
                    WHERE sdr.SubscriptionId = @SubscriptionId
                          AND
                          (
                              (@ServiceAppliedCount
                          BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange
                              )
                              OR @ServiceAppliedCount >= sdr.DiscountLowServiceRange
                                 AND sdr.DiscountTopServiceRange IS NULL
                          )
                          AND sdr.RowStatus = 1
                    ORDER BY sdr.DateCreated DESC;

                    IF @DiscountValue IS NOT NULL
                    BEGIN
                        IF @Type = 'Porcentaje'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100);
                        END;
                        ELSE IF @Type = 'Monto'
                        BEGIN
                            SET @DiscountMembership = @DiscountValue;
                        END;
                        ELSE IF @Type = 'Servicio'
                        BEGIN
                            SET @DiscountMembership = @PriceShippment;
                        END;

                        SET @NewPriceShippment = @PriceShippment - @DiscountMembership;

                        IF @NewPriceShippment < 0
                        BEGIN
                            SET @DiscountMembership = @PriceShippment;
                            SET @NewPriceShippment = 0;
                        END;
                    END;
                END;
            END;

            IF @DiscountMembership > 0
            BEGIN
                SET @DiscountMembership = @DiscountMembership * -1;
                UPDATE tr
                SET Discount = @DiscountMembership
                  , DiscountName = 'Descuento membresía'
                  , Price = @NewPriceShippment
                FROM @TempRate tr
                WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                      OR @ServiceShortName = 'EXP';

                IF @SetUpdate = 'true'
                BEGIN
                    UPDATE MembershipSubscriptionLog
                    SET LogGuideOriginalValue = @PriceShippment
                      , LogGuideNewValue = @NewPriceShippment
                      , TokenUpdated = @Token
                      , DateUpdated = GETDATE()
                    WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId;
                END;
            END;
        END;
        ELSE
        BEGIN
            --Se busca si existe una membresía activa
            SELECT TOP 1
                   @MembershipId          = ms.IdMembership
                 , @CatMembershipStatusId = ms.CatMembershipStatusId
                 , @ServiceValue
                                          = IIF(ms.ActualServiceCount + 1 <= ms.MembershipMaxServiceFixedValue, ms.MembershipFixedValue, -1)
            FROM Membership                      ms
                INNER JOIN CatSalesPackageStatus csps
                    ON csps.IdCatSalesPackageStatus = ms.CatMembershipStatusId
            WHERE ms.CustomerId = @IdCustomer
                  AND @DateCreated <= ms.ExpirationDate
                  AND ms.RowStatus = 1
                  AND csps.SalesPackageStatusName = 'Activa'
            ORDER BY ms.DateCreated DESC;

            --Si existe una membresía y la guía tiene precio
            IF @MembershipId IS NOT NULL
               AND @PriceShippment IS NOT NULL
               AND @PriceShippment > 0
            BEGIN

                --Si es tarifa fija
                IF @ServiceValue >= 0
                BEGIN
                    SET @DiscountMembership = @PriceShippment - @ServiceValue;
                    IF (@ServiceValue = 0)
                    BEGIN
                        SET @PriceWithCreditCard = 1;
                    END;
                    ELSE
                    BEGIN
                        SET @PriceWithCreditCard = 0;
                    END;

                    SET @NewPriceShippment = @ServiceValue;
                    SET @DecriptionDiscount = CONCAT('Tarifa fija membresía a ', @ServiceValue);
                    SET @ServiceAppliedType = 1;
                END;
                ELSE
                BEGIN
                    --Se busca suscripciones
					DECLARE @NameTypeSubscrition VARCHAR(50);
					SET @NameTypeSubscrition =(SELECT CatTypeSubscriptionName FROM CatTypeSubscription WHERE IdCatTypeSubscription = @TypeSubscriptionId)
					IF(@NameTypeSubscrition = 'Porcentaje')
						   BEGIN
								SELECT TOP 1
									   @SubscriptionId = sc.IdSubscription,
                                       @ServiceValueSubscription = sdr.DiscountValue
								FROM Subscription sc
									INNER JOIN CatSalesPackageStatus csps
										ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
									INNER JOIN SubscriptionDiscountRange sdr 
									  ON sc.IdSubscription = sdr.SubscriptionId
								WHERE sc.CustomerId = @IdCustomer
									  AND @DateCreated <= sc.ExpirationDate
									  AND sc.RowStatus = 1
									  AND csps.SalesPackageStatusName = 'Activa'
									  --AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
									  AND sc.CatTypeSubscriptionId = @TypeSubscriptionId
								  ORDER BY sdr.DiscountValue DESC
								--ORDER BY sc.ExpirationDate;
							END
					ELSE IF (@NameTypeSubscrition = 'Monto Fijo')
							BEGIN
									SELECT TOP 1
									   @SubscriptionId = sc.IdSubscription,
									   @ServiceValueSubscription = sdr.DiscountValue
										   --= IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue,
											  --sc.SubscriptionFixedValue,
											  ---1)
								FROM Subscription sc
									INNER JOIN CatSalesPackageStatus csps
										ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
									INNER JOIN SubscriptionDiscountRange sdr 
									    ON sc.IdSubscription = sdr.SubscriptionId
								WHERE sc.CustomerId = @IdCustomer
									  AND @DateCreated <= sc.ExpirationDate
									  AND sc.RowStatus = 1
									  AND csps.SalesPackageStatusName = 'Activa'
									  AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
									  AND sc.CatTypeSubscriptionId = @TypeSubscriptionId
								  ORDER BY sc.IdSubscription ASC
							END

                    --Si existe una suscripción
                    IF @SubscriptionId IS NOT NULL
                    BEGIN
                        --Si es tarifa fija
                        IF @ServiceValueSubscription >= 0
                        BEGIN
                            --SET @DiscountMembership = @PriceShippment - @ServiceValueSubscription;
							IF(@NameTypeSubscrition = 'Porcentaje')
							BEGIN
								SET @DiscountMembership = @PriceShippment*(@ServiceValueSubscription/100);
							END
							ELSE IF (@NameTypeSubscrition = 'Monto Fijo')
							BEGIN
									SET @DiscountMembership = @PriceShippment
							END


                            IF (@ServiceValueSubscription = 0)
                            BEGIN
                                SET @PriceWithCreditCard = 1;
                            END;
                            ELSE
                            BEGIN
                                SET @PriceWithCreditCard = 0;
                            END;
							IF(@NameTypeSubscrition = 'Porcentaje')
							BEGIN
							SET @NewPriceShippment = @PriceShippment-(@PriceShippment*(@ServiceValueSubscription/100));
							END
						ELSE IF (@NameTypeSubscrition = 'Monto Fijo')
							BEGIN
							SET @NewPriceShippment = @ServiceValueSubscription;
							END


                            --SET @NewPriceShippment = @ServiceValueSubscription;
                            SET @DecriptionDiscount = CONCAT('Tarifa fija suscripción a ', @ServiceValueSubscription);
                            SET @ServiceAppliedType = 2;

							

                        END;
                        ELSE
                        BEGIN
                            --Se busca por rango de servicios
                            SELECT TOP 1
                                   @DiscountValue = DiscountValue
                                 , @Type          = cvt.ValueTypeName
                            FROM SubscriptionDiscountRange sdr
                                INNER JOIN Subscription    sc
                                    ON sc.IdSubscription = sdr.SubscriptionId
                                INNER JOIN CatValueType    cvt
                                    ON sdr.ValueTypeId = cvt.IdCatValueType
                            WHERE sdr.SubscriptionId = @SubscriptionId
                                  AND
                                  (
                                      (sc.ActualServiceCount + 1
                                  BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange
                                      )
                                      OR sc.ActualServiceCount + 1 >= sdr.DiscountLowServiceRange
                                         AND sdr.DiscountTopServiceRange IS NULL
                                  )
                                  AND sdr.RowStatus = 1
                            ORDER BY sdr.DateCreated DESC;

                            IF @DiscountValue IS NOT NULL
                            BEGIN
                                IF @Type = 'Porcentaje'
                                BEGIN
                                    SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100);
                                    SET @DecriptionDiscount
                                        = CONCAT('Por rango de servicios suscripción, porcentaje ', @DiscountValue);
                                    SET @ServiceAppliedType = 2;
                                END;
                                ELSE IF @Type = 'Monto'
                                BEGIN
                                    SET @DiscountMembership = @DiscountValue;
                                    SET @DecriptionDiscount
                                        = CONCAT('Por rango de servicios suscripción, monto ', @DiscountValue);
                                    SET @ServiceAppliedType = 2;
                                END;
                                ELSE IF @Type = 'Servicio'
                                BEGIN
                                    SET @DiscountMembership = @PriceShippment;
                                    SET @DecriptionDiscount
                                        = CONCAT('Por rango de servicios suscripción, servicio ', @PriceShippment);
                                    SET @ServiceAppliedType = 2;
                                END;

                                SET @NewPriceShippment = @PriceShippment - @DiscountMembership;

                                IF @NewPriceShippment < 0
                                BEGIN
                                    SET @DiscountMembership = @PriceShippment;
                                    SET @NewPriceShippment = 0;
                                END;
                            END;
                        END;
                    END;

                    IF @SubscriptionId IS NULL
                       OR @ServiceAppliedType IS NULL
                    BEGIN
                        SET @DiscountValue = NULL;
                        SET @Type = NULL;

                        --Se busca por rango de servicios
                        SELECT TOP 1
                               @DiscountValue = DiscountValue
                             , @Type          = cvt.ValueTypeName
                        FROM MembershipDiscountRange mdr
                            INNER JOIN Membership    ms
                                ON ms.IdMembership = mdr.MembershipId
                            INNER JOIN CatValueType  cvt
                                ON mdr.ValueTypeId = cvt.IdCatValueType
                        WHERE mdr.MembershipId = @MembershipId
                              AND
                              (
                                  (ms.ActualServiceCount + 1
                              BETWEEN mdr.DiscountLowServiceRange AND mdr.DiscountTopServiceRange
                                  )
                                  OR ms.ActualServiceCount + 1 >= mdr.DiscountLowServiceRange
                                     AND mdr.DiscountTopServiceRange IS NULL
                              )
                              AND mdr.RowStatus = 1
                        ORDER BY mdr.DateCreated DESC;

                        IF @DiscountValue IS NOT NULL
                        BEGIN
                            IF @Type = 'Porcentaje'
                            BEGIN
                                SET @DiscountMembership = @PriceShippment * (@DiscountValue / 100);
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios membresía, porcentaje ', @DiscountValue);
                                SET @ServiceAppliedType = 1;
                            END;
                            ELSE IF @Type = 'Monto'
                            BEGIN
                                SET @DiscountMembership = @DiscountValue;
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios membresía, monto ', @DiscountValue);
                                SET @ServiceAppliedType = 1;
                            END;
                            ELSE IF @Type = 'Servicio'
                            BEGIN
                                SET @DiscountMembership = @PriceShippment;
                                SET @DecriptionDiscount
                                    = CONCAT('Por rango de servicios membresía, servicio ', @PriceShippment);
                                SET @ServiceAppliedType = 1;
                            END;

                            SET @NewPriceShippment = @PriceShippment - @DiscountMembership;

                            IF @NewPriceShippment < 0
                            BEGIN
                                SET @DiscountMembership = @PriceShippment;
                                SET @NewPriceShippment = 0;
                            END;
                        END;
                    END;
                END;

                IF @DiscountMembership > 0
                BEGIN
                    SET @DiscountMembership = @DiscountMembership * -1;

                    UPDATE tr
                    SET Discount = @DiscountMembership
                      , DiscountName = 'Descuento membresía'
                      , Price = @NewPriceShippment
                    FROM @TempRate tr
                    WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                          OR @ServiceShortName = 'EXP';

                    IF @SetUpdate = 'true'
                    BEGIN

                        IF @ServiceAppliedType = 1
                        BEGIN
                            --Actualizar contador membresía
                            UPDATE Membership
                            SET ActualServiceCount = ActualServiceCount + 1
                              , @ServiceAppliedCount = ActualServiceCount + 1
                              , TokenUpdated = @Token
                              , DateUpdated = GETDATE()
                            WHERE IdMembership = @MembershipId;
                        END;
                        ELSE
                        BEGIN
                            --Actualizar contador sucripción
                            UPDATE Subscription
                            SET ActualServiceCount = ActualServiceCount + 1
                              , @ServiceAppliedCount = ActualServiceCount + 1
                              , TokenUpdated = @Token
                              , DateUpdated = GETDATE()
                            WHERE IdSubscription = @SubscriptionId;
                        END;

                        SET @DecriptionDiscount
                            = CONCAT('Se aplicó descuento de membresía y suscripción (', @DecriptionDiscount, ')');
                        --Insertar log
                        INSERT INTO [dbo].[MembershipSubscriptionLog]
                        (
                            [SystemId]
                          , [ModuleId]
                          , [MembershipId]
                          , [SubscriptionId]
                          , [SalesPackageStatusId]
                          , [StationId]
                          , [CustomerId]
                          , [AccountId]
                          , [VisitPointClientId]
                          , [LogActionDescription]
                          , [LogGuideSerie]
                          , [LogGuideNumber]
                          , [LogGuideOriginalValue]
                          , [LogGuideNewValue]
                          , [RowStatus]
                          , [TokenCreated]
                          , [DateCreated]
                          , [TokenUpdated]
                          , [DateUpdated]
                          , [LogServiceNumber]
                        )
                        VALUES
                        ((
                             SELECT TOP 1 SysIdSystem FROM CatSystem WHERE SysNameSystem = 'Parser'
                         ), (
                                SELECT TOP 1 ModIdModule FROM CatModule WHERE ModPath = 'Parser'
                            ), @MembershipId, IIF(@ServiceAppliedType = 1, NULL, @SubscriptionId)
                       , @CatMembershipStatusId, NULL, @IdCustomer, NULL, NULL, @DecriptionDiscount, @GuideSerie
                       , @GuideNumber, @PriceShippment, @NewPriceShippment, 1, @Token, GETDATE(), NULL, NULL
                       , @ServiceAppliedCount);
                    END;
                END;
            END;
        END;

    END;
    /* Termina membresías y suscripciones */

    PRINT 'inicio de actualizacion de datos';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    IF @SetUpdate = 'true' -- indica que se guardaran los cambios en la guia de trasporte
    BEGIN

        DECLARE @NewPrice DECIMAL(12, 2) = 0;
        DECLARE @BaseRate DECIMAL(12, 2) = 0;
        DECLARE @Discount DECIMAL(12, 2) = 0;
        DECLARE @DiscountDescription VARCHAR(100) = '';
        DECLARE @FragilRate DECIMAL(12, 2) = 0;
        DECLARE @CollectedRate DECIMAL(12, 2) = 0;
        DECLARE @InsuranceRate DECIMAL(12, 2) = 0;
        DECLARE @OverWeightRate DECIMAL(12, 2) = 0;
        DECLARE @IrregularPiece DECIMAL(12, 2) = 0;
        DECLARE @CreditCardRate DECIMAL(12, 2) = 0;
        DECLARE @Taxes DECIMAL(12, 2) = 0;
        DECLARE @ReturnAmount DECIMAL(12, 2);

        DECLARE @RESULT AS NVARCHAR(MAX);
        PRINT 'precio';
        PRINT @NewPrice;

        PRINT 'servicio';
        PRINT @ServiceShortName;

        SELECT @NewPrice
                                    = IIF(@PriceWithCreditCard = 1
                                        , (ISNULL(tr.Price, 0) + ISNULL(tr.FragilRate, 0) + ISNULL(tr.CollectedRate, 0)
                                           + ISNULL(tr.InsuranceRate, 0) + ISNULL(tr.OverWeightRate, 0)
                                          )
                                        , (ISNULL(tr.Price, 0) + ISNULL(tr.FragilRate, 0) + ISNULL(tr.CollectedRate, 0)
                                           + ISNULL(tr.InsuranceRate, 0) + ISNULL(tr.OverWeightRate, 0) + ISNULL(tr.CreditCardRate, 0)
                                          ))
             , @BaseRate            = ISNULL(tr.BaseRate, 0)
             , @Discount            = ISNULL(tr.Discount, 0)
             , @DiscountDescription = ISNULL(tr.DiscountName, '')
             , @FragilRate          = ISNULL(tr.FragilRate, 0)
             , @CollectedRate       = ISNULL(tr.CollectedRate, 0)
             , @InsuranceRate       = ISNULL(tr.InsuranceRate, 0)
             , @OverWeightRate      = ISNULL(tr.OverWeightRate, 0)
             , @IrregularPiece      = ISNULL(tr.IrregularPieceRate, 0)
             , @CreditCardRate      = ISNULL(tr.CreditCardRate, 0)
             , @Taxes               = ISNULL(tr.Taxes, 0)
             , @ReturnAmount        = IIF(@IsReturn = 'TRUE', (tr.Price * ISNULL(tr.ReturnRate, 0) / 100), 0)
        FROM @TempRate tr
        WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
              OR @ServiceShortName = 'EXP';
        PRINT 'precio devolucion ';
        PRINT @ReturnAmount;

        PRINT 'precio';
        PRINT @NewPrice;

        IF @NewPrice = 0
        BEGIN
            SELECT TOP 1
                   @NewPrice
                                        = IIF(@PriceWithCreditCard = 1
                                            , (ISNULL(tr.Price, 0) + ISNULL(tr.FragilRate, 0) + ISNULL(tr.CollectedRate, 0)
                                               + ISNULL(tr.InsuranceRate, 0) + ISNULL(tr.OverWeightRate, 0)
                                              )
                                            , (ISNULL(tr.Price, 0) + ISNULL(tr.FragilRate, 0) + ISNULL(tr.CollectedRate, 0)
                                               + ISNULL(tr.InsuranceRate, 0) + ISNULL(tr.OverWeightRate, 0) + ISNULL(tr.CreditCardRate, 0)
                                              ))
                 , @BaseRate            = ISNULL(tr.BaseRate, 0)
                 , @Discount            = ISNULL(tr.Discount, 0)
                 , @DiscountDescription = ISNULL(tr.DiscountName, '')
                 , @FragilRate          = ISNULL(tr.FragilRate, 0)
                 , @CollectedRate       = ISNULL(tr.CollectedRate, 0)
                 , @InsuranceRate       = ISNULL(tr.InsuranceRate, 0)
                 , @OverWeightRate      = ISNULL(tr.OverWeightRate, 0)
                 , @IrregularPiece      = ISNULL(tr.IrregularPieceRate, 0)
                 , @CreditCardRate      = ISNULL(tr.CreditCardRate, 0)
                 , @Taxes               = ISNULL(tr.Taxes, 0)
            FROM @TempRate tr
            ORDER BY tr.Price ASC;

        END;


        -- Actualizar campos de delivery order
        UPDATE DeliveryOrder
        SET IsCollect = @IsCollect
          , IsInsuarance = @IsInsurance
          , InsuranceAmount = @InsuranceAmount
          , PriceShippment = @NewPrice
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber;

        -- Actualizar pesos de piezas
        PRINT 'guardando  tabla costos';
        PRINT CONVERT(VARCHAR, GETDATE(), 9);
        -- Guardar Costos

        DECLARE @TblCost [dbo].[TblNewChangeList];

        INSERT INTO @TblCost
        (
            RowNumber
          , [Description]
          , [Amount]
          , [ModIdModule]
          , [RowStatus]
          , [TokenCreated]
          , [BreakdownOfPaymentTypeId]
        )
        VALUES
        (1, 'Servicio', (@BaseRate + @IrregularPiece), @IdModule, 'true', @Token, 1)
      , (2, 'Frágil', @FragilRate, @IdModule, 'true', @Token, 2)
      , (3, 'Seguro', @InsuranceRate, @IdModule, 'true', @Token, 3)
      , (4, 'Pago en Destino', @CollectedRate, @IdModule, 'true', @Token, 4)
      , (5, 'Recargo por Peso', @OverWeightRate, @IdModule, 'true', @Token, 5)
      , (6, 'Otros cargos', @CreditCardRate, @IdModule, 'true', @Token, 6)
      , (7, @DiscountDescription, @Discount, @IdModule, 'true', @Token, NULL)
      , (8, 'IVA', @Taxes, @IdModule, 'true', @Token, 7);

        DECLARE @ProdctNumber VARCHAR(49) = @GuideSerie + CONVERT(VARCHAR, @GuideNumber);
        --select * from @TblCost	
        DECLARE @TBLRESULT TABLE
        (
            RESULT NVARCHAR(MAX)
        );

        --	INSERT INTO @TBLRESULT

        PRINT 'guardando costos';
        PRINT CONVERT(VARCHAR, GETDATE(), 9);

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
        DECLARE @CostPaid DECIMAL(18, 2);

        IF EXISTS
        (
            SELECT TOP 1
                   cst.ProductNumber
            FROM dbo.Cost cst WITH (NOLOCK)
            WHERE (
                      (
                          cst.GuideSerie = ISNULL(@GuideSerie, 'FD')
                          AND cst.GuideNumber = @GuideNumber
                      )
                      OR
                      (
                          cst.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                          AND cst.GuideSerie IS NULL
                          AND cst.GuideNumber IS NULL
                      )
                  )
                  AND cst.RowStatus = 1
        )
        BEGIN
            PRINT 'existe';
            PRINT CONVERT(VARCHAR, GETDATE(), 9);

            SELECT TOP 1
                   @IdCost   = cst.IdCost
                 , @CostPaid = cst.TotalAmountPaid
            FROM dbo.Cost cst WITH (NOLOCK)
            WHERE (
                      (
                          cst.GuideSerie = ISNULL(@GuideSerie, 'FD')
                          AND cst.GuideNumber = @GuideNumber
                      )
                      OR
                      (
                          cst.ProductNumber = CONCAT(ISNULL(@GuideSerie, 'FD'), @GuideNumber)
                          AND cst.GuideSerie IS NULL
                          AND cst.GuideNumber IS NULL
                      )
                  )
                  AND cst.RowStatus = 1
            ORDER BY cst.DateCreated DESC;

            -- No ha sido pagado y es posible alterar el costo
            IF (ISNULL(@CostPaid, 0) = 0)
            BEGIN

                PRINT 'Actualizando costo';
                PRINT CONVERT(VARCHAR, GETDATE(), 9);
                UPDATE dbo.Cost
                SET TotalAmount = @NewPrice
                  , TokenUpdated = @Token
                  , DateUpdated = GETDATE()
                  , GuideSerie = @GuideSerie
                  , GuideNumber = @GuideNumber
                WHERE IdCost = @IdCost;
                PRINT 'guardando en breackdown';
                PRINT CONVERT(VARCHAR, GETDATE(), 9);
                INSERT INTO [dbo].[BreakdownOfPayment]
                (
                    [IdCost]
                  , [Description]
                  , [Amount]
                  , [ModIdModule]
                  , [RowStatus]
                  , [TokenCreated]
                  , [DateCreated]
                  , [BreakdownOfPaymentTypeId]
                )
                SELECT @IdCost
                     , det.Description
                     , det.Amount
                     , det.ModIdModule
                     , 1 -- crear registro activo por default
                     , det.TokenCreated
                     , GETDATE()
                     , det.BreakdownOfPaymentTypeId
                FROM @TblCost                        det
                    LEFT JOIN dbo.BreakdownOfPayment bk WITH (NOLOCK)
                        ON bk.IdCost = @IdCost
                           AND bk.Description = det.Description
                WHERE bk.IdBreakdownOfPayment IS NULL
                      AND ABS(det.Amount) > 0;


                PRINT 'actualizando en breackdown';
                PRINT CONVERT(VARCHAR, GETDATE(), 9);
                -- actualizar los registros que si existen 
                UPDATE dbo.BreakdownOfPayment
                SET Amount = det.Amount
                  , RowStatus = det.RowStatus
                  , DateUpdated = GETDATE()
                FROM dbo.Cost                         cs
                    INNER JOIN dbo.BreakdownOfPayment bk
                        ON bk.IdCost = cs.IdCost
                    INNER JOIN @TblCost               det
                        ON det.Description = bk.Description
                WHERE cs.IdCost = @IdCost;

            END;
        END;
        ELSE
        BEGIN
            PRINT 'registro no existe , hay que crearlo';
            INSERT INTO dbo.Cost
            (
                IdProduct
              , ProductNumber
              , IdTypeCharge
              , TotalAmount
              , IdModule
              , RowStatus
              , TokenCreated
              , DateCreated
              , GuideSerie
              , GuideNumber
            )
            VALUES
            (   1, @ProdctNumber, 1     -- costo de envio
              , @NewPrice, @IdModule, 1 -- guardar los registros como activos 
              , @Token, GETDATE(), ISNULL(@GuideSerie, 'FD'), @GuideNumber);

            SET @IdCost = SCOPE_IDENTITY();

            INSERT INTO [dbo].[BreakdownOfPayment]
            (
                [IdCost]
              , [Description]
              , [Amount]
              , [ModIdModule]
              , [RowStatus]
              , [TokenCreated]
              , [DateCreated]
              , [BreakdownOfPaymentTypeId]
            )
            SELECT @IdCost
                 , det.Description
                 , det.Amount
                 , det.ModIdModule
                 , 1 -- crear registro activo por default
                 , det.TokenCreated
                 , GETDATE()
                 , det.BreakdownOfPaymentTypeId
            FROM @TblCost det
            WHERE ABS(det.Amount) > 0;
        END;




        PRINT 'costos guardados';
        PRINT CONVERT(VARCHAR, GETDATE(), 9);

    END;
    PRINT 'format';
    PRINT @Format;
    IF @Format = 'json'
    BEGIN
        DECLARE @jsonResult AS NVARCHAR(MAX);

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Title":"' + ISNULL(tr.Service, '') + '",' + '"Title":"'
                                       + ISNULL(tr.Service, '') + '",' + '"Service":"' + ISNULL(tr.Segment, '') + '",'
                                       + '"ServiceDescription":"' + ISNULL(tr.Service, '') + '",'
                                       + '"ServiceShortName":"' + ISNULL(tr.Service, '') + '",' + '"DeliveryDate":"'
                                       + CONVERT(VARCHAR(24), tr.FechaCompra, 120) + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20)
                                                  , CONVERT(
                                                               DECIMAL(12, 2)
                                                             , (tr.BaseRate + tr.Discount + tr.FragilRate
                                                                + tr.CollectedRate + tr.InsuranceRate
                                                                + tr.CreditCardRate + tr.OverWeightRate
                                                                + tr.IrregularPieceRate
                                                               )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '",' + '"OldPrice":"'
                                       + CONVERT(VARCHAR(20), @OldPrice) + '",' + '"Integration":[{"Description":"'
                                       + 'Servicio' + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20)
                                                  , CONVERT(
                                                               DECIMAL(12, 2)
                                                             , dbo.fnt_Iva_Calculator(
                                                                                         @CalculateTaxes
                                                                                       , 'GT'
                                                                                       , tr.BaseRate
                                                                                         + tr.IrregularPieceRate
                                                                                       , 'false'
                                                                                     )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                       + IIF(tr.FragilRate > 0
                                           , ',{"Description":"' + 'Frágil' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20)
                                                        , CONVERT(
                                                                     DECIMAL(12, 2)
                                                                   , dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes
                                                                                             , 'GT'
                                                                                             , tr.FragilRate
                                                                                             , 'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                           , ' ')
                                       + IIF(tr.InsuranceRate > 0
                                           , ',{"Description":"' + 'Seguro' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20)
                                                        , CONVERT(
                                                                     DECIMAL(12, 2)
                                                                   , dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes
                                                                                             , 'GT'
                                                                                             , tr.InsuranceRate
                                                                                             , 'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                           , ' ')
                                       + IIF(tr.CollectedRate > 0
                                           , ',{"Description":"' + 'Pago en Destino' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20)
                                                        , CONVERT(
                                                                     DECIMAL(12, 2)
                                                                   , dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes
                                                                                             , 'GT'
                                                                                             , tr.CollectedRate
                                                                                             , 'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                           , ' ')
                                       + IIF((tr.OverWeightRate) > 0
                                           , ',{"Description":"' + 'Recargo por Peso' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20)
                                                        , CONVERT(
                                                                     DECIMAL(12, 2)
                                                                   , dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes
                                                                                             , 'GT'
                                                                                             , tr.OverWeightRate
                                                                                             , 'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                           , ' ')
                                       + IIF((tr.CreditCardRate) > 0
                                           , ',{"Description":"' + 'Otros cargos' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20)
                                                        , dbo.fnt_Iva_Calculator(
                                                                                    @CalculateTaxes
                                                                                  , 'GT'
                                                                                  , tr.CreditCardRate
                                                                                  , 'false'
                                                                                )
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}'
                                           , ' ')
                                       + IIF((ABS(ISNULL(tr.Discount, 0))) > 0
                                           , ',{"Description":"' + ISNULL(tr.DiscountName, '') + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR
                                                        , CAST((dbo.fnt_Iva_Calculator(
                                                                                          @CalculateTaxes
                                                                                        , 'GT'
                                                                                        , (tr.Discount)
                                                                                        , 'false'
                                                                                      )
                                                               ) AS DECIMAL(18, 2))
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}'
                                           , ' ') + ',{"Description":"' + 'IVA' + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20)
                                                  , CONVERT(
                                                               DECIMAL(12, 2)
                                                             , dbo.fnt_Iva_Calculator(
                                                                                         @CalculateTaxes
                                                                                       , 'GT'
                                                                                       , (tr.BaseRate - tr.Discount
                                                                                          + tr.FragilRate
                                                                                          + tr.CollectedRate
                                                                                          + tr.InsuranceRate
                                                                                          + tr.CreditCardRate
                                                                                          + tr.OverWeightRate
                                                                                          + tr.IrregularPieceRate
                                                                                         )
                                                                                       , 'true'
                                                                                     )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '"' + '}' + ' ]}'
                                FROM @TempRate tr
                                WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                                      OR @ServiceShortName = 'EXP'
                                --	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );

        SELECT '[' + @jsonResult + ']';
    END;
    IF @Format = 'datatable'
    BEGIN

        SELECT ISNULL(tr.Price, 0)              [Price]
             , ISNULL(tr.BaseRate, 0)           [BaseRate]
             , ISNULL(tr.Discount, 0)           [Discount]
             , ISNULL(tr.DiscountName, '')      [DiscountName]
             , ISNULL(tr.FragilRate, 0)         [FragilRate]
             , ISNULL(tr.CollectedRate, 0)      [CollectedRate]
             , ISNULL(tr.InsuranceRate, 0)      [InsuranceRate]
             , ISNULL(tr.OverWeightRate, 0)     [OverWeightRate]
             , ISNULL(tr.IrregularPieceRate, 0) [IrregularPieceRate]
             , ISNULL(tr.CreditCardRate, 0)     [CreditCardRate]
             , ISNULL(tr.Taxes, 0)              [Taxes]
             , ISNULL(@OldPrice, 0)             [OldPrice]
             , ISNULL(tr.ReturnRate, 0)         [ReturnRate]
        --	, TR.TypeRate
        INTO #TempResult
        FROM @TempRate tr
        WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
              OR @ServiceShortName = 'EXP';

        DECLARE @HasData INT =
                (
                    SELECT COUNT(*)FROM #TempResult
                );
        PRINT 'precio';
        PRINT @HasData;
        IF @HasData = 0
        BEGIN
            SELECT TOP 1
                   ISNULL(tr.Price, 0)              [Price]
                 , ISNULL(tr.BaseRate, 0)           [BaseRate]
                 , ISNULL(tr.Discount, 0)           [Dicount]
                 , ISNULL(tr.DiscountName, '')      [DiscountName]
                 , ISNULL(tr.FragilRate, 0)         [FragilRate]
                 , ISNULL(tr.CollectedRate, 0)      [CollectedRate]
                 , ISNULL(tr.InsuranceRate, 0)      [InsuranceRate]
                 , ISNULL(tr.OverWeightRate, 0)     [OverWeightRate]
                 , ISNULL(tr.IrregularPieceRate, 0) [IrregularPieceRate]
                 , ISNULL(tr.CreditCardRate, 0)     [CreditCardRate]
                 , ISNULL(tr.Taxes, 0)              [Taxes]
                 , ISNULL(@OldPrice, 0)             [OldPrice]
                 , ISNULL(tr.ReturnRate, 0)         [ReturnRate]
            FROM @TempRate tr
            ORDER BY tr.Price ASC;
        END;
        ELSE
        BEGIN
            SELECT *
            FROM #TempResult;
        END;
    END;



    IF OBJECT_ID('tempdb.dbo.#TempResult', 'U') IS NOT NULL
        DROP TABLE #TempResult;
END;