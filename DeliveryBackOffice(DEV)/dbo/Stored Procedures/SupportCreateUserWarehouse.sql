-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2024-09-02>
-- Description:	<Sp para reactivar>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCreateUserWarehouse]
    @IdUser NVARCHAR(100)
  , @Usename INT
  , @idStation INT
  , @Token NVARCHAR(60)
AS
BEGIN

    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.InternalUser it WITH (NOLOCK)
        WHERE it.IdUser = @IdUser
              AND it.Username = @Usename
              AND it.RowStatus = 1
    )
    BEGIN

        BEGIN TRY
            BEGIN TRANSACTION;

            DECLARE @IdRegisterUser INT;


            SELECT @IdRegisterUser = it.RegisterUserID
            FROM dbo.InternalUser it WITH (NOLOCK)
            WHERE it.IdUser = @IdUser
                  AND it.Username = @Usename
                  AND it.RowStatus = 1;

            SELECT TOP 1
                   @idStation = StationId
            FROM dbo.RolByUserBySystem
            WHERE RusIdUser = @IdRegisterUser;


            INSERT INTO dbo.UserSystemRestriction
            (
                UstIdUser
              , UstIdSystem
              , UstAccessRetries
              , UstRetries
              , UstStatus
              , UstRowStatus
              , UstTokenCreated
              , UstDateCreated
              , UstOperationDate
            )
            VALUES
            (   @IdRegisterUser -- UstIdUser - bigint
              , 12              -- UstIdSystem - int
              , 10              -- UstAccessRetries - int
              , 0               -- UstRetries - int
              , 'ACTIVE'        -- UstStatus - varchar(10)
              , 1               -- UstRowStatus - bit
              , @Token          -- UstTokenCreated - varchar(50)
              , GETDATE()       -- UstDateCreated - datetime
              , GETDATE()       -- UstOperationDate - datetime
                );


            INSERT INTO dbo.RolByUserBySystem
            (
                RusIdRol
              , RusIdSystem
              , RusIdUser
              , RusRowStatus
              , RusTokenCreated
              , RusDateCreated
              , RusTokenUpdated
              , RusDateUpdated
              , StationId
            )
            VALUES
            (   25              -- RusIdRol - int
              , 12              -- RusIdSystem - int
              , @IdRegisterUser -- RusIdUser - bigint
              , 1               -- RusRowStatus - bit
              , @Token          -- RusTokenCreated - varchar(50)
              , GETDATE()       -- RusDateCreated - datetime
              , NULL            -- RusTokenUpdated - varchar(50)
              , NULL            -- RusDateUpdated - datetime
              , @idStation      -- StationId - int
                );
            COMMIT TRANSACTION;

            SELECT 'La ruta ya exite';
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
        SELECT 'Usuario no existe o esta de baja consulta el estado de este usuario con el sp [SupportGetStatusCorporateUser] ';
    END;
END;