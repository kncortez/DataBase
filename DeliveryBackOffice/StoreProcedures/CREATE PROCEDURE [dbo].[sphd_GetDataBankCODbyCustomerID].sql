USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sphd_GetDataBankCODbyCustomerID]    Script Date: 6/25/2021 6:48:44 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-05-25>
-- Description:	<Get COD DataMaster by CustomerID>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_GetDataBankCODbyCustomerID]
    -- Add the parameters for the stored procedure here
    @IdCustomer AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT cli.CODAccountBankID,
           cli.CODAccountNumber,
           cli.CODAccountName,
           cli.CODAccountTypeID,
           cli.CODCurrencyID,
           cli.IdCustomer
    FROM dbo.Customer cli
    WHERE cli.IdCustomer = @IdCustomer;

END;
GO


