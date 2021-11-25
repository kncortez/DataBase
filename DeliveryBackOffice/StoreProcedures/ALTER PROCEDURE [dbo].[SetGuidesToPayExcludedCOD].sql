USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetGuidesToPayExcludedCOD]    Script Date: 25/11/2021 10:49:47 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set excluido en guias por pagar COD>
-- =============================================

ALTER PROCEDURE [dbo].[SetGuidesToPayExcludedCOD] 
-- Add the parameters for the stored procedure here
	@BatchCODId int,
	@BatchDetailCODId int,
	@Excluded bit
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BatchDetailCOD] 
	SET [Excluded] = @Excluded
	WHERE [IdBatchDetailCOD] = @BatchDetailCODId

END