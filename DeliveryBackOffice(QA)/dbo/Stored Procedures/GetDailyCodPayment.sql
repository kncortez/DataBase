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
CREATE PROCEDURE [dbo].[GetDailyCodPayment]
-- Add the parameters for the stored procedure here

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
            --       IIF(do.VisitpointClientPortfolioId > 0,NULL,cu.IdCustomer) IdCustomer,
            --do.VisitpointClientPortfolioId AS IdClientPortfolio,
               cu.IdCustomer,
               -- IIF(do.VisitpointClientPortfolioId != NULL,CONCAT(vpbc.Email,'envios.parser4@gmail.com,carlos.valdes@forzalatam.com,gloria.villatoro@forzalatam.com'),
               IIF(@Debug = 'true',
                   'envios@parser4@gmail.com,cod.gt@forzalatam.com',
                   CONCAT(
                             COALESCE(
                                         IIF(LTRIM(RTRIM(cu.CODContactEmail)) = '', NULL, LTRIM(RTRIM(cu.CODContactEmail))),
                                         IIF(LTRIM(RTRIM(do.Sender_Mail)) = '', NULL, LTRIM(RTRIM(do.Sender_Mail))),
                                         IIF(LTRIM(RTRIM(cu.RegexEmail)) = '', NULL, LTRIM(RTRIM(cu.RegexEmail)))
                                     ),
                             ',envios.parser4@gmail.com,cod.gt@forzalatam.com'
                         ))
               --)
               RegexEmail,
               '0' SenderEmail,
               btd.BankId  AS DCBA_Bank_Id
        FROM [dbo].[BatchDetailCOD] AS btd
            INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
                ON btd.[GuideSerie] = pg.[GuideSerie]
                   AND btd.[GuideNumber] = pg.[GuideNumber]
            INNER JOIN [dbo].[DeliveryOrder] AS do
                ON btd.[GuideSerie] = do.[Guide_Serie]
                   AND btd.[GuideNumber] = do.[Guide_Number]
            --LEFT JOIN VisitPointByClientPortfolio vpbc 
            --	ON do.VisitpointClientPortfolioId = vpbc.IdVisitPointByClientPortfolio 
            --	AND vpbc.RowStatus = 1
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = do.ReceiverIdTownship
            LEFT JOIN dbo.Township tw
                ON tw.TownshipName = do.Receiver_Town
            LEFT JOIN dbo.Province prv
                ON prv.IdProvince = twn.IdProvince
            LEFT JOIN dbo.Province pr
                ON pr.IdProvince = tw.IdProvince
            LEFT JOIN dbo.VisitPointClient vpc
                ON vpc.CodeOfReference = do.Sender_ID
            LEFT JOIN dbo.Customer cu
                ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
            LEFT JOIN dbo.DeliveryCustomerBankAccount dc
                ON dc.DCBA_Id = do.DCBA_ID
                   AND dc.DCBA_Id_estado = 1
        WHERE pg.[Notificated] = 0
              AND pg.BatchCODId IS NOT NULL
              AND btd.[AuthorizationNumber] IS NOT NULL
              AND vpc.SaleChannelId NOT IN ( 3 )
        --ORDER BY cu.IdCustomer
        UNION
        SELECT *
        FROM
        (
            SELECT DISTINCT
                --IIF(do.VisitpointClientPortfolioId > 0,NULL,cu.IdCustomer) IdCustomer,
                --do.VisitpointClientPortfolioId AS IdClientPortfolio,
                   0 IdCustomer,
                   --IIF(do.VisitpointClientPortfolioId != NULL,CONCAT(vpbc.Email,'envios.parser4@gmail.com,carlos.valdes@forzalatam.com,gloria.villatoro@forzalatam.com'),

                   LTRIM(RTRIM(IIF(@Debug = 'true',
                                   'envios.parser4@gmail.com,cod.gt@forzalatam.com',
                                   ISNULL(
                                             IIF(do.Sender_Mail = '',
                                              NULL,
                                              CONCAT(do.Sender_Mail, ',envios.parser4@gmail.com,cod.gt@forzalatam.com')),
                                             'envios.parser4@gmail.com,cod.gt@forzalatam.com'
                                         ))
                              )
                        )
                   --)
                   RegexEmail,
                   do.Sender_Mail SenderEmail,
                   btd.BankId  AS DCBA_Bank_Id
            FROM [dbo].[BatchDetailCOD] AS btd
                INNER JOIN [dbo].[ProcessedGuideCOD] AS pg
                    ON btd.[GuideSerie] = pg.[GuideSerie]
                       AND btd.[GuideNumber] = pg.[GuideNumber]
                INNER JOIN [dbo].[DeliveryOrder] AS do
                    ON btd.[GuideSerie] = do.[Guide_Serie]
                       AND btd.[GuideNumber] = do.[Guide_Number]
                --LEFT JOIN VisitPointByClientPortfolio vpbc 
                --	ON do.VisitpointClientPortfolioId = vpbc.IdVisitPointByClientPortfolio 
                --	AND vpbc.RowStatus = 1
                LEFT JOIN dbo.Township twn
                    ON twn.IdTownship = do.ReceiverIdTownship
                LEFT JOIN dbo.Township tw
                    ON tw.TownshipName = do.Receiver_Town
                LEFT JOIN dbo.Province prv
                    ON prv.IdProvince = twn.IdProvince
                LEFT JOIN dbo.Province pr
                    ON pr.IdProvince = tw.IdProvince
                LEFT JOIN dbo.VisitPointClient vpc
                    ON vpc.CodeOfReference = do.Sender_ID
                LEFT JOIN dbo.Customer cu
                    ON cu.IdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
                LEFT JOIN dbo.DeliveryCustomerBankAccount dc
                    ON dc.DCBA_Id = do.DCBA_ID
                       AND dc.DCBA_Id_estado = 1
            WHERE pg.[Notificated] = 0
                  AND pg.BatchCODId IS NOT NULL
                  AND btd.[AuthorizationNumber] IS NOT NULL
                  AND do.SalePipeLineId IN ( 3 )
            GROUP BY do.Sender_Mail,
                     cu.CODContactEmail,
                     cu.RegexEmail,
                     dc.DCBA_Bank_Id,
                     pg.GuideSerie,
                     pg.GuideNumber,
					 btd.BankId
        ) X
    ) CDATA
    WHERE ISNULL(IIF(CDATA.DCBA_Bank_Id = '', NULL, CDATA.DCBA_Bank_Id), 0) <> 0;


END;







