-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2025-01-06>
-- Description:	<Devuelve el listado de clientes Corporativos, Cartera de cliente express center o Individuales>
-- =============================================
CREATE PROCEDURE [dbo].[spws_getCustomersReportAnticipatedCOD]
    @IdCountry VARCHAR(2) = 'GT'
AS
BEGIN

    IF OBJECT_ID('tempdb..#AnticipatedCODCustomerReport', 'U') IS NOT NULL 
    BEGIN
        DROP TABLE #AnticipatedCODCustomerReport
    END

	CREATE TABLE #AnticipatedCODCustomerReport (
		ID INT IDENTITY(1,1),
		IdCustomer INT,
		CustomerType NVARCHAR(50),
		Name NVARCHAR(150)
	);

	INSERT INTO #AnticipatedCODCustomerReport (IdCustomer, CustomerType, Name)
	SELECT 
	    C.IdCustomer        AS IdCustomer,
		CT.Description      AS CustomerType,
		UPPER(TRIM(C.Name)) AS Name
	FROM DeliveryBackOffice.dbo.Customer C WITH (NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.Customertype CT WITH(NOLOCK) ON CT.IdCustomerType = C.IdCustomerType
	WHERE C.IdCustomerType IN (1, 3)
	AND ISNULL(C.CountryID, 'GT') = @IdCountry
	GROUP BY C.IdCustomer,CT.Description,C.Name

	UNION

	SELECT 
	    VPP.IdVisitPointByClientPortfolio                         AS IdCustomer,
		'CARTERA'                                                 AS CustomerType,
		UPPER(CONCAT(TRIM(VPP.FirstName),' ',TRIM(VPP.LastName))) AS Name
	FROM DeliveryBackOffice.dbo.Customer C WITH (NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VP WITH (NOLOCK)
			ON VP.CustomerID = C.IdCustomer
		INNER JOIN DeliveryBackOffice.dbo.VisitPointByClientPortfolio VPP WITH (NOLOCK)
			ON ISNULL(VPP.VisitPointId,0) = ISNULL(VP.IdVisitPointClient,0)
	WHERE C.IdCustomerType = 2
	AND ISNULL(C.CountryID,'GT') = @IdCountry
	AND VPP.RowStatus = 1
	AND VP.StatusClient = 1
	GROUP BY C.IdCustomer,VPP.IdVisitPointByClientPortfolio,VPP.FirstName,VPP.LastName;

	SELECT ID, CONCAT(ISNULL(IdCustomer,0),' - ',CustomerType,' - ',Name) AS Customer
	FROM #AnticipatedCODCustomerReport
	ORDER BY CustomerType desc, IdCustomer asc;

END;