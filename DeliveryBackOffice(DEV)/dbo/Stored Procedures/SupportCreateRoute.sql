-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2024-09-02>
-- Description:	<Sp para reactivar>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCreateRoute]
    @RouteCode NVARCHAR(100)
  , @IdTownship INT
  , @idTypeRoute INT
  , @Token NVARCHAR(60)
  , @IdCounry NVARCHAR(2)
AS
BEGIN

    IF NOT EXISTS (SELECT * FROM dbo.CatRoute WHERE CodeRoute = @RouteCode)
    BEGIN

        BEGIN TRY
            BEGIN TRANSACTION;


            INSERT INTO dbo.CatRoute
            (
                CodeRoute
              , Description
              , IdTownship
              , IdTypeRoute
              , Zone
              , RowStatus
              , TokenCreated
              , DateCreated
              , TokenUpdated
              , DateUpdated
              , CountryId
            )
            VALUES
            (   @RouteCode      -- CodeRoute - varchar(100)
              , @RouteCode      -- Description - varchar(200)
              , @IdTownship     -- IdTownship - int
              , @idTypeRoute    -- IdTypeRoute - int
              , NULL            -- Zone - varchar(50)
              , 1               -- RowStatus - bit
              , @Token          -- TokenCreated - varchar(50)
              , GETDATE()       -- DateCreated - datetime
              , NULL            -- TokenUpdated - varchar(50)
              , NULL, @IdCounry -- DateUpdated - datetime
                );

            SELECT *
            FROM dbo.CatRoute
            WHERE CodeRoute = @RouteCode;
            COMMIT TRANSACTION;

            SELECT 'Ruta creada exitosamente';
        END TRY
        BEGIN CATCH

            ROLLBACK TRANSACTION;

            SELECT ERROR_LINE()
                 , ERROR_MESSAGE()
                 , ERROR_NUMBER()
                 , ERROR_PROCEDURE()
                 , ERROR_STATE();
        END CATCH;
    END;
    ELSE
    BEGIN
        SELECT 'La ruta ya existe ';
    END;
END;