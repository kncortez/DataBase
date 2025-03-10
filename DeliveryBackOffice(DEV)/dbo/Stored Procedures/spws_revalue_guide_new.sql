

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
-- Author:		<Cristian, Suazo>
-- Create date: <2024-06-11>
-- Description:	<Agrega el tipo de moneda origen y destino, dependiendo del pais >
-- =============================================
-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2024-08-12>
-- Description:	<Modificación de forma dinamica los códigos para los articulos filtrado por país.>
-- =============================================
-- =============================================
-- Author:		<Cristian, Suazo>
-- Create date: <2025-03-10>
-- Description:	<Se pasa a entidades la respuesta del Json para el proyecto de compatibilidad de BD>
-- =============================================
CREATE PROCEDURE [dbo].[spws_revalue_guide_new]
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
  , @CategoryProductId AS INT = 0
  , @ProductId AS INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
		DECLARE @TypeSubscriptionId  AS INT = 1
    SET NOCOUNT ON;
		IF(@UseMembership = 0/* OR @TypeSubscriptionId = 0 */)
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
	DECLARE @ReceiverCountryId NVARCHAR(2);
	DECLARE @SenderCountryId NVARCHAR(2);

	DECLARE @IdKindOfVPClient AS INT = 0;

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
		 , @IdKindOfVPClient		= VPC.IdKindOfVPClient
		 , @ReceiverCountryId		= ISNULL(ord.ReceiverCountryId, 'GT')
		 , @SenderCountryId			= ISNULL(ord.SenderCountryId, 'GT')
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

    -- Variables "estaticas"
    DECLARE @NewMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar' AND CountryId = @ReceiverCountryId  --COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewAlternativeRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario destinos express center' AND CountryId = @ReceiverCountryId --COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewAutoSalesMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' AND CountryId = @ReceiverCountryId --COLLATE Latin1_General_CI_AI
            );

	PRINT 'origen';
    PRINT @HeaderCodeSource;
    PRINT 'destino';
    PRINT @HeaderCodeDestiny;

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
            WHERE ord.Guide_Serie = @GuideSerie
              AND ord.Guide_Number = @GuideNumber;
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
            WHERE ord.Guide_Serie = @GuideSerie
              AND ord.Guide_Number = @GuideNumber;
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
    CREATE NONCLUSTERED INDEX IX_Pieces_Id ON #Pieces (Id);

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
	  , CurrencyId int
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
            DECLARE @ParcelCode2 NVARCHAR(40);
            --SET @Parcel = N'EXP076';
            SET @Pesos = N'10';

            SELECT TOP 1 @Parcel = Code FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH(NOLOCK)
			WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle WITH(NOLOCK)
			WHERE  ArtName = 'Paquete pequeño' AND (IdCountry = @ReceiverCountryId OR (IdCountry IS NULL AND @ReceiverCountryId = 'GT')))

			SET @ParcelCode2 = @Parcel;

            IF (@DataCounter < @PiecesCount)
            BEGIN
                WHILE @DataCounter < @PiecesCount
                BEGIN

                    --SET @Parcel = CONCAT(@Parcel, ',EXP076');
                    SET @Parcel = CONCAT(@Parcel, ',' + @ParcelCode2);
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
    --select @Pesos , @Parcel
	------------------------------------------------------------------------------------------------------------------------------------
	/*
		Inicio FIx 20250603 Membersías y suscripciones
		Verifica los productos validos y activos del cliente
	*/
	IF @UseMembership=1
	BEGIN 
		Declare @IdAcount INT=(SELECT TOP 1 AccIdAccount FROM DBO.ACCOUNT where idCustomer=@IdCustomer and AccRowStatus=1)
		Declare @TechnicalDescription NVARCHAR(50);

		DECLARE  @ActiveProducts  TABLE 
		(
			StatusId INT,
			CatProductCategoryId INT,
			ProductId INT,
			ProductName NVARCHAR(50),
			ProductDescription NVARCHAR(300),
			IncludeCollect BIT
		);	
		INSERT INTO @ActiveProducts 
		EXEC ClientSubscriptionFetcher_Data @IdAccount=@IdAcount


		SELECT Top 1 @TechnicalDescription=TechnicalDescription FROM CatProductCategory
		WHERE IdCatProductCategory= @CategoryProductId
		and rowstatus=1

		declare @NewProductId INT=NULL;

		SELECT Top 1 @NewProductId=ProductId FROM @ActiveProducts 
		WHERE CatProductCategoryId=(SELECT IDCatProductCategory FROM CatProductCategory WHERE TechnicalDescription=@TechnicalDescription and rowstatus=1 and (IdCountry = @ReceiverCountryId OR (IdCountry IS NULL AND @ReceiverCountryId = 'GT')))
	
		IF(@NewProductId IS NULL)
		BEGIN
			SET @ProductId=0;
			SET  @CategoryProductId=0;
			SET @UseMembership=0;
		END
		ELSE
		BEGIN
			SET @ProductId=@NewProductId
		END
	END
    ELSE
    BEGIN 
        --Verificando si ya hace uso de alguna membresía o suscripción
        SELECT 
            @ProductId=ISNULL(SubscriptionId,MembershipId),
            @CategoryProductId= (
                CASE 
                    WHEN MembershipId IS NOT NULL THEN 1 
                    WHEN SubscriptionId IS NOT NULL THEN 2 
                END)
        FROM dbo.MembershipSubscriptionLog
        WHERE LogGuideNumber=@GuideNumber
            AND LogGuideSerie=@GuideSerie
        
        IF @ProductId >0 AND @CategoryProductId >0
        BEGIN 
            SET @UseMembership=1
        END
        ELSE
        BEGIN 
            SET @ProductId=0
            SET @CategoryProductId=0
            SET @UseMembership=0
        END
    END


	--FIN FIx 20250603
	------------------------------------------------------------------------------------------------------------------------------------

    INSERT INTO @TempRate
    EXECUTE [dbo].[spws_get_delivery_rate] @CodApp = @CodeApp
                                         , @IdCustomerParams = @IdCustomer
                                         , @HeaderCodeDestiny = @HeaderCodeDestiny
                                         , @HeaderCodeSource = @HeaderCodeSource
                                         , @Country = @ReceiverCountryId 
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
										 , @RevaluedGuide = @RevaluedGuide
										 , @CategoryProductId = @CategoryProductId
										 , @ProductId = @ProductId
										 , @FetchActivePRoduct=0										 

     IF (@UseMembership = 1 AND @CategoryProductId >0 AND @ProductId >0 )
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
		DECLARE @CategoryProductName VARCHAR (50);
        --DECLARE @DiscountDescription2 VARCHAR(100)
        --DECLARE @DiscountAnt DECIMAL(12,2)

		  SET @CategoryProductName =
            (
                SELECT TOP 1
                       TechnicalDescription
                FROM CatProductCategory WITH(NOLOCK)
                WHERE IdCatProductCategory = @CategoryProductId
            );

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
            --Si existe una membresía y la guía tiene precio
            --IF @MembershipId IS NOT NULL
            --   AND @PriceShippment IS NOT NULL
            --   AND @PriceShippment > 0
            --BEGIN
                    --Se busca suscripciones
					DECLARE @NameTypeSubscrition VARCHAR(50);
					--SET @NameTypeSubscrition =(SELECT CatTypeSubscriptionName 
					--FROM CatTypeSubscription WHERE IdCatTypeSubscription = @TypeSubscriptionId)
			 IF(@CategoryProductName <> 'Membresías')
					BEGIN
						SET @NameTypeSubscrition =(SELECT TOP 1 cts.CatTypeSubscriptionName
                FROM CatSubscription csp WITH (NOLOCK)
				INNER JOIN CatTypeSubscription cts WITH (NOLOCK)
				ON csp.CatTypeSubscriptionId = cts.IdCatTypeSubscription
				INNER JOIN CatProductCategory cpc WITH (NOLOCK)
				ON csp.CatProductCategoryId = cpc.IdCatProductCategory
                WHERE cpc.IdCatProductCategory  =  @CategoryProductId)
					END
			 ELSE
					BEGIN
						SET @NameTypeSubscrition =
						(
							SELECT TOP 1 cvt.ValueTypeName
								FROM CatValueType cvt WITH (NOLOCK)
								INNER JOIN MembershipDiscountRange mdr
								ON cvt.IdCatValueType = mdr.ValueTypeId
								INNER JOIN Membership mbs WITH (NOLOCK)
								ON mdr.MembershipId = mbs.IdMembership
								WHERE mbs.IdMembership = @ProductId)
					END


				IF (@CategoryProductName <> 'Membresías')
					BEGIN
							IF(@NameTypeSubscrition = 'Porcentaje')
								   BEGIN
										SELECT TOP 1
											   @SubscriptionId = sc.IdSubscription,
											   @ServiceValueSubscription = sdr.DiscountValue
										FROM Subscription sc WITH (NOLOCK)
											INNER JOIN CatSalesPackageStatus csps WITH (NOLOCK)
												ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
											INNER JOIN SubscriptionDiscountRange sdr WITH (NOLOCK)
											  ON sc.IdSubscription = sdr.SubscriptionId
											INNER JOIN CatSubscription cat WITH (NOLOCK)
											ON sc.CatSubscriptionId = cat.IdCatSubscription 
											INNER JOIN CatProductCategory cts WITH (NOLOCK)
											ON cat.CatProductCategoryId = cts.IdCatProductCategory

										WHERE sc.CustomerId = @IdCustomer
											  AND @DateCreated <= sc.ExpirationDate
											  AND sc.RowStatus = 1
											  AND csps.SalesPackageStatusName = 'Activa'
											  AND sc.IdSubscription = @ProductId
											  AND cts.IdCatProductCategory = @CategoryProductId
										  ORDER BY sdr.DiscountValue DESC
										--ORDER BY sc.ExpirationDate;
									END
							ELSE IF (@NameTypeSubscrition = 'Monto Fijo')
									BEGIN
											SELECT TOP 1
											   @SubscriptionId = sc.IdSubscription,
											   @ServiceValueSubscription = sdr.DiscountValue
										FROM Subscription sc WITH (NOLOCK)
											INNER JOIN CatSalesPackageStatus csps WITH (NOLOCK)
												ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
											INNER JOIN SubscriptionDiscountRange sdr WITH (NOLOCK)
												ON sc.IdSubscription = sdr.SubscriptionId
											INNER JOIN CatSubscription cat WITH (NOLOCK)
											ON sc.CatSubscriptionId = cat.IdCatSubscription
											INNER JOIN CatProductCategory cts WITH (NOLOCK)
											ON cat.CatProductCategoryId = cts.IdCatProductCategory
										WHERE sc.CustomerId = @IdCustomer
											  AND @DateCreated <= sc.ExpirationDate
											  AND sc.RowStatus = 1
											  AND csps.SalesPackageStatusName = 'Activa'
											  AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
											  AND sc.IdSubscription = @ProductId
											  AND cts.IdCatProductCategory = @CategoryProductId
										  ORDER BY sc.IdSubscription ASC
									END
					END
				ELSE
					BEGIN
										SELECT TOP 1
								@SubscriptionId = sc.IdMembership,
								@ServiceValueSubscription = scdr.DiscountValue
							FROM Membership sc WITH (NOLOCK)
								INNER JOIN CatSalesPackageStatus csps WITH (NOLOCK)
									ON csps.IdCatSalesPackageStatus = sc.CatMembershipStatusId
								INNER JOIN CatSubscription cat WITH (NOLOCK)
									ON sc.CatMembershipId = cat.IdCatSubscription
								INNER JOIN CatProductCategory cts WITH (NOLOCK)
									ON cat.CatProductCategoryId = cts.IdCatProductCategory
								INNER JOIN MembershipDiscountRange scdr WITH (NOLOCK)
									ON sc.IdMembership = scdr.MembershipId
							WHERE sc.CustomerId = @IdCustomer
								  AND GETDATE() <= sc.ExpirationDate
								  AND sc.RowStatus = 1
								  AND csps.SalesPackageStatusName = 'Activa'
								  AND sc.IdMembership = @ProductId
								  AND cts.IdCatProductCategory = @CategoryProductId
								  AND sc.MembershipMaxServiceFixedValue > sc.ActualServiceCount
							ORDER BY scdr.DiscountValue DESC
							
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
                            FROM SubscriptionDiscountRange sdr WITH (NOLOCK)
                                INNER JOIN Subscription    sc WITH (NOLOCK)
                                    ON sc.IdSubscription = sdr.SubscriptionId
                                INNER JOIN CatValueType    cvt WITH (NOLOCK)
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
                        FROM MembershipDiscountRange mdr WITH (NOLOCK)
                            INNER JOIN Membership    ms WITH (NOLOCK)
                                ON ms.IdMembership = mdr.MembershipId
                            INNER JOIN CatValueType  cvt WITH (NOLOCK)
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
                --END;

                IF @DiscountMembership >= 0
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
						DECLARE @MaxProduct INT = 0;
					     SET @MaxProduct = (SELECT MembershipMaxServiceFixedValue FROM Membership where IdMembership = @ProductId )
                        --IF @ServiceAppliedType = 1
						IF(@CategoryProductName = 'Membresías' AND @MaxProduct > 0)
                        BEGIN
                            --Actualizar contador membresía
                            UPDATE Membership
                            SET ActualServiceCount = ActualServiceCount + 1
                              , @ServiceAppliedCount = ActualServiceCount + 1
                              , TokenUpdated = @Token
                              , DateUpdated = GETDATE()
                            WHERE IdMembership = @ProductId--@MembershipId;
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
						IF(@CategoryProductName = 'Membresías')
							BEGIN
								DECLARE @MaxMembership INT = -1;

								IF (@NameTypeSubscrition = 'Porcentaje')
									BEGIN
										SET @MaxMembership = (SELECT COUNT(MembershipMaxServiceFixedValue) FROM Membership
										WHERE IdMembership = @ProductId
										AND MembershipMaxServiceFixedValue > 0
										AND MembershipMaxServiceFixedValue <> 0)
									END
								ELSE
									BEGIN
										SET @MaxMembership = (SELECT COUNT(MembershipMaxServiceFixedValue) FROM Membership
										WHERE IdMembership = @ProductId
										AND MembershipMaxServiceFixedValue > 0
										AND MembershipMaxServiceFixedValue > ActualServiceCount  AND MembershipMaxServiceFixedValue <> 0)
								    END


							END
						IF(@MaxMembership = 0)
							 BEGIN
								UPDATE tr
									 SET Discount = 0--@DiscountMembership
									   --, DiscountName = 'Descuento membresía'
									   , Price = @PriceShippment
									 FROM @TempRate tr
									 WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
									       OR @ServiceShortName = 'EXP';

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
								     ),IIF(@CategoryProductName = 'Membresías', @SubscriptionId, NULL), IIF(@CategoryProductName <> 'Membresías',@SubscriptionId, NULL)/*IIF(@ServiceAppliedType = 1, NULL, @SubscriptionId)*/
								, NULL, NULL, @IdCustomer, NULL, NULL, @DecriptionDiscount, @GuideSerie
								, @GuideNumber, @PriceShippment, @PriceShippment, 1, @Token, GETDATE(), NULL, NULL
								, @ServiceAppliedCount);

							 END
                       ELSE
							BEGIN
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
								     ), IIF(@CategoryProductName = 'Membresías', @SubscriptionId, NULL), IIF(@CategoryProductName <> 'Membresías',@SubscriptionId, NULL)
								, NULL, NULL, @IdCustomer, NULL, NULL, @DecriptionDiscount, @GuideSerie
								, @GuideNumber, @PriceShippment, IIF(@NewPriceShippment IS NULL,0,@NewPriceShippment), 1, @Token, GETDATE(), NULL, NULL
								, @ServiceAppliedCount);
							--END
							END
                    END;
                END;
            END;
       -- END;

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
		DECLARE @CurrencyId INT;

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
			 , @CurrencyId			= tr.CurrencyId
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
				 , @CurrencyId			= tr.CurrencyId
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

              --SELECT @NewPrice, @InsuranceAmount, @IsCollect

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
			DECLARE @CurrencyReceiver INT,
				    @ExchangeRateReceiver DECIMAL(12,6),
					@CurrencySender INT,
					@ExchangeSender DECIMAL(12,6)
			/******************DATOS DE MONEDA ORIGEN*************************/
			SELECT TOP 1 
				  @CurrencySender = C.IdCatCurrencyCOD, 
				  @ExchangeSender = CE.ExchangeRate
			FROM CurrencyExchangeRates CE 
			INNER JOIN CatCurrencyCOD C  ON C.IdCatCurrencyCOD = CE.SourceCurrency
			WHERE CodeISO LIKE ''+ @SenderCountryId +'%'
			ORDER BY CE.ExchangeDate DESC
			
            PRINT 'registro no existe , hay que crearlo';
			IF @ServiceShortName = 'COD'
			BEGIN
			PRINT 'ES COD'
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
				  , ShippingCurrency
				  , ShippingExchangeRate
				  , CodCurrency
				  , CodExchangeRate
				)
				VALUES
				(   1, @ProdctNumber, 1     -- costo de envio
				  , @NewPrice, @IdModule, 1 -- guardar los registros como activos 
				  , @Token, GETDATE(), ISNULL(@GuideSerie, 'FD'), @GuideNumber
				  , @CurrencySender, @ExchangeSender
				  , @CurrencySender, @ExchangeSender
				);
			END
			ELSE 
			BEGIN
			PRINT 'ES STD'
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
				  , ShippingCurrency
				  , ShippingExchangeRate				 
				)
				VALUES
				(   1, @ProdctNumber, 1     -- costo de envio
				  , @NewPrice, @IdModule, 1 -- guardar los registros como activos 
				  , @Token, GETDATE(), ISNULL(@GuideSerie, 'FD'), @GuideNumber
				  , @CurrencySender, @ExchangeSender				
				);
			END

            SET @IdCost = SCOPE_IDENTITY();

			if (@IdKindOfVPClient = 3 and @IsCollect = 0 ) --SI ES CONCESIONARIO y NO ES COLLECT DEBE QUEDAR REGISTRADO EL PAGO DE LA GUÍA
			BEGIN
				UPDATE DeliveryBackOffice.dbo.Cost
				SET PaymentDate = GETDATE()
				,TotalAmountPaid = @NewPrice
				WHERE IdCost = @IdCost
			END

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
        SELECT ISNULL(tr.Service, '') AS Title,
                ISNULL(tr.Segment, '') AS [Service], 
                ISNULL(tr.Service, '') AS ServiceDescription,
                ISNULL(tr.Service, '') AS ServiceShortName, 
                tr.FechaCompra AS DeliveryDate, 
                CONVERT(
                        DECIMAL(12, 2)
                        , (tr.BaseRate + tr.Discount + tr.FragilRate
                        + tr.CollectedRate + tr.InsuranceRate
                        + tr.CreditCardRate + tr.OverWeightRate
                        + tr.IrregularPieceRate
                        )
                    ) AS Price, 
					tr.Currency AS Currency, 
                @OldPrice AS OldPrice
        FROM @TempRate tr
        WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                OR @ServiceShortName = 'EXP'


		SELECT [Description],
			   Price
		FROM
		(
			SELECT 'Servicio' AS [Description],
				   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.BaseRate + tr.IrregularPieceRate, 'false') AS Price
			FROM @TempRate tr
			WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
				  OR @ServiceShortName = 'EXP'
			UNION ALL
			SELECT CASE
					   WHEN tr.FragilRate > 0 THEN
						   'Frágil'
					   WHEN tr.InsuranceRate > 0 THEN
						   'Seguro'
					   WHEN tr.CollectedRate > 0 THEN
						   'Pago en Destino'
					   WHEN tr.OverWeightRate > 0 THEN
						   'Recargo por Peso'
					   WHEN tr.CreditCardRate > 0 THEN
						   'Otros cargos'
					   WHEN ABS(ISNULL(tr.Discount, 0)) > 0 THEN
						   ISNULL(tr.DiscountName, '')
					   ELSE
						   NULL
				   END AS [Description],
				   CASE
					   WHEN tr.FragilRate > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.FragilRate, 'false')
					   WHEN tr.InsuranceRate > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.InsuranceRate, 'false')
					   WHEN tr.CollectedRate > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.CollectedRate, 'false')
					   WHEN tr.OverWeightRate > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.OverWeightRate, 'false')
					   WHEN tr.CreditCardRate > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.CreditCardRate, 'false')
					   WHEN ABS(ISNULL(tr.Discount, 0)) > 0 THEN
						   dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.Discount, 'false')
					   ELSE
						   NULL
				   END AS Price
			FROM @TempRate tr
			WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
				  OR @ServiceShortName = 'EXP'
			UNION ALL
			SELECT 'IVA' AS [Description],
				   dbo.fnt_Iva_Calculator(
											 @CalculateTaxes,
											 'GT',
											 (tr.BaseRate - tr.Discount + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate
											  + tr.CreditCardRate + tr.OverWeightRate + tr.IrregularPieceRate
											 ),
											 'true'
										 ) AS Price
			FROM @TempRate tr
			WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
				  OR @ServiceShortName = 'EXP'
		) DatTable
		WHERE [Description] IS NOT NULL
			  AND Price IS NOT NULL

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
