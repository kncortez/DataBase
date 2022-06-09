-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-06-23>
-- Description:	<Obtiene la data principal del socio y punto servicio hermes>
-- =============================================
CREATE PROCEDURE [dbo].[sphdGetHeaderMemorandumVP]
    -- Add the parameters for the stored procedure here
    @IdVisitPoint AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


    SELECT --General Data
		TOP (1)
        UPPER(cus.Name) [LegalCustomerName],                                         --razon social
        UPPER(cus.CommercialName) [CommercialCustomerName],                          --nombre comercial
        UPPER(cus.NotificationAddress) [CustomerAddress],                            --direccion
        (
            SELECT UPPER(cba.BusinessActivityName)
            FROM dbo.CatBusinessActivity cba
            WHERE cba.IdBusinessActivity = cus.BusinessActivityID
        ) [BussinessActivity],                                                       --Actividad de la empresa
        UPPER(cus.ContactName) [CustomerContact],                                    --contacto
        cus.CustomerPhone [CustomerPhone],                                           --phone	
        cus.ContactEmail [CustomerEmail],                                            --email
		--Billing Data
        UPPER(cus.InvoiceName) [NameInInvoice],                                      --nombre en la factura
        UPPER(cus.FiscalAddress) [FiscalAddress],                                    --direccion fiscal
        cus.TaxIdentificationNumber [TaxIdentificationNumber],                       --nit
        cus.InvoiceEmail [InvoiceEmail],                                             --email
        UPPER(cus.LegalSponsorName + ' ' + cus.LegalSponsorLastName) [LegalSponsor], --representantelegal
        cus.LegalSponsorDPI [SponsorDPI],                                            --dpi representante legar
        UPPER(cus.InvoiceContactName) [InvoiceContactName],                          --contacto facturacion  
        cus.InvoiceContactPhone [InvoiceContactPhone],                               --telefono facturacion
        cus.InvoiceContactEmail [InvoiceContactEmail],                               --Email contacto facturacion
        -- COD Data
        (
            SELECT UPPER(bank.Name)
            FROM dbo.DeliveryBank bank
            WHERE bank.Id_bank = cus.CODAccountBankID
        ) [CODBank],
        UPPER(cus.CODAccountName) [CODAccountName],
        cus.CODAccountNumber [CODAccountNumber],
        (
            SELECT cbt.BankAccountType
            FROM dbo.CatBankAccountType cbt
            WHERE cbt.IdBankAccountType = cus.CODAccountTypeID
        ) [CODAccountType],
        (
            SELECT UPPER(COALESCE(ccc.CodeISO, '') + ' - ' + ccc.Name)
            FROM dbo.CatCurrencyCOD ccc
            WHERE ccc.IdCatCurrencyCOD = cus.CODCurrencyID
        ) [CODAccountCurrency],
		cus.CODContactName,
		cus.CODContactPhone,
		cus.CODContactEmail,
		-- Operation Data
        vpf.DateStartOperation [DateUpService],
        CASE WHEN ISNULL(cus.OperationContactName,'') = '' THEN ISNULL(UPPER(vpc.ContactName),'') ELSE ISNULL(UPPER(cus.OperationContactName),'') + ' ' + ISNULL(UPPER(vpc.ContactName),'') END [OperationContactName],
        CASE WHEN ISNULL(cus.OperationContactPhone,'') = '' THEN ISNULL(vpc.Phone,'') ELSE  ISNULL(cus.OperationContactPhone,'') + ' ' + ISNULL(vpc.Phone,'') END  [OperationContactPhone],
        CASE WHEN ISNULL(cus.OperationContactEmail,'') = '' THEN ISNULL(vpc.Email,'') ELSE ISNULL(cus.OperationContactEmail,'') + ' ' + ISNULL(vpc.Email,'') END [OperationContactEmail],                                                   --
		--	operation recoleccion
        vpc.CodeOfReference [IdVisitPoint],                                          --codigo de punto
        vpc.DescriptionOfClient [VisitPointName],                                    --nombre de lugar recoleccion
        UPPER(vpc.Address) [VisitPointAddress],
        (
            SELECT UPPER(vpbank.Name)
            FROM dbo.DeliveryBank vpbank
            WHERE vpbank.Id_bank = vpf.CODAccountBankID
        ) [CODVPBank],
        UPPER(vpf.CODAccountName) [CODVPAccountName],
        vpf.CODAccountNumber [CODVPAccountNumber],
        (
            SELECT UPPER(vpcbt.BankAccountType)
            FROM dbo.CatBankAccountType vpcbt
            WHERE vpcbt.IdBankAccountType = vpf.CODAccountBankTypeID
        ) [CODVPAccountType],
        (
            SELECT UPPER(COALESCE(vpccc.CodeISO, '') + ' - ' + vpccc.Name)
            FROM dbo.CatCurrencyCOD vpccc
            WHERE vpccc.IdCatCurrencyCOD = vpf.CODAccountCurrencyID
        ) [CODVPCurrency],
        vpf.AveragePackageDaily,
        (
            SELECT UPPER(COALESCE(hub.HubAbbreviation, '') + ' - ' + hub.HubName)
            FROM dbo.HubLogistics hub
            WHERE hub.IdHubLogistic = vpf.HubLogisticID
        ) [VPHub],
        vfq.VisitsOnSunday,
        vfq.VisitsOnMonday,
        vfq.VisitsOnTuesday,
        vfq.VisitsOnWednesday,
        vfq.VisitsOnThursday,
        vfq.VisitsOnFriday,
        vfq.VisitsOnSaturday
    FROM dbo.VisitPointClient vpc
        JOIN dbo.Customer cus
            ON cus.IdCustomer = vpc.CustomerID
        LEFT JOIN dbo.VisitPointConfiguration vpf
            ON vpf.VisitPointID = vpc.CodeOfReference
               AND vpf.RowStatus = 'true'
        LEFT JOIN dbo.VisitPointFrequency vfq
            ON vfq.VPConfigurationID = vpf.IdVPConfiguration
               AND vfq.RowStatus = 'true'
    WHERE vpc.CodeOfReference = @IdVisitPoint

END;
