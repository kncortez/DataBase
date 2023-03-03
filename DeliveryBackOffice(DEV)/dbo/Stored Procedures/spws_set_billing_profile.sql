
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Administracion de perfiles de facturación >
-- ===========================================

--	Cambiar tabla temporal messagelist a variable tipo tabla @TblMessageList
--	Author: Jerson Ochoa - <05-01-2023>

CREATE PROCEDURE [dbo].[spws_set_billing_profile]
    -- Add the parameters for the stored procedure here

    @IdBilling BIGINT,
    @IdAccount BIGINT,
    @Name NVARCHAR(100),
    @Address NVARCHAR(200),
    @TaxId NVARCHAR(50),
    @Status INT = 1,
    @Token NVARCHAR(200),
    @IsDefault BIT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @TelemarketingRole INT =
            (
                SELECT TOP 1
                       CR.RolIdRol
                FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH (NOLOCK)
                WHERE CR.RolName = 'Ventas telemercadeo' COLLATE Latin1_General_CI_AI
            );

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @TblMessageList TABLE
    (
        IdResult INT,
        Message NVARCHAR(150),
        Id NVARCHAR(50)
    );

    -- insertar en variable tipo tabla posibles mensajes de respuesta
    INSERT INTO @TblMessageList
    (
        IdResult,
        Message,
        Id
    )
    VALUES
    (200, 'Registro creado correctamente', 'Insert');
    INSERT INTO @TblMessageList
    (
        IdResult,
        Message,
        Id
    )
    VALUES
    (500, 'Usuario no asociado a cuenta', 'Access');
    INSERT INTO @TblMessageList
    (
        IdResult,
        Message,
        Id
    )
    VALUES
    (200, 'Registro actualizado correctamente', 'Update');
    INSERT INTO @TblMessageList
    (
        IdResult,
        Message,
        Id
    )
    VALUES
    (200, 'Registro eliminado', 'Delete');
    INSERT INTO @TblMessageList
    (
        IdResult,
        Message,
        Id
    )
    VALUES
    (501, 'Ocurrió una excepción', 'Exception');

    BEGIN TRY
        BEGIN TRANSACTION;
        -- obtener el id de usuarion con base al token

        DECLARE @IdUser BIGINT =
                (
                    SELECT TOP 1 t.TknIdUser FROM TokenLog t WHERE t.TknIdToken = @Token
                );
        DECLARE @IdUserTokenIsTelemarketing BIT =
                (
                    SELECT TOP 1
                           1
                    FROM [DeliveryBackOffice].[dbo].[RolByUserBySystem] RBUBA WITH (NOLOCK)
                    WHERE RBUBA.RusIdUser = @IdUser
                          AND RBUBA.RusIdRol = @TelemarketingRole
                          AND RBUBA.RusRowStatus = 1
                );

        IF (
               (EXISTS
        (
            SELECT TOP 1
                   1
            FROM RolByUserByAccount
            WHERE RuaIdAccount = @IdAccount
                  AND RuaIdUser = @IdUser
                  AND RuaRowStatus = 1
        )
               )
               OR (@IdUserTokenIsTelemarketing = 1)
           ) -- el usuario tiene acceso  a la cuenta indicada
        BEGIN

            SELECT TOP 1
                   blp.BlpIdBilling
            INTO #Billing
            FROM dbo.BillingProfile blp
            WHERE blp.BlpIdBilling = @IdBilling
                  AND blp.BlpIdAccount = @IdAccount;


            IF
            (
                SELECT COUNT(1)FROM #Billing
            ) > 0 -- verifica que la direccion exista
            BEGIN
                IF @Status = 0 -- se infiere que, se va a desctivar el registro
                BEGIN
                    -- desactivar registro (borrado logico)
                    UPDATE [dbo].[BillingProfile]
                    SET [BlpRowStatus] = @Status,
                        [BlpTokenUpdated] = @Token,
                        [BlpDateUpdated] = GETDATE(),
                        [IsDefault] = 0
                    WHERE [BlpIdBilling] = @IdBilling;

                    SET @jsonResult =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"IdBilling":'
                                                   + CONVERT(VARCHAR, @IdBilling) + ',' + '"Message":"' + Message
                                                   + '"}'
                                            FROM @TblMessageList
                                            WHERE Id = 'Delete'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'),
                                        1,
                                        1,
                                        ''
                                    )
                    );

                END;
                ELSE -- se va a actualizar el registro
                BEGIN


                    IF (@IsDefault = 1)
                    BEGIN
                        UPDATE BillingProfile
                        SET IsDefault = 0
                        WHERE BlpRowStatus = 1
                              AND BlpIdAccount = @IdAccount;
                    END;

                    -- actualizar el registro con los datos proporcionado
                    UPDATE [dbo].[BillingProfile]
                    SET [BlpIdAccount] = @IdAccount,
                        [BlpName] = @Name,
                        [BlpAddress] = @Address,
                        [BlpTaxId] = @TaxId,
                        [BlpTokenUpdated] = @Token,
                        [BlpDateUpdated] = GETDATE(),
                        [IsDefault] = @IsDefault
                    WHERE [BlpIdBilling] = @IdBilling;

                    SET @jsonResult =
                    (
                        SELECT STUFF(
                                        (
                                            SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"IdBilling":'
                                                   + CONVERT(VARCHAR, @IdBilling) + ',' + '"Message":"' + Message
                                                   + '"}'
                                            FROM @TblMessageList
                                            WHERE Id = 'Update'
                                            FOR XML PATH(''), TYPE
                                        ).value('.', 'varchar(max)'),
                                        1,
                                        1,
                                        ''
                                    )
                    );
                END;
            END;
            ELSE -- la cuenta no existe, entonces se crea
            BEGIN

                IF (@IsDefault = 1)
                BEGIN
                    UPDATE BillingProfile
                    SET IsDefault = 0
                    WHERE BlpRowStatus = 1
                          AND BlpIdAccount = @IdAccount;
                END;
                ELSE IF NOT EXISTS
                     (
                         SELECT TOP 1
                                1
                         FROM BillingProfile
                         WHERE BlpIdAccount = @IdAccount
                               AND BlpRowStatus = 1
                     )
                BEGIN
                    SET @IsDefault = 1;
                END;

                -- insertar nueva direccion

                INSERT INTO [dbo].[BillingProfile]
                (
                    [BlpIdAccount],
                    [BlpName],
                    [BlpAddress],
                    [BlpTaxId],
                    [BlpRowStatus],
                    [BlpTokenCreated],
                    [BlpDateCreated],
                    [BlpTokenUpdated],
                    [BlpDateUpdated],
                    [IsDefault]
                )
                VALUES
                (   @IdAccount, @Name, @Address, @TaxId, 1, -- se crean los registros activos por default 
                    @Token, GETDATE(), NULL, NULL, @IsDefault);

                SET @IdBilling = SCOPE_IDENTITY();
                SET @jsonResult =
                (
                    SELECT STUFF(
                                    (
                                        SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"IdBilling":'
                                               + CONVERT(VARCHAR, @IdBilling) + ',' + '"Message":"' + Message + '"}'
                                        FROM @TblMessageList
                                        WHERE Id = 'Insert'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                )
                );
            END;
        END;
        ELSE
        BEGIN
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"IdBilling":'
                                           + CONVERT(VARCHAR, @IdBilling) + ',' + '"Message":"' + Message + '"}'
                                    FROM @TblMessageList
                                    WHERE Id = 'Access'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"IdBilling":'
                                       + CONVERT(VARCHAR, @IdBilling) + ',' + '"Message":"' + Message + '"}'
                                FROM @TblMessageList
                                WHERE Id = 'Exception'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

    END CATCH;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#Billing', 'U') IS NOT NULL
        DROP TABLE #Billing;

    -- retornar resultado en formato json

    SELECT ('[{' + @jsonResult + ']') jsonResult;
END;



