USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetBillingData]    Script Date: 2/09/2021 00:37:02 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Morales, Oscar>
-- Create date: <2021-09-16>
-- Description:	<Recupera información para form Billing>
-- =============================================
CREATE PROCEDURE [dbo].[GetBillingData]
		@GuideSerie NVARCHAR(2),
		@GuideNumber INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @IdCustomer INT 
	DECLARE @Email NVARCHAR(100)
	DECLARE @Amount DECIMAL(14,2)

	SET NOCOUNT ON;

	-- Table 0
	SELECT 
		@IdCustomer = cu.IdCustomer
		,@Email = cu.RegexEmail
		,@Amount = do.PriceShippment
	FROM DeliveryOrder do
	INNER JOIN Customer cu
		ON do.IdCustomer = cu.IdCustomer
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	SELECT @IdCustomer Customer, @Email Email, @Amount Amount

	-- Table 1
	SELECT 
		bp.BlpTaxId Nit
		,bp.BlpAddress Address
		,bp.BlpName Name 
	FROM BillingProfile bp
	INNER JOIN Account ac 
		ON bp.BlpIdAccount = ac.AccIdAccount
	WHERE ac.IdCustomer = @IdCustomer

	SET NOCOUNT OFF;
END