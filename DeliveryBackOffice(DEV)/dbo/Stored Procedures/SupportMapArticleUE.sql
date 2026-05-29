-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Reasignación de un articulo a Article by Customer>
-- =============================================


CREATE PROCEDURE [dbo].SupportMapArticleUE
    @ArticleForzaID INT  --= 6
  , @ArticleEUId INT  --= 'Caja 30'
  , @Token NVARCHAR(50)    --= 'SYS-CAQUINO'
  
AS
BEGIN
    BEGIN TRY


        IF NOT EXISTS
        (
          SELECT * FROM dbo.ArticleMapping 
		  WHERE ArticleForzaId = @ArticleForzaID
        )
        BEGIN

            BEGIN TRANSACTION;

				INSERT INTO dbo.ArticleMapping
				(
				    ArticleForzaId
				  , ArticleUEId
				  , RowStatus
				  , TokenCreated
				  , DateCreated
				  , TokenUpdated
				  , DateUpdated
				)
				VALUES
				(   @ArticleForzaID         -- ArticleForzaId - int
				  , @ArticleEUId         -- ArticleUEId - int
				  , 1      -- RowStatus - bit
				  , @Token       -- TokenCreated - nvarchar(50)
				  , GETDATE() -- DateCreated - datetime
				  , NULL      -- TokenUpdated - nvarchar(50)
				  , NULL      -- DateUpdated - datetime
				    )



            COMMIT TRANSACTION;

           SELECT * FROM dbo.ArticleMapping
		   WHERE ArticleForzaId =  @ArticleForzaID

        END;
        ELSE
        BEGIN
            SELECT 'El Articulo Forza ya esta relacionado con un articulo de Ultra entregas';
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