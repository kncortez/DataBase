-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_price_courierapp]
    -- Add the parameters for the stored procedure here
    -- Add the parameters for the stored procedure here
    @Token VARCHAR(200),
    @IdPickup BIGINT,
    @InGuides NVARCHAR(MAX)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonSummary NVARCHAR(MAX);
    DECLARE @jsonDetail NVARCHAR(MAX);

    DECLARE @jsonResult NVARCHAR(MAX);


    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @jsonToken NVARCHAR(MAX);

    DECLARE @PickupRate DECIMAL(12, 2) =
            (
                SELECT TOP 1
                       ISNULL(ct.Value, 15)
                FROM dbo.CatToCharge ct
                WHERE ct.Name = 'PickupRate'
            ); -- tarifa de recoleccion 

    IF OBJECT_ID('tempdb.dbo.#BrainProcessedGuides', 'U') IS NOT NULL
        DROP TABLE #BrainProcessedGuides;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;

    DECLARE @TokenAct INT =
            (
                SELECT TOP 1
                       RowStatus
                FROM LogTokenPOD WITH (NOLOCK)
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
                ORDER BY DateCreated DESC
            );
    DECLARE @hourtoken INT =
            (
                SELECT TOP 1
                       DATEDIFF(HOUR, DateCreated, GETDATE()) AS horas
                FROM LogTokenPOD WITH (NOLOCK)
                WHERE LogTokenPOD LIKE '%' + @Token + '%'
                ORDER BY DateCreated DESC
            );


    IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
    BEGIN
        CREATE TABLE #Temp
        (
            Guide VARCHAR(255),
            Message VARCHAR(255),
        );
        INSERT INTO #Temp
        (
            Guide,
            Message
        )
        EXEC [dbo].[spws_get_validate_guides_pickup] @InGuides = @InGuides,
                                                     @IdPickup = @IdPickup,
                                                     @Token = @Token;

        DECLARE @test INT =
                (
                    SELECT COUNT(*)FROM #Temp
                );

        IF (@test = 0)
        BEGIN

            CREATE TABLE #BrainProcessedGuides
            (
                GuideSerie NVARCHAR(2),
                GuideNumber INT,
                IsCollect BIT,
                Price DECIMAL(18, 2),
                COD DECIMAL(18, 2),
                AmountPaid DECIMAL(18, 2),
                CODPaid DECIMAL(18, 2),
                CODIsPaid BIT,
                PaymentTime INT,
                TimeSequence INT,
                FelNumber NVARCHAR(50),
                IsPaid BIT,
                IsCustomer INT,
                ConditionPayment NVARCHAR(200),
                HaveCredit BIT,
                CollectCOD BIT,
                ReturnRate DECIMAL(5, 2),
                CurrencyPrice_CODCodeISO NVARCHAR(8),
		        CurrencyPrice_CODSymbol  NVARCHAR(8),
		        CurrencyPriceCodeISO     NVARCHAR(8),
		        CurrencyPriceSymbol      NVARCHAR(8),
                AmountToPay DECIMAL(18, 2),
                CODAmount DECIMAL(18, 2),
                ReturnRates DECIMAL(5, 2)
            );

            INSERT INTO #BrainProcessedGuides
            EXEC [dbo].[spws_get_guide_pending_payment] @InGuides, -- Guías recibidas
                                                        2,         -- Tiempo de pago 2 - En recolección
                                                        0,         -- No es retorno
                                                        '',        -- Codeapp
                                                        1,         -- Identificador de modulo donde proviene
                                                        @Token;    -- Token de courier

            SET @jsonDetail =
            (
                SELECT STUFF(
                                (
                                    SELECT DISTINCT
                                           ',{"GuideSerie":"' + ISNULL(tbl.GuideSerie, 'N/A') + '",' + '"GuideNumber":"'
                                           + ISNULL(CONVERT(VARCHAR, tbl.GuideNumber), 'N/A') + '",' + '"Amount":"'
                                           + ISNULL(CONVERT(VARCHAR, tbl.AmountToPay), '0.00') + '",' + '"PickupRate":"'
                                           + CONVERT(VARCHAR, '0.00') + +'"}'
                                    FROM #BrainProcessedGuides tbl
                                    GROUP BY tbl.GuideSerie,
                                             tbl.GuideNumber,
                                             tbl.AmountToPay
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            -- no agrupar para resumen

            SET @jsonSummary =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Amount":"' + CONVERT(VARCHAR, ISNULL(SUM(tbl.AmountToPay), 0)) + '",'
                                           + '"PickupRate":"' + CONVERT(VARCHAR, ISNULL(@PickupRate, 0)) + '",'
										   + '"CurrencyPrice_CODCodeISO":"' + CONVERT(VARCHAR, ISNULL(tbl.CurrencyPrice_CODCodeISO, 0)) + '",'
                                           + '"CurrencyPrice_CODSymbol":"' +  CONVERT(VARCHAR, ISNULL(tbl.CurrencyPrice_CODSymbol, 0)) + '",'
                                           + '"CurrencyPriceCodeISO":"' +  CONVERT(VARCHAR, ISNULL(tbl.CurrencyPriceCodeISO , 0)) + '",'
                                           + '"CurrencyPriceSymbol":"' +  CONVERT(VARCHAR, ISNULL(tbl.CurrencyPriceSymbol , 0)) + '",'
                                           + '"Collect":"' + 'false' + +'"}'
                                    FROM #BrainProcessedGuides tbl
									GROUP BY tbl.CurrencyPrice_CODCodeISO,
										tbl.CurrencyPrice_CODSymbol,
										tbl.CurrencyPriceCodeISO,
										tbl.CurrencyPriceSymbol 
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            ------ unir encabezado y detalle para resultado

			PRINT '@jsonDetail'
			PRINT @jsonDetail

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":200' + ',' + '"Summary":[' + @jsonSummary + '],' + '"Detail":['
                                           + @jsonDetail + ']' + ''
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );




            -- retornar resultado en formato json
            IF @jsonResult IS NULL
            BEGIN
                -- it was chanced idResult from 412 to 204 18/02/2022
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{"IdResult":204,' + '"Message":" No se encontraron registros"'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
            --end 18/02/2022
            SELECT ('{' + @jsonResult + '}') jsonResult;


        END;

        ELSE IF (@test > 0)
        BEGIN
            SET @jsonResult1 =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Error":"' + ISNULL(CONVERT(VARCHAR, Guide), 'N/A') + +'"}'
                                    FROM #Temp
                                    WHERE Guide IN
                                          (
                                              SELECT Guide FROM #Temp
                                          )
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            PRINT @jsonResult1;

            SET @jsonResult2 =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"Message":"' + ISNULL(CONVERT(NVARCHAR(MAX), Message), 'N/A') + +'"}'
                                    FROM #Temp
                                    WHERE Guide IN
                                          (
                                              SELECT Guide FROM #Temp
                                          )
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );

            PRINT @jsonResult2;
            SET @jsonError =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":412' + ',' + '"Guides":[' + @jsonResult1 + '],' + '"Messege":['
                                           + @jsonResult2 + ']' + ''
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
            PRINT @jsonError;

            SELECT ('{' + @jsonError + '}') jsonError;

        END;

    END;

    ELSE IF (@TokenAct = 0 OR @TokenAct IS NULL OR @hourtoken > 8)
    BEGIN
        PRINT 'token inválido';
        SET @jsonToken =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdError":' + '403' + ',' + '"DescriptionError":"' + 'Token inválido' + '"'
                                       + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        SELECT '[' + @jsonToken + ']' jsonToken;

        RETURN;
    END;

END;
--select * from dbo.RouteAssigment
GO

