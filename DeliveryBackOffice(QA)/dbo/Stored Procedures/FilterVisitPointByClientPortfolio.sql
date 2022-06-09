
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-11-24>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta filtrado por nombres, CUI, correo y telefono>
-- =============================================


CREATE PROCEDURE [dbo].[FilterVisitPointByClientPortfolio]
    @IdAccount INT,
    @Token VARCHAR(50) = '',
    @TextFilter NVARCHAR(100)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
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




    SET @jsonResult2 =
    (
        SELECT STUFF(
                        (
                            SELECT DISTINCT
                                   ',
									{									
                                    "IdVisitPointByClientPortfolio":"'
                                   + CONVERT(VARCHAR, vcp.IdVisitPointByClientPortfolio) + '",' + '"InternalCode":"'
                                   + ISNULL(vcp.InternalCode, '') + '",' + '"FirstName":"'
                                   + dbo.fnt_String_Escape(
                                                              CONVERT(
                                                                         NVARCHAR(50),
                                                                         [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                         vcp.FirstName,
                                                                                                                         ''
                                                                                                                     )
                                                                                                              )
                                                                     ),
                                                              'json'
                                                          ) + '",' + '"SecondName":"'
                                   + dbo.fnt_String_Escape(
                                                              ISNULL(
                                                                        CONVERT(
                                                                                   VARCHAR,
                                                                                   [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                   vcp.SecondName,
                                                                                                                                   ''
                                                                                                                               )
                                                                                                                        )
                                                                               ),
                                                                        'json'
                                                                    ),
                                                              ''
                                                          ) + '",' + '"LastName":"'
                                   + dbo.fnt_String_Escape(
                                                              ISNULL(
                                                                        CONVERT(
                                                                                   VARCHAR,
                                                                                   [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                   vcp.LastName,
                                                                                                                                   ''
                                                                                                                               )
                                                                                                                        )
                                                                               ),
                                                                        'json'
                                                                    ),
                                                              ''
                                                          ) + '",' + '"SecondLastName":"'
                                   + dbo.fnt_String_Escape(
                                                              ISNULL(
                                                                        CONVERT(
                                                                                   VARCHAR,
                                                                                   [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                   vcp.SecondLastName,
                                                                                                                                   ''
                                                                                                                               )
                                                                                                                        )
                                                                               ),
                                                                        'json'
                                                                    ),
                                                              ''
                                                          ) + '",' + '"NirPhone":"'
                                   + dbo.fnt_String_Escape(ISNULL(CONVERT(VARCHAR, vcp.NirPhone), 'json'), '') + '",'
                                   + '"Phone":"'
                                   + dbo.fnt_String_Escape(
                                                              ISNULL(
                                                                        CONVERT(
                                                                                   VARCHAR,
                                                                                   [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                   vcp.Phone,
                                                                                                                                   ''
                                                                                                                               )
                                                                                                                        )
                                                                               ),
                                                                        'json'
                                                                    ),
                                                              ''
                                                          ) + '",' + '"Email":"'
                                   + dbo.fnt_String_Escape(
                                                              ISNULL(
                                                                        CONVERT(VARCHAR(50), REPLACE(vcp.Email, '"', '')),
                                                                        'json'
                                                                    ),
                                                              ''
                                                          ) + '",' + '"CUI":"'
                                   + dbo.fnt_String_Escape(ISNULL(CONVERT(VARCHAR, vcp.CUI), 'json'), '') + '",'
                                   + '"Status":"' + ISNULL(CONVERT(VARCHAR, vcp.RowStatus), ' ') + '",' + '"Token":"'
                                   + ISNULL(CONVERT(VARCHAR, vcp.TokenCreated), ' ') + '",' + '"TaxId":"'
                                   + ISNULL(vcp.TaxId, ' ') + '",' + '"ContactName":"'
                                   + dbo.fnt_String_Escape(REPLACE(ISNULL(vcp.ContactName, ' '), '"', ''), 'json') + '",'
                                   + '"Billing":['
                                   + ISNULL(
                                               STUFF(
                                               (
                                                   SELECT ',{ "IdBilling":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.BlpIdBilling), ' ') + '",'
                                                          + '"IdAccount":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     ISNULL(
                                                                                               CONVERT(
                                                                                                          VARCHAR,
                                                                                                          SUB.BlpIdAccount
                                                                                                      ),
                                                                                               ' '
                                                                                           ),
                                                                                     'json'
                                                                                 ) + '",' + '"Name":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     ISNULL(
                                                                                               CONVERT(
                                                                                                          VARCHAR,
                                                                                                          [dbo].[fn_replace_special_characters](SUB.BlpName)
                                                                                                      ),
                                                                                               ' '
                                                                                           ),
                                                                                     'json'
                                                                                 ) + '",' + '"Address":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     ISNULL(
                                                                                               CONVERT(
                                                                                                          VARCHAR,
                                                                                                          [dbo].[fn_replace_special_characters](SUB.BlpAddress)
                                                                                                      ),
                                                                                               'json'
                                                                                           ),
                                                                                     ' '
                                                                                 ) + '",' + '"TaxId":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.BlpTaxId), ' ') + '",'
                                                          + '"Status":"' + ISNULL(CONVERT(VARCHAR, SUB.BlpRowStatus), ' ')
                                                          + '",' + '"Token":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.BlpTokenCreated), ' ') + '",'
                                                          + '"IdVisitPointByClientPortfolio":"'
                                                          + ISNULL(
                                                                      CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId),
                                                                      ' '
                                                                  ) + '"}'
                                                   FROM dbo.BillingProfile SUB WITH (NOLOCK)
                                                   WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                         AND SUB.BlpRowStatus = 1
                                                   FOR XML PATH('')
                                               ),
                                               1,
                                               1,
                                               ''
                                                    ),
                                               ' '
                                           ) + '],' + '"cod":['
                                   + ISNULL(
                                               STUFF(
                                                        (
                                                            SELECT ',{ "Id":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.IdDeliveryFavCOD), ' ')
                                                                   + '",' + '"IdAccount":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.IdAccountFavCOD), ' ')
                                                                   + '",' + '"IdBank":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.IdBank), ' ') + '",'
                                                                   + '"NameBank":"'
                                                                   + ISNULL(CONVERT(NVARCHAR(MAX), DB.Name), '') + '",'
                                                                   + '"NameAccount":"'
                                                                   + dbo.fnt_String_Escape(
                                                                                              ISNULL(
                                                                                                        CONVERT(
                                                                                                                   VARCHAR,
                                                                                                                   [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                                   SUB.NameAccountFavCOD,
                                                                                                                                                                   ''
                                                                                                                                                               )
                                                                                                                                                        )
                                                                                                               ),
                                                                                                        'json'
                                                                                                    ),
                                                                                              ' '
                                                                                          ) + '",' + '"TypeAccount":"'
                                                                   + dbo.fnt_String_Escape(
                                                                                              ISNULL(
                                                                                                        CONVERT(
                                                                                                                   VARCHAR,
                                                                                                                   SUB.TypeAccountFavCOD
                                                                                                               ),
                                                                                                        'json'
                                                                                                    ),
                                                                                              ' '
                                                                                          ) + '",' + '"DocID":"'
                                                                   + dbo.fnt_String_Escape(
                                                                                              ISNULL(
                                                                                                        CONVERT(
                                                                                                                   VARCHAR,
                                                                                                                   SUB.DocumentIdFavCOD
                                                                                                               ),
                                                                                                        'json'
                                                                                                    ),
                                                                                              ' '
                                                                                          ) + '",' + '"Alias":"'
                                                                   + dbo.fnt_String_Escape(
                                                                                              ISNULL(
                                                                                                        CONVERT(
                                                                                                                   VARCHAR,
                                                                                                                   SUB.AliasFavCOD
                                                                                                               ),
                                                                                                        ' '
                                                                                                    ),
                                                                                              'json'
                                                                                          ) + '",' + '"Token":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.TokenCreated), ' ')
                                                                   + '",' + '"TokenUpdate":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.TokenUpdate), ' ') + '",'
                                                                   + '"NumberAcc":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.NumberAccFavCOD), ' ')
                                                                   + '",' + '"Status":"'
                                                                   + ISNULL(CONVERT(VARCHAR, SUB.StatusFavCOD), ' ')
                                                                   + '",' + '"IdVisitPointByClientPortfolio":"'
                                                                   + ISNULL(
                                                                               CONVERT(
                                                                                          VARCHAR,
                                                                                          SUB.VisitPointByClientPortfolioId
                                                                                      ),
                                                                               ' '
                                                                           ) + '"}'
                                                            FROM dbo.DeliveryFavCOD SUB WITH (NOLOCK),
                                                                 dbo.DeliveryBank DB WITH (NOLOCK)
                                                            --join  dbo.DeliveryBank db on db.Id_bank = SUB.IdBank
                                                            WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                                  AND SUB.StatusFavCOD = 1
                                                                  AND DB.Id_bank = SUB.IdBank
                                                            FOR XML PATH(''), TYPE
                                                        ).value('.', 'varchar(max)'),
                                                        1,
                                                        1,
                                                        ''
                                                    ),
                                               ' '
                                           ) + '],' + '"Addresses":['
                                   + ISNULL(
                                               STUFF(
                                               (
                                                   SELECT DISTINCT
                                                          ',{ "IdAddress":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadIdAddress), ' ') + '",'
                                                          + '"IdTownship":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadIdTownship), ' ') + '",'
                                                          + '"IdProvince":"' + ISNULL(CONVERT(VARCHAR, pr.IdProvince), ' ')
                                                          + '",' + '"Province":"'
                                                          + ISNULL(CONVERT(VARCHAR, pr.ProvinceName), ' ') + '",'
                                                          + '"Township":"' + ISNULL(CONVERT(VARCHAR, tw.TownshipName), ' ')
                                                          + '",' + '"HeaderCode":"'
                                                          + ISNULL(CONVERT(VARCHAR, tw.HeaderCode), ' ') + '",'
                                                          + '"IdAccount":"' + ISNULL(CONVERT(VARCHAR, SUB.UadIdAccount), ' ')
                                                          + '",' + '"IdCountry":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadIdCountry), ' ') + '",'
                                                          + '"FullName":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                SUB.UadFullName,
                                                                                                                                                ''
                                                                                                                                            )
                                                                                                                                     ),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"Address1":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                SUB.UadAddress1,
                                                                                                                                                ''
                                                                                                                                            )
                                                                                                                                     ),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"Address2":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                SUB.UadAddress2,
                                                                                                                                                ''
                                                                                                                                            )
                                                                                                                                     ),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"NirPhone":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                ISNULL(SUB.UadNirPhone, ''),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"Phone":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                SUB.UadPhone,
                                                                                                                                                ''
                                                                                                                                            )
                                                                                                                                     ),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"AdditionalInstructions":"'
                                                          + dbo.fnt_String_Escape(
                                                                                     REPLACE(
                                                                                                [dbo].[fn_replace_special_characters](ISNULL(
                                                                                                                                                SUB.UadAdditionalInstructions,
                                                                                                                                                ''
                                                                                                                                            )
                                                                                                                                     ),
                                                                                                '"',
                                                                                                ''
                                                                                            ),
                                                                                     'json'
                                                                                 ) + '",' + '"Status":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadRowStatus), ' ') + '",'
                                                          + '"Token":"'
                                                          + ISNULL(CONVERT(VARCHAR(100), SUB.UadTokenCreated), ' ') + '",'
                                                          + '"IdSettlement":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadIdSettlement), '') + '",'
                                                          + '"SettlementDescription":"' + ISNULL(st.Settlement, '') + '",'
                                                          + '"IdDeliveryOption":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.UadIdDeliveryOption), ' ') + '",'
                                                          + '"DescriptionDeliveryOption":"' + ISNULL(cdo.Name, ' ') + '",'
                                                          + '"IsTDA":"' + CASE
                                                                              WHEN dsc.TDA = 1 THEN
                                                                                  'TRUE'
                                                                              ELSE
                                                                                  'FALSE'
                                                                          END + '",' + '"HasSDD":"'
                                                          + CASE
                                                                WHEN dsc.SDD = 1 THEN
                                                                    'TRUE'
                                                                ELSE
                                                                    'FALSE'
                                                            END + '",' + '"Hub":"' + ISNULL(dsc.Hub, '') + '",'
                                                          + '"IdVisitPointByClientPortfolio":"'
                                                          + ISNULL(CONVERT(VARCHAR, SUB.VisitPointByClientPortfolioId), ' ')
                                                          + '"}'
                                                   FROM UserAddress SUB WITH (NOLOCK)
                                                       RIGHT JOIN Township tw WITH (NOLOCK)
                                                           ON tw.IdTownship = SUB.UadIdTownship
                                                       RIGHT JOIN Province pr WITH (NOLOCK)
                                                           ON pr.IdProvince = tw.IdProvince
                                                       LEFT JOIN Settlement st WITH (NOLOCK)
                                                           ON st.IdSettlement = SUB.UadIdSettlement
                                                              AND st.SettlementSatus = 1
                                                       LEFT JOIN CatDeliveryOptions cdo WITH (NOLOCK)
                                                           ON cdo.IdDeliveryOption = SUB.UadIdDeliveryOption
                                                       LEFT JOIN DeliveryBackOffice.dbo.DumpServiceCoverage dsc WITH (NOLOCK)
                                                           ON dsc.IdSettlement = st.IdSettlement
                                                              AND dsc.RowStatus = 1
                                                   WHERE SUB.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                                         AND SUB.UadRowStatus = 1
                                                   FOR XML PATH('')
                                               ),
                                               1,
                                               1,
                                               ''
                                                    ),
                                               ' '
                                           ) + ']' + '}'
                            FROM VisitPointByClientPortfolio vcp WITH (NOLOCK)
                                LEFT JOIN UserAddress uad WITH (NOLOCK)
                                    ON uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                       AND uad.UadRowStatus = 1
                                LEFT JOIN DeliveryFavCOD dfc WITH (NOLOCK)
                                    ON dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                                LEFT JOIN BillingProfile bp WITH (NOLOCK)
                                    ON bp.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                            WHERE vcp.RowStatus = 1
                                  AND vcp.VisitPointId = @VisitPointId
                                  AND
                                  (
                                      CONCAT(
                                                vcp.FirstName,
                                                ' ',
                                                vcp.SecondName,
                                                ' ',
                                                vcp.LastName,
                                                ' ',
                                                vcp.SecondLastName
                                            ) LIKE CONCAT('%', @TextFilter, '%')
                                      OR
                                      --vcp.FirstName LIKE CONCAT('%',@TextFilter,'%') OR
                                      --vcp.SecondName LIKE CONCAT('%',@TextFilter,'%') OR
                                      --vcp.LastName LIKE CONCAT('%',@TextFilter,'%') OR
                                      --vcp.SecondLastName LIKE CONCAT('%',@TextFilter,'%') OR
                                      vcp.CUI LIKE CONCAT('%', @TextFilter, '%')
                                      OR vcp.Phone LIKE CONCAT('%', @TextFilter, '%')
                                      OR vcp.Email LIKE CONCAT('%', @TextFilter, '%')
                                  )
                            FOR XML PATH(''), TYPE
                        ).value('.', 'varchar(max)'),
                        1,
                        1,
                        ''
                    )
    );



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

--zIF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

--select ('[' + COALESCE(@jsonResult,'') 
--+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
--+ CASE WHEN @jsonResult2 IS NOT NULL THEN ',' ELSE ''',' END    
--+ COALESCE(@jsonResult3,'') + ']') jsonResult




END;





