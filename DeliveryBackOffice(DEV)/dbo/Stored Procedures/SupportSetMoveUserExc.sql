-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2024-09-02>
-- Description:	<Sp para reactivar>
-- =============================================

CREATE PROCEDURE [dbo].[SupportSetMoveUserExc]
    @Email NVARCHAR(200)
  , @Token NVARCHAR(50)
  , @NewVisitpoint INT
AS
BEGIN

    DECLARE @IdRegister INT = NULL;
    DECLARE @NewStation INT = NULL;


    SELECT TOP 1
           @IdRegister = rg.UsrIdUser
    FROM dbo.RegisterUser               rg
        INNER JOIN dbo.VisitPointByUser vup
            ON vup.RegisterUserID = rg.UsrIdUser
        INNER JOIN dbo.VisitPointClient vp
            ON vp.IdVisitPointClient = vup.IdVisitPointClient
    WHERE rg.UsrEmail = @Email
          AND rg.UsrRowStatus = 1
          AND vup.RowStatus = 1
          AND vp.StatusClient = 1;


    IF @IdRegister IS NULL
    BEGIN
        SELECT 'El usuario no existe o esta inactivo';
    END;
    ELSE
    BEGIN



        SELECT 'Configuracion Anterior'
             , rg.UsrIdUser           [IdRegisterUser]
             , rg.UsrEmail            [Email]
             , vup.IdVisitPointClient [IdVisitPointClient]
             , vp.DescriptionOfClient [EXC]
             , rg.UsrLastPassword     [Password]
        FROM dbo.RegisterUser               rg
            INNER JOIN dbo.VisitPointByUser vup
                ON vup.RegisterUserID = rg.UsrIdUser
            INNER JOIN dbo.VisitPointClient vp
                ON vp.IdVisitPointClient = vup.IdVisitPointClient
        WHERE rg.UsrEmail = @Email;



        SELECT TOP 1
               @NewStation = cs.IdStation
        FROM dbo.VisitPointClient     vp
            INNER JOIN dbo.CatStation cs
                ON cs.CodeOfReference = vp.CodeOfReference
        WHERE vp.IdVisitPointClient = @NewVisitpoint
              AND cs.RowStatus = 1
              AND cs.StationType = 2
        ORDER BY cs.IdStation DESC;

        IF @NewStation IS NULL
        BEGIN

            SELECT 'La estacion no existe verifique el numero de visitpoint que ingresó';
        END;

        BEGIN TRY
            BEGIN TRANSACTION;
            UPDATE dbo.VisitPointByUser
            SET IdVisitPointClient = @NewVisitpoint
              , TokenUpdated = @Token
              , DateUpdated = GETDATE()
            WHERE RegisterUserID = @IdRegister
                  AND RowStatus = 1;


            UPDATE dbo.RolByUserBySystem
            SET StationId = @NewStation
              , RusTokenUpdated = @Token
              , RusDateUpdated = GETDATE()
            WHERE RusIdUser = @IdRegister
                  AND RusRowStatus = 1;
            COMMIT;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            SELECT ERROR_LINE()
                 , ERROR_MESSAGE()
                 , ERROR_NUMBER();

        END CATCH;



        SELECT 'Configuración Nueva'
             , rg.UsrIdUser           [IdRegisterUser]
             , rg.UsrEmail            [Email]
             , vup.IdVisitPointClient [IdVisitPointClient]
             , vp.DescriptionOfClient [EXC]
             , rg.UsrLastPassword     [Password]
        FROM dbo.RegisterUser               rg
            INNER JOIN dbo.VisitPointByUser vup
                ON vup.RegisterUserID = rg.UsrIdUser
            INNER JOIN dbo.VisitPointClient vp
                ON vp.IdVisitPointClient = vup.IdVisitPointClient
        WHERE rg.UsrEmail = @Email;




    END;


END;