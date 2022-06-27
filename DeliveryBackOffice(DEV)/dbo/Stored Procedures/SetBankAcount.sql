-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-10-28>
-- Description:	<Devuelve el id de la cuenta si exite
--				 si no exite la crea>
-- =============================================
CREATE PROCEDURE [dbo].[SetBankAcount]
    @BankId AS INT,
    @IdCustomer AS INT = -1,
    @AccountName AS NVARCHAR(100),
    @AccountNumner AS NVARCHAR(40),
    @Id_Currency AS INT = 1,
    @Token AS NVARCHAR(40),
    @BankAccountType AS NVARCHAR(40),
    @Identification AS NVARCHAR(40)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @IdExist AS INT = 0;
        SET @IdExist =
        (
            SELECT TOP 1
                   dcba.DCBA_Id
            FROM DeliveryCustomerBankAccount dcba
            WHERE dcba.DCBA_Num_account = @AccountNumner
                  AND LTRIM(RTRIM(dcba.DCBA_Nom_account)) = LTRIM(RTRIM(@AccountName))
                  AND dcba.DCBA_Bank_Id = @BankId
                  AND dcba.DCBA_Id_estado = 1
        );

        DECLARE @Id AS INT = 0;
        IF @IdExist IS NULL
        BEGIN



            IF (@BankId > 0)
            BEGIN
                SET @Id =
                (
                    SELECT ISNULL(MAX(dcba.DCBA_Id) + 1, 1)
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
                VALUES
                (@Id, @BankId, @IdCustomer, @AccountNumner, LTRIM(RTRIM(@AccountName)), @Id_Currency, @Token,
                 GETDATE(), NULL, NULL, 1, '', 0, '', @BankAccountType, @Identification);
            END;
        END;
        IF @IdExist > 0
        BEGIN
            SET @Id = @IdExist;
            UPDATE [dbo].[DeliveryCustomerBankAccount]
            SET [DCBA_BankAccountType] = @BankAccountType,
                [DCBA_Identification] = @Identification,
                [ACN_DateUpdate] = GETDATE(),
                [DCBA_TokenUpdate] = @Token,
                [DCBA_Bank_Id] = @BankId
            WHERE [DCBA_Id] = @Id;
        END;
    END TRY
    BEGIN CATCH
        SELECT 0 AS 'DCBA_Id',
               ERROR_MESSAGE() AS 'Description';
        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
        SELECT @Id AS 'DCBA_Id',
               'Registros guardados correctamente' AS 'Description';
    END;

END;
