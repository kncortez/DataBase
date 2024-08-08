-- =============================================
-- Author:		<Walter, Orozco>
-- Create date: <2024-07-04>
-- Description:	<Crear Guias - Crear nuevo método para calcular el monto asegurado por tipo de cliente y por país.>
-- =============================================
CREATE PROCEDURE [dbo].[spGetInsuranceTypeCustomerMC]
    @pTypeCustomer INT,
    @pId INT,
	@pIdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

	IF (@pTypeCustomer = 0) --INDIVIDUAL O CORPORATIVO
	BEGIN

		SELECT DISTINCT
		ISNULL(RH.InsuranceRate,0)		[InsuranceRate], 
		ISNULL(RH.InsuranceExempt,0)	[InsuranceExempt],
		ISNULL(RH.CollectRate,0)		[CollectRate]
		FROM DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
			ON RH.RheId = RBC.RbcIdRate
		INNER JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
			ON RBC.RbcIdCustomer = C.IdCustomer
		WHERE C.IdCustomer = @pId AND RH.CountryId = @pIdCountry AND RH.RheRowStatus = 1
		AND RBC.RbcRowStatus = 1 --AND C.RowSatus = 1

	END;
	ELSE --CLIENTE CARTERA O EXC @pTypeCustomer = 1
	BEGIN

		SELECT DISTINCT
		ISNULL(RH.InsuranceRate,0)		[InsuranceRate], 
		ISNULL(RH.InsuranceExempt,0)	[InsuranceExempt],
		ISNULL(RH.CollectRate,0)		[CollectRate]
		FROM DeliveryBackOffice.dbo.RateHeader RH WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.RatebyCustomer RBC WITH(NOLOCK)
			ON RH.RheId = RBC.RbcIdRate
		INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
			ON RBC.RbcIdCustomer = VPC.CustomerID
		WHERE VPC.CodeOfReference = @pId AND RH.CountryId = @pIdCountry
		AND RH.RheRowStatus = 1 AND RBC.RbcRowStatus = 1

	END;
     
END;