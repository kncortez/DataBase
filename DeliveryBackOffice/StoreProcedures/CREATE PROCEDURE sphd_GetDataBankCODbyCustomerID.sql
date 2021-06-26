-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-05-25>
-- Description:	<Get COD DataMaster by CustomerID>
-- =============================================
CREATE PROCEDURE sphd_GetDataBankCODbyCustomerID
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
