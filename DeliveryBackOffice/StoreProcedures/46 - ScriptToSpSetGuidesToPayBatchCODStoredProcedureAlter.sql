USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetGuidesToPayBatchCOD]    Script Date: 23/06/2021 17:18:39 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar,Morales>
-- Create date: <2021-06-23>
-- Description:	<Set datos lote COD>
-- =============================================
ALTER PROCEDURE [dbo].[SetGuidesToPayBatchCOD]
-- Add the parameters for the stored procedure here
	@BatchCODId int,
	@TotalAmount decimal(18,2),
	@AuthorizationNumber nvarchar(50),
	@AuthorizationDate datetime,
	@TokenCreated nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE [dbo].[BatchCOD] 
	SET [TotalAmountIncluded] = @TotalAmount
	WHERE [IdBatchCOD] = @BatchCODId;

	UPDATE [dbo].[BatchDetailCOD]
	SET [AuthorizationNumber] = @AuthorizationNumber,
		[AuthorizationDate] = @AuthorizationDate,
		[CreditDate] = CONVERT(DATE,@AuthorizationDate)
	WHERE [BatchCODId] = @BatchCODId;

	UPDATE [dbo].[DeliveryOrderPaid]
	SET [IdStatus] = 0,
		[TokenUpdate] = @TokenCreated,
		[DateUpdate] = GETDATE()
	WHERE CONCAT([Guide_Serie], [Guide_Number]) IN (SELECT CONCAT(GuideSerie, GuideNumber)
													FROM [dbo].[BatchDetailCOD]
													WHERE [BatchCODId] = @BatchCODId);

	INSERT INTO [dbo].[DeliveryOrderPaid]
           ([Guide_Serie]
           ,[Guide_Number]
           ,[Deposit_Number]
           ,[IsVirtualDeposit]
           ,[IdStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate]
           ,[IdDeliveryOrderPaidHeader]
           ,[DocumentType])
     SELECT bd.[GuideSerie]
		   ,bd.[GuideNumber]
		   ,@AuthorizationNumber
		   ,1
		   ,1
		   ,@TokenCreated
		   ,@AuthorizationDate
		   ,NULL
		   ,NULL
		   ,NULL
		   ,NULL
	 FROM [dbo].[BatchDetailCOD] AS bd
	 WHERE bd.[BatchCODId] = @BatchCODId;

	 UPDATE do
	 SET do.[Deposit_Number] = @AuthorizationNumber
		,do.[Guide_Collected] = 1
	 FROM [dbo].[DeliveryOrder] AS do
	 INNER JOIN [dbo].[BatchDetailCOD] AS bd 
		ON do.[Guide_Serie] = bd.[GuideSerie] 
		AND do.[Guide_Number] = bd.[GuideNumber]
	 WHERE bd.[BatchCODId] = @BatchCODId;
END