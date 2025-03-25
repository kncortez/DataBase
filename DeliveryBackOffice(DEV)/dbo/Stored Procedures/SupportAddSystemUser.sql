--insertarle nuevos sistemas a un usuario
CREATE PROCEDURE SupportAddSystemUser
    @UstIdUser INT
  , @UstIdSystem INT
  , @UstTokenCreated VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS
    (
        SELECT 1
        FROM UserSystemRestriction
        WHERE UstIdUser = @UstIdUser
              AND UstIdSystem = @UstIdSystem
    )
    BEGIN
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
        (   @UstIdUser       -- RusIdUser --este campo es RegisterUserID
          , @UstIdSystem     -- sistema que quiere usar el usuario
          , 10               -- INTENTOS
          , 0                -- INTENTOS QUE LLEVA
          , 'ACTIVE'         -- ESTADO
          , 1                -- ROWSTATUS
          , @UstTokenCreated -- token varchar(50)
          , GETDATE()        --date created
          , GETDATE()        --date created
            );
        SELECT 'El sistema fue agregado correctamente' AS Mensaje;
    END;
    ELSE
    BEGIN
        SELECT 'Ya existe un registro de este sistema para este usuario' AS Mensaje;
    END;
END;