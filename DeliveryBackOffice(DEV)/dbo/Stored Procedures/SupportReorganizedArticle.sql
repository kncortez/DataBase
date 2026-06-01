-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Reasignación de un articulo a Article by Customer>
-- =============================================


CREATE PROCEDURE [dbo].SupportReorganizedArticle
    @AbcID INT  --= 6
  , @OldeArticleId INT  --= 'Caja 30'
  , @Token NVARCHAR(50)    --= 'SYS-CAQUINO'
  , @NewArticleId int --= 'HN'
AS
BEGIN
    BEGIN TRY


        IF  EXISTS
        (
           SELECT * FROM dbo.ArticleByCustomer art
		   WHERE art.AbcId =  @AbcID AND art.AbcIdArticle = @OldeArticleId AND art.AbcRowStatus =1
        )
        BEGIN

            BEGIN TRANSACTION;

			UPDATE dbo.ArticleByCustomer
			SET	 AbcIdArticle = @NewArticleId
				, AbcTokenUpdated = @Token
				, AbcDateUpdated = GETDATE()
			WHERE AbcId = @AbcID  AND AbcIdArticle = @OldeArticleId AND AbcRowStatus = 1




            COMMIT TRANSACTION;

           SELECT ar.AbcId , ar.AbcIdArticle , ct.ArtName , ar.AbcRowStatus FROM dbo.ArticleByCustomer ar
			INNER JOIN dbo.CatArticle ct ON ct.ArtId = ar.AbcIdArticle
		   WHERE ar.AbcId = @AbcID

        END;
        ELSE
        BEGIN
            SELECT 'El Articulo no existe';
        END;
    END TRY
    BEGIN CATCH
        ROLLBACK;
        SELECT 'error'
             , ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;



END;