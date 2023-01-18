
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-11>
-- Description:	<Actualizacion de datos de perfil de usuario>
-- =============================================

CREATE PROCEDURE [dbo].[spws_set_profile]
    -- Add the parameters for the stored procedure here
    @FirstName VARCHAR(200),
    @LastName VARCHAR(200),
    @Gender VARCHAR(200),
    @Birthdate DATE,
    @Identification VARCHAR(200),
    @Nationality VARCHAR(200),
    @NickName VARCHAR(200),
    @Language VARCHAR(2) = 'ES', -- ESPAÑOL
    @Currency VARCHAR(10),
    @Token VARCHAR(200),
    @IdSystem INT = 1,
    @Phone NVARCHAR(15) = '+502',
	@VerifiedPhone BIT	='false',
    @UrlFacebook NVARCHAR(300) = NULL,
    @UrlInstagram NVARCHAR(300) = NULL,
    @UrlEcommerce NVARCHAR(300) = NULL,
    @UrlWebsite NVARCHAR(300) = NULL,
    @IdentificationImageA NVARCHAR(500) = NULL,
    @IdentificationImageB NVARCHAR(500) = NULL,
	@PerfilImage NVARCHAR(500) = NULL
--	@UpdateIdentificationImage BIT	 ='false'

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --select * from Person

    -- insertar en tabla temporal posbibles mensajes de error

    IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
        DROP TABLE #errormessage;
    SELECT *
    INTO #errormessage
    FROM
    (
        SELECT 500 AS IdResult,
               'Token Inválido' AS Message,
               'Token' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Error fatal intente de nuevo mas tarde' AS Message,
               'Transaction' AS Id
        UNION
        SELECT 200 AS IdResult,
               'Perfil Actualizado correctamente' AS Message,
               'Ok' AS Id
    ) AS errror;



    DECLARE @jsonResult NVARCHAR(MAX);

    DECLARE @IdUser BIGINT =
            (
                SELECT TOP 1 t.TknIdUser FROM TokenLog t WHERE t.TknIdToken = @Token
            );

	DECLARE @IdAccount BIGINT =
            (
                SELECT ac.AccIdAccount FROM RolByUserByAccount rba
					INNER JOIN Account ac
					ON rba.RuaIdAccount = ac.AccIdAccount
					WHERE rba.RuaIdUser = @IdUser
            );

    PRINT @@TRANCOUNT;

    IF @IdUser > 0
    BEGIN
        BEGIN TRANSACTION;
        BEGIN TRY
            PRINT @@TRANCOUNT;
            UPDATE dbo.Person
            SET PerFirstName = @FirstName,
                PerLastName = @LastName,
                PerGender = @Gender,
                PerBirthdate = @Birthdate,
                PerIdentification = @Identification,
                PerNationality = @Nationality,
                PerTokenUpdated = @Token,
                PerDateUpdated = GETDATE()
            FROM dbo.RegisterUser usr
                INNER JOIN dbo.Person per
                    ON per.PerIdPerson = usr.UsrIdPerson
            WHERE usr.UsrIdUser = @IdUser;

            UPDATE dbo.RegisterUser
            SET UsrNickName = @NickName,
                UsrLang = @Language,
                UsrCurrency = @Currency,
                UsrTokenUpdated = @Token,
                UsrDateUpdated = GETDATE(),
                PrefixCallingCode = '+502',
                Phone = @Phone,
                UrlFacebook = @UrlFacebook,
                UrlInstagram = @UrlInstagram,
                UrlWebsite = @UrlWebsite,
                UrlEcommerce = @UrlEcommerce,
                IdentificationImageA = ISNULL(@IdentificationImageA, IdentificationImageA),
                IdentificationImageB = ISNULL(@IdentificationImageB, IdentificationImageB),
				VerifiedPhone = @VerifiedPhone
            WHERE UsrIdUser = @IdUser;

			UPDATE dbo.Account
			SET ImageProfile = ISNULL(@PerfilImage, ImageProfile)
			WHERE AccIdAccount = @IdAccount

        END TRY
        BEGIN CATCH

            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message
                                           + '"}'
                                    FROM #errormessage
                                    WHERE Id = 'Transaction'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
            ROLLBACK TRANSACTION;
        END CATCH;
        PRINT @@TRANCOUNT;
        IF @@TRANCOUNT > 0
        BEGIN
            COMMIT TRANSACTION;
            SET @jsonResult =
            (
                SELECT STUFF(
                                (
                                    SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message
                                           + '"}'
                                    FROM #errormessage
                                    WHERE Id = 'Ok'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;
    -- destruir tablas temporales
    END;
    ELSE
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message
                                       + '"}'
                                FROM #errormessage
                                WHERE Id = 'Token'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;
    IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL
        DROP TABLE #errormessage;

    -- retornar resultado en formato json

    SELECT ('[{' + @jsonResult + ']') jsonResult;

END;



