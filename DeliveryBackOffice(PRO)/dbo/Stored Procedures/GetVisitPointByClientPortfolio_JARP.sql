-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asignadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[GetVisitPointByClientPortfolio_JARP]
    @IdAccount INT,
    @Token VARCHAR(200) = ''
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON
    DECLARE @jsonResult NVARCHAR(MAX) = NULL;
    DECLARE @jsonResult2 NVARCHAR(MAX) = NULL;
    DECLARE @jsonResult3 NVARCHAR(MAX) = NULL;
    DECLARE @jsonResultErrror NVARCHAR(MAX) = NULL;
    DECLARE @VisitPointId INT;
    SET @VisitPointId = (   SELECT TOP 1 vp.IdVisitPointClient
                              FROM [dbo].RegisterUser usr WITH (NOLOCK)
                              LEFT JOIN [dbo].[RolByUserByAccount] rua WITH (NOLOCK)
                                ON rua.RuaIdUser     = usr.UsrIdUser
                               AND rua.RuaRowStatus  = 1
                             INNER JOIN [dbo].Account ac WITH (NOLOCK)
                                ON ac.AccIdAccount   = rua.RuaIdAccount
                               AND ac.AccRowStatus   = 1
                             INNER JOIN VisitPointByUser vp WITH (NOLOCK)
                                ON vp.RegisterUserID = usr.UsrIdUser
                             WHERE ac.AccIdAccount = @IdAccount);

    --SET STATISTICS TIME ON; 
    SET @jsonResult2 = (SELECT STUFF(
                                   (   SELECT DISTINCT ',
									{									
                                    "IdVisitPointByClientPortfolio":"'
                                                       + CONVERT(VARCHAR, vcp.IdVisitPointByClientPortfolio) + '",'
                                                       + '"InternalCode":"' + ISNULL(vcp.InternalCode, '') + '",'
                                                       + '"FirstName":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             CONVERT(NVARCHAR(50), (ISNULL(vcp.FirstName, '')))) + '",'
                                                       + '"SecondName":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(
                                                                 CONVERT(
                                                                     VARCHAR,
                                                                     (
                                                                         ISNULL(vcp.SecondName, ''))),
                                                                 '')) + '",' + '"LastName":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(
                                                                 CONVERT(
                                                                     VARCHAR,
                                                                     (
                                                                         ISNULL(vcp.LastName, ''))),
                                                                 '')) + '",' + '"SecondLastName":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(
                                                                 CONVERT(
                                                                     VARCHAR,
                                                                     (
                                                                         ISNULL(vcp.SecondLastName, ''))),
                                                                 '')) + '",' + '"NirPhone":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(CONVERT(VARCHAR, vcp.NirPhone),'')) + '",'
                                                       + '"Phone":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(
                                                                 CONVERT(
                                                                     VARCHAR,
                                                                     (
                                                                         ISNULL(vcp.Phone, ''))),
                                                                 '')) + '",' + '"Email":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(
                                                                 CONVERT(VARCHAR(50), REPLACE(vcp.Email, '"', '')),
                                                                 '')) + '",' + '"CUI":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             ISNULL(CONVERT(VARCHAR, vcp.CUI), '')) + '",'
                                                       + '"Status":"' + ISNULL(CONVERT(VARCHAR, vcp.RowStatus), ' ')
                                                       + '",' + '"Token":"'
                                                       + ISNULL(CONVERT(VARCHAR, vcp.TokenCreated), ' ') + '",'
                                                       + '"TaxId":"' + ISNULL(vcp.TaxId, ' ') + '",'
                                                       + '"ContactName":"'
                                                       + dbo.fn_ReplaceSpecialCharsForJSON(
                                                             REPLACE(ISNULL(vcp.ContactName, ' '), '"', ''))
                                                       + '",' + '"Billing":['
                                                       + ISNULL(
                                                             STUFF(
                                                             (   SELECT ',{ "IdBilling":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.BlpIdBilling), ' ')
                                                                        + '",' + '"IdAccount":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(VARCHAR, SUB.BlpIdAccount),
                                                                                  ' ')) + '",' + '"Name":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(
                                                                                      VARCHAR,
                                                                                      (
                                                                                          SUB.BlpName)),
                                                                                  ' ')) + '",' + '"Address":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(
                                                                                      VARCHAR,
                                                                                      (
                                                                                          SUB.BlpAddress)),
                                                                                  '')) + '",' + '"TaxId":"'
                                                                        + ISNULL(CONVERT(VARCHAR, SUB.BlpTaxId), ' ')
                                                                        + '",' + '"Status":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.BlpRowStatus), ' ')
                                                                        + '",' + '"Token":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.BlpTokenCreated),
                                                                              ' ') + '",'
                                                                        + '"IdVisitPointByClientPortfolio":"'
                                                                        + ISNULL(
                                                                              CONVERT(
                                                                                  VARCHAR,
                                                                                  SUB.VisitPointByClientPortfolioId),
                                                                              ' ') + '"}'
                                                                   FROM dbo.BillingProfile SUB WITH (NOLOCK)
                                                                  WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                                    AND SUB.BlpRowStatus                  = 1
                                                                 FOR XML PATH('')),
                                                             1,
                                                             1,
                                                             ''),
                                                             ' ')
															 + '],' + '"cod":['
                                                       + ISNULL(
                                                             STUFF(
                                                             (   SELECT ',{ "Id":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.IdDeliveryFavCOD),
                                                                              ' ') + '",' + '"IdAccount":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.IdAccountFavCOD),
                                                                              ' ') + '",' + '"IdBank":"'
                                                                        + ISNULL(CONVERT(VARCHAR, SUB.IdBank), ' ')
                                                                        + '",' + '"NameBank":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(
                                                                                      VARCHAR,
                                                                                      (
                                                                                          ISNULL(DB.Name, ''))),
                                                                                  '')) + '",' + '"NameAccount":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(
                                                                                      VARCHAR,
                                                                                      (
                                                                                          ISNULL(
                                                                                              SUB.NameAccountFavCOD, ''))),
                                                                                  '')) + '",' + '"TypeAccount":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(
                                                                                      VARCHAR, SUB.TypeAccountFavCOD),
                                                                                  '')) + '",' + '"DocID":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(VARCHAR, SUB.DocumentIdFavCOD),
                                                                                  '')) + '",' + '"Alias":"'
                                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                              ISNULL(
                                                                                  CONVERT(VARCHAR, SUB.AliasFavCOD),
                                                                                  '')) + '",' + '"Token":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.TokenCreated), ' ')
                                                                        + '",' + '"TokenUpdate":"'
                                                                        + ISNULL(CONVERT(VARCHAR, SUB.TokenUpdate), ' ')
                                                                        + '",' + '"NumberAcc":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.NumberAccFavCOD),
                                                                              ' ') + '",' + '"Status":"'
                                                                        + ISNULL(
                                                                              CONVERT(VARCHAR, SUB.StatusFavCOD), ' ')
                                                                        + '",' + '"IdVisitPointByClientPortfolio":"'
                                                                        + ISNULL(
                                                                              CONVERT(
                                                                                  VARCHAR,
                                                                                  SUB.VisitPointByClientPortfolioId),
                                                                              ' ') + '"}'
                                                                   FROM DeliveryBackOffice.dbo.DeliveryFavCOD SUB WITH (NOLOCK)
                                                                  INNER JOIN dbo.DeliveryBank DB WITH (NOLOCK)
                                                                     ON SUB.StatusFavCOD = 1
                                                                    AND DB.Id_bank       = SUB.IdBank
                                                                  WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                                 FOR XML PATH('')),
                                                             1,
                                                             1,
                                                             ''),
                                                             ' ') 
															 + '],' + '"Addresses":['
                                                       + ISNULL(
                                                             STUFF(
                                                             (   SELECT DISTINCT ',{ "IdAddress":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(
                                                                                           VARCHAR, SUB.UadIdAddress),
                                                                                       ' ') + '",' 
																					   + '"IdTownship":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(
                                                                                           VARCHAR, SUB.UadIdTownship),
                                                                                       ' ') + '",' + '"IdProvince":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(VARCHAR, pr.IdProvince),
                                                                                       ' ') + '",' + '"Province":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(VARCHAR, pr.ProvinceName),
                                                                                       ' ') + '",' + '"Township":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(VARCHAR, tw.TownshipName),
                                                                                       ' ') + '",' + '"HeaderCode":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(VARCHAR, tw.HeaderCode),
                                                                                       ' ') + '",' + '"IdAccount":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(
                                                                                           VARCHAR, SUB.UadIdAccount),
                                                                                       ' ') + '",' + '"IdCountry":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(
                                                                                           VARCHAR, SUB.UadIdCountry),
                                                                                       ' ') + '",' + '"FullName":"'
                                                                                 + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                                       REPLACE(
                                                                                           (
                                                                                               ISNULL(
                                                                                                   SUB.UadFullName, '')),
                                                                                           '"',
                                                                                           '')) + '",' 
																						   ------+ '"Address1":"'
                         ------                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                         ------                                                              REPLACE(
                         ------                                                                  (
                         ------                                                                      ISNULL(
                         ------                                                                          SUB.UadAddress1, '')),
                         ------                                                                  '"',
                         ------                                                                  '')) + '",' 
																						   ------+ '"Address2":"'
                         ------                                                        + dbo.fn_ReplaceSpecialCharsForJSON(
                         ------                                                              REPLACE(
                         ------                                                                  (
                         ------                                                                      ISNULL(
                         ------                                                                          SUB.UadAddress2, '')),
                         ------                                                                  '"',
                         ------                                                                  '')) + '",' 
																						   + '"NirPhone":"'
                                                                                 + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                                       REPLACE(
                                                                                           ISNULL(SUB.UadNirPhone, ''),
                                                                                           '"',
                                                                                           '')) + '",' + '"Phone":"'
                                                                                 + dbo.fn_ReplaceSpecialCharsForJSON(
                                                                                       REPLACE(
                                                                                           (
                                                                                               ISNULL(SUB.UadPhone, '')),
                                                                                           '"',
                                                                                           '')) + '",'
                        --                                                         + '"AdditionalInstructions":"'
                        --                                                         + dbo.fn_ReplaceSpecialCharsForJSON(
                        --                                                               REPLACE(
                        --                                                                   (
                        --                                                                       ISNULL(
                        --                                                                           SUB.UadAdditionalInstructions,
                        --                                                                           '')),
                        --                                                                   '"',
                        --                                                                   '')) + '",' + '"Status":"'
                        --                                                         + ISNULL(
                        --                                                               CONVERT(
                        --                                                                   VARCHAR, SUB.UadRowStatus),
                        --                                                               ' ') + '",' 
																					   --+ '"Token":"'
                        --                                                         + ISNULL(
                        --                                                               CONVERT(
                        --                                                                   VARCHAR(100),
                        --                                                                   SUB.UadTokenCreated),
                        --                                                               ' ') + '",' 
																					   --+ '"IdSettlement":"'
                        --                                                         + ISNULL(
                        --                                                               CONVERT(
                        --                                                                   VARCHAR, SUB.UadIdSettlement),
                        --                                                               '') + '",'
                        --                                                         + '"SettlementDescription":"'
                        --                                                         + ISNULL(st.Settlement, '') + '",'
                        --                                                         + '"IdDeliveryOption":"'
                        --                                                         + ISNULL(
                        --                                                               CONVERT(
                        --                                                                   VARCHAR,
                        --                                                                   SUB.UadIdDeliveryOption),
                        --                                                               ' ') + '",'
                        --                                                         + '"DescriptionDeliveryOption":"'
                        --                                                         + ISNULL(cdo.Name, ' ') + '",'
                                                                                 --+ '"IsTDA":"'
                                                                                 --+ CASE
                                                                                 --       WHEN dsc.TDA = 1 THEN 'TRUE'
                                                                                 --       ELSE 'FALSE' END + '",'
                                                                                 --+ '"HasSDD":"'
                                                                                 --+ CASE
                                                                                 --       WHEN dsc.SDD = 1 THEN 'TRUE'
                                                                                 --       ELSE 'FALSE' END + '",'
                                                                                 --+ '"Hub":"' + ISNULL(dsc.Hub, '')
                                                                                 --+ '",'
                                                                                 + '"IdVisitPointByClientPortfolio":"'
                                                                                 + ISNULL(
                                                                                       CONVERT(
                                                                                           VARCHAR,
                                                                                           SUB.VisitPointByClientPortfolioId),
                                                                                       ' ') + '"}'
                                                                   FROM DeliveryBackOffice.dbo.UserAddress SUB WITH (NOLOCK)
                                                                  LEFT JOIN DeliveryBackOffice.dbo.Township tw WITH (NOLOCK)
                                                                     ON tw.IdTownship        = SUB.UadIdTownship
                                                                  LEFT JOIN DeliveryBackOffice.dbo.Province pr WITH (NOLOCK)
                                                                     ON pr.IdProvince        = tw.IdProvince
                                                                  -- LEFT JOIN DeliveryBackOffice.dbo.Settlement st WITH (NOLOCK)
                                                                  --   ON st.IdSettlement      = SUB.UadIdSettlement
                                                                  --  AND st.SettlementSatus   = 1
                                                                  -- LEFT JOIN DeliveryBackOffice.dbo.CatDeliveryOptions cdo WITH (NOLOCK)
                                                                  --   ON cdo.IdDeliveryOption = SUB.UadIdDeliveryOption
                                                                   --LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc WITH (NOLOCK)
                                                                   --  ON dsc.IdSettlement     = st.IdSettlement
                                                                   -- AND dsc.RowStatus        = 1
                                                                  WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                                    AND SUB.UadRowStatus                  = 1
                                                                 FOR XML PATH('')),
                                                             1,
                                                             1,
                                                             ''),
                                                             ' ')
															 + ']' + '}'
                                         FROM DeliveryBackOffice.dbo.VisitPointByClientPortfolio vcp WITH (NOLOCK)
                                         LEFT JOIN DeliveryBackOffice.dbo.UserAddress uad WITH (NOLOCK)
                                           ON uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                          AND uad.UadRowStatus                  = 1
                                         LEFT JOIN DeliveryBackOffice.dbo.DeliveryFavCOD dfc WITH (NOLOCK)
                                           ON dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                         LEFT JOIN DeliveryBackOffice.dbo.BillingProfile bp WITH (NOLOCK)
                                           ON bp.VisitPointByClientPortfolioId  = vcp.IdVisitPointByClientPortfolio
                                        WHERE vcp.RowStatus    = 1
                                          AND vcp.VisitPointId = @VisitPointId
                                       FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),
                                   1,
                                   1,
                                   ''));

    --SET STATISTICS TIME OFF;
    IF @jsonResult IS NULL
   AND @jsonResult2 IS NULL
   AND @jsonResult3 IS NULL
    BEGIN
        SET @jsonResultErrror = (SELECT STUFF(
                                            (   SELECT '{{"IdResult":500,'
                                                       + '"Message":" No se encontraron registros"}'
                                                FOR XML PATH(''), TYPE).value('.', 'varchar(max)'),
                                            1,
                                            1,
                                            ''));
    END;
    SELECT ('[' + COALESCE(@jsonResultErrror, '') + CASE
                                                         WHEN @jsonResult IS NOT NULL
                                                          AND @jsonResult2 IS NULL
                                                          AND @jsonResult3 IS NULL THEN CONCAT(@jsonResult, '')
                                                         ELSE '' END
            + CASE
                   WHEN @jsonResult IS NOT NULL
                    AND (   @jsonResult2 IS NOT NULL
                       OR   @jsonResult3 IS NOT NULL) THEN CONCAT(@jsonResult, ',')
                   ELSE '' END + CASE
                                      WHEN @jsonResult2 IS NOT NULL
                                       AND @jsonResult3 IS NULL THEN CONCAT(@jsonResult2, '')
                                      ELSE '' END + CASE
                                                         WHEN @jsonResult2 IS NOT NULL
                                                          AND @jsonResult3 IS NOT NULL THEN CONCAT(@jsonResult2, ',')
                                                         ELSE '' END + COALESCE(@jsonResult3, '') + ']') jsonResult;
END;





