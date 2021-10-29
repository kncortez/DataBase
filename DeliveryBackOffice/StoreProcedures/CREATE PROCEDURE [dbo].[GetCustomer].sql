USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetCustomer]    Script Date: 29/10/2021 07:13:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2021-29-10>
-- Description:	<Obtiene el listado de clientes>
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomer]
	-- Add the parameters for the stored procedure here
	@IdCustomer INT = -1,
	@Country NVARCHAR(2) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT cu.[IdCustomer]
		, cu.[Name]
		, cu.[Description]
		, cu.[CountryID]
	FROM Customer cu
	WHERE (@IdCustomer = -1 OR cu.IdCustomer = @IdCustomer)
		AND  (@Country IS NULL OR cu.CountryID = @Country)
		AND (cu.RowSatus = 1 OR cu.RowSatus IS NULL)
	ORDER BY cu.[Name];
END
GO