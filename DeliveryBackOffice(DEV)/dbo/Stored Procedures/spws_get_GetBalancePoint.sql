
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-06-26>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_GetBalancePoint]
    -- Add the parameters for the stored procedure here
    @Token VARCHAR(200),
    @PromoCard NVARCHAR(50) = '',
    @IdCustomer INT = -1
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @RedeenFactorDefault DECIMAL(12, 2);
    DECLARE @RedeenIdDefault DECIMAL(12, 2);
    DECLARE @RedeenNameDefault VARCHAR(50);



    SELECT TOP 1
           @RedeenFactorDefault = ISNULL(rd.Factor, 0),
           @RedeenIdDefault = ISNULL(rd.IdRedeem, 1),
           @RedeenNameDefault = ISNULL(rd.TypeName, '')
    FROM dbo.RedeemType rd
    WHERE rd.RedeemDefault = 'true'
    ORDER BY rd.IdRedeem DESC;




    DECLARE @jsonResult NVARCHAR(MAX);
    SET @jsonResult =
    (
        SELECT STUFF(
                        (
                            SELECT ',{"PromoCard":"' + pc.PromoCardNumber + '",' + '"PromoCardName":"'
                                   + dbo.fnt_String_Escape(pc.PromoCardName, 'json') + '",' + '"IdCustomer":"'
                                   + CONVERT(VARCHAR, pc.CustomerId) + '",' + '"IdClientPortFolio":"'
                                   + CONVERT(VARCHAR, ISNULL(pc.ClientPortfolioId, -1)) + '",' + '"AcumulatePoints":"'
                                   + CONVERT(VARCHAR, pc.Balance) + '",' + '"Factor":"'
                                   + CONVERT(VARCHAR, ISNULL(rd.Factor, @RedeenFactorDefault)) + '",'
                                   + '"RedeemName":"'
                                   + dbo.fnt_String_Escape(ISNULL(rd.TypeName, @RedeenNameDefault), 'json') + '",'
								   + '"CustomerName":"'
                                   + dbo.fnt_String_Escape(ISNULL(cs.Name, ''), 'json') + '",'
                                   + '"RedeemId":"' + CONVERT(VARCHAR, ISNULL(rd.IdRedeem, @RedeenIdDefault)) + '",'
                                   + '"Amount":"'
                                   + CONVERT(
                                                VARCHAR,
                                                ISNULL(
                                                          ISNULL(rd.Factor, @RedeenFactorDefault)
                                                          * ISNULL(pc.Balance, 0),
                                                          0
                                                      )
                                            ) + '",' + '"Currency":"' + ISNULL(cr.Currency_Symbol, '') + +'"}'
                            FROM dbo.PromoCard pc
                                LEFT JOIN dbo.RedeemType rd
                                    ON rd.IdRedeem = pc.RedeemTypeId
                                       AND pc.RowStatus = 'true'
                                LEFT JOIN dbo.DeliveryCurrency cr
                                    ON cr.Currency_Id = pc.CurrencyId
								LEFT JOIN dbo.Customer cs
									ON cs.IdCustomer = pc.CustomerId
                            WHERE pc.PromoCardNumber = @PromoCard
                                  AND
                                  (
                                      @IdCustomer = -1
                                      OR pc.CustomerId = @IdCustomer
                                  )
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );


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


