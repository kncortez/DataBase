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
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-12-26>
-- Description:	<Validar si se requiere uso de memrbesia y subscripción4>
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
    @CalculateTaxes BIT = 'false',
    @CalculateMembership BIT = 'false',
    @TypeSubscriptionId INT = NULL
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

    --DECLARE @TarifaPlanBasico INT =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Básico' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanBasicoPlus INT =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanGold INT =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Gold' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanCorporativo INT =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo' COLLATE Latin1_General_CI_AI
    --        );

    --DECLARE @TarifaPlanBasicoAlt INT
    --    =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Básico destinos express center' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanBasicoPlusAlt INT
    --    =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Básico Plus destinos express center' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanGoldAlt INT
    --    =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Gold destinos express center' COLLATE Latin1_General_CI_AI
    --        );
    --DECLARE @TarifaPlanCorporativoAlt INT
    --    =
    --        (
    --            SELECT TOP 1
    --                   RH.RheId
    --            FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
    --            WHERE RH.RheName = 'Tarifa suscripción Plan Corporativo destinos express center' COLLATE Latin1_General_CI_AI
    --        );

    DECLARE @IdRate AS INT;
    DECLARE @IdTypeRate AS INT;
    DECLARE @WeigthLimit AS DECIMAL(12, 2) = 0;
    DECLARE @Currency AS VARCHAR(10) = '';
    DECLARE @PiecesIncluded AS DECIMAL(12, 2) = 1;
    DECLARE @PriceWithCreditCard AS INT = 0;

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

    IF (@CalculateMembership = 1)
    BEGIN

        DECLARE @CustomerHasActiveSubscription INT;

        SELECT @CustomerHasActiveSubscription = SC.IdSubscription
        FROM [DeliveryBackOffice].[dbo].[Subscription] SC WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                ON CSPS.IdCatSalesPackageStatus = SC.CatSubscriptionStatusId
            INNER JOIN [DeliveryBackOffice].[dbo].[Membership] MB WITH (NOLOCK)
                ON SC.MembershipId = MB.IdMembership
                   AND MB.CustomerId = @IdCustomer
                   AND GETDATE() <= MB.ExpirationDate
                   AND MB.RowStatus = 1
            INNER JOIN [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPSM WITH (NOLOCK)
                ON CSPSM.IdCatSalesPackageStatus = MB.CatMembershipStatusId
        WHERE SC.CustomerId = @IdCustomer
              AND GETDATE() <= SC.ExpirationDate
              AND SC.RowStatus = 1
              AND CSPS.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
              AND CSPSM.SalesPackageStatusName = 'Activa' COLLATE Latin1_General_CI_AI
              AND SC.CatTypeSubscriptionId = ISNULL(@TypeSubscriptionId, 2)
        ORDER BY SC.ExpirationDate ASC;

        IF (ISNULL(@CustomerHasActiveSubscription, 0) > 0)
        BEGIN

            -- Destino es un express center activo, aplicar tarifa destino express center de suscripción
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

                -- Si falla en encontrar tarifa "valida", defecto la tarifa actual
                SELECT @RateId = ISNULL(ISNULL(SC.AlternativeRateHeaderId, CS.AlternativeRateHeaderId), @IdRate)
                FROM [DeliveryBackOffice].[dbo].[Subscription] SC WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
                        ON SC.CatSubscriptionId = CS.IdCatSubscription
                WHERE SC.IdSubscription = @CustomerHasActiveSubscription;

                SET @IdRate = @RateId;
            END;
            ELSE
            BEGIN
                -- Destino no es express center activo, aplicar tarifa base de suscripción

                -- Si falla en encontrar tarifa "valida", defecto la tarifa actual
                SELECT @RateId = ISNULL(ISNULL(SC.RateHeaderId, CS.RateHeaderId), @IdRate)
                FROM [DeliveryBackOffice].[dbo].[Subscription] SC WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
                        ON SC.CatSubscriptionId = CS.IdCatSubscription
                WHERE SC.IdSubscription = @CustomerHasActiveSubscription;

                SET @IdRate = @RateId;
            END;

        END;
    END;

    --IF (@IdCustomerParams = 0 AND @IdCustomer = 6)
    --BEGIN

        SET @CalculateTaxes = 'false';

    --END;

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
                                    1
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

	PRINT '@IdHubSource'
	PRINT @IdHubSource
	PRINT '@IdHubDestiny'
	PRINT @IdHubDestiny

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
        IF (@CustomerType != 1)
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
        ELSE
        BEGIN
            SELECT TOP 1
                   @IdSegment = CTC.SegmentTypeId
            FROM [DeliveryBackOffice].[dbo].[CorporateTownshipCoverage] CTC WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnSource WITH (NOLOCK)
                    ON CTC.TownshipSourceId = TwnSource.IdTownship
                INNER JOIN [DeliveryBackOffice].[dbo].[Township] TwnDestiny WITH (NOLOCK)
                    ON CTC.TownshipDestinyId = TwnDestiny.IdTownship
            WHERE (TwnSource.HeaderCode = @HeaderCodeSource)
                  AND (TwnDestiny.HeaderCode = @HeaderCodeDestiny)
                  AND CTC.RowStatus = 1;
        END;

    END;

    IF @IdSegment IS NULL -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
    BEGIN

        SELECT TOP 1
               @IdSegment = sg.CrsId
        FROM [DeliveryBackOffice].dbo.CatRateSegment sg WITH (NOLOCK)
        WHERE sg.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI;
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
	
    -- Hotfix - Andrés Ruíz - 17-02-2023
    IF (
           (
               LTRIM(RTRIM(REPLACE(@ParcelCode, ',', ''))) = ''
               OR LTRIM(RTRIM(REPLACE(@ParcelCode, ',', ''))) = '0'
           )
           AND @IdTypeRate = 3
       )
    BEGIN

        DECLARE @DataCounter INT = 1;

        SET @ParcelCode = N'EXP076';

        IF (@DataCounter < @CountPiecesParams)
        BEGIN
            WHILE @DataCounter < @CountPiecesParams
            BEGIN

                SET @ParcelCode = CONCAT(@ParcelCode, ',EXP076');

                SET @DataCounter = @DataCounter + 1;

            END;
        END;

    END;
    -- Fin hotfix

    IF OBJECT_ID('tempdb.dbo.#ParceCode', 'U') IS NOT NULL
        DROP TABLE #ParceCode;
    IF OBJECT_ID('tempdb.dbo.#ParceWeigth', 'U') IS NOT NULL
        DROP TABLE #ParceWeigth;

    SELECT Item,
           ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID
    INTO #ParceCode
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',');

	IF ( @IdTypeRate = 3 )
	BEGIN
	    
		UPDATE
			[#ParceCode]
		SET
			[Item] = 'EXP076'
		WHERE
			LTRIM(RTRIM(ISNULL([Item], ''))) = ''

	END

    SELECT Item,
           ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID
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
        Id INT IDENTITY(1, 1),
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

	PRINT '@IdRateGroup'
	PRINT @IdRateGroup


    IF @IdTypeRate = 1 -- tarifas estandar
    BEGIN
        --print 'aqui van las tarifas standar'
        DECLARE @CountPiecebyArticle INT = 0;
        DECLARE @ParcelPrice2 DECIMAL(12, 2) = 0;

        SET @CountPiecebyArticle =
        (
            SELECT COUNT(1)
            FROM #ParceWeigth pw
                INNER JOIN #ParceCode pc
                    ON pc.ID = pw.ID
            WHERE pc.Item <> '0'
                  AND pc.Item <> ''
                  AND pc.Item <> 'EXP076'
                  AND pc.Item <> 'EXP077'
                  AND pc.Item <> 'EXP078'
                  AND pc.Item <> 'EXP079'
                  AND pc.Item <> 'EXP080'
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
                INNER JOIN dbo.ArticleByCustomer ar
                    ON ar.Code = ls.Item
                INNER JOIN dbo.RateData ra
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
                            CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
                INNER JOIN dbo.RateData rd WITH (NOLOCK)
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
                            CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
                INNER JOIN dbo.RateData rd WITH (NOLOCK)
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
                        CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
            INNER JOIN dbo.RateData rd WITH (NOLOCK)
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

                IF (@IdSegment IS NULL) -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.
                BEGIN
                    SELECT TOP 1
                           @IdSegment = sg.CrsId
                    FROM [DeliveryBackOffice].dbo.CatRateSegment sg WITH (NOLOCK)
                    WHERE sg.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI;
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
		
            -- Paquetes con su peso indicado
            IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerTypeCorp', 'U') IS NOT NULL
                DROP TABLE #ParcelOverweightPerTypeCorp;
				
			DECLARE @DefaultWeighRatetOfRate DECIMAL(12,2) = 0;
			DECLARE @DefaultWeightOfRate DECIMAL(18,2) = 0;

			SET @DefaultWeighRatetOfRate = (
				SELECT 
					TOP (1) 
						RH.[AdditionalWeightRate]
				FROM 
					[DeliveryBackOffice].[dbo].[RateHeader] RH  WITH(NOLOCK) 
				WHERE
					RH.[RheId] = @IdRate
			)

			SET @DefaultWeightOfRate = (
				SELECT 
					TOP (1) 
						RH.[WeightLimit]
				FROM 
					[DeliveryBackOffice].[dbo].[RateHeader] RH  WITH(NOLOCK) 
				WHERE
					RH.[RheId] = @IdRate
			)

            DECLARE @ExpectedWeightCorp DECIMAL(12, 2) = 0;

            SELECT p.ID 'RowNumber',
                    ABC.Code 'ParcelCode',
                    (
						CASE 
							WHEN RD.[IdRateData] IS NULL THEN @DefaultWeightOfRate
							ELSE CAST(PW.[Item] AS DECIMAL(12, 2))
						END
					) 'ParcelWeight'
            INTO #ParcelOverweightPerTypeCorp
            FROM #ParceCode p
				INNER JOIN [#ParceWeigth] PW
				ON
					P.[ID] = PW.[ID]
                INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH (NOLOCK)
                    ON p.Item = ABC.Code COLLATE Latin1_General_CI_AI
                        AND ABC.AbcRowStatus = 1
				OUTER APPLY
				(
					SELECT 
						TOP (1) 
							RD.[IdRateData]
					FROM 
						 [DeliveryBackOffice].[dbo].[RateData] RD  WITH(NOLOCK) 
					WHERE [RD].[ArticleId] = [ABC].[AbcId]
					AND [RD].[RateId] = @IdRate
				) RD;

            SET @ExpectedWeightCorp =
            (
                SELECT SUM(POPT.ParcelWeight) FROM #ParcelOverweightPerTypeCorp POPT
            );

            BEGIN TRY

                SET @OverWeight =
                (
                    SELECT SUM(CAST(ROUND(CAST(PW.Item AS DECIMAL(12, 2)), 0) AS INT))
                    FROM #ParceWeigth PW
                );

            END TRY
            BEGIN CATCH

                SET @OverWeight = @ExpectedWeightCorp;

            END CATCH;

            DECLARE @NewOverWeightCorp DECIMAL(12, 2) = 0;
            SET @NewOverWeightCorp = (@OverWeight - @ExpectedWeightCorp);

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
                   x.OverWeightRate + CAST((IIF(@NewOverWeightCorp > 0, @NewOverWeightCorp * ISNULL(@DefaultWeighRatetOfRate, 0), 0)) AS DECIMAL(12,2)),
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
                       0 OverWeightRate,
                       ISNULL(rd.RateValue, ISNULL(ar.PriceDefault, 0)) AS IrregularParcelRate,
                       ISNULL(sv.CtsName, '') AS CtsName,
                       ISNULL(sv.CtsDescription, '') AS CtsDescription,
                       ISNULL(rh.ReturnRate, 0) AS ReturnRate
                FROM #ParceCode ls
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
                UNION ALL
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
                       0 OverWeightRate,
                       ISNULL(rd.RateValue, ISNULL(ar.PriceDefault, 0)) AS IrregularParcelRate,
                       ISNULL(sv.CtsName, '') AS CtsName,
                       ISNULL(sv.CtsDescription, '') AS CtsDescription,
                       ISNULL(rh.ReturnRate, 0) AS ReturnRate
                FROM #ParceCode ls
                    INNER JOIN dbo.ArticleByCustomer ar WITH (NOLOCK)
                        ON ar.Code = ls.Item
                    INNER JOIN dbo.RateHeader rh WITH (NOLOCK)
                        ON rh.RheId = @IdRate
                    LEFT JOIN dbo.RateData rdignore WITH (NOLOCK) -- Ignorar artículos sin codigo dentro de tarifario
                        ON rdignore.ArticleId = ar.AbcId
                           AND rdignore.RateId = rh.RheId
                           AND rdignore.RowStatus = 'true'
                    LEFT JOIN dbo.RateData rd WITH (NOLOCK)
                        ON rd.ArticleId IS NULL
                           AND rd.RateId = rh.RheId
                           AND rd.RowStatus = 'true'
                    LEFT JOIN dbo.CatRateSegment sg WITH (NOLOCK)
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN dbo.CatTypeService sv WITH (NOLOCK)
                        ON sv.CtsId = rd.TypeServiceId
                    LEFT JOIN dbo.CatTypeRate cr WITH (NOLOCK)
                        ON cr.IdTypeRate = rh.RateTypeId
                WHERE rdignore.IdRateData IS NULL -- Ignorar artículos sin codigo dentro de tarifario
                      AND rd.TypeSegmentId = @IdSegment
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

            IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerTypeCorp', 'U') IS NOT NULL
                DROP TABLE #ParcelOverweightPerTypeCorp;

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
                            CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
                INNER JOIN RateData rd
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 1
                LEFT JOIN CatRateSegment crs
                    ON crs.CrsId = rd.TypeSegmentId
                LEFT JOIN CatTypeService cts
                    ON cts.CtsId = rd.TypeServiceId
                LEFT JOIN CatTypeRate ctr
                    ON ctr.IdTypeRate = rh.RateTypeId
                INNER JOIN #ParceWeigth pw
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
                            CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
                INNER JOIN RateData rd
                    ON rd.RateId = rh.RheId
                       AND rd.RowStatus = 1
                LEFT JOIN CatRateSegment crs
                    ON crs.CrsId = rd.TypeSegmentId
                LEFT JOIN CatTypeService cts
                    ON cts.CtsId = rd.TypeServiceId
                LEFT JOIN CatTypeRate ctr
                    ON ctr.IdTypeRate = rh.RateTypeId
                INNER JOIN @tblNotInRange pw
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
    ELSE IF @IdTypeRate = 6 -- tarifas coberturas
    BEGIN
        SET @CountPiece = dbo.FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded);

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
                        CAST(((@InsuranceAmount) * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2)),
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
            INNER JOIN dbo.RateData rd WITH (NOLOCK)
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
    ELSE
    BEGIN
        PRINT 'error no se encontro un tarifario';
    END;

    /* Membresías y Suscripciones */
    -- Oscar Morales 2022-07-18
    /* Actualización: Aplicar descuento únicamente a costo base 
	   Autor: Jerson Ochoa 30-12-2022 */

    IF @CalculateMembership = 'true'
    BEGIN
        DECLARE @PriceShippment DECIMAL(14, 2);
        DECLARE @MembershipId INT;
        DECLARE @ServiceValue DECIMAL(14, 2) = 0;
        DECLARE @Discount DECIMAL(18, 2) = 0;
        DECLARE @NewPriceShippment DECIMAL(14, 2);
        --DECLARE @CatMembershipStatusId INT
        DECLARE @SubscriptionId INT;
        DECLARE @ServiceValueSubscription DECIMAL(14, 2) = 0;
        DECLARE @DiscountValue DECIMAL(5, 2);
        DECLARE @DescriptionTypeSubscription NVARCHAR(50);
        DECLARE @Type NVARCHAR(50);
        DECLARE @DiscountValue2 DECIMAL(5, 2);
        DECLARE @Type2 NVARCHAR(50);

        DECLARE @i INT = 0;
        DECLARE @total INT = ISNULL(
                             (
                                 SELECT MAX(Id)FROM @TempRate
                             ),
                             0
                                   );

        --Se busca si existe una membresía activa
        SELECT TOP 1
               @MembershipId = ms.IdMembership,
               --,@CatMembershipStatusId = ms.CatMembershipStatusId
               @ServiceValue
                   = IIF(ms.ActualServiceCount + 1 <= ms.MembershipMaxServiceFixedValue, ms.MembershipFixedValue, -1)
        FROM Membership ms
            INNER JOIN CatSalesPackageStatus csps
                ON csps.IdCatSalesPackageStatus = ms.CatMembershipStatusId
        WHERE ms.CustomerId = @IdCustomer
              AND GETDATE() <= ms.ExpirationDate
              AND ms.RowStatus = 1
              AND csps.SalesPackageStatusName = 'Activa'
        ORDER BY ms.DateCreated DESC;

        --Si existe una membresía
        IF @MembershipId IS NOT NULL
        BEGIN
            --Se busca membresía por rango de servicios
            SELECT TOP 1
                   @DiscountValue2 = DiscountValue,
                   @Type2 = cvt.ValueTypeName
            FROM MembershipDiscountRange mdr
                INNER JOIN Membership ms
                    ON ms.IdMembership = mdr.MembershipId
                INNER JOIN CatValueType cvt
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

            --Se busca suscripciones 
            IF (@TypeSubscriptionId > 0)
                DECLARE @NameTypeSubscrition VARCHAR(50);

            SET @NameTypeSubscrition =
            (
                SELECT CatTypeSubscriptionName
                FROM CatTypeSubscription
                WHERE IdCatTypeSubscription = @TypeSubscriptionId
            )
            BEGIN
                IF (@NameTypeSubscrition = 'Porcentaje')
                BEGIN
                    SELECT TOP 1
                        @SubscriptionId = sc.IdSubscription,
                        @ServiceValueSubscription
                            = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue,
                                  sc.SubscriptionFixedValue,
                                  -1),
                        @DescriptionTypeSubscription = cts.CatTypeSubscriptionName
                    FROM Subscription sc
                        INNER JOIN CatSalesPackageStatus csps
                            ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
                        INNER JOIN CatTypeSubscription cts
                            ON sc.CatTypeSubscriptionId = cts.IdCatTypeSubscription
                        INNER JOIN SubscriptionDiscountRange scdr
                            ON sc.IdSubscription = scdr.SubscriptionId
                    WHERE sc.CustomerId = @IdCustomer
                          AND GETDATE() <= sc.ExpirationDate
                          AND sc.RowStatus = 1
                          AND csps.SalesPackageStatusName = 'Activa'
                          --AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
                          AND sc.CatTypeSubscriptionId = @TypeSubscriptionId
                    ORDER BY scdr.DiscountValue DESC
                END
                ELSE IF (@NameTypeSubscrition = 'Monto Fijo')
                BEGIN
                    SELECT TOP 1
                        @SubscriptionId = sc.IdSubscription,
                        @ServiceValueSubscription
                            = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue,
                                  sc.SubscriptionFixedValue,
                                  -1),
                        @DescriptionTypeSubscription = cts.CatTypeSubscriptionName
                    FROM Subscription sc
                        INNER JOIN CatSalesPackageStatus csps
                            ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
                        INNER JOIN CatTypeSubscription cts
                            ON sc.CatTypeSubscriptionId = cts.IdCatTypeSubscription
                    WHERE sc.CustomerId = @IdCustomer
                          AND GETDATE() <= sc.ExpirationDate
                          AND sc.RowStatus = 1
                          AND csps.SalesPackageStatusName = 'Activa'
                          AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
                          AND sc.CatTypeSubscriptionId = @TypeSubscriptionId
                    ORDER BY sc.IdSubscription ASC
                END

            END




            /* SELECT TOP 1
                   @SubscriptionId = sc.IdSubscription
                 , @ServiceValueSubscription
                                   = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue
                          , sc.SubscriptionFixedValue
                          , -1)
            FROM Subscription                    sc
                INNER JOIN CatSalesPackageStatus csps
                    ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId
            WHERE sc.CustomerId = @IdCustomer
                  AND GETDATE() <= sc.ExpirationDate
                  AND sc.RowStatus = 1
                  AND csps.SalesPackageStatusName = 'Activa'
                  AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo
            ORDER BY sc.IdSubscription ASC;*/
            --ORDER BY sc.ExpirationDate;

            --Se busca membresía por rango de servicios
            SELECT TOP 1
                   @DiscountValue = DiscountValue,
                   @Type = cvt.ValueTypeName
            FROM SubscriptionDiscountRange sdr
                INNER JOIN Subscription sc
                    ON sc.IdSubscription = sdr.SubscriptionId
                INNER JOIN CatValueType cvt
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

            WHILE @i < @total
            BEGIN
                SET @i = @i + 1;

                SELECT @PriceShippment = (tr.BaseRate + tr.IrregularPieceRate)
                FROM @TempRate tr
                WHERE Id = @i;

                --Si tiene precio
                IF @PriceShippment IS NOT NULL
                   AND @PriceShippment > 0
                BEGIN
                    --Si es tarifa fija
                    IF @ServiceValue >= 0
                    BEGIN
                        IF (@ServiceValue = 0)
                        BEGIN
                            SELECT @Discount = (@PriceShippment + tr.CreditCardRate),
                                   @NewPriceShippment
                                       = (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.OverWeightRate)
                            FROM @TempRate tr
                            WHERE Id = @i;
                            SET @PriceWithCreditCard = 1;
                        END;
                        ELSE
                        BEGIN
                            SET @Discount = @PriceShippment - @ServiceValue;
                            SELECT @NewPriceShippment
                                = (@ServiceValue + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate
                                   + tr.CreditCardRate + tr.OverWeightRate
                                  )
                            FROM @TempRate tr
                            WHERE Id = @i;
                        END;
                    END;
                    ELSE
                    BEGIN
                        --Si existe una suscripción
                        IF @SubscriptionId IS NOT NULL
                        BEGIN
                            --Si es tarifa fija
                            IF @ServiceValueSubscription >= 0
                                IF (@ServiceValueSubscription = 0)
                                BEGIN

                                    /*SELECT @Discount --= @DiscountValue
									= (@PriceShippment + tr.CreditCardRate)
                                         , @NewPriceShippment
                                                     = (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate
                                                        + tr.OverWeightRate
                                                       )*/
                                    SELECT @Discount
                                        = --IIF(@DescriptionTypeSubscription = 'Porcentaje', (tr.IrregularPieceRate * (@DiscountValue/100)),@DiscountValue)
                                        IIF(@DescriptionTypeSubscription = 'Porcentaje',
                                            (tr.IrregularPieceRate * (@DiscountValue / 100)),
                                            (IIF(@DiscountValue IS NULL, tr.IrregularPieceRate, @DiscountValue))),
                                           @NewPriceShippment
                                               = (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate
                                                  + tr.OverWeightRate
                                                 )
                                    FROM @TempRate tr
                                    WHERE Id = @i;
                                    SET @PriceWithCreditCard = 1;
                                END;
                                ELSE
                                BEGIN
                                    SET @Discount = @PriceShippment - @ServiceValueSubscription;
                                    SELECT @NewPriceShippment
                                        = (@ServiceValueSubscription + tr.FragilRate + tr.CollectedRate
                                           + tr.InsuranceRate + tr.CreditCardRate + tr.OverWeightRate
                                          )
                                    FROM @TempRate tr
                                    WHERE Id = @i;
                                END;
                            ELSE
                            BEGIN
                                IF @DiscountValue IS NOT NULL
                                BEGIN
                                    IF @Type = 'Porcentaje'
                                    BEGIN
                                        SET @Discount = @PriceShippment * (@DiscountValue / 100);
                                    END;
                                    ELSE IF @Type = 'Monto'
                                    BEGIN
                                        SET @Discount = @DiscountValue;
                                    END;
                                    ELSE IF @Type = 'Servicio'
                                    BEGIN
                                        SET @Discount = @PriceShippment;
                                    END;

                                    SELECT @NewPriceShippment
                                        = (@PriceShippment - @Discount)
                                          + (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.CreditCardRate
                                             + tr.OverWeightRate
                                            )
                                    FROM @TempRate tr
                                    WHERE Id = @i;

                                    IF @NewPriceShippment < 0
                                    BEGIN
                                        SET @Discount = @PriceShippment;
                                        SET @NewPriceShippment = 0;
                                    END;
                                END;
                            END;
                        END;

                        IF @SubscriptionId IS NULL
                           OR @Discount = 0
                        BEGIN
                            --Tarifa por rango de servicios (Membresía)
                            IF @DiscountValue2 IS NOT NULL
                            BEGIN
                                IF @Type2 = 'Porcentaje'
                                BEGIN
                                    SET @Discount = @PriceShippment * (@DiscountValue2 / 100);
                                END;
                                ELSE IF @Type2 = 'Monto'
                                BEGIN
                                    SET @Discount = @DiscountValue2;
                                END;
                                ELSE IF @Type2 = 'Servicio'
                                BEGIN
                                    SET @Discount = @PriceShippment;
                                END;

                                SELECT @NewPriceShippment
                                    = (@PriceShippment - @Discount)
                                      + (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.CreditCardRate
                                         + tr.OverWeightRate
                                        )
                                FROM @TempRate tr
                                WHERE Id = @i;

                                IF @NewPriceShippment < 0
                                BEGIN
                                    SET @Discount = @PriceShippment;
                                    SET @NewPriceShippment = 0;
                                END;
                            END;
                        END;
                    END;

                    /* IF @Discount > 0
                    BEGIN
                        UPDATE @TempRate
                        SET Discount = @Discount
                          , DiscountName = 'Descuento membresía'
                        WHERE Id = @i;
                    END;*/
                    IF @Discount > 0
                       AND @NameTypeSubscrition = 'Monto Fijo'
                       AND @IsCollected = 1
                    BEGIN
                        UPDATE @TempRate
                        SET Discount = 0,
                            DiscountName = 'No puede utilizar la suscripción de monto fijo con un servicio collect'
                        WHERE Id = @i;
                    END;
                    ELSE IF (@Discount > 0)
                    BEGIN
                        UPDATE @TempRate
                        SET Discount = @Discount,
                            DiscountName = 'Descuento membresía'
                        WHERE Id = @i;
                    END;
                END;
            END;
        END;
    END;
    /* Termina membresías y suscripciones */

    --print 'Respuesta desde tabla temporal'

    IF @FormatResponse = 'Json'
    BEGIN
        DECLARE @jsonResult AS NVARCHAR(MAX);

        -- Desplegar valor base sin IVA
        IF (
               --@IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates, @TarifaPlanBasico,
               --             @TarifaPlanBasicoPlus, @TarifaPlanGold, @TarifaPlanCorporativo, @TarifaPlanBasicoAlt,
               --             @TarifaPlanBasicoPlusAlt, @TarifaPlanGoldAlt, @TarifaPlanCorporativoAlt
               --           )
			     @IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates
                          )
               AND @IdCustomerParams != 0
           )
            SET @CalculateTaxes = 'false';

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Title":"' + ISNULL(tr.ServiceName, '') + '",' + '"UseMembership":"'
                                       + CONVERT(VARCHAR(1), @CalculateMembership) + '",' + '"Service":"'
                                       + IIF(@IdCustomerParams = 0 AND @IdCustomer = 6,
                                             ISNULL(tr.ServiceName, ''),
                                             ISNULL(tr.Segment, '')) + '",' + '"ServiceDescription":"'
                                       + ISNULL(tr.ServiceDescription, '') + '",' + '"ServiceShortName":"'
                                       + ISNULL(tr.Service, '') + '",' + '"DeliveryDate":"'
                                       + CONVERT(VARCHAR(24), @FechaCompra, 120) + '",' + '"Price":"'
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
                                             ',{"Description":"' + 'Otros recargos' + '",' + '"Price":"'
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
                                             ',{"Description":"' + ISNULL(tr.DiscountName, '') + '",' + '"Price":"'
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
               --@IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates, @TarifaPlanBasico,
               --             @TarifaPlanBasicoPlus, @TarifaPlanGold, @TarifaPlanCorporativo, @TarifaPlanBasicoAlt,
               --             @TarifaPlanBasicoPlusAlt, @TarifaPlanGoldAlt, @TarifaPlanCorporativoAlt
               --)
               @IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates )
               AND @IdCustomerParams != 0
           )
            SET @CalculateTaxes = 'false';

        SELECT tr.TypeRate,
               tr.Segment,
               tr.Service,
               IIF(@PriceWithCreditCard = 1,
                   (tr.BaseRate - tr.Discount + tr.IrregularPieceRate + tr.CreditCardRate),
                   (tr.BaseRate - tr.Discount + tr.IrregularPieceRate)) AS Price, --  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ) as Price
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