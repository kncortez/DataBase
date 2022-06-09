
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-05-13>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================
--EXEC GetVisitPointByClientPortfolio 6877,''


CREATE PROCEDURE [dbo].[GetVisitPointByClientPortfolio_MK12052022]
    @IdAccount int,
    @Token VARCHAR(200) = ''
AS
BEGIN
   
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX) = NULL
    DECLARE @jsonResult2 NVARCHAR(MAX) = NULL
    DECLARE @jsonResultErrror NVARCHAR(MAX) = NULL
    DECLARE @VisitPointId INT

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
    )

    SET @jsonResult2 =
 (SELECT STUFF(
                 (
                     SELECT *
                     FROM VisitPointByClientPortfolio VCP WITH (NOLOCK)                         
                         --LEFT JOIN UserAddress uad with (nolock)
                         --    ON uad.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                         --       AND uad.UadRowStatus = 1
                         --left join DeliveryFavCOD dfc with (nolock)
                         --    on dfc.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                         --LEFT JOIN BillingProfile bp with (nolock)
                         --    on bp.VisitPointByClientPortfolioId = vcp.IdVisitPointByClientPortfolio
                     WHERE VCP.RowStatus = 1
                           AND VCP.VisitPointId = @VisitPointId
                     FOR XML PATH(''), TYPE
                 ).value('.', 'VARCHAR(MAX)'),
                 1,
                 1,
                 ''
             ))




    If @jsonResult is null
       and @jsonResult2 is null
    begin
        set @jsonResultErrror =
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
        )
    end



    select ('[' + COALESCE(@jsonResultErrror, '') + CASE
                                                        WHEN @jsonResult IS NOT NULL
                                                             and @jsonResult2 Is null                                                              THEN
                                                            CONCAT(@jsonResult, '')
                                                        ELSE
                                                            ''
                                                    END + CASE
                                                              WHEN @jsonResult IS NOT NULL
                                                                   and (
                                                                           @jsonResult2 IS NOT NULL
                                                                           
                                                                       ) THEN
                                                                  CONCAT(@jsonResult, ',')
                                                              ELSE
                                                                  ''
                                                          END + CASE
                                                                    WHEN @jsonResult2 IS NOT NULL
                                                                        THEN
                                                                        CONCAT(@jsonResult2, '')
                                                                    ELSE
                                                                        ''
                                                                END + CASE
                                                                          WHEN @jsonResult2 IS NOT NULL
                                                                               THEN
                                                                              CONCAT(@jsonResult2, ',')
                                                                          ELSE
                                                                              ''
                                                                      END  + ']'
           ) jsonResult

--zIF OBJECT_ID('tempdb.dbo.#GuideService', 'U') IS NOT NULL DROP TABLE #GuideService;

--select ('[' + COALESCE(@jsonResult,'') 
--+ CASE WHEN @jsonResult IS NOT NULL THEN ',' ELSE '' END 
--+ CASE WHEN @jsonResult2 IS NOT NULL THEN ',' ELSE ''',' END    
--+ COALESCE(@jsonResult3,'') + ']') jsonResult




END





