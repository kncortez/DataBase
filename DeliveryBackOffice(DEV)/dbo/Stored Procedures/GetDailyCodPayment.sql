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
               cu.IdCustomer,
               IIF(@Debug = 'true',
                   'envios@parser4@gmail.com,cod.gt@forzalatam.com',
                   CONCAT(
                             COALESCE(
                                         IIF(LTRIM(RTRIM(cu.CODContactEmail)) = '', NULL, LTRIM(RTRIM(cu.CODContactEmail))),
                                         IIF(LTRIM(RTRIM(do.Sender_Mail)) = '', NULL, LTRIM(RTRIM(do.Sender_Mail))),
                                         IIF(LTRIM(RTRIM(cu.RegexEmail)) = '', NULL, LTRIM(RTRIM(cu.RegexEmail)))
                                     ),
                             ''--',envios.parser4@gmail.com,cod.gt@forzalatam.com'
                         ))
               --)
               RegexEmail,
               '0' SenderEmail,
               btd.BankId AS DCBA_Bank_Id
        FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
            INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                ON btd.[GuideSerie] = pg.[GuideSerie]
                   AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                ON btd.[GuideSerie] = do.[Guide_Serie]
                   AND btd.[GuideNumber] = do.[Guide_Number]
            --LEFT JOIN VisitPointByClientPortfolio vpbc 
            --	ON do.VisitpointClientPortfolioId = vpbc.IdVisitPointByClientPortfolio 
            --	AND vpbc.RowStatus = 1
            LEFT JOIN dbo.Township twn WITH (NOLOCK)
                ON twn.IdTownship = do.ReceiverIdTownship
                AND  twn.TownshipName = do.Receiver_Town
            LEFT JOIN dbo.Province prv WITH (NOLOCK)
                ON prv.IdProvince = twn.IdProvince
            LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN dbo.Customer cu WITH (NOLOCK)
                ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
            LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
                ON dc.DCBA_Id = do.DCBA_ID
                   AND dc.DCBA_Id_estado = 1
        WHERE pg.[Notificated] = 0
              AND pg.BatchCODId IS NOT NULL
              AND btd.[AuthorizationNumber] IS NOT NULL
              AND vpc.SaleChannelId NOT IN ( 3 ) --no es portal
			  AND 
			  (LEN(COALESCE(cu.CODContactEmail,''))>0
			  OR LEN(COALESCE(do.Sender_Mail,''))>0
			  OR LEN(COALESCE(cu.RegexEmail,''))>0--quitar valores nulos
			  )
 AND NOT EXISTS --búsqueda por sender
 (
	SELECT A1.IdCustomer FROM DeliveryBackOffice.dbo.Customer A1 WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.DBO.VisitPointClient  A2 WITH(NOLOCK) 
	ON A1.IdCustomer = A2.CustomerID
	WHERE DO.Sender_ID = A2.CodeOfReference    
	AND A2.IdKindOfVPClient = 1
 )
 AND NOT EXISTS --búsqueda por customer
 (
	SELECT A1.IdCustomer FROM DeliveryBackOffice.dbo.Customer A1 WITH(NOLOCK)	
	WHERE DO.IdCustomer = A1.IdCustomer
	AND A1.IdCustomerType = 2 --REDISTRIBUIDOR
 )

--NO INCLUIR A EXPRESS CENTER



        --ORDER BY cu.IdCustomer
        UNION
        SELECT *
        FROM
        (
            SELECT DISTINCT
                   0 IdCustomer,
                   LTRIM(RTRIM(IIF(@Debug= 'true',
                                   'envios.parser4@gmail.com,cod.gt@forzalatam.com',
                                   ISNULL(
                                             IIF(do.Sender_Mail = '',
                                              NULL,
                                              do.Sender_Mail/*CONCAT(do.Sender_Mail, ',envios.parser4@gmail.com,cod.gt@forzalatam.com')*/
											  ),
                                             ''--'envios.parser4@gmail.com,cod.gt@forzalatam.com'
                                         ))
                              )
                        )
                   RegexEmail,
                   do.Sender_Mail SenderEmail,
                   btd.BankId AS DCBA_Bank_Id
            FROM [dbo].[BatchDetailCOD] AS btd WITH (NOLOCK)
                INNER JOIN [dbo].[ProcessedGuideCOD] AS pg WITH (NOLOCK)
                    ON btd.[GuideSerie] = pg.[GuideSerie]
                       AND btd.[GuideNumber] = pg.[GuideNumber]
                INNER JOIN [dbo].[DeliveryOrder] AS do WITH (NOLOCK)
                    ON btd.[GuideSerie] = do.[Guide_Serie]
                       AND btd.[GuideNumber] = do.[Guide_Number] 
                --LEFT JOIN VisitPointByClientPortfolio vpbc 
                --	ON do.VisitpointClientPortfolioId = vpbc.IdVisitPointByClientPortfolio 
                --	AND vpbc.RowStatus = 1
                LEFT JOIN dbo.Township twn WITH (NOLOCK)
                    ON twn.IdTownship = do.ReceiverIdTownship
                    AND twn.TownshipName = do.Receiver_Town
                LEFT JOIN dbo.Province prv WITH (NOLOCK)
                    ON prv.IdProvince = twn.IdProvince
                LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = do.Sender_ID
                LEFT JOIN dbo.Customer cu WITH (NOLOCK)
                    ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                LEFT JOIN dbo.DeliveryCustomerBankAccount dc WITH (NOLOCK)
                    ON dc.DCBA_Id = do.DCBA_ID
                       AND dc.DCBA_Id_estado = 1
            WHERE pg.[Notificated] = 0
                  AND pg.BatchCODId IS NOT NULL
                  AND btd.[AuthorizationNumber] IS NOT NULL
                  AND do.SalePipeLineId IN ( 3 )
				  AND LEN(COALESCE(do.Sender_Mail,''))>0 --quitar valores nulos
            GROUP BY do.Sender_Mail,
                     cu.CODContactEmail,
                     cu.RegexEmail,
                     dc.DCBA_Bank_Id,
                     pg.GuideSerie,
                     pg.GuideNumber,
                     btd.BankId
        ) X
    ) CDATA
          LEFT JOIN [dbo].[DeliveryBank] AS bank
                 ON bank.Id_bank = CDATA.DCBA_Bank_Id
    WHERE ISNULL(IIF(CDATA.DCBA_Bank_Id = '', NULL, CDATA.DCBA_Bank_Id), 0) <> 0
      AND ISNULL(bank.Id_country,'GT') = IIF(@IdCountry = '-1', ISNULL(bank.Id_country,'GT'), @IdCountry)
END;







