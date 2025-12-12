-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-29>
-- Description:	<Guias por pagar COD>
-- =============================================
-- =============================================
-- Author:		      <Marco, Jiménez>
-- Modification date: <2021-11-10>
-- Description:	      <Se agrega la capacidad para poder enviar un reporte de depósito, 
--                     tomando como base el correo que se tiene registrado en la DeliveryOrder>
-- =============================================
-- =============================================
-- Author:		      <Marco, Jiménez>
-- Modification date: <2022-01-24>
-- Description:	      <Se cambia la manera de obtener el id de banco, para poder obtener el 
-- banco con el que se generó el lote en la BatchDetailCOD>
-- =============================================
-- Author:            <Daniel, Ramirez>
-- Modification date: <2024-07-11>
-- Description:       <Se agrega el filtro por pais, ajustando el tiempo de ejcución>
-- =============================================
CREATE PROCEDURE [dbo].[GetDailyCodPayment]
-- Add the parameters for the stored procedure here
   @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN
    DECLARE @Debug BIT = 'false';
    SELECT TOP 500
           CDATA.IdCustomer,
           CASE
               WHEN SUBSTRING(CDATA.RegexEmail, 1, 1) = ',' THEN
                   LEFT(CDATA.RegexEmail, 1)
               ELSE
                   CDATA.RegexEmail
           END AS RegexEmail,
           CDATA.SenderEmail,
           CDATA.DCBA_Bank_Id
    FROM
    (
        SELECT DISTINCT
        DH.Customer_Id AS IdCustomer,
        DH.Customer_Email AS RegexEmail,
        '0' AS SenderEmail,
        DH.Bank_id AS DCBA_Bank_Id
        FROM dbo.DepositReportCODHeader AS DH
        WHERE DH.Notificated = 0
        AND DH.SaleChannelId NOT IN (3)
        AND (
            LEN(COALESCE(DH.Customer_Email, '')) > 0
            OR LEN(COALESCE(DH.Sender_Email, '')) > 0
        )
        AND (DH.IdKindOfVPClient IS NULL OR DH.IdKindOfVPClient <> 1)
        AND (DH.IdCustomer IS NULL  OR ISNULL(DH.Customer_Type, 0) <> 2)
        UNION
        SELECT DISTINCT
        0 AS IdCustomer,
        DH.Customer_Email AS RegexEmail,
        DH.Sender_Email AS SenderEmail,
        DH.Bank_id AS DCBA_Bank_Id
        FROM dbo.DepositReportCODHeader AS DH
        WHERE DH.Notificated = 0
        AND DH.SalePipeLineId = 3
        AND LEN(COALESCE(DH.Sender_Email, '')) > 0
    ) CDATA
          LEFT JOIN [dbo].[DeliveryBank]  AS bank WITH(NOLOCK)
                 ON bank.Id_bank = CDATA.DCBA_Bank_Id
    WHERE ISNULL(IIF(CDATA.DCBA_Bank_Id = '', NULL, CDATA.DCBA_Bank_Id), 0) <> 0
      AND bank.Id_country = @IdCountry--IIF(@IdCountry = '-1', bank.Id_country, @IdCountry)  
   --OPTION (MAXDOP 1);  
END;






