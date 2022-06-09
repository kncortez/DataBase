-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-11-17>
-- Description:	<Generación de manifiesto y pago para guias de trasporte>
-- =============================================
CREATE PROCEDURE [dbo].[SetPaymentCOD]
	-- Add the parameters for the stored procedure here
		 @InGuides  varchar(100)= 'FD1001,FD1002'
		,@TokenCreated varchar(100) = 'SYS.CAQUINO'
		,@DocumentNumber varchar(50)= 'N/A'
		,@DocumentType int= 0 --0 Depósito, 1 Autorización		
		,@Manifest_Serie varchar(5) = 'PC'
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
		BEGIN TRY
		select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
				into #listGuides_cod
				from DenariusDesktop_Dev.dbo.SplitUnlimited(@InGuides,',')

			-- Insert MANIFEST HEADER
			DECLARE @ID_M bigint 
			DECLARE @ID_Manifest bigint
			DECLARE @GuideCount int

			Set @GuideCount = (select count(*) FROM #listGuides_cod guides
				inner join [DeliveryBackOffice].[dbo].[DeliveryOrder] o  on o.Guide_Serie = guides.ItemSerie and o.Guide_Number = guides.ItemNumber
			  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number
			  AND p.Guide_Number is null 
			  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number AND Det.RowStatus = 1		 
			  where   
					isnull(Det.Settlement_Collect_OnDelivery,0)>0)
			

			if (@GuideCount>0) begin
			SET @ID_Manifest = (
			 SELECT ISNULL(MAX([Manifest_Number]),999) +1  FROM [dbo].[DeliveryOrderPaidHeader]
			)
			
			insert into [DeliveryBackOffice].[dbo].[DeliveryOrderPaidHeader] 
			([Manifest_Date], [Manifest_Serie], [Manifest_Number], [IdStatus])
			values(Getdate()
			,@Manifest_Serie
			,@ID_Manifest
			,1)
		
		   SET @ID_M=	(  select @@IDENTITY 'IDENTITY')

		   --  INSERT MANIFEST DETAIL
		    insert into [DeliveryBackOffice].[dbo].[DeliveryOrderPaid] 
			  (
			  [Guide_Serie], [Guide_Number], [Deposit_Number], [IsVirtualDeposit], [IdStatus], [TokenCreated], [DateCreated], [TokenUpdate], [DateUpdate], [IdDeliveryOrderPaidHeader], [DocumentType]
			  )
			  SELECT  
			  o.Guide_Serie as 'Guide_Serie'
			  , o.Guide_Number as 'Guide_Nuber'
			  ,@DocumentNumber
			  ,1
			  ,1 
			  ,@TokenCreated
			  ,GETDATE()
			  ,null
			  ,null
			  ,@ID_M
			  ,@DocumentType
				FROM #listGuides_cod guides
				inner join [DeliveryBackOffice].[dbo].[DeliveryOrder] o  on o.Guide_Serie = guides.ItemSerie and o.Guide_Number = guides.ItemNumber
			  left join DeliveryBackOffice.dbo.DeliveryOrderPaid p on p.Guide_Serie = o.Guide_Serie and p.Guide_Number = o.Guide_Number and p.Guide_Number is null 
			  left join [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] Det on Det.Guide_Serie = o.Guide_Serie and Det.Guide_Number = o.Guide_Number and Det.RowStatus = 1		
			  where   
					isnull(Det.Settlement_Collect_OnDelivery,0)>0
			
			  --Guardar número de depósito únicamente no número de autorización
			  --if (@DocumentType =0)
			  BEGIN
				update DeliveryBackOffice.dbo.DeliveryOrder 
			    set Deposit_Number = @DocumentNumber 				
			    from DeliveryBackOffice.dbo.DeliveryOrder ,#listGuides_cod
			    where Guide_Serie = ItemSerie and Guide_Number = ItemNumber
			  END
			  
			  end 
			
		END TRY

		BEGIN CATCH
			SELECT 
				'Transaccion no completada' AS 'msg', 
				ERROR_MESSAGE() AS 'Description'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
			
			 DECLARE @jsonDetail NVARCHAR(MAX)
		   DECLARE @jsonHeader NVARCHAR(MAX)

	if (@ID_M>0) begin
		  set @jsonDetail = (
		  SELECT STUFF((
		  select 
		  ',{"Guide_Serie":"' + d.Guide_Serie + '",' +
		  '"Guide_Number":' + CONVERT(varchar,d.Guide_Number) + '}'
		  from DeliveryBackOffice.dbo.DeliveryOrderPaidHeader h
		  inner join DeliveryBackOffice.dbo.DeliveryOrderPaid d on d.IdDeliveryOrderPaidHeader = h.IdDeliveryOrderPaid 
		  where h.IdDeliveryOrderPaid= @ID_M
		   FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
              ) 
			  )

			set @jsonHeader = (
		  SELECT STUFF((
		  select 
		  ',{"Date":"' +
		    CASE WHEN h.Manifest_Date IS NULL THEN '' ELSE CONVERT(VARCHAR,h.Manifest_Date,126) END + '",' +
		  '"Serie":"' + h.Manifest_Serie + '",' +
		  '"Id_Manifest":' + convert(varchar,h.Manifest_Number) + '}'
		  from DeliveryBackOffice.dbo.DeliveryOrderPaidHeader h
		  where h.IdDeliveryOrderPaid= @ID_M
		   FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
              ) 
			  )


			select replace( '['+ @jsonHeader + '"services":[' + @jsonDetail + ']}]','}"services',',"services') FormatJson
		end
		else begin
		set @jsonHeader = (
		SELECT STUFF((
		  
		SELECT 
				',{"msg":"' + 'No hay guias aptas para pago' + '}'
				FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
              ) 
			  )
		end
		END
	
END