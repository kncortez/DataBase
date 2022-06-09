-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asignadas a una cuenta>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-05-16>
-- Description:	< Intento de mejora de rendimiento >
-- =============================================
CREATE PROCEDURE [dbo].[GetVisitPointByClientPortfolio_JARP]
    @IdAccount INT,
    @Token VARCHAR(200) = ''
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX) = NULL;
    DECLARE @jsonResult2 NVARCHAR(MAX) = NULL;
    DECLARE @jsonResult3 NVARCHAR(MAX) = NULL;
    DECLARE @jsonResultErrror NVARCHAR(MAX) = NULL;
	 
    DECLARE @VisitPointId INT;
    SET @VisitPointId =
    (
        SELECT TOP 1
               vp.IdVisitPointClient
        FROM [dbo].RegisterUser usr WITH (NOLOCK)
            LEFT JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                ON rua.RuaIdUser = usr.UsrIdUser
                   AND rua.RuaRowStatus = 1
            INNER JOIN [dbo].Account ac WITH (NOLOCK)
                ON ac.AccIdAccount = rua.RuaIdAccount
                   AND ac.AccRowStatus = 1
            INNER JOIN VisitPointByUser vp WITH (NOLOCK)
                ON vp.RegisterUserID = usr.UsrIdUser
        WHERE ac.AccIdAccount = @IdAccount
    );

		--SET STATISTICS TIME ON; 

	
    IF OBJECT_ID('tempdb.dbo.#BillingValues', 'U') IS NOT NULL
        DROP TABLE #BillingValues;
    IF OBJECT_ID('tempdb.dbo.#CoDValues', 'U') IS NOT NULL
        DROP TABLE #CoDValues;
    IF OBJECT_ID('tempdb.dbo.#AddressValues', 'U') IS NOT NULL
        DROP TABLE #AddressValues;
	
    SET @jsonResult2 =
    (
        SELECT STUFF(
                        (
                            SELECT DISTINCT
                                   ',
									{									
                                    "IdVisitPointByClientPortfolio":"' + CONVERT(VARCHAR, vcp.IdVisitPointByClientPortfolio) + '",' + 
									'"InternalCode":"' + ISNULL(vcp.InternalCode, '') + '",' + 
									'"FirstName":"' + dbo.fn_ReplaceSpecialCharsForJSON(CONVERT( NVARCHAR(50), (ISNULL( vcp.FirstName,  '' ) ) ) ) + '",' + 
									'"SecondName":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( vcp.SecondName, '' ) ) ), '' )) + '",' + 
									'"LastName":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( vcp.LastName, '' ) ) ), '' )) + '",' + 
									'"SecondLastName":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( vcp.SecondLastName, '' ) ) ), '' )) + '",' + 
									'"NirPhone":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(CONVERT(VARCHAR, vcp.NirPhone), '')) + '",'  + 
									'"Phone":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( vcp.Phone, '' ) ) ), '' )) + '",' + 
									'"Email":"' +  dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT(VARCHAR(50), REPLACE(vcp.Email, '"', '')), '' )) + '",' + 
									'"CUI":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(CONVERT(VARCHAR, vcp.CUI), '')) + '",' + 
									'"Status":"' + ISNULL(CONVERT(VARCHAR, vcp.RowStatus), ' ') + '",' +
									'"Token":"' + ISNULL(CONVERT(VARCHAR, vcp.TokenCreated), ' ') + '",' + 
									'"TaxId":"' + ISNULL(vcp.TaxId, ' ') + '",' + 
									'"ContactName":"' + dbo.fn_ReplaceSpecialCharsForJSON(REPLACE(ISNULL(vcp.ContactName, ' '), '"', '')) + '",' +
									'"Billing":[' + ISNULL(
                                               STUFF(
                                               (
                                                   SELECT ',{ "IdBilling":"' + ISNULL(CONVERT(VARCHAR, SUB.BlpIdBilling), '') + '",' + 
														   '"IdAccount":"' +  dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, SUB.BlpIdAccount ), '' )) + '",' + 
														   '"Name":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (SUB.BlpName) ), '' )) + '",' + 
														   '"Address":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL(  CONVERT( VARCHAR, (SUB.BlpAddress)  ), '' )) + '",' +
														   '"TaxId":"' + ISNULL(CONVERT(VARCHAR, SUB.BlpTaxId), ' ') + '",' + 
														   '"Status":"' + ISNULL(CONVERT(VARCHAR, SUB.BlpRowStatus), ' ') + '",' + 
														   '"Token":"' + ISNULL(CONVERT(VARCHAR, SUB.BlpTokenCreated), ' ') + '",' +
														   '"IdVisitPointByClientPortfolio":"' + ISNULL( CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId), '' ) + 
														   '"}'
                                                   FROM dbo.BillingProfile SUB WITH (NOLOCK)
                                                   WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                         AND SUB.BlpRowStatus = 1
                                                   FOR XML PATH('')
                                               ),
                                               1,
                                               1,
                                               '' 
											   ),
                                               ''
                                           ) + '],'  + 
									'"cod":[' + ISNULL(
                                               STUFF(
                                               (
                                                   SELECT ',{ "Id":"' + ISNULL(CONVERT(VARCHAR, SUB.IdDeliveryFavCOD), ' ') + '",' + 
															'"IdAccount":"' + ISNULL(CONVERT(VARCHAR, SUB.IdAccountFavCOD), ' ') + '",' +
															'"IdBank":"' + ISNULL(CONVERT(VARCHAR, SUB.IdBank), ' ') + '",' + 
															'"NameBank":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( DB.Name, '' ) ) ), '' )) + '",' +
															'"NameAccount":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, (ISNULL( SUB.NameAccountFavCOD, '' ) ) ), '' )) + '",' + 
															'"TypeAccount":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, SUB.TypeAccountFavCOD ), '' )) + '",' +
															'"DocID":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, SUB.DocumentIdFavCOD ), '' )) + '",' + 
															'"Alias":"' + dbo.fn_ReplaceSpecialCharsForJSON(ISNULL( CONVERT( VARCHAR, SUB.AliasFavCOD ), '' )) + '",' + 
															'"Token":"' + ISNULL(CONVERT(VARCHAR, SUB.TokenCreated), ' ') + '",'
                                                          + '"TokenUpdate":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.TokenUpdate), ' ') + '",'
                                                          + '"NumberAcc":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.NumberAccFavCOD), ' ') + '",'
                                                          + '"Status":"' + ISNULL(CONVERT(VARCHAR, SUB.StatusFavCOD), ' ')
                                                          + '",' + '"IdVisitPointByClientPortfolio":"'
                                                          + ISNULL(
                                                                      CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId),
                                                                      ' '
                                                                  ) + '"}'
                                                   FROM DeliveryBackOffice.dbo.DeliveryFavCOD SUB WITH (NOLOCK)
                                                        JOIN dbo.DeliveryBank DB WITH (NOLOCK) ON SUB.StatusFavCOD = 1   
														 AND DB.Id_bank = SUB.IdBank
                                                   WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                   FOR XML PATH('')
                                               ),
                                               1,
                                               1,
                                               ''
                                                    ),
                                               ' '
                                           ) + '],' + 
									'"Addresses":[' + ']' + '}'
                            FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)
                                LEFT JOIN DeliveryBackOffice.dbo.UserAddress uad WITH (NOLOCK)
                                    ON uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                       AND uad.UadRowStatus = 1
                                LEFT JOIN DeliveryBackOffice.dbo.DeliveryFavCOD dfc WITH (NOLOCK)
                                    ON dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                LEFT JOIN DeliveryBackOffice.dbo.BillingProfile bp WITH (NOLOCK)
                                    ON bp.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                            WHERE vcp.RowStatus = 1
                                  AND vcp.VisitPointId = @VisitPointId
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );

	--SET STATISTICS TIME OFF;


    IF @jsonResult IS NULL
       AND @jsonResult2 IS NULL
       AND @jsonResult3 IS NULL
    BEGIN
        SET @jsonResultErrror =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":500,' + '"Message":" No se encontraron registros"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;


    SELECT ('[' + COALESCE(@jsonResultErrror, '') + CASE
                                                        WHEN @jsonResult IS NOT NULL
                                                             AND @jsonResult2 IS NULL
                                                             AND @jsonResult3 IS NULL THEN
                                                            CONCAT(@jsonResult, '')
                                                        ELSE
                                                            ''
                                                    END + CASE
                                                              WHEN @jsonResult IS NOT NULL
                                                                   AND
                                                                   (
                                                                       @jsonResult2 IS NOT NULL
                                                                       OR @jsonResult3 IS NOT NULL
                                                                   ) THEN
                                                                  CONCAT(@jsonResult, ',')
                                                              ELSE
                                                                  ''
                                                          END + CASE
                                                                    WHEN @jsonResult2 IS NOT NULL
                                                                         AND @jsonResult3 IS NULL THEN
                                                                        CONCAT(@jsonResult2, '')
                                                                    ELSE
                                                                        ''
                                                                END + CASE
                                                                          WHEN @jsonResult2 IS NOT NULL
                                                                               AND @jsonResult3 IS NOT NULL THEN
                                                                              CONCAT(@jsonResult2, ',')
                                                                          ELSE
                                                                              ''
                                                                      END + COALESCE(@jsonResult3, '') + ']'
           ) jsonResult;

		   

	
    IF OBJECT_ID('tempdb.dbo.#BillingValues', 'U') IS NOT NULL
        DROP TABLE #BillingValues;
    IF OBJECT_ID('tempdb.dbo.#CoDValues', 'U') IS NOT NULL
        DROP TABLE #CoDValues;
    IF OBJECT_ID('tempdb.dbo.#AddressValues', 'U') IS NOT NULL
        DROP TABLE #AddressValues;

END;





