-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

ALTER PROCEDURE [dbo].[spws_get_price_courierapp]
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
	DECLARE @CountryId NVARCHAR(2) =(Select top 1 ISNULL(C.CountryId,'GT') From 
										dbo.SchedulePickup A WITH(NOLOCK)
										INNER JOIN
										dbo.Account B WITH(NOLOCK)
										ON A.AccountId= B.AccIdAccount
										INNER JOIN 
							 			dbo.customer C WITH(NOLOCK)
										ON B.IdCustomer = C.IdCustomer
										Where A.SchedulePickupid=@IdPickup	
	);

	DECLARE @CurrencyPriceCodeISO NVARCHAR(4)=(select CodeISO from [DeliveryBackOffice].[dbo].[CatCurrencyCOD]
                                               Where CodeISO like '%'+ @CountryId+'%');
	DECLARE @CurrencyPriceSymbol NVARCHAR(2)=(select Symbol from [DeliveryBackOffice].[dbo].[CatCurrencyCOD]
                                               Where CodeISO like '%'+ @CountryId+'%')

 

    DECLARE @TokenAct INT =1;
           
    DECLARE @hourtoken INT = 8;
          


    IF ((@TokenAct = 1 AND @hourtoken <= 8) OR 1 = 1)
    BEGIN
        
        DECLARE @test INT = 0
                

        IF (@test = 0)
        BEGIN


            SET @jsonDetail =
            (
                SELECT STUFF(
                                (
                                    SELECT DISTINCT
                                           ',{"GuideSerie":"FD",'
										   + '"GuideNumber":"0",'
                                           + '"Amount":"0",'
										   + '"PickupRate":"'
                                           + CONVERT(VARCHAR, '0.00') + +'"}'
                                  
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
                                    SELECT ',{"Amount":"' + CONVERT(VARCHAR,  0) + '",'
                                           + '"PickupRate":"' + CONVERT(VARCHAR,  0) + '",'
										   + '"CurrencyPrice_CODCodeISO":"' + CONVERT(VARCHAR,  0) + '",'
                                           + '"CurrencyPrice_CODSymbol":"' +  CONVERT(VARCHAR,  0) + '",'
                                           + '"CurrencyPriceCodeISO":"' +  CONVERT(VARCHAR, ISNULL(@CurrencyPriceCodeISO , 0)) + '",'
                                           + '"CurrencyPriceSymbol":"' +  CONVERT(VARCHAR, ISNULL(@CurrencyPriceSymbol , 0)) + '",'
                                           + '"Collect":"' + 'false' + +'"}'
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
                                    SELECT ',{"Error":"' + ISNULL(CONVERT(VARCHAR, 0), 'N/A') + +'"}'
                                   
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
                                    SELECT ',{"Message":"' + ISNULL(CONVERT(NVARCHAR(MAX), 'error'), 'N/A') + +'"}'
                                   
                                  
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