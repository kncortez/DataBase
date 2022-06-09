
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-26>
-- Description:	<Descuenta o canjea puntos de tarjeta club forza>
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_RedeemPoints]
    -- Add the parameters for the stored procedure here
    @PromoCard NVARCHAR(50),
    @IdCustomer INT,
    @Token NVARCHAR(50),
    @IdSystem INT,
    @IdModule INT,
    @RedeemPoint DECIMAL(12, 2),
    @RedeemAmount DECIMAL(12, 2),
    @GuideSerie VARCHAR(2),
    @GuideNumer INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @RedeenFactorDefault DECIMAL(12, 2);
    DECLARE @RedeenmIdDefault DECIMAL(12, 2);
    DECLARE @RedeenNameDefault VARCHAR(50);

    DECLARE @RedeenFactor DECIMAL(12, 2);
    DECLARE @RedeemId DECIMAL(12, 2);
    DECLARE @RedeenName VARCHAR(50);



    SELECT TOP 1
           @RedeenFactorDefault = ISNULL(rd.Factor, 0),
           @RedeenmIdDefault = ISNULL(rd.IdRedeem, 1),
           @RedeenNameDefault = ISNULL(rd.TypeName, '')
    FROM dbo.RedeemType rd
    WHERE rd.RedeemDefault = 'true'
    ORDER BY rd.IdRedeem DESC;



    DECLARE @IdPromoCard INT;
    DECLARE @BalancePoint DECIMAL(12, 2);
    DECLARE @Amount DECIMAL(12, 2);

    SELECT @IdPromoCard = pc.IdPromoCard,
           @BalancePoint = pc.Balance,
           @Amount = ISNULL(ISNULL(rd.Factor, @RedeenFactorDefault) * @RedeemPoint, 0),
           @RedeenFactor = ISNULL(rd.Factor, @RedeenFactorDefault),
           @RedeemId = ISNULL(pc.RedeemTypeId, @RedeenmIdDefault)
    FROM dbo.PromoCard pc
        LEFT JOIN dbo.RedeemType rd
            ON rd.IdRedeem = pc.RedeemTypeId
               AND pc.RowStatus = 'true'
        LEFT JOIN dbo.DeliveryCurrency cr
            ON cr.Currency_Id = pc.CurrencyId
    WHERE pc.PromoCardNumber = @PromoCard
          AND
          (
              @IdCustomer = -1
              OR pc.CustomerId = @IdCustomer
          );

    IF (@RedeemPoint <= @BalancePoint)
    BEGIN
        IF (@RedeemAmount = @Amount)
        BEGIN
            -- hacer debito de puntos

            BEGIN TRANSACTION;
            BEGIN TRY


                INSERT INTO [dbo].[PromoCardDetail]
                (
                    [PromoCardId],
                    [SystemId],
                    [ModuleId],
                    [RedeemTypeId],
                    [DebitPoint],
                    [RedeemAmount],
                    [GuidSerie],
                    [GuidNumber],
                    [GuideAmount],
                    [RowStatus],
                    [TokenCreated],
                    [DateCreated]
                )
                SELECT @IdPromoCard,
                       @IdSystem,
                       @IdModule,
                       @RedeemId,
                       @RedeemPoint,
                       @RedeemAmount,
                       @GuideSerie,
                       @GuideNumer,
                       dor.PriceShippment,
                       'true',
                       @Token,
                       GETDATE()
                FROM dbo.DeliveryOrder dor
                WHERE dor.Guide_Serie = @GuideSerie
                      AND dor.Guide_Number = @GuideNumer;

                UPDATE dbo.PromoCard
                SET Balance = @BalancePoint - @RedeemPoint,
                    TokenUpdated = @Token,
                    DateUpdated = GETDATE()
                WHERE IdPromoCard = @IdPromoCard;
            END TRY
            BEGIN CATCH

                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":500,' + '"Message":' + ERROR_MESSAGE() + '}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );

                ROLLBACK TRANSACTION;
            END CATCH;
            IF @@TRANCOUNT > 0
            BEGIN
                COMMIT TRANSACTION;
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{{"IdResult":200,' + '"Message":" Registro operado correctamente"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;

        END;
        ELSE
        BEGIN
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":412,' + '"Message":" Datos inconsistentes"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;
    END;
    ELSE
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":412,' + '"Message":" Saldo insufiente"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;


    IF @jsonResult IS NULL
    BEGIN


        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":500,' + '"Message":" No se econtraron registros"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;

    SELECT ('[' + @jsonResult + ']') jsonResult;



END;


