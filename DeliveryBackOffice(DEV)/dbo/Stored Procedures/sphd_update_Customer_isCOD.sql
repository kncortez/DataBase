-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Update date: <2024-04-23>
-- Description:	<Actualizacion de campo int isCOD en tabla Customer para clientes corporativos>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_update_Customer_isCOD]
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Datos iniciales para COD socios comerciales
    update cs
    SET cs.isCOD = 0
    FROM [DeliveryBackOffice].[dbo].[Customer] AS cs	WITH (NOLOCK)
    WHERE cs.IdCustomerType = 1;

    -- En caso tenga datos COD en cuenta
    UPDATE		cs
    SET			cs.isCOD = 1
    FROM		[DeliveryBackOffice].[dbo].[Customer]				AS cs	WITH (NOLOCK)
    WHERE		cs.CODAccountBankID			IS NOT NULL
    AND			cs.CODAccountNumber			IS NOT NULL
    AND			cs.CODAccountName			IS NOT NULL
    AND			cs.CODAccountTypeID			IS NOT NULL
    AND			cs.IdCustomerType = 1;

    -- En caso no tenga datos COD en cuenta pero tenga datos COD en punto de visita
    UPDATE		cs
    SET			cs.isCOD = 1
    FROM		[DeliveryBackOffice].[dbo].[Customer]					AS cs	WITH (NOLOCK)
	INNER JOIN  [DeliveryBackOffice].[dbo].[VisitPointClient]			AS vpc	WITH (NOLOCK)	ON	vpc.CustomerID = cs.IdCustomer
	INNER JOIN	[DeliveryBackOffice].[dbo].[VisitPointConfiguration]	AS vpcf	WITH (NOLOCK)	ON	vpcf.VisitPointID = vpc.VisitPointID
    WHERE		cs.CODAccountBankID			IS NULL
    AND			cs.CODAccountNumber			IS NULL
    AND			cs.CODAccountName			IS NULL
    AND			cs.CODAccountTypeID			IS NULL
	AND			vpcf.CODAccountBankID		IS NOT NULL
	AND			vpcf.CODAccountNumber		IS NOT NULL
	AND			vpcf.CODAccountName			IS NOT NULL
	AND			vpcf.CODAccountBankTypeID	IS NOT NULL
    AND			cs.IdCustomerType = 1;

END;
