-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-28>
-- Description:	<Devuelve la opción y precio shipping según un punto de visita ó un cliente>
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-06-15>
-- Description:	<Logíca para implementar nuevo tarifario y tarifario de descuento si destino es Ex C>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-07-06>
-- Description:	< Corrección de cálculo de sobrepesos de nuevo esquema de tarifas >
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_delivery_rate]
    @CodApp AS NVARCHAR(50) = '',
    @IdCustomerParams AS INT = 0,
    @HeaderCodeDestiny AS VARCHAR(10) = '',
    @HeaderCodeSource AS VARCHAR(10) = '',
    @Country AS NVARCHAR(2) = 'GT',
    @CountPiecesParams AS INT = 1,
    @IsFragile AS BIT = 'FALSE',
    @IsCollected AS BIT = 'FALSE',
    @IsInsurance AS BIT = 'FALSE',
    @WeigthParcels AS NVARCHAR(MAX) = '0',
    @InsuranceAmount AS DECIMAL(18, 2) = 0,
    @IsCreditCardPayment AS BIT = 'false',
    @ParcelCode AS NVARCHAR(MAX) = '0',
    @Zone AS INT = 0,
    @AddressParse AS NVARCHAR(600) = '',
    @IdSettlementSource AS INT = 0,
    @IdSettlementDestiny AS INT = 0,
    @CodeOfReferenceSource AS INT = 0,
    @CodeOfReferenceDestiny AS INT = 0,
    @IdSalePipeLine AS INT = 0,
    @FormatResponse AS NVARCHAR(10) = 'DataTable',
    @CalculateTaxes BIT = 'false'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @IdCustomer AS INT = 0;

    DECLARE @FechaCompra AS DATETIME = GETDATE();
    DECLARE @Time AS TIME = CONVERT(TIME, @FechaCompra);

    ------- determinar el cliente -----------------------------------------------------------------------------------------------
    IF @IdCustomerParams <= 0 -- si el id de client no viene en los parametros determinar via CODAPP
    BEGIN
        SET @IdCustomer =
        (
            SELECT TOP 1
                   eco.IdCustomer
            FROM DeliveryBackOffice.[dbo].[Ecommerce] eco WITH (NOLOCK)
            WHERE eco.UserKey = @CodApp --'SIFDCECOM300720201459'
                  AND eco.IdCountry = @Country
                  AND eco.EcommerceStatus = 'TRUE'
        );
    END;
    ELSE
    BEGIN
        SET @IdCustomer = @IdCustomerParams;
    END;
    ------- fin determinar cliente ------------------------------------------------------------------------------------------------

    ------- determinar el Tarifario y tipo de tarifario que se va a aplicar -------------------------------------------------------

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

    DECLARE @IdRate AS INT;
    DECLARE @IdTypeRate AS INT;
    DECLARE @WeigthLimit AS DECIMAL(12, 2) = 0;
    DECLARE @Currency AS VARCHAR(10) = '';
    DECLARE @PiecesIncluded AS DECIMAL(12, 2) = 1;

    IF EXISTS
    (
        SELECT rbc.RbcIdRate
        FROM dbo.RatebyCustomer rbc WITH (NOLOCK)
        WHERE rbc.RbcIdCustomer = @IdCustomer
              AND rbc.RbcRowStatus = 'TRUE'
              AND rbc.RbcCodeOfReference = @CodeOfReferenceSource
    )
    BEGIN
        SELECT @IdRate = rc.RbcIdRate,
               @IdTypeRate = rh.RateTypeId,
               @WeigthLimit = rh.WeightLimit,
               @Currency = dc.Currency_Symbol,
               @PiecesIncluded = rh.PiecesIncluded
        FROM dbo.RatebyCustomer rc WITH (NOLOCK)
            LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
                ON rh.RheId = rc.RbcIdRate
                   AND rh.RheRowStatus = 'true'
            LEFT JOIN dbo.DeliveryCurrency dc WITH (NOLOCK)
                ON dc.Currency_Id = rh.CurrencyId
        WHERE rc.RbcIdCustomer = @IdCustomer
              AND rc.RbcRowStatus = 'true'
              AND rc.RbcCodeOfReference = @CodeOfReferenceSource;
    END;
    ELSE
    BEGIN
        SELECT @IdRate = rc.RbcIdRate,
               @IdTypeRate = rh.RateTypeId,
               @WeigthLimit = rh.WeightLimit,
               @Currency = dc.Currency_Symbol,
               @PiecesIncluded = rh.PiecesIncluded
        FROM dbo.RatebyCustomer rc WITH (NOLOCK)
            LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
                ON rh.RheId = rc.RbcIdRate
                   AND rh.RheRowStatus = 'true'
            LEFT JOIN dbo.DeliveryCurrency dc WITH (NOLOCK)
                ON dc.Currency_Id = rh.CurrencyId
        WHERE rc.RbcIdCustomer = @IdCustomer
              AND rc.RbcRowStatus = 'true'
              AND rc.RbcCodeOfReference IS NULL;
    END;

    IF @IdRate IS NULL -- si el cliente no tiene una tarifa asociada determinar por canal de venta
    BEGIN
        SELECT @IdRate = rh.RheId,
               @IdTypeRate = rh.RateTypeId,
               @WeigthLimit = rh.WeightLimit,
               @Currency = dc.Currency_Symbol,
               @PiecesIncluded = rh.PiecesIncluded
        FROM dbo.RateBySalePipeLine sp WITH (NOLOCK)
            LEFT JOIN dbo.RateHeader rh WITH (NOLOCK)
                ON rh.RheId = sp.RateId
                   AND rh.RheRowStatus = 'true'
            LEFT JOIN dbo.DeliveryCurrency dc WITH (NOLOCK)
                ON dc.Currency_Id = rh.CurrencyId
        WHERE sp.RowStatus = 'true'
              AND sp.SalePipeLineId = @IdSalePipeLine;

    END;

    IF @IdRate IS NULL -- si no se encuentra por canal de venta se determina por el valor default 
    BEGIN
        SELECT @IdRate = rh.RheId,
               @IdTypeRate = rh.RateTypeId,
               @WeigthLimit = rh.WeightLimit,
               @Currency = dc.Currency_Symbol,
               @PiecesIncluded = rh.PiecesIncluded
        FROM dbo.RateHeader rh WITH (NOLOCK)
            LEFT JOIN dbo.DeliveryCurrency dc WITH (NOLOCK)
                ON dc.Currency_Id = rh.CurrencyId
        WHERE rh.RheRowStatus = 'true'
              AND rh.RheDefault = 'true';
    END;

    -------- Fin determinar tarifa que se va usar ---------------------------------------------------------------------

    ------------Validar Usuario Individual ó Ex C y Asignar nuevo tarifario-----------------------------------------------------------------------------------
    DECLARE @CustomerType INT;
    DECLARE @RateId INT;
    SELECT @CustomerType = C.IdCustomerType
    FROM dbo.Customer C
    WHERE IdCustomer = @IdCustomer;

    IF (@CustomerType IN ( 2, 3 )) --Validación si Usuario es Individual o Express center
    BEGIN

        IF (EXISTS
        (
            SELECT TOP 1
                   1
            FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
            WHERE VPC.CodeOfReference = @CodeOfReferenceDestiny
                  AND VPC.StatusClient = 1
                  AND VPC.DescriptionOfClient LIKE 'FD%EXC%' COLLATE Latin1_General_CI_AI
        )
           )
        BEGIN

            SELECT @RateId = ARC.RateId
            FROM [DeliveryBackOffice].[dbo].[AlternativeRateByCustomer] ARC WITH (NOLOCK)
            WHERE ARC.CustomerId = @IdCustomer
                  AND ARC.RowStatus = 1
                  AND @IdRate IN ( @NewMainRates, @NewAutoSalesMainRates );

            SET @IdRate = ISNULL(@RateId, @IdRate);

        END;
    END;

    IF (@IdCustomerParams = 0 AND @IdCustomer = 6)
    BEGIN

        SET @CalculateTaxes = 'false';

    END;

    ------------------------- Determinar si el servico es TDA ------------------------------------------------------------------

    --DECLARE @Tsettlement table (IdSettlement bigint )
    DECLARE @IsTDA BIT = 'false';
    DECLARE @IsSDD BIT = 'false';

    IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL
        DROP TABLE #ItemAddress;
    IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL
        DROP TABLE #SettlementList;

    --PRINT 'TEST 1'
    -- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia
    SET @AddressParse =
    (
        SELECT TOP 1
               REPLACE(
                          REPLACE(
                                     REPLACE(
                                                REPLACE(
                                                           REPLACE(
                                                                      REPLACE(
                                                                                 REPLACE(
                                                                                            REPLACE(
                                                                                                       REPLACE(
                                                                                                                  REPLACE(
                                                                                                                             REPLACE(
                                                                                                                                        REPLACE(
                                                                                                                                                   REPLACE(
                                                                                                                                                              REPLACE(
                                                                                                                                                                         REPLACE(
                                                                                                                                                                                    REPLACE(
                                                                                                                                                                                               REPLACE(
                                                                                                                                                                                                          REPLACE(
                                                                                                                                                                                                                     REPLACE(
                                                                                                                                                                                                                                REPLACE(
                                                                                                                                                                                                                                           REPLACE(
                                                                                                                                                                                                                                                      REPLACE(
                                                                                                                                                                                                                                                                 REPLACE(
                                                                                                                                                                                                                                                                            REPLACE(
                                                                                                                                                                                                                                                                                       REPLACE(
                                                                                                                                                                                                                                                                                                  REPLACE(
                                                                                                                                                                                                                                                                                                             REPLACE(
                                                                                                                                                                                                                                                                                                                        REPLACE(
                                                                                                                                                                                                                                                                                                                                   REPLACE(
                                                                                                                                                                                                                                                                                                                                              REPLACE(
                                                                                                                                                                                                                                                                                                                                                         REPLACE(
                                                                                                                                                                                                                                                                                                                                                                    REPLACE(
                                                                                                                                                                                                                                                                                                                                                                               REPLACE(
                                                                                                                                                                                                                                                                                                                                                                                          REPLACE(
                                                                                                                                                                                                                                                                                                                                                                                                     REPLACE(
                                                                                                                                                                                                                                                                                                                                                                                                                @AddressParse,
                                                                                                                                                                                                                                                                                                                                                                                                                '!',
                                                                                                                                                                                                                                                                                                                                                                                                                ''
                                                                                                                                                                                                                                                                                                                                                                                                            ),
                                                                                                                                                                                                                                                                                                                                                                                                     '"',
                                                                                                                                                                                                                                                                                                                                                                                                     ''
                                                                                                                                                                                                                                                                                                                                                                                                 ),
                                                                                                                                                                                                                                                                                                                                                                                          '#',
                                                                                                                                                                                                                                                                                                                                                                                          ''
                                                                                                                                                                                                                                                                                                                                                                                      ),
                                                                                                                                                                                                                                                                                                                                                                               '$',
                                                                                                                                                                                                                                                                                                                                                                               ''
                                                                                                                                                                                                                                                                                                                                                                           ),
                                                                                                                                                                                                                                                                                                                                                                    '%',
                                                                                                                                                                                                                                                                                                                                                                    ''
                                                                                                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                                                                                         '&',
                                                                                                                                                                                                                                                                                                                                                         'y'
                                                                                                                                                                                                                                                                                                                                                     ),
                                                                                                                                                                                                                                                                                                                                              '''',
                                                                                                                                                                                                                                                                                                                                              ''
                                                                                                                                                                                                                                                                                                                                          ),
                                                                                                                                                                                                                                                                                                                                   '*',
                                                                                                                                                                                                                                                                                                                                   ''
                                                                                                                                                                                                                                                                                                                               ),
                                                                                                                                                                                                                                                                                                                        '+',
                                                                                                                                                                                                                                                                                                                        ''
                                                                                                                                                                                                                                                                                                                    ),
                                                                                                                                                                                                                                                                                                             '/',
                                                                                                                                                                                                                                                                                                             ''
                                                                                                                                                                                                                                                                                                         ),
                                                                                                                                                                                                                                                                                                  '<',
                                                                                                                                                                                                                                                                                                  ''
                                                                                                                                                                                                                                                                                              ),
                                                                                                                                                                                                                                                                                       '=',
                                                                                                                                                                                                                                                                                       ''
                                                                                                                                                                                                                                                                                   ),
                                                                                                                                                                                                                                                                            '>',
                                                                                                                                                                                                                                                                            ''
                                                                                                                                                                                                                                                                        ),
                                                                                                                                                                                                                                                                 '?',
                                                                                                                                                                                                                                                                 ''
                                                                                                                                                                                                                                                             ),
                                                                                                                                                                                                                                                      '@',
                                                                                                                                                                                                                                                      ''
                                                                                                                                                                                                                                                  ),
                                                                                                                                                                                                                                           '[',
                                                                                                                                                                                                                                           ''
                                                                                                                                                                                                                                       ),
                                                                                                                                                                                                                                '\',
                                                                                                                                                                                                                                ''
                                                                                                                                                                                                                            ),
                                                                                                                                                                                                                     ']',
                                                                                                                                                                                                                     ''
                                                                                                                                                                                                                 ),
                                                                                                                                                                                                          '^',
                                                                                                                                                                                                          ''
                                                                                                                                                                                                      ),
                                                                                                                                                                                               '_',
                                                                                                                                                                                               ''
                                                                                                                                                                                           ),
                                                                                                                                                                                    '`',
                                                                                                                                                                                    ''
                                                                                                                                                                                ),
                                                                                                                                                                         '{',
                                                                                                                                                                         ''
                                                                                                                                                                     ),
                                                                                                                                                              '|',
                                                                                                                                                              ''
                                                                                                                                                          ),
                                                                                                                                                   '}',
                                                                                                                                                   ''
                                                                                                                                               ),
                                                                                                                                        '~',
                                                                                                                                        ''
                                                                                                                                    ),
                                                                                                                             '¡',
                                                                                                                             ''
                                                                                                                         ),
                                                                                                                  '¿',
                                                                                                                  ''
                                                                                                              ),
                                                                                                       '°',
                                                                                                       ''
                                                                                                   ),
                                                                                            '¬',
                                                                                            ''
                                                                                        ),
                                                                                 '´',
                                                                                 ''
                                                                             ),
                                                                      '¨',
                                                                      ''
                                                                  ),
                                                           '&Quot;',
                                                           ''
                                                       ),
                                                CHAR(255),
                                                ''
                                            ),
                                     twn.TownshipName,
                                     ''
                                 ),
                          prv.ProvinceName,
                          ''
                      )
        FROM Township twn WITH (NOLOCK)
            LEFT JOIN Province prv WITH (NOLOCK)
                ON prv.IdProvince = twn.IdProvince
        WHERE twn.HeaderCode = @HeaderCodeDestiny
              AND twn.TownshipStatus = 'true'
    );

    --PRINT 'TEST 2'

    DECLARE @IdSettlement BIGINT;

    --PRINT '@IdSettlementDestiny'
    --PRINT @IdSettlementDestiny

    IF @IdSettlementDestiny <= 0 --  no se envio el id settlement desde front por lo tanto intenta determinarlo con base a la dirección
    BEGIN
        --PRINT 'entra @IdSettlementDestiny<=0'
        --PRINT '@AddressParse'
        --PRINT @AddressParse

        -- separar en un arrglo la direccion 
        SELECT Item
        INTO #ItemAddress
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@AddressParse, ' ');

        --PRINT 'FIN DE PARSERO DE DIRECCEION'
        IF @Zone = 0 -- si no trae zona verificar por direccion
        BEGIN
            SELECT TOP 1
                   st.IdSettlement,
                   COUNT(st.IdSettlement) AS mas_popular,
                   st.Settlement
            INTO #SettlementList
            FROM #ItemAddress i
                LEFT JOIN dbo.Township tw WITH (NOLOCK)
                    ON tw.HeaderCode = @HeaderCodeDestiny
                LEFT JOIN dbo.Settlement st WITH (NOLOCK)
                    ON st.IdTownship = tw.IdTownship
                       AND st.Settlement LIKE CONCAT('%', i.Item, '%')
            WHERE LEN(i.Item) > 3
                  AND st.IdSettlement IS NOT NULL
            GROUP BY st.IdSettlement,
                     st.Settlement
            ORDER BY 2 DESC;

            CREATE NONCLUSTERED INDEX IX_SettlementList_ParcelCode
            ON #SettlementList (IdSettlement);

            SET @IdSettlement =
            (
                SELECT TOP 1 IdSettlement FROM #SettlementList
            );


        END;
        ELSE
        BEGIN -- si trae zona verificar por zona 
            SET @IdSettlement =
            (
                SELECT TOP 1
                       st.IdSettlement
                FROM dbo.Township tw WITH (NOLOCK)
                    LEFT JOIN dbo.Settlement st WITH (NOLOCK)
                        ON st.IdTownship = tw.IdTownship
                WHERE tw.HeaderCode = @HeaderCodeDestiny
                      AND st.Settlement LIKE CONCAT('%Zona ', @Zone, '%')
                ORDER BY IdSettlement
            );

        END;
        --PRINT 'FIN IF DE LA ZONA'
        IF @IdSettlement IS NULL -- si no se puede identificar el settlement trae el primero del municipio proporcionado
        BEGIN
            SET @IdSettlement =
            (
                SELECT TOP 1
                       st.IdSettlement
                FROM dbo.Township tw WITH (NOLOCK)
                    LEFT JOIN dbo.Settlement st WITH (NOLOCK)
                        ON st.IdTownship = tw.IdTownship
                WHERE tw.HeaderCode = @HeaderCodeDestiny
                ORDER BY IdSettlement
            );
        END;

    --PRINT 'FIN DEL IF DEL SETTLEMENT'
    END;
    ELSE
    BEGIN
        --PRINT 'ENTRA EN ELSE'
        --PRINT '@IdSettlement'
        --PRINT @IdSettlement
        --PRINT '@IdSettlementDestiny'
        --PRINT @IdSettlementDestiny
        SET @IdSettlement = @IdSettlementDestiny;
    END;


    --PRINT 'TEST 3'
    -- IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
    -- IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

    SET @IsTDA = ISNULL(
                 (
                     SELECT TOP 1
                            IIF(cov.TDA = 0, 'false', 'true')
                     FROM dbo.DumpServiceCoverage cov WITH (NOLOCK)
                     WHERE cov.IdSettlement = @IdSettlement
                           AND cov.RowStatus = 1
                 ),
                 'false'
                       );

    DECLARE @IdRateGroup INT = (IIF(@IsTDA = 'false',
                                    1,
                                (
                                    SELECT TOP 1
                                           RateGroup
                                    FROM dbo.CatTypeService WITH (NOLOCK)
                                    WHERE CtsShortName = 'TDA'
                                          AND CtsRowStatus = 1
                                ))
                               );


    ---HOTFIX_SAMEDAY.INI	
    --PRINT 'HOTFIX INI'

    IF @IdRateGroup = 1
    BEGIN
        SET @IsSDD = ISNULL(
                     (
                         SELECT TOP 1
                                IIF(cov.SDD = 0, 'false', 'true')
                         FROM dbo.DumpServiceCoverage cov WITH (NOLOCK)
                         WHERE cov.IdSettlement = @IdSettlement
                               AND cov.RowStatus = 1
                     ),
                     'false'
                           );

        DECLARE @IdRateGroupSDD INT = (IIF(@IsSDD = 'false',
                                           1,
                                       (
                                           SELECT TOP 1
                                                  RateGroup
                                           FROM dbo.CatTypeService WITH (NOLOCK)
                                           WHERE CtsShortName = 'SDD'
                                                 AND CtsRowStatus = 1
                                       ))
                                      );
    END;


    --PRINT 'HOTFIX FIN'
    ---HOTFIX_SAMEDAY.FIN

    --------------- Fin determinar si es TDA   -----------------------.-------------------------------------------------------------------------------------
    ---------------- Determinar HubOrigen y Destino --------------------------------------------------------------------------------------------------------

    DECLARE @IdHubSource INT;
    DECLARE @IdHubDestiny INT;

    SELECT TOP 1
           @IdHubSource = hb.IdHubLogistic
    FROM dbo.DumpServiceCoverage cov WITH (NOLOCK)
        LEFT JOIN dbo.HubLogistics hb WITH (NOLOCK)
            ON hb.HubAbbreviation = cov.Hub
    WHERE cov.HeaderCode = @HeaderCodeSource
    ORDER BY cov.Hub;

    SELECT TOP 1
           @IdHubDestiny = hb.IdHubLogistic
    FROM dbo.DumpServiceCoverage cov WITH (NOLOCK)
        LEFT JOIN dbo.HubLogistics hb WITH (NOLOCK)
            ON hb.HubAbbreviation = cov.Hub
    WHERE cov.HeaderCode = @HeaderCodeDestiny
    ORDER BY cov.Hub DESC;

    --------------- Fin determinar Hub Origen y Destino ---------------------------------------------------------------------------------------------------

    ---------------- Determinar Segmento LOC/MET/FOR-------------------------------------------------------------------------------------------------------
    --PRINT 'determinar segmento LOC/MET/FOR '
    IF @CodeOfReferenceSource <= 0 -- si no viene el codeOfReference tomar el primero de cada cliente
    BEGIN
        SELECT TOP 1
               @CodeOfReferenceSource = vp.CodeOfReference
        FROM dbo.VisitPointClient vp WITH (NOLOCK)
        WHERE vp.CustomerID = @IdCustomer;
    END;
    DECLARE @IdSegment INT;

    --PRINT 'CodeOfReference'
    --PRINT @CodeOfReferenceSource

    --PRINT '@IdHubDestiny'
    --PRINT @IdHubDestiny
    SELECT TOP 1
           @IdSegment = cov.SegmentId
    FROM dbo.VisitPointCoverage cov
    WHERE cov.RowStatus = 'true'
          AND cov.HubLogisticId = @IdHubDestiny
          AND cov.VisitPointId = @CodeOfReferenceSource;

    --PRINT 'segmento'
    --PRINT @IdSegment
    IF @IdSegment IS NULL -- si no se encuentra una configuracion válida para determinar el segmento tomar  LOCAL si el hub de origen es igual al hub de destino
    BEGIN
        --PRINT 'segmento nulo'
        IF @IdHubSource = @IdHubDestiny
        BEGIN
            --PRINT 'hubs iguales'
            SELECT TOP 1
                   @IdSegment = sg.CrsId
            FROM dbo.CatRateSegment sg WITH (NOLOCK)
            WHERE sg.CrsShortName = 'LOC';
        END;
        ELSE
        BEGIN
            --PRINT 'hubs default'
            SELECT TOP 1
                   @IdSegment = cov.SegmentId -- si los hubs no son iguales verficar en la configuracion por default asignada el visit point 0
            FROM dbo.VisitPointCoverage cov WITH (NOLOCK)
            WHERE cov.RowStatus = 'true'
                  AND cov.HubLogisticId = @IdHubDestiny
                  AND @IdHubSource IN ( 1, 22 );
        END;
    END;

    IF @IdSegment IS NULL -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
    BEGIN

        SELECT TOP 1
               @IdSegment = sg.CrsId
        FROM dbo.CatRateSegment sg WITH (NOLOCK)
        WHERE sg.CrsShortName = 'FOR';
    END;

    --------------- Fin Determinar Segmento LOC/MET/FOR --- ---------------------------------------------------------------------------------------------------
    -------------------------------Obtener descuento --------------------------------------------------------------------------

    DECLARE @IdTypeCustomer INT =
            (
                SELECT TOP 1
                       cus.IdCustomerType
                FROM dbo.Customer cus WITH (NOLOCK)
                WHERE cus.IdCustomer = @IdCustomer
            );

    SELECT TOP 1
           ss.Name AS DicountName,
           ss.IsGlobal AS IsGlobla,
           sd.UnitId AS IdUnit,
           sd.Value AS Value,
           unt.Prefix AS Unit,
           sd.TypeDiscountId AS idTypeDiscount,
           tyd.ShortName AS TypeDiscount
    INTO #Dicounts
    FROM dbo.SpecialSale ss WITH (NOLOCK)
        INNER JOIN dbo.SpecialSaleDetail sd WITH (NOLOCK)
            ON sd.SpecialSaleId = ss.IdSpecialSale
               AND sd.RowStatus = 1
        LEFT JOIN dbo.Unit unt WITH (NOLOCK)
            ON unt.IdUnit = sd.UnitId
        LEFT JOIN dbo.CatTypeDiscount tyd WITH (NOLOCK)
            ON tyd.IdCatTypeDiscount = sd.TypeDiscountId
        LEFT JOIN dbo.SpecialSaleTarget tgt WITH (NOLOCK)
            ON tgt.SpecialSaleId = ss.IdSpecialSale
    WHERE ss.RowStatus = 1
          AND GETDATE()
          BETWEEN ss.StartDate AND ss.FinishDate
          AND
          (
              ss.IsGlobal = 1
              OR tgt.CustomerId = @IdCustomer
              OR tgt.CustomerTypeid = @IdTypeCustomer
          )
    ORDER BY ss.Priority DESC;

    DECLARE @Value DECIMAL(12, 2) = 0;

    DECLARE @TypeDiscount VARCHAR(20) =
            (
                SELECT TOP 1 ds.TypeDiscount FROM #Dicounts ds
            );
    DECLARE @DiscountName VARCHAR(100) =
            (
                SELECT TOP 1 ds.DicountName FROM #Dicounts ds
            );
    SET @Value =
    (
        SELECT TOP 1 ISNULL(ds.Value, 0)FROM #Dicounts ds
    );
    DECLARE @Unit VARCHAR(10) =
            (
                SELECT TOP 1 ds.Unit FROM #Dicounts ds
            );

    ---------------------Fin obtener descuento -------------------------------------------------------------------------------------
    ---------------------Determinar si existe exceso de libras ---------------------------------------------------------------------

    IF OBJECT_ID('tempdb.dbo.#ParceCode', 'U') IS NOT NULL
        DROP TABLE #ParceCode;
    IF OBJECT_ID('tempdb.dbo.#ParceWeigth', 'U') IS NOT NULL
        DROP TABLE #ParceWeigth;

    SELECT Item,
           ROW_NUMBER() OVER (ORDER BY Item) ID
    INTO #ParceCode
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',');

    SELECT Item,
           ROW_NUMBER() OVER (ORDER BY Item) ID
    INTO #ParceWeigth
    FROM DeliveryBackOffice.dbo.SplitUnlimited(RTRIM(LTRIM(@WeigthParcels)), ',');

    DECLARE @OverWeight DECIMAL(12, 2) = 0;
    DECLARE @OverWeightchar NVARCHAR(100);

    SET @OverWeightchar =
    (
        SELECT SUM(IIF((w.Item - @WeigthLimit) < 0, 0, (w.Item - @WeigthLimit))) AS exeso
        FROM #ParceWeigth w
            LEFT JOIN #ParceCode p
                ON p.ID = w.ID
        WHERE p.Item = '0'
              OR p.Item IS NULL
              OR p.Item = ''
    );
    --PRINT @OverWeightchar

    SET @OverWeight =
    (
        SELECT SUM(IIF((w.Item - @WeigthLimit) < 0, 0, (w.Item - @WeigthLimit))) AS exeso
        FROM #ParceWeigth w
            LEFT JOIN #ParceCode p
                ON p.ID = w.ID
        WHERE p.Item = '0'
              OR p.Item IS NULL
              OR p.Item = ''
    );
    --print 'exceso de peso'
    --print @OverWeight

    ----------------- Fin Determinar si existe exceso de libras --------------------------------------------------------------------
    DECLARE @CountPiece INT = 0;

    ----------------- Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------

    DECLARE @TempRate TABLE
    (
        TypeRate VARCHAR(50),
        Segment VARCHAR(50),
        Service VARCHAR(50),
        BaseRate DECIMAL(12, 2),
        DiscountName VARCHAR(100),
        Discount DECIMAL(12, 2),
        FragilRate DECIMAL(12, 2),
        CollectedRate DECIMAL(12, 2),
        InsuranceRate DECIMAL(12, 2),
        CreditCardRate DECIMAL(12, 2),
        OverWeightRate DECIMAL(12, 2),
        IrregularPieceRate DECIMAL(12, 2),
        ServiceName VARCHAR(100),
        ServiceDescription VARCHAR(200),
        ReturnRate DECIMAL(12, 2)
    );

    ----------------- Fin Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------


    IF @IdTypeRate = 1 -- tarifas estandar
    BEGIN
        --print 'aqui van las tarifas standar'
        DECLARE @CountPiecebyArticle INT = 0;
        DECLARE @ParcelPrice2 DECIMAL(12, 2) = 0;

        SET @CountPiecebyArticle =
        (
            SELECT COUNT(1)
            FROM #ParceWeigth pw
                JOIN #ParceCode pc
                    ON pc.ID = pw.ID
            WHERE pc.Item <> '0'
                  AND pc.Item <> ''
                  AND pc.Item IS NOT NULL
        );

        SET @CountPiece = dbo.FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded) - @CountPiecebyArticle;

        SELECT Item
        INTO #ListCode2
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',');

        SET @ParcelPrice2 =
        (
            SELECT SUM(ISNULL(ra.RateValue, ISNULL(ar.PriceDefault, 0)))
            FROM #ListCode2 ls
                JOIN dbo.ArticleByCustomer ar
                    ON ar.Code = ls.Item
                JOIN dbo.RateData ra
                    ON ra.ArticleId = ar.AbcId
                       AND ra.TypeSegmentId = @IdSegment
                       AND ra.RateId = @IdRate
        );

        IF (@IsSDD = 'true' AND @CountPiecebyArticle = 0) -----HOTFIX_SAMEDAY.INI	
        BEGIN

            INSERT INTO @TempRate
            SELECT ISNULL(cr.Name, '') TypeRate,
                   ISNULL(sg.CrsShortName, '') Segment,
                   ISNULL(sv.CtsShortName, '') Service,
                   (ISNULL(rd.RateValue, 0) * @CountPiece) BaseRate,
                   ISNULL(@DiscountName, '') DiscountName,
                   CAST(((ISNULL(rd.RateValue, 0) * @CountPiece) * ISNULL(@Value, 0) / 100) AS DECIMAL(12, 2)) DiscountValue,
                   IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                   IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                   IIF(@IsInsurance = 'true',
                       (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                            CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                            0)
                       ),
                       0) AS InsuranceRate,
                   IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                   IIF(ISNULL(@OverWeight, 0) > 0, ISNULL(@OverWeight, 0) * ISNULL(rh.AdditionalWeightRate, 0), 0) OverWeightRate,
                   ISNULL(@ParcelPrice2, 0) IrregularParcelRate,
                   ISNULL(sv.CtsName, '') AS CstName,
                   ISNULL(sv.CtsDescription, '') AS CtsDescription,
                   ISNULL(rh.ReturnRate, 0) AS ReturnRate
            FROM dbo.RateHeader rh WITH (NOLOCK)
                JOIN dbo.RateData rd WITH (NOLOCK)
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 'true'
                LEFT JOIN dbo.CatRateSegment sg WITH (NOLOCK)
                    ON sg.CrsId = rd.TypeSegmentId
                LEFT JOIN dbo.CatTypeService sv WITH (NOLOCK)
                    ON sv.CtsId = rd.TypeServiceId
                LEFT JOIN dbo.CatTypeRate cr WITH (NOLOCK)
                    ON cr.IdTypeRate = rh.RateTypeId
            WHERE rh.RheRowStatus = 'true'
                  AND rh.RheId = @IdRate
                  AND rd.ArticleId IS NULL
                  AND (rd.TypeServiceId IN
                       (
                           SELECT CtsId
                           FROM dbo.CatTypeService
                           WHERE RateGroup = @IdRateGroup
                                 AND CtsRowStatus = 1
                       )
                      )
                  AND rd.HubSourceId = @IdHubSource
                  AND rd.HubDestinyId = @IdHubDestiny
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                                 CONVERT(
                                                                            DATETIME,
                                                                            ISNULL(
                                                                                      rd.LimitHourPickup,
                                                                                      sv.LimitHourPickup
                                                                                  ),
                                                                            108
                                                                        ),
                                                                 CONVERT(DATETIME, '23:59:59', 108)
                                                             );

        END;
        ELSE
        BEGIN

            INSERT INTO @TempRate
            SELECT ISNULL(cr.Name, '') TypeRate,
                   ISNULL(sg.CrsShortName, '') Segment,
                   ISNULL(sv.CtsShortName, '') Service,
                   (ISNULL(rd.RateValue, 0) * @CountPiece) BaseRate,
                   ISNULL(@DiscountName, '') DiscountName,
                   CAST(((ISNULL(rd.RateValue, 0) * @CountPiece) * ISNULL(@Value, 0) / 100) AS DECIMAL(12, 2)) DiscountValue,
                   IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                   IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                   IIF(@IsInsurance = 'true',
                       (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                            CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                            0)
                       ),
                       0) AS InsuranceRate,
                   IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                   IIF(ISNULL(@OverWeight, 0) > 0, ISNULL(@OverWeight, 0) * ISNULL(rh.AdditionalWeightRate, 0), 0) OverWeightRate,
                   ISNULL(@ParcelPrice2, 0) IrregularParcelRate,
                   ISNULL(sv.CtsName, '') AS CstName,
                   ISNULL(sv.CtsDescription, '') AS CtsDescription,
                   ISNULL(rh.ReturnRate, 0) AS ReturnRate
            FROM dbo.RateHeader rh WITH (NOLOCK)
                JOIN dbo.RateData rd WITH (NOLOCK)
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 'true'
                LEFT JOIN dbo.CatRateSegment sg WITH (NOLOCK)
                    ON sg.CrsId = rd.TypeSegmentId
                LEFT JOIN dbo.CatTypeService sv WITH (NOLOCK)
                    ON sv.CtsId = rd.TypeServiceId
                LEFT JOIN dbo.CatTypeRate cr WITH (NOLOCK)
                    ON cr.IdTypeRate = rh.RateTypeId
            WHERE rh.RheRowStatus = 'true'
                  AND rh.RheId = @IdRate
                  AND rd.ArticleId IS NULL
                  AND (rd.TypeServiceId IN
                       (
                           SELECT CtsId
                           FROM dbo.CatTypeService
                           WHERE RateGroup = @IdRateGroup
                                 AND CtsRowStatus = 1
                       )
                      )
                  AND rd.HubSourceId = @IdHubSource
                  AND rd.HubDestinyId = @IdHubDestiny
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                                 CONVERT(
                                                                            DATETIME,
                                                                            ISNULL(
                                                                                      rd.LimitHourPickup,
                                                                                      sv.LimitHourPickup
                                                                                  ),
                                                                            108
                                                                        ),
                                                                 CONVERT(DATETIME, '23:59:59', 108)
                                                             )
                  AND sv.CtsShortName NOT IN ( 'SDD' );

        END; -----HOTFIX_SAMEDAY.FIN


    END;
    ELSE IF @IdTypeRate = 2 -- tarifas todo destino
    BEGIN
        --print 'aqui van las tarifas todo destino'
        --print 'segmento'
        --print  @IdSegment
        --print 'grupo de servicios'

        --IF @IdCustomer = 1  -- el igss se cobra por guia no por pieza
        --	set @CountPiece = 1
        --ELSE
        SET @CountPiece = dbo.FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded); -- todos los demas clientes se les cobra por pieza


        --
        --print @IdRateGroup
        INSERT INTO @TempRate
        SELECT ISNULL(cr.Name, '') TypeRate,
               ISNULL(sg.CrsShortName, '') Segment,
               ISNULL(sv.CtsShortName, '') Service,
               (ISNULL(rd.RateValue, 0) * @CountPiece) BaseRate,
               '' DiscountName,
               0 DiscountValue,
               IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
               IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
               IIF(@IsInsurance = 'true',
                   (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                        CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                        0)
                   ),
                   0) AS InsuranceRate,
               IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
               IIF(@OverWeight > 0, @OverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) OverWeightRate,
               0 IrregularParcelRate,
               ISNULL(sv.CtsName, '') AS CstName,
               ISNULL(sv.CtsDescription, '') AS CstDescription,
               ISNULL(rh.ReturnRate, 0) AS ReturnRate
        FROM dbo.RateHeader rh WITH (NOLOCK)
            JOIN dbo.RateData rd WITH (NOLOCK)
                ON rd.RateId = rh.RheId
                   AND rd.RowStatus = 'true'
            LEFT JOIN dbo.CatRateSegment sg WITH (NOLOCK)
                ON sg.CrsId = rd.TypeSegmentId
            LEFT JOIN dbo.CatTypeService sv WITH (NOLOCK)
                ON sv.CtsId = rd.TypeServiceId
            LEFT JOIN dbo.CatTypeRate cr WITH (NOLOCK)
                ON cr.IdTypeRate = rh.RateTypeId
        WHERE rh.RheId = @IdRate
              AND rd.ArticleId IS NULL
              AND rd.TypeSegmentId = @IdSegment
              AND (rd.TypeServiceId IN
                   (
                       SELECT CtsId
                       FROM dbo.CatTypeService
                       WHERE RateGroup = @IdRateGroup
                             AND CtsRowStatus = 1
                   )
                  )
              AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                             CONVERT(
                                                                        DATETIME,
                                                                        ISNULL(rd.LimitHourPickup, sv.LimitHourPickup),
                                                                        108
                                                                    ),
                                                             CONVERT(DATETIME, '23:59:59', 108)
                                                         );
    END;
    ELSE IF @IdTypeRate = 3 -- tarifas por articulo
    BEGIN

        --print 'aqui van las tarifas por articulo'
        -- cantidad de piezas regulares
        SET @CountPiece =
        (
            SELECT COUNT(*)
            FROM #ParceWeigth w
                LEFT JOIN #ParceCode p
                    ON p.ID = w.ID
            WHERE p.Item = '0'
                  OR p.Item IS NULL
                  OR p.Item = ''
        );
        ------------------------------------- verificar tarifas de piezas irregulares ---------------------------------------------------
        SELECT Item
        INTO #ListCode
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',');

        --select * from #ListCode
        DECLARE @ParcelPrice DECIMAL(12, 2) = 0;

        IF (@IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates ))
        BEGIN

            SET @IdSegment = NULL;
            --PRINT 'ENTRO AL IF'
            IF (EXISTS (SELECT TOP 1 1 FROM #ListCode)
                AND LTRIM(RTRIM(
                          (
                              SELECT TOP 1 Item FROM #ListCode
                          )
                               )
                         ) <> ''
               )
            BEGIN
                -- Cálculo de segmento - nuevas tarifas
                -- HeaderCodes Iguales - LOC
                IF (@HeaderCodeSource = @HeaderCodeDestiny)
                BEGIN
                    SELECT TOP 1
                           @IdSegment = sg.CrsId
                    FROM dbo.CatRateSegment sg WITH (NOLOCK)
                    WHERE sg.CrsShortName = 'LOC';
                END;
                -- HeaderCodes diferentes - revisar tabla
                ELSE
                BEGIN
                    SELECT TOP 1
                           @IdSegment = RTC.SegmentTypeId
                    FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH (NOLOCK)
                        INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnSource WITH (NOLOCK)
                            ON RTC.TownshipSourceId = TwnSource.IdTownship
                        INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnDestiny WITH (NOLOCK)
                            ON RTC.TownshipDestinyId = TwnDestiny.IdTownship
                    WHERE RTC.RateId = @IdRate
                          AND (TwnSource.HeaderCode = @HeaderCodeSource)
                          AND (TwnDestiny.HeaderCode = @HeaderCodeDestiny)
                          AND RTC.RowStatus = 1;

                END;

                PRINT @IdSegment;
                IF (@IdSegment IS NULL) -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
                BEGIN
                    SELECT TOP 1
                           @IdSegment = sg.CrsId
                    FROM [DeliveryBackOffice].dbo.CatRateSegment sg WITH (NOLOCK)
                    WHERE sg.CrsShortName = 'FOR';
                END;

                -- Cálculo de precios
                IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL
                    DROP TABLE #ParcelAmountPerType;
                IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL
                    DROP TABLE #ParcelOverweightPerType;

                -- Servicios y segmentos
                SELECT CRS.CrsId 'SegmentType',
                       CTS.CtsId 'ServiceType',
                       CAST(0 AS DECIMAL(18, 2)) 'TotalAmount'
                INTO #ParcelAmountPerType
                FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS
                    CROSS JOIN [DeliveryBackOffice].[dbo].[CatTypeService] CTS;

                -- Paquetes con su peso indicado
                DECLARE @ExpectedWeight DECIMAL(12, 2) = 0;

                SELECT p.ID 'RowNumber',
                       ABC.Code 'ParcelCode',
                       ABC.MassWeight 'ParcelWeight'
                INTO #ParcelOverweightPerType
                FROM #ParceCode p
                    INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH (NOLOCK)
                        ON p.Item = ABC.Code COLLATE Latin1_General_CI_AI
                           AND ABC.AbcRowStatus = 1;

                SET @ExpectedWeight =
                (
                    SELECT SUM(POPT.ParcelWeight)FROM #ParcelOverweightPerType POPT
                );

                BEGIN TRY

                    SET @OverWeight =
                    (
                        SELECT SUM(CAST(ROUND(CAST(PW.Item AS DECIMAL(12, 2)), 0) AS INT))
                        FROM #ParceWeigth PW
                    );

                END TRY
                BEGIN CATCH

                    SET @OverWeight = @ExpectedWeight;

                END CATCH;

                DECLARE @NewOverWeight DECIMAL(12, 2) = 0;
                SET @NewOverWeight = (@OverWeight - @ExpectedWeight);

                --SET @OverWeight = ISNULL(( IIF( (@OverWeight - @ExpectedWeight) < 0, 0, (@OverWeight - @ExpectedWeight) ) ),0);

                -- Actualizar con los que esten dentro del tarifario por tipo de servicio y tipo de segmento
                UPDATE #ParcelAmountPerType
                SET TotalAmount = TotalAmount + AddedTotalAmount
                FROM
                (
                    SELECT rd.TypeSegmentId AddedSegmentType,
                           rd.TypeServiceId AddedServiceType,
                           SUM(rd.RateValue) 'AddedTotalAmount'
                    FROM dbo.RateHeader rh
                        INNER JOIN dbo.RateData rd
                            ON rd.RateId = rh.RheId
                               AND rd.RowStatus = 'true'
                        INNER JOIN dbo.ArticleByCustomer abc
                            ON rd.ArticleId = abc.AbcId
                        INNER JOIN #ListCode LC
                            ON abc.Code = LC.Item
                    WHERE rh.RheId = @IdRate
                          AND rd.TypeSegmentId = @IdSegment
                    --and  (rd.TypeServiceId in(select CtsId from dbo.CatTypeService  where RateGroup = @IdRateGroup and CtsRowStatus = 1) )
                    GROUP BY rd.TypeSegmentId,
                             rd.TypeServiceId
                ) TempValues
                WHERE TempValues.AddedSegmentType = #ParcelAmountPerType.SegmentType
                      AND TempValues.AddedServiceType = #ParcelAmountPerType.ServiceType;

                -- Actualizar con los que NO esten dentro del tarifario por tipo de servicio y tipo de segmento
                UPDATE #ParcelAmountPerType
                SET TotalAmount = TotalAmount + AddedTotalAmount
                FROM
                (
                    SELECT rd.TypeSegmentId AddedSegmentType,
                           SUM(ISNULL(rd.RateValue, abc.PriceDefault)) 'AddedTotalAmount'
                    FROM #ListCode lc
                        INNER JOIN dbo.ArticleByCustomer abc
                            ON abc.Code = lc.Item
                        INNER JOIN dbo.RateData rd
                            ON rd.ArticleId = abc.AbcId
                    WHERE rd.TypeServiceId IS NULL
                          AND rd.TypeSegmentId = @IdSegment
                          AND rd.RateId = @IdRate
                    GROUP BY rd.TypeSegmentId
                ) TempValues
                WHERE TempValues.AddedSegmentType = SegmentType;

                DECLARE @RealRateGroup AS TABLE
                (
                    ServiceTypeId INT NOT NULL,
                    RowStatus BIT NOT NULL
                        DEFAULT 1
                );

                INSERT INTO @RealRateGroup
                (
                    ServiceTypeId
                )
                SELECT CtsId
                FROM [DeliveryBackOffice].dbo.CatTypeService CTS WITH (NOLOCK)
                WHERE RateGroup = @IdRateGroup
                      AND CtsRowStatus = 1;

                DECLARE @SDDTypeId INT =
                        (
                            SELECT TOP 1
                                   CTS.CtsId
                            FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH (NOLOCK)
                            WHERE CTS.CtsShortName = 'SDD' COLLATE Latin1_General_CI_AI
                        );
                IF (@IsSDD = 0)
                    UPDATE @RealRateGroup
                    SET RowStatus = 0
                    WHERE ServiceTypeId = @SDDTypeId;

                -- Tarifas finales
                INSERT INTO @TempRate
                SELECT DISTINCT
                       ISNULL(cr.Name, '') TypeRate,
                       ISNULL(sg.CrsShortName, '') Segment,
                       ISNULL(sv.CtsShortName, '') Service,
                       (ISNULL(rd.RateValue, 0) * @CountPiece) BaseRate,
                       '' DiscountName,
                       0 DiscountValue,
                       IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                       IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                       IIF(@IsInsurance = 'true',
                           (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                                CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                                0)
                           ),
                           0) AS InsuranceRate,
                       IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                       IIF(@NewOverWeight > 0, @NewOverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) OverWeightRate,
                       ISNULL(papt.TotalAmount, 0) AS IrregularParcelRate,
                       ISNULL(sv.CtsName, '') AS CtsName,
                       ISNULL(sv.CtsDescription, '') AS CtsDescription,
                       ISNULL(rh.ReturnRate, 0) AS ReturnRate
                FROM dbo.RateHeader rh
                    INNER JOIN dbo.RateData rd
                        ON rd.RateId = rh.RheId
                           AND rd.RowStatus = 'true'
                    INNER JOIN #ParcelAmountPerType papt
                        ON rd.TypeSegmentId = papt.SegmentType
                           AND rd.TypeServiceId = papt.ServiceType
                    LEFT JOIN dbo.CatRateSegment sg
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN dbo.CatTypeService sv
                        ON sv.CtsId = rd.TypeServiceId
                    LEFT JOIN dbo.CatTypeRate cr
                        ON cr.IdTypeRate = rh.RateTypeId
                WHERE rh.RheId = @IdRate
                      --and rd.ArticleId is null
                      AND rd.TypeSegmentId = @IdSegment
                      AND (rd.TypeServiceId IN
                           (
                               SELECT RRG.ServiceTypeId FROM @RealRateGroup RRG WHERE RRG.RowStatus = 1
                           )
                          )
                      AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                                     CONVERT(
                                                                                DATETIME,
                                                                                ISNULL(
                                                                                          rd.LimitHourPickup,
                                                                                          sv.LimitHourPickup
                                                                                      ),
                                                                                108
                                                                            ),
                                                                     CONVERT(DATETIME, '23:59:59', 108)
                                                                 );

                IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL
                    DROP TABLE #ParcelOverweightPerType;
                IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL
                    DROP TABLE #ParcelAmountPerType;
            END;
        END;
        ELSE
        BEGIN

            -------------------------------------- fin verificar tarifas de piezas irregulares -----------------------------------------------
            INSERT INTO @TempRate
            SELECT x.TypeRate,
                   x.Segment,
                   x.Service,
                   SUM(x.BaseRate),
                   x.DiscountName,
                   SUM(x.DiscountValue),
                   x.fragilRate,
                   x.CollectedRate,
                   SUM(x.InsuranceRate),
                   x.CreditCardRate,
                   x.OverWeightRate,
                   SUM(x.IrregularParcelRate),
                   x.CtsName,
                   x.CtsDescription,
                   x.ReturnRate
            FROM
            (
                SELECT ISNULL(cr.Name, '') TypeRate,
                       ISNULL(sg.CrsShortName, '') Segment,
                       ISNULL(sv.CtsShortName, '') Service,
                       (ISNULL(rd.RateValue, 0) * @CountPiece) BaseRate,
                       '' DiscountName,
                       0 DiscountValue,
                       IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                       IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                       IIF(@IsInsurance = 'true',
                           (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                                CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                                0)
                           ),
                           0) AS InsuranceRate,
                       IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                       IIF(@OverWeight > 0, @OverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) OverWeightRate,
                       ISNULL(rd.RateValue, ISNULL(ar.PriceDefault, 0)) AS IrregularParcelRate,
                       ISNULL(sv.CtsName, '') AS CtsName,
                       ISNULL(sv.CtsDescription, '') AS CtsDescription,
                       ISNULL(rh.ReturnRate, 0) AS ReturnRate
                FROM #ListCode ls
                    INNER JOIN dbo.ArticleByCustomer ar WITH (NOLOCK)
                        ON ar.Code = ls.Item
                    INNER JOIN dbo.RateHeader rh WITH (NOLOCK)
                        ON rh.RheId = @IdRate
                    INNER JOIN dbo.RateData rd WITH (NOLOCK)
                        ON rd.ArticleId = ar.AbcId
                           AND rd.RateId = rh.RheId
                           AND rd.RowStatus = 'true'
                    LEFT JOIN dbo.CatRateSegment sg WITH (NOLOCK)
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN dbo.CatTypeService sv WITH (NOLOCK)
                        ON sv.CtsId = rd.TypeServiceId
                    LEFT JOIN dbo.CatTypeRate cr WITH (NOLOCK)
                        ON cr.IdTypeRate = rh.RateTypeId
                WHERE rd.TypeSegmentId = @IdSegment
                      AND (rd.TypeServiceId IN
                           (
                               SELECT CtsId
                               FROM dbo.CatTypeService WITH (NOLOCK)
                               WHERE RateGroup = @IdRateGroup
                                     AND CtsRowStatus = 1
                           )
                          )
            ) x
            GROUP BY x.TypeRate,
                     x.Segment,
                     x.Service,
                     x.DiscountName,
                     x.fragilRate,
                     x.CollectedRate,
                     x.CtsName,
                     x.CreditCardRate,
                     x.OverWeightRate,
                     x.CtsDescription,
                     x.ReturnRate;

        END;
    --print 'rate'
    --print @IdRate
    --print 'segment'
    --print @IdSegment
    --print 'grupo'
    --print @IdRateGroup
    END;
    ELSE IF @IdTypeRate = 4 -- tarifas especiales
    BEGIN
        PRINT 'aqui van las tarifas especiales';
    END;
    -- FDD-671 INI
    ELSE IF @IdTypeRate = 5 -- tarifas por peso
    BEGIN
        --PRINT 'tarifas por peso'

        --Cálcular las piezas que no entran en rangos
        DECLARE @tblNotInRange AS TABLE
        (
            ID INT NULL,
            Weight DECIMAL(12, 2) NULL,
            CatTypeServiceId INT NULL
        );

        INSERT INTO @tblNotInRange
        SELECT pw.ID,
               pw.Item,
               cts.CtsId
        FROM #ParceWeigth pw,
             CatTypeService cts
        WHERE NOT EXISTS
        (
            SELECT 1
            FROM RateData
            WHERE RateId = @IdRate
                  AND TypeSegmentId = @IdSegment
                  AND TypeServiceId = cts.CtsId
                  AND RowStatus = 1
                  AND pw.Item
                  BETWEEN WeightFrom AND WeightTo
        )
              AND cts.CtsRowStatus = 1
              AND cts.RateGroup = @IdRateGroup;

        INSERT INTO @TempRate
        SELECT TypeRate,
               Segment,
               Service,
               SUM(BaseRate) BaseRate,
               DiscountName,
               DiscountValue,
               fragilRate,
               CollectedRate,
               InsuranceRate,
               CreditCardRate,
               (SUM(OverWeightRate) + IIF(@OverWeight > 0, @OverWeight, 0)) * AdditionalWeightRate OverWeightRate,
               IrregularParcelRate,
               CtsName,
               CtsDescription,
               ReturnRate
        FROM
        (
            SELECT ISNULL(ctr.Name, '') TypeRate,
                   ISNULL(crs.CrsShortName, '') Segment,
                   ISNULL(cts.CtsShortName, '') Service,
                   ISNULL(rd.RateValue, 0) BaseRate,
                   '' DiscountName,
                   0 DiscountValue,
                   IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                   IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                   IIF(@IsInsurance = 'true',
                       (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                            CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                            0)
                       ),
                       0) AS InsuranceRate,
                   IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                   0 OverWeightRate,
                   ISNULL(@ParcelPrice, 0) AS IrregularParcelRate,
                   ISNULL(cts.CtsName, '') AS CtsName,
                   ISNULL(cts.CtsDescription, '') AS CtsDescription,
                   ISNULL(rh.ReturnRate, 0) AS ReturnRate,
                   ISNULL(rh.AdditionalWeightRate, 0) AdditionalWeightRate
            FROM RateHeader rh
                JOIN RateData rd
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 1
                LEFT JOIN CatRateSegment crs
                    ON crs.CrsId = rd.TypeSegmentId
                LEFT JOIN CatTypeService cts
                    ON cts.CtsId = rd.TypeServiceId
                LEFT JOIN CatTypeRate ctr
                    ON ctr.IdTypeRate = rh.RateTypeId
                JOIN #ParceWeigth pw
                    ON pw.Item
                       BETWEEN rd.WeightFrom AND rd.WeightTo
            WHERE rh.RheId = @IdRate
                  AND rd.TypeSegmentId = @IdSegment
                  AND (rd.TypeServiceId IN
                       (
                           SELECT CtsId
                           FROM CatTypeService
                           WHERE RateGroup = @IdRateGroup
                                 AND CtsRowStatus = 1
                       )
                      )
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                                 CONVERT(
                                                                            DATETIME,
                                                                            ISNULL(
                                                                                      rd.LimitHourPickup,
                                                                                      cts.LimitHourPickup
                                                                                  ),
                                                                            108
                                                                        ),
                                                                 CONVERT(DATETIME, '23:59:59', 108)
                                                             )
            UNION ALL
            SELECT ISNULL(ctr.Name, '') TypeRate,
                   ISNULL(crs.CrsShortName, '') Segment,
                   ISNULL(cts.CtsShortName, '') Service,
                   ISNULL(rd.RateValue, 0) BaseRate,
                   '' DiscountName,
                   0 DiscountValue,
                   IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0) AS fragilRate,
                   IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0) AS CollectedRate,
                   IIF(@IsInsurance = 'true',
                       (IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0),
                            CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
                            0)
                       ),
                       0) AS InsuranceRate,
                   IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate,
                   IIF(pw.Weight <= @WeigthLimit,
                       pw.Weight - rd.WeightTo,
                       IIF(@WeigthLimit > rd.WeightTo, @WeigthLimit - rd.WeightTo, 0)) OverWeightRate,
                   ISNULL(@ParcelPrice, 0) AS IrregularParcelRate,
                   ISNULL(cts.CtsName, '') AS CtsName,
                   ISNULL(cts.CtsDescription, '') AS CtsDescription,
                   ISNULL(rh.ReturnRate, 0) AS ReturnRate,
                   ISNULL(rh.AdditionalWeightRate, 0) AdditionalWeightRate
            FROM RateHeader rh
                JOIN RateData rd
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 1
                LEFT JOIN CatRateSegment crs
                    ON crs.CrsId = rd.TypeSegmentId
                LEFT JOIN CatTypeService cts
                    ON cts.CtsId = rd.TypeServiceId
                LEFT JOIN CatTypeRate ctr
                    ON ctr.IdTypeRate = rh.RateTypeId
                JOIN @tblNotInRange pw
                    ON pw.CatTypeServiceId = rd.TypeServiceId
                       AND rd.IdRateData =
                       (
                           SELECT TOP 1
                                  IdRateData
                           FROM RateData
                           WHERE RateId = @IdRate
                                 AND TypeSegmentId = @IdSegment
                                 AND TypeServiceId = cts.CtsId
                                 AND RowStatus = 1
                           ORDER BY WeightTo DESC
                       )
            WHERE rh.RheId = @IdRate
                  AND rd.TypeSegmentId = @IdSegment
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(
                                                                 CONVERT(
                                                                            DATETIME,
                                                                            ISNULL(
                                                                                      rd.LimitHourPickup,
                                                                                      cts.LimitHourPickup
                                                                                  ),
                                                                            108
                                                                        ),
                                                                 CONVERT(DATETIME, '23:59:59', 108)
                                                             )
        ) X
        GROUP BY TypeRate,
                 Segment,
                 Service,
                 DiscountName,
                 DiscountValue,
                 fragilRate,
                 CollectedRate,
                 InsuranceRate,
                 CreditCardRate,
                 IrregularParcelRate,
                 CtsName,
                 CtsDescription,
                 ReturnRate,
                 AdditionalWeightRate;
    END;
    -- FDD-671 FIN
    ELSE
    BEGIN
        PRINT 'error no se encontro un tarifario';
    END;

    --print 'Respuesta desde tabla temporal'

    IF @FormatResponse = 'Json'
    BEGIN
        DECLARE @jsonResult AS NVARCHAR(MAX);

        -- Desplegar valor base sin IVA
        IF (
               @IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates )
               AND @IdCustomerParams != 0
           )
            SET @CalculateTaxes = 'false';

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Title":"' + ISNULL(tr.ServiceName, '') + '",' + '"Service":"'
                                       + IIF(@IdCustomerParams = 0 AND @IdCustomer = 6,
                                             ISNULL(tr.ServiceName, ''),
                                             ISNULL(tr.Segment, '')) + '",' + '"ServiceDescription":"'
                                       + ISNULL(tr.ServiceDescription, '') + '",' + '"ServiceShortName":"'
                                       + ISNULL(tr.Service, '') + '",' + '"DeliveryDate":"'
                                       + CONVERT(VARCHAR(24), @FechaCompra, 120) + '",'
                                       +
                                    --'"Price":"' + convert(varchar(20), convert(decimal(12,1), (tr.BaseRate -  tr.Discount  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ))) + '",' +
                                    '"Price":"'
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
                                                    + CONVERT(
                                                                 DECIMAL(12, 2),
                                                                 (dbo.fnt_Iva_Calculator(
                                                                                            @CalculateTaxes,
                                                                                            'GT',
                                                                                            (tr.Discount * -1),
                                                                                            'false'
                                                                                        )
                                                                 )
                                                             )
                                                    + CONVERT(
                                                                 DECIMAL(12, 2),
                                                                 dbo.fnt_Iva_Calculator(
                                                                                           @CalculateTaxes,
                                                                                           'GT',
                                                                                           tr.FragilRate,
                                                                                           'false'
                                                                                       )
                                                             )
                                                    + CONVERT(
                                                                 DECIMAL(12, 2),
                                                                 dbo.fnt_Iva_Calculator(
                                                                                           @CalculateTaxes,
                                                                                           'GT',
                                                                                           tr.CollectedRate,
                                                                                           'false'
                                                                                       )
                                                             )
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
                                                             )
                                                    + CONVERT(
                                                                 VARCHAR(20),
                                                                 dbo.fnt_Iva_Calculator(
                                                                                           @CalculateTaxes,
                                                                                           'GT',
                                                                                           tr.CreditCardRate,
                                                                                           'false'
                                                                                       )
                                                             )
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
                                                             )
                                                    + CONVERT(
                                                                 DECIMAL(12, 2),
                                                                 dbo.fnt_Iva_Calculator(
                                                                                           @CalculateTaxes,
                                                                                           'GT',
                                                                                           (CONVERT(
                                                                                                       DECIMAL(12, 2),
                                                                                                       tr.BaseRate
                                                                                                   )
                                                                                            - CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.Discount
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.FragilRate
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.CollectedRate
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.InsuranceRate
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.CreditCardRate
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.OverWeightRate
                                                                                                     )
                                                                                            + CONVERT(
                                                                                                         DECIMAL(12, 2),
                                                                                                         tr.IrregularPieceRate
                                                                                                     )
                                                                                           ),
                                                                                           'true'
                                                                                       )
                                                             )
                                                ) + '",' + '"Currency":"' + @Currency + '",'
                                       + '"Integration":[{"Description":"' + 'Servicio' + '",' + '"Price":"'
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
                                                ) + '",' + '"Currency":"' + @Currency + '"' + '}'
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
                                                      ) + '",' + '"Currency":"' + @Currency + '"' + '}',
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
                                                      ) + '",' + '"Currency":"' + @Currency + '"' + '}',
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
                                                      ) + '",' + '"Currency":"' + @Currency + '"' + '}',
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
                                                      ) + '",' + '"Currency":"' + @Currency + '"' + '}',
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
                                                      ) + '",' + '"Currency":"' + COALESCE(@Currency, '') + '"' + '}',
                                             ' ')
                                       + IIF((ISNULL(tr.Discount, 0)) > 0,
                                             ',{"Description":"' + ISNULL(@DiscountName, '') + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR,
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     (dbo.fnt_Iva_Calculator(
                                                                                                @CalculateTaxes,
                                                                                                'GT',
                                                                                                (tr.Discount * -1),
                                                                                                'false'
                                                                                            )
                                                                     )
                                                                 )
                                                      ) + '",' + '"Currency":"' + COALESCE(@Currency, '') + '"' + '}',
                                             ' ')
                                       + IIF((ISNULL(
                                                        dbo.fnt_Iva_Calculator(
                                                                                  @CalculateTaxes,
                                                                                  'GT',
                                                                                  (CONVERT(DECIMAL(12, 2), tr.BaseRate)
                                                                                   - CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.Discount
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.FragilRate
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.CollectedRate
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.InsuranceRate
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.CreditCardRate
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.OverWeightRate
                                                                                            )
                                                                                   + CONVERT(
                                                                                                DECIMAL(12, 2),
                                                                                                tr.IrregularPieceRate
                                                                                            )
                                                                                  ),
                                                                                  'true'
                                                                              ),
                                                        0
                                                    )
                                             ) > 0,
                                             ',{"Description":"' + 'IVA' + '",' + '"Price":"'
                                             + CONVERT(
                                                          VARCHAR(20),
                                                          CONVERT(
                                                                     DECIMAL(12, 2),
                                                                     dbo.fnt_Iva_Calculator(
                                                                                               @CalculateTaxes,
                                                                                               'GT',
                                                                                               (CONVERT(
                                                                                                           DECIMAL(12, 2),
                                                                                                           tr.BaseRate
                                                                                                       )
                                                                                                - CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.Discount
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.FragilRate
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.CollectedRate
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.InsuranceRate
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.CreditCardRate
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.OverWeightRate
                                                                                                         )
                                                                                                + CONVERT(
                                                                                                             DECIMAL(12, 2),
                                                                                                             tr.IrregularPieceRate
                                                                                                         )
                                                                                               ),
                                                                                               'true'
                                                                                           )
                                                                 )
                                                      ) + '",' + '"Currency":"' + @Currency + '"' + '}',
                                             ' ') + ' ]}'
                                FROM @TempRate tr
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
    ELSE
    BEGIN

        -- Desplegar valor base sin IVA
        IF (
               @IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates )
               AND @IdCustomerParams != 0
           )
            SET @CalculateTaxes = 'false';

        SELECT tr.TypeRate,
               tr.Segment,
               tr.Service,
               (tr.BaseRate - tr.Discount + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.CreditCardRate
                + tr.OverWeightRate + tr.IrregularPieceRate
               ) AS Price,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.BaseRate, 'false') AS BaseRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', (tr.Discount * -1), 'false') AS DiscountValue,
               tr.DiscountName,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.FragilRate, 'false') AS FragilRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.CollectedRate, 'false') AS CollectedRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.InsuranceRate, 'false') AS InsuranceRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.OverWeightRate, 'false') AS OverWeightRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.IrregularPieceRate, 'false') AS IrregularPieceRate,
               dbo.fnt_Iva_Calculator(@CalculateTaxes, 'GT', tr.CreditCardRate, 'false') AS CreditCardRate,
               dbo.fnt_Iva_Calculator(
                                         @CalculateTaxes,
                                         'GT',
                                         (tr.BaseRate - tr.Discount + tr.FragilRate + tr.CollectedRate
                                          + tr.InsuranceRate + tr.CreditCardRate + tr.OverWeightRate
                                          + tr.IrregularPieceRate
                                         ),
                                         'true'
                                     ) AS Iva,
               @FechaCompra [FechaCompra],
               @Currency [Currency],
               tr.ReturnRate [ReturnRate]
        FROM @TempRate tr;
    END;


--PRINT 'precio'

END;