-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Crear un Nuevo Articulo>
-- =============================================


CREATE PROCEDURE [dbo].SupportCreateArticle
    @ArtIdTypeArticle INT  --= 6
  , @ArtName NVARCHAR(50)  --= 'Caja 30'
  , @Token NVARCHAR(50)    --= 'SYS-CAQUINO'
  , @CountryId NVARCHAR(2) --= 'HN'
AS
BEGIN
    BEGIN TRY


        IF NOT EXISTS
        (
            SELECT *
            FROM dbo.CatArticle
            WHERE ArtName = @ArtName
                  AND ArtRowStatus = 1
                  AND IdCountry = @CountryId
        )
        BEGIN

            BEGIN TRANSACTION;

            INSERT INTO dbo.CatArticle
            (
                ArtIdTypeArticle
              , ArtName
              , ArtShowDefault
              , ArtRowStatus
              , ArtTokenCreated
              , ArtDateCreated
              , ArtTokenUpdated
              , ArtDateUpdated
              , ArtHeight
              , ArtWidth
              , ArtLength
              , ArtMassWeight
              , IdCountry
            )
            VALUES
            (   @ArtIdTypeArticle -- ArtIdTypeArticle - int
              , @ArtName          -- ArtName - varchar(50)
              , 0                 -- ArtShowDefault - bit
              , 1                 -- ArtRowStatus - bit
              , @Token            -- ArtTokenCreated - varchar(50)
              , GETDATE()         -- ArtDateCreated - datetime
              , NULL              -- ArtTokenUpdated - varchar(50)
              , NULL              -- ArtDateUpdated - datetime
              , NULL              -- ArtHeight - decimal(18, 2)
              , NULL              -- ArtWidth - decimal(18, 2)
              , NULL              -- ArtLength - decimal(18, 2)
              , NULL              -- ArtMassWeight - decimal(18, 2)
              , @CountryId        -- IdCountry - varchar(2)
                );




            COMMIT TRANSACTION;

            SELECT SCOPE_IDENTITY();

        END;
        ELSE
        BEGIN
            SELECT 'El Articulo ya existe';
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