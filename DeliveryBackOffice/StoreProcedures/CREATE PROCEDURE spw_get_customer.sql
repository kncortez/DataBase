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
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2020-12-24>
-- Description:	<get customer forza delivery>
-- =============================================
CREATE PROCEDURE spw_get_customer
	-- Add the parameters for the stored procedure here
	@IdCustomer as int = -1
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	declare @CustomerID as int;

	set @CustomerID = @IdCustomer;

    -- Insert statements for procedure here
	SELECT A.IdCustomer [IdCustomer] , A.CustomerName [CustomerName]
	FROM (
				select -1 [IdCustomer], 'TODOS' [CustomerName]
				union
				select client.IdCustomer [IdCustomer], UPPER(client.Name) [CustomerName]
				from Customer client
		) A
	WHERE (A.IdCustomer = @CustomerID  OR @CustomerID = -1)
END
GO
