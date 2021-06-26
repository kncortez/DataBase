USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetGuidesToPayExcludedCOD]    Script Date: 23/06/2021 17:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set excluido en guias por pagar COD>
-- =============================================

CREATE PROCEDURE [dbo].[SetGuidesToPayExcludedCOD] 
-- Add the parameters for the stored procedure here
	@BatchCODId int,
	@BatchDetailCODId int,
	@Excluded bit,
	@AuthorizationNumber nvarchar(50),
	@AuthorizationDate datetime,
	@Total decimal(18,2)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BatchDetailCOD] 
	SET [Excluded] = @Excluded,
		[AuthorizationNumber] = @AuthorizationNumber,
		[AuthorizationDate] = @AuthorizationDate
	WHERE [IdBatchDetailCOD] = @BatchDetailCODId

	UPDATE [dbo].[BatchCOD]
	SET [TotalAmountIncluded] = @Total
	WHERE [IdBatchCOD] = @BatchCODId

END