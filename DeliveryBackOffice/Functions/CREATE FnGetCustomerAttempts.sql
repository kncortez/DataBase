USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnGetCustomerAttempts](
    @IdCustomer INT
)
RETURNS INT
AS
BEGIN
    
    DECLARE @Attempts INT = (SELECT Attempt FROM DeliveryBackOffice.dbo.RateHeader
							WHERE RheId= (SELECT RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer
							WHERE RbcIdCustomer = @IdCustomer AND RbcRowStatus = 1))

	RETURN @Attempts
 
END