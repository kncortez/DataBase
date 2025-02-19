-- =============================================  
-- Mofified:    <Cristian Suazo>  
-- Create date: <2025-01-19>  
-- Description: <Se pasa el Json a tablas>  
-- =============================================  

ALTER PROCEDURE [dbo].[spwsGetFavoritiesCOD_New]
    @IdAccount int,
    @Status int
AS
BEGIN

    SELECT COALESCE(UPPER(fav.AliasFavCOD), 'N/A') AS Alias,
           COALESCE(UPPER(fav.NameAccountFavCOD) , 'N/A') AS NameAccount,
           COALESCE(UPPER(fav.IdDeliveryFavCOD), 'N/A') AS IdFavCOD,
           COALESCE(UPPER(fav.TypeAccountFavCOD), 'N/A') AS TypeAccount,
           COALESCE(CAST(fav.DocumentIdFavCOD AS VARCHAR(20)), 'N/A') AS DocumentID,
           COALESCE(fav.TokenCreated, 'N/A') AS TokenCreate,
           COALESCE(CAST(fav.IdBank AS VARCHAR(20)), 'N/A') AS IdBank,
           COALESCE(REPLACE(fav.NumberAccFavCOD , '-', ''), 'N/A') AS NumberAccount,
           COALESCE(bn.Acronym , 'N/A') AS Acronym,
           COALESCE(bn.Name , 'N/A') AS BankDescription,
           CASE
               WHEN fav.IsDefault = 1 THEN
                   'true'
               ELSE
                   'false'
           END AS IsDefault,
           COALESCE(CAST(DCBAmax.DCBA_Id AS VARCHAR(20)), 'N/A') AS DCBA
    FROM dbo.DeliveryFavCOD fav WITH (NOLOCK)
        INNER JOIN dbo.DeliveryBank bn
            on (bn.Id_bank = fav.IdBank)
        OUTER APPLY
    (
        SELECT MAX(DCBA.DCBA_Id) 'DCBA_Id'
        FROM [DeliveryBackOffice].[dbo].[DeliveryCustomerBankAccount] DCBA WITH (NOLOCK)
        WHERE fav.NumberAccFavCOD = dcba.DCBA_Num_account
              AND fav.IdBank = dcba.DCBA_Bank_Id
              AND fav.TypeAccountFavCOD = dcba.DCBA_BankAccountType
              AND dcba.DCBA_Id_estado = 1
    ) DCBAmax
    WHERE StatusFavCOD = 1
          and IdAccountFavCOD = @IdAccount
END
