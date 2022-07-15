
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
    @GuideSerie VARCHAR(2) = 'FD',
    @GuideNumber INT = 200307,
    @CodeApp VARCHAR(50) = '',
    @Format AS NVARCHAR(20) = 'Datatable',
    @CalculateTaxes BIT = 'true',
    @IdModule INT = 1,
    @SetUpdate BIT = 'false',
    @Token VARCHAR(50) = 'spws_revalue_guide',
    @ParIsCollect BIT = NULL,
    @ParIsInsurance BIT = NULL,
    @ParInsuranceAmount DECIMAL(12, 2) = NULL,
    @ParIsCreditCard BIT = NULL,
    @ParPesos VARCHAR(400) = NULL,
    @IsReturn BIT = 'false'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

	-- Variables "estaticas"
	DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI);
	DECLARE @NewAutoSalesMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar autoventas' COLLATE Latin1_General_CI_AI);

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

    DECLARE @PiecesInOrder AS INT;


    DECLARE @OldPrice DECIMAL(12, 2);
    PRINT 'inicio carga inicial';
    ------ Carga inicial de datos ----------------------------------------------------------------------------
    SELECT @IdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID),
           @VisitPointClient = ord.Sender_ID,
           @VisitPointClientDestiny = ISNULL(ord.Receiver_ID, 0),
           @IdSettlement = ISNULL(ord.ReceiverIdSettlement, 0),
           @HeaderCodeSource = stwn.HeaderCode,
           @HeaderCodeDestiny = rtwn.HeaderCode,
           @IsCollect = ISNULL(@ParIsCollect, ISNULL(ord.IsCollect, 'false')),
           @IsInsurance = ISNULL(@ParIsInsurance, ISNULL(ord.IsInsuarance, 'false')),
           @InsuranceAmount = ISNULL(@ParInsuranceAmount, ISNULL(ord.InsuranceAmount, 0)),
           @AddressParse = ISNULL(ord.Receiver_Address, ''),
           @IdSalePipeLine = ISNULL(ord.SalePipeLineId, 0),
           @PiecesInOrder = (ISNULL(ord.Pieces_Dry, 0) + ISNULL(ord.Pieces_Cold, 0)),
           @OldPrice = ISNULL(ord.PriceShippment, 0),
           @ServiceShortName = ISNULL(ord.TypeService, 'NDD')
    FROM dbo.DeliveryOrder ord WITH (NOLOCK)
        LEFT JOIN dbo.Township stwn
            ON stwn.IdTownship = ord.SenderIdTownship
        LEFT JOIN dbo.Township rtwn
            ON rtwn.IdTownship = ord.ReceiverIdTownship
        LEFT JOIN dbo.VisitPointClient vpc
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
        FROM dbo.VisitPointClient vpc
        WHERE vpc.CustomerID = @IdCustomer;
    END;

    PRINT 'Fin determinar vp';
    PRINT CONVERT(VARCHAR, GETDATE(), 9);
    ---------------------Fin determinar vp---------------------------------------------------------------------
    -------------------- Determinar HeaderCode de Origen y Destino --------------------------------------------

    IF @HeaderCodeSource IS NULL
    BEGIN
        SELECT @HeaderCodeSource = twn.HeaderCode
        FROM dbo.VisitPointClient vpc
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = vpc.IdTownship
        WHERE vpc.CodeOfReference = @VisitPointClient;

        IF @HeaderCodeSource IS NULL
        BEGIN
            SELECT @HeaderCodeSource = twn.HeaderCode
            FROM dbo.DeliveryOrder ord
                LEFT JOIN dbo.Township twn
                    ON twn.TownshipName = ord.Sender_Town
            WHERE ord.Guide_Number = @GuideNumber;
        END;
    END;

    IF @HeaderCodeDestiny IS NULL
    BEGIN
        IF @HeaderCodeDestiny IS NULL
        BEGIN
            SELECT @HeaderCodeDestiny = twn.HeaderCode
            FROM dbo.DeliveryOrder ord
                LEFT JOIN dbo.Township twn
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

    SELECT ROW_NUMBER() OVER (ORDER BY ps.DateCreated) Id,
           ISNULL(ps.ParcelCode, ' ') [ParcelCode],
           ISNULL(ps.PiecePhysicalWeight, 0) [MassWeight],
           ISNULL(ps.PieceWeight, 0) [VolumetricWeight],
           ISNULL(ps.MassWeight, 0) [MassWeightChecked],
           ISNULL(ps.volumetricWeight, 0) [VolumetricWeightChecked]
    INTO #Pieces
    FROM dbo.DeliveryOrderPiece ps
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
            SELECT @MassWeight = pc.MassWeight,
                   @VolumetricWeight = pc.VolumetricWeight,
                   @MassWeightChecked = pc.MassWeightChecked,
                   @VolumetricWeightChecked = pc.VolumetricWeightChecked,
                   @PCode = pc.ParcelCode
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
            FROM dbo.Cost cst
                LEFT JOIN dbo.BreakdownOfPayment br
                    ON br.IdCost = cst.IdCost
            WHERE cst.IdProduct = 1
                  AND cst.ProductNumber = CONCAT('FD', @GuideNumber)
                  AND br.Description = 'Recargo por pago con tarjeta'
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
        TypeRate VARCHAR(50),
        Segment VARCHAR(50),
        Service VARCHAR(50),
        Price DECIMAL(12, 2),
        BaseRate DECIMAL(12, 2),
        Discount DECIMAL(12, 2),
        DiscountName VARCHAR(100),
        FragilRate DECIMAL(12, 2),
        CollectedRate DECIMAL(12, 2),
        InsuranceRate DECIMAL(12, 2),
        OverWeightRate DECIMAL(12, 2),
        IrregularPieceRate DECIMAL(12, 2),
        CreditCardRate DECIMAL(12, 2),
        Taxes DECIMAL(12, 2),
        FechaCompra DATETIME,
        Currency VARCHAR(10),
        ReturnRate DECIMAL(12, 2)
    );

    PRINT 'pesos';
    PRINT @Pesos;
	 
	--- Validar la tarifa del usuario antes de realizar cambios
	DECLARE @CustomerIdRate INT = 0;
	SELECT
		TOP 1
			@CustomerIdRate = RBC.RbcIdRate
	FROM
		[DeliveryBackOffice].[dbo].[RatebyCustomer] RBC WITH(NOLOCK)
	WHERE
		RBC.RbcIdCustomer = @IdCustomer
		AND
		RBC.RbcRowStatus = 1

	IF(@CustomerIdRate IN (@NewMainRates,@NewAutoSalesMainRates))
	BEGIN
	
		IF( LTRIM(RTRIM(REPLACE(@Parcel,',',''))) = '' )
		BEGIN
			
			DECLARE @DataCounter INT = 1;
			
			SET @Parcel = 'EXP076';
			SET @Pesos = '10';
			
			IF(@DataCounter < @PiecesCount)
			BEGIN
				WHILE @DataCounter < @PiecesCount
				BEGIN
					
					SET @Parcel = CONCAT(@Parcel,',EXP076');
					SET @Pesos = CONCAT(@Pesos,',10');

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
                                           @CalculateTaxes = @CalculateTaxes;



    --select tp.* from @TempRate tp

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

        SELECT @NewPrice = ISNULL(tr.Price, 0),
               @BaseRate = ISNULL(tr.BaseRate, 0),
               @Discount = ISNULL(tr.Discount, 0),
               @DiscountDescription = ISNULL(tr.DiscountName, ''),
               @FragilRate = ISNULL(tr.FragilRate, 0),
               @CollectedRate = ISNULL(tr.CollectedRate, 0),
               @InsuranceRate = ISNULL(tr.InsuranceRate, 0),
               @OverWeightRate = ISNULL(tr.OverWeightRate, 0),
               @IrregularPiece = ISNULL(tr.IrregularPieceRate, 0),
               @CreditCardRate = ISNULL(tr.CreditCardRate, 0),
               @Taxes = ISNULL(tr.Taxes, 0),
               @ReturnAmount = IIF(@IsReturn = 'TRUE', (tr.Price * ISNULL(tr.ReturnRate, 0) / 100), 0)
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
                   @NewPrice = ISNULL(tr.Price, 0),
                   @BaseRate = ISNULL(tr.BaseRate, 0),
                   @Discount = ISNULL(tr.Discount, 0),
                   @DiscountDescription = ISNULL(tr.DiscountName, ''),
                   @FragilRate = ISNULL(tr.FragilRate, 0),
                   @CollectedRate = ISNULL(tr.CollectedRate, 0),
                   @InsuranceRate = ISNULL(tr.InsuranceRate, 0),
                   @OverWeightRate = ISNULL(tr.OverWeightRate, 0),
                   @IrregularPiece = ISNULL(tr.IrregularPieceRate, 0),
                   @CreditCardRate = ISNULL(tr.CreditCardRate, 0),
                   @Taxes = ISNULL(tr.Taxes, 0)
            FROM @TempRate tr
            ORDER BY tr.Price ASC;

        END;


        -- Actualizar campos de delivery order
        UPDATE DeliveryOrder
        SET IsCollect = @IsCollect,
            IsInsuarance = @IsInsurance,
            InsuranceAmount = @InsuranceAmount,
            PriceShippment = @NewPrice
        WHERE Guide_Serie = @GuideSerie
              AND Guide_Number = @GuideNumber;

        -- Actualizar pesos de piezas
        PRINT 'guardando  tabla costos';
        PRINT CONVERT(VARCHAR, GETDATE(), 9);
        -- Guardar Costos

        DECLARE @TblCost [dbo].[TblChangeList];

        INSERT INTO @TblCost
        (
            RowNumber,
            [Description],
            [Amount],
            [ModIdModule],
            [RowStatus],
            [TokenCreated]
        )
        VALUES
        (1, 'Servicio', (@BaseRate + @IrregularPiece), @IdModule, 'true', @Token),
        (2, 'Frágil', @FragilRate, @IdModule, 'true', @Token),
        (3, 'Seguro', @InsuranceRate, @IdModule, 'true', @Token),
        (4, 'Pago en Destino', @CollectedRate, @IdModule, 'true', @Token),
        (5, 'Recargo por Peso', @OverWeightRate, @IdModule, 'true', @Token),
        (6, 'Recargo por pago con tarjeta', @CreditCardRate, @IdModule, 'true', @Token),
        (7, @DiscountDescription, @Discount, @IdModule, 'true', @Token),
        (8, 'IVA', @Taxes, @IdModule, 'true', @Token);

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

        IF EXISTS
        (
            SELECT cst.ProductNumber
            FROM dbo.Cost cst
            WHERE cst.IdProduct = 1
                  AND cst.ProductNumber = @ProdctNumber
                  AND ISNULL(cst.TotalAmountPaid, 0) = 0
        )
        BEGIN
            PRINT 'existe';
            PRINT CONVERT(VARCHAR, GETDATE(), 9);
            SET @IdCost =
            (
                SELECT cst.IdCost
                FROM dbo.Cost cst
                WHERE cst.IdProduct = 1
                      AND cst.ProductNumber = @ProdctNumber
                      AND ISNULL(cst.TotalAmountPaid, 0) = 0
            );

            PRINT 'Actualizando costo';
            PRINT CONVERT(VARCHAR, GETDATE(), 9);
            UPDATE dbo.Cost
            SET TotalAmount = @NewPrice,
                TokenUpdated = @Token,
                DateUpdated = GETDATE()
            WHERE IdCost = @IdCost;
            PRINT 'guardando en breackdown';
            PRINT CONVERT(VARCHAR, GETDATE(), 9);
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
                LEFT JOIN dbo.BreakdownOfPayment bk
                    ON bk.IdCost = @IdCost
                       AND bk.Description = det.Description
            WHERE bk.IdBreakdownOfPayment IS NULL
                  AND ABS(det.Amount) > 0;


            PRINT 'actualizando en breackdown';
            PRINT CONVERT(VARCHAR, GETDATE(), 9);
            -- actualizar los registros que si existen 
            UPDATE dbo.BreakdownOfPayment
            SET Amount = det.Amount,
                RowStatus = det.RowStatus,
                DateUpdated = GETDATE()
            FROM dbo.Cost cs
                JOIN dbo.BreakdownOfPayment bk
                    ON bk.IdCost = cs.IdCost
                JOIN @TblCost det
                    ON det.Description = bk.Description
            WHERE cs.IdCost = @IdCost;

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
            (   1, @ProdctNumber, 1,     -- costo de envio
                @NewPrice, @IdModule, 1, -- guardar los registros como activos 
                @Token, GETDATE());

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
            WHERE det.Amount > 0;
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
                                SELECT ',{"Title":"' + ISNULL(tr.Service, '') + '",' + '"Service":"'
                                       + ISNULL(tr.Segment, '') + '",' + '"ServiceDescription":"'
                                       + ISNULL(tr.Service, '') + '",' + '"ServiceShortName":"'
                                       + ISNULL(tr.Service, '') + '",' + '"DeliveryDate":"'
                                       + CONVERT(VARCHAR(24), tr.FechaCompra, 120) + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20),
                                                    CONVERT(
                                                               DECIMAL(12, 2),
                                                               (tr.BaseRate - tr.Discount + tr.FragilRate
                                                                + tr.CollectedRate + tr.InsuranceRate
                                                                + tr.CreditCardRate + tr.OverWeightRate
                                                                + tr.IrregularPieceRate
                                                               )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '",' + '"OldPrice":"'
                                       + CONVERT(VARCHAR(20), @OldPrice) + '",' + '"Integration":[{"Description":"'
                                       + 'Servicio' + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20),
                                                    CONVERT(
                                                               DECIMAL(12, 2),
                                                               dbo.fnt_Iva_Calculator(
                                                                                         @CalculateTaxes,
                                                                                         'GT',
                                                                                         tr.BaseRate
                                                                                         + tr.IrregularPieceRate,
                                                                                         'false'
                                                                                     )
                                                           )
                                                ) + '",' + '"Currency":"' + tr.Currency + '"' + '}'
                                       + IIF(tr.FragilRate > 0,
                                             ',{"Description":"' + 'Frágil' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.FragilRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + IIF(tr.InsuranceRate > 0,
                                             ',{"Description":"' + 'Seguro' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.InsuranceRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + IIF(tr.CollectedRate > 0,
                                             ',{"Description":"' + 'Pago en Destino' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.CollectedRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + IIF((tr.OverWeightRate) > 0,
                                             ',{"Description":"' + 'Recargo por Peso' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               tr.OverWeightRate,
                                                                                               'false'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + tr.Currency + '"' + '}',
                                             ' ')
                                       + IIF((tr.CreditCardRate) > 0,
                                             ',{"Description":"' + 'Recargo por pago con tarjeta' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          dbo.fnt_Iva_Calculator(
                                                                                    @CalculateTaxes,
                                                                                    'GT',
                                                                                    tr.CreditCardRate,
                                                                                    'false'
                                                                                )
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}',
                                             ' ')
                                       + IIF((ISNULL(tr.Discount, 0)) > 0,
                                             ',{"Description":"' + ISNULL(tr.DiscountName, '') + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR,
                                                          CAST((dbo.fnt_Iva_Calculator(
                                                                                          @CalculateTaxes,
                                                                                          'GT',
                                                                                          (tr.Discount * -1),
                                                                                          'false'
                                                                                      )
                                                               ) AS DECIMAL(18, 2))
                                                      ) + '",' + '"Currency":"' + COALESCE(tr.Currency, '') + '"' + '}',
                                             ' ') + ',{"Description":"' + 'IVA' + '",' + '"Price":"'
                                       + CONVERT(
                                                    VARCHAR(20),
                                                    CONVERT(
                                                               DECIMAL(12, 2),
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
                                FROM @TempRate tr
                                WHERE tr.Service = ISNULL(@ServiceShortName, 'NDD')
                                      OR @ServiceShortName = 'EXP'
                                --	where us.UsrEmail = @UserName and us.UsrRowStatus = 1 
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

        SELECT '[' + @jsonResult + ']';
    END;
    IF @Format = 'datatable'
    BEGIN

        SELECT ISNULL(tr.Price, 0) [Price],
               ISNULL(tr.BaseRate, 0) [BaseRate],
               ISNULL(tr.Discount, 0) [Dicount],
               ISNULL(tr.DiscountName, '') [DiscountName],
               ISNULL(tr.FragilRate, 0) [FragilRate],
               ISNULL(tr.CollectedRate, 0) [CollectedRate],
               ISNULL(tr.InsuranceRate, 0) [InsuranceRate],
               ISNULL(tr.OverWeightRate, 0) [OverWeightRate],
               ISNULL(tr.IrregularPieceRate, 0) [IrregularPieceRate],
               ISNULL(tr.CreditCardRate, 0) [CreditCardRate],
               ISNULL(tr.Taxes, 0) [Taxes],
               ISNULL(@OldPrice, 0) [OldPrice],
               ISNULL(tr.ReturnRate, 0) [ReturnRate]
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
                   ISNULL(tr.Price, 0) [Price],
                   ISNULL(tr.BaseRate, 0) [BaseRate],
                   ISNULL(tr.Discount, 0) [Dicount],
                   ISNULL(tr.DiscountName, '') [DiscountName],
                   ISNULL(tr.FragilRate, 0) [FragilRate],
                   ISNULL(tr.CollectedRate, 0) [CollectedRate],
                   ISNULL(tr.InsuranceRate, 0) [InsuranceRate],
                   ISNULL(tr.OverWeightRate, 0) [OverWeightRate],
                   ISNULL(tr.IrregularPieceRate, 0) [IrregularPieceRate],
                   ISNULL(tr.CreditCardRate, 0) [CreditCardRate],
                   ISNULL(tr.Taxes, 0) [Taxes],
                   ISNULL(@OldPrice, 0) [OldPrice],
                   ISNULL(tr.ReturnRate, 0) [ReturnRate]
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
