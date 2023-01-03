
-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-27>
-- Description:	<Registrar favoritos >
-- =============================================
CREATE PROCEDURE [dbo].[spsSetAccountFavCOD]
    @Id int = null,
    @Alias VARCHAR(50),
    @IDBank int,
    @NameAccount NVARCHAR(30),
    @TypeAccount varchar(30),
    @DocID varchar(30),
    @IdAcount int,
    @Token varchar(30) = null,
    @NumberAcc varchar(30),
    @TokenUpdate varchar(30) = null,
    @Status int = 1,
    @IsDefault BIT = 0,
    @PhoneNumber AS INT = null,
    @NIT AS nvarchar(15) = null,
    @FlagInstantDeposits AS bit = null,
    @FlagApprovalofCODPaymentsWithTC as bit = null
AS
BEGIN

    BEGIN TRY
        BEGIN TRANSACTION

        DECLARE @IdExist AS INT = 0;
        --Adición funcionalidad cunenta por defecto
        --Oscar Morales - 2022-08-25
        IF (@Id is null or @Id = 0)
        BEGIN

            IF (@IsDefault = 1)
            BEGIN
                UPDATE DeliveryFavCOD
                SET IsDefault = 0
                WHERE StatusFavCOD = 1
                      AND IdAccountFavCOD = @IdAcount
            END
            ELSE IF NOT EXISTS
                 (
                     SELECT TOP 1
                         1
                     FROM DeliveryFavCOD
                     WHERE StatusFavCOD = 1
                           AND IdAccountFavCOD = @IdAcount
                 )
            BEGIN
                SET @IsDefault = 1
            END

            INSERT INTO DeliveryBackOffice.dbo.DeliveryFavCOD
            (
                AliasFavCOD,
                NameAccountFavCOD,
                TypeAccountFavCOD,
                DocumentIdFavCOD,
                StatusFavCOD,
                IdAccountFavCOD,
                TokenCreated,
                DateCreated,
                TokenUpdate,
                DateUpdate,
                IdBank,
                NumberAccFavCOD,
                IsDefault
            )
            VALUES
            (@Alias,
             @NameAccount,
             @TypeAccount,
             @DocID,
             1  ,
             @IdAcount,
             @Token,
             GETDATE(),
             NULL,
             NULL,
             @IdBank,
             @NumberAcc,
             @IsDefault
            )

            SELECT 1 [blnResult],
                   'Se ha guardado correctamente sus registros' [Description],
                   SCOPE_IDENTITY() [Id]
        END
        ELSE IF (@Id is not null)
        BEGIN

            if (@Status = 1) -- estado activo
            begin

                IF (@IsDefault = 1)
                BEGIN
                    UPDATE DeliveryFavCOD
                    SET IsDefault = 0
                    WHERE StatusFavCOD = 1
                          AND IdAccountFavCOD = @IdAcount
                END

                UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD
                SET AliasFavCOD = @Alias,
                    NameAccountFavCOD = @NameAccount,
                    TypeAccountFavCOD = @TypeAccount,
                    DocumentIdFavCOD = @DocID,
                    StatusFavCOD = 1,
                    IdAccountFavCOD = @IdAcount,
                    TokenUpdate = @Token,
                    DateUpdate = GETDATE(),
                    IdBank = @IDBank,
                    NumberAccFavCOD = @NumberAcc,
                    IsDefault = @IsDefault
                WHERE IdDeliveryFavCOD = @Id

                SELECT 1 [blnResult],
                       'Se ha actualizado actualizado sus registros' AS [Description],
                       @Id [Id]
            end
            else
            begin
                UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD
                set StatusFavCOD = @Status,
                    IsDefault = 0
                WHERE IdDeliveryFavCOD = @Id

                SELECT 1 [blnResult],
                       'Registro eliminado' AS [Description],
                       @Id [Id]
            end
        END

        SET @IdExist =
        (
            SELECT TOP 1
                dcba.DCBA_Id
            FROM DeliveryCustomerBankAccount dcba
            WHERE dcba.DCBA_Num_account = @NumberAcc
                  AND LTRIM(RTRIM(dcba.DCBA_Nom_account)) = LTRIM(RTRIM(@NameAccount))
                  AND dcba.DCBA_Bank_Id = @IdBank
                  AND dcba.DCBA_Id_estado = 1
        );

        BEGIN TRY
            IF (@IdExist IS NULL)
            BEGIN
                IF (@IdBank > 0)
                BEGIN
                    SET @Id =
                    (
                        SELECT ISNULL(max(dcba.DCBA_Id) + 1, 1)
                        FROM DeliveryCustomerBankAccount dcba
                    );
                    INSERT INTO [dbo].[DeliveryCustomerBankAccount]
                    (
                        [DCBA_Id],
                        [DCBA_Bank_Id],
                        [DCBA_Customer_Id],
                        [DCBA_Num_account],
                        [DCBA_Nom_account],
                        [DCBA_Id_currency],
                        [DCBA_TokenCreated],
                        [DCBA_DateCreated],
                        [DCBA_TokenUpdate],
                        [ACN_DateUpdate],
                        [DCBA_Id_estado],
                        [DCBA_Prefix],
                        [DCBA_IsCodeIBAN],
                        [DCBA_LegalIDN],
                        [DCBA_BankAccountType],
                        [DCBA_Identification]
                    )
                    --,[DCBA_TaxId])
                    VALUES
                    (@Id,
                     @IdBank,
                     -1 ,
                     @NumberAcc,
                     LTRIM(RTRIM(@NameAccount)),
                     1  ,
                     @Token,
                     GETDATE(),
                     null,
                     null,
                     1  ,
                     '' ,
                     0  ,
                     '' ,
                     @TypeAccount,
                     @DocID
                    )
                -- ,IIF(@Nit='',NULL,@Nit))
                END
            END
            IF (@IdExist > 0)
            BEGIN
                SET @Id = @IdExist;
                UPDATE [dbo].[DeliveryCustomerBankAccount]
                SET [DCBA_BankAccountType] = @TypeAccount,
                    [DCBA_Identification] = @DocID,
                    [ACN_DateUpdate] = GETDATE(),
                    [DCBA_TokenUpdate] = @Token,
                    [DCBA_Bank_Id] = @IdBank
                where [DCBA_Id] = @Id
            END
        END TRY
        BEGIN CATCH
        END CATCH

        IF @@TRANCOUNT > 0
            COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT 0 [blnResult],
               ERROR_MESSAGE() [Description],
               0 [Id],
               ERROR_NUMBER() [ErrorNumber],
               ERROR_SEVERITY() [ErrorSeverity],
               ERROR_STATE() [ErrorState],
               ERROR_PROCEDURE() [ErrorProcedure],
               ERROR_LINE() [ErrorLine],
               ERROR_MESSAGE() [ErrorMessage];
    END CATCH
END


