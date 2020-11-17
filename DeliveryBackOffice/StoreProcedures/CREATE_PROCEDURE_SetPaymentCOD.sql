USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_headerInvoice]    Script Date: 17/11/2020 13:59:38 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-11-17>
-- Description:	<Generación de manifiesto y pago para guias de trasporte>
-- =============================================
CREATE PROCEDURE SetPaymentCOD
	-- Add the parameters for the stored procedure here
		@InGuides  varchar(100)= '1001,1002'
		,@TokenCreated varchar(100) = 'SYS.CAQUINO'
		,@Deposit_number varchar(50)= 'N/A'
		,@Manifest_Serie varchar(5) = 'FD'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		BEGIN TRY
			-- Insert MANIFEST HEADER
			DECLARE @ID_M bigint 
			DECLARE @ID_Manifest bigint
			SET @ID_Manifest = (
			 SELECT ISNULL(MAX([Manifest_Number]),999) +1  FROM [dbo].[DeliveryOrderPaidHeader]
			)

			insert into [DeliveryBackOffice].[dbo].[DeliveryOrderPaidHeader] 
			values(Getdate()
			,@Manifest_Serie
			,@ID_Manifest
			,1)

		
		   SET @ID_M=	(  select @@IDENTITY 'IDENTITY')

		   --  INSERT MANIFEST DETAIL

		    insert into [DeliveryBackOffice].[dbo].[DeliveryOrderPaid] 
			  SELECT  
			  o.Guide_Serie as 'Guide_Serie'
			  , o.Guide_Number as 'Guide_Nuber'
			  ,@Deposit_Number
			  , 1
			  ,1 
			  ,@TokenCreated
			  ,GETDATE()
			  ,null
			  ,null
			  ,@ID_Manifest
				FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] o
			  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
			  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number
			 /* where o.Collect_OnDelivery is not null */
			  where o.Guide_Number in(SELECT value  
								FROM STRING_SPLIT(@InGuides, ',')  
								WHERE RTRIM(value) <> '') 
					and p.Guide_Number is null 
					and isnull(Det.Settlement_Collect_OnDelivery,0)>0

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'DCBA_Id', 
				ERROR_MESSAGE() AS 'Description'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
			
			 DECLARE @jsonDetail NVARCHAR(MAX)
		   DECLARE @jsonHeader NVARCHAR(MAX)

		  set @jsonDetail = (
		  select 
		  d.Guide_Serie as 'Guide_Serie'
		  ,d.Guide_Number as 'Guide_Number'
		  from DeliveryBackOffice.dbo.DeliveryOrderPaidHeader h
		  inner join DeliveryBackOffice.dbo.DeliveryOrderPaid d on d.IdDeliveryOrderPaidHeader = h.Manifest_Number
		  where h.IdDeliveryOrderPaid= @ID_M
		   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)

			set @jsonHeader = (
		  select h.Manifest_Date as 'Date'
		  ,h.Manifest_Serie as 'Serie'
		  ,h.Manifest_Number as 'Id_Manifest'
		  from DeliveryBackOffice.dbo.DeliveryOrderPaidHeader h
		  where h.IdDeliveryOrderPaid= @ID_M
		   FOR JSON PATH, WITHOUT_ARRAY_WRAPPER)


		select replace( '['+ @jsonHeader + '"services":[' + @jsonDetail + ']}]','}"services',',"services') FormatJson

		END
	


END
GO
