USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_codDeliveryOrderData]    Script Date: 25/11/2021 11:44:10 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Freddy, Monterroso>
-- Create date: <2021-11-02>
-- Description:	<Devuelve los datos de COD de una guía>
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_codDeliveryOrderData]
    @GuideSerie AS NVARCHAR(50),
    @GuideNumber AS BIGINT
AS
BEGIN
	
	DECLARE @jsonResult NVARCHAR(MAX);

	SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{'
                                       +'"Guide":"' + ISNULL(CONCAT(BDC.GuideSerie, BDC.GuideNumber), 'N/A') + '",'
									   +'"BankId":' + CONVERT(NVARCHAR,ISNULL(BDC.BankId, '')) + ','
                                       +'"BankName":"' + CONVERT(NVARCHAR,ISNULL(BDC.BankName, '')) + '",'
									   +'"TypeAccountName":"' + CONVERT(NVARCHAR,ISNULL(BDC.TypeAccountName, '')) + '",'
									   +'"AccountNumber":"' + CONVERT(NVARCHAR,ISNULL(BDC.AccountNumber, '')) + '",'
							           +'"COD":"' + CONVERT(VARCHAR, CAST(COALESCE(BDC.Amount, '0') AS MONEY), 1) + '",'
									   +'"AuthorizationNumber":"' + CONVERT(NVARCHAR,ISNULL(BDC.AuthorizationNumber, '')) + '",'
									   +'"Commission":"' + CONVERT(VARCHAR, CAST(COALESCE(BDC.Commission, '0') AS MONEY), 1) + '",'
									   +'"CODCommissionPercentage":"' + CONVERT(VARCHAR, CAST(COALESCE(BDC.CODCommissionPercentage, '0') AS MONEY), 1) + '",'
									   +'"Collect_OnDelivery":"' + CONVERT(VARCHAR, CAST(COALESCE(BDC2.Collect_OnDelivery, '0') AS MONEY), 1) + '",'
									   +'"PriceShippment":"' + CONVERT(VARCHAR, CAST(COALESCE(BDC2.PriceShippment, '0') AS MONEY), 1) + '",'
									   +'"BatchCODId":"' + CONVERT(NVARCHAR,ISNULL(BDC.BatchCODId, '')) + '",'
									   +'"AuthorizationDate":"' + ISNULL(CONVERT(VARCHAR, BDC.AuthorizationDate, 20), '') + '"}'
                                FROM DeliveryBackOffice.dbo.BatchDetailCOD BDC
								JOIN DeliveryBackOffice.dbo.DeliveryOrder BDC2 ON BDC2.Guide_Number = BDC.GuideNumber AND BDC2.Guide_Serie = BDC.GuideSerie
								WHERE BDC.CatConceptCODId = 2 --filtrar solo depósitos a clientes
								AND BDC.GuideNumber = @GuideNumber AND BDC.GuideSerie = @GuideSerie


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

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{{"IdResult":500,' + '"Message":" No se encontraron datos de COD."}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

        SELECT ('[' + @jsonResult + ']') jsonResult;

END
