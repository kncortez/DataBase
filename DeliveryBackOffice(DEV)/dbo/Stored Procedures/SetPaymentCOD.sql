/* =================================================
   SP:        [dbo].[SetPaymentCOD]
   Propósito: Generación de manifiesto y pago para guias de trasporte
   Autor:     César Aquino
   Historia:  
   Fecha:     2020-11-17
============================================
=== CHANGELOG ================================
2026-03-13 | Historia/épica: FDAPI-5800 | Autor: Brenda Echeverria | reemplazo de sintaxis JOIN antiguo a JOIN explicita, operador + por CONCAT, uso de alias y otros aspectos de lienamientos de BD y versionamiento
-----
=========================================== */

CREATE PROCEDURE [dbo].[SetPaymentCOD]
	 @InGuides			VARCHAR(100) = 'FD1001,FD1002'
	,@TokenCreated		VARCHAR(100) = 'SYS.CAQUINO'
	,@DocumentNumber	VARCHAR(50)	 = 'N/A'
	,@DocumentType		INT			 = 0 --0 Depósito, 1 Autorización		
	,@Manifest_Serie	VARCHAR(5)	 = 'PC'
AS
BEGIN
	SET NOCOUNT ON;
			
	BEGIN TRANSACTION
	BEGIN TRY
		
		SELECT 
			SUBSTRING(Item,1,2) AS ItemSerie,
			SUBSTRING(Item,3,len(Item)) AS ItemNumber 
		INTO #listGuides_cod
		FROM dbo.SplitUnlimited(@InGuides,',');

		-- Insert MANIFEST HEADER
		DECLARE @ID_M bigint 
		DECLARE @ID_Manifest bigint
		DECLARE @GuideCount int

		SELECT 
			@GuideCount = COUNT(*) 
		FROM #listGuides_cod guides
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
				ON DO.Guide_Serie = guides.ItemSerie 
				AND DO.Guide_Number = guides.ItemNumber
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)
				ON DOP.Guide_Serie = DO.Guide_Serie 
				AND DOP.Guide_Number = DO.Guide_Number
				AND DOP.Guide_Number is null 
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DET WITH (NOLOCK)
				ON DET.Guide_Serie = DO.Guide_Serie 
				AND DET.Guide_Number = DO.Guide_Number 
				AND DET.RowStatus = 1		 
		WHERE   
			ISNULL(DET.Settlement_Collect_OnDelivery,0)>0;
			
		IF (@GuideCount>0) 
		BEGIN
			SELECT 
				@ID_Manifest = ISNULL(MAX([Manifest_Number]),999) +1 
			FROM [dbo].[DeliveryOrderPaidHeader] WITH (NOLOCK);
			
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderPaidHeader] 
			(
				 [Manifest_Date]
				,[Manifest_Serie]
				,[Manifest_Number]
				,[IdStatus]
			)
			VALUES
			(
				GETDATE()
				,@Manifest_Serie
				,@ID_Manifest
				,1
			) ;
		
			SET @ID_M=	(  select @@IDENTITY 'IDENTITY') ;
						
			--  INSERT MANIFEST DETAIL
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderPaid] 
			(
				 [Guide_Serie]
				,[Guide_Number]
				,[Deposit_Number]
				,[IsVirtualDeposit]
				,[IdStatus]
				,[TokenCreated]
				,[DateCreated]
				,[TokenUpdate]
				,[DateUpdate]
				,[IdDeliveryOrderPaidHeader]
				,[DocumentType]
			)
			SELECT  
				 DO.Guide_Serie AS 'Guide_Serie'
				,DO.Guide_Number AS 'Guide_Nuber'
				,@DocumentNumber
				,1
				,1 
				,@TokenCreated
				,GETDATE()
				,NULL
				,NULL
				,@ID_M
				,@DocumentType
			FROM 
				#listGuides_cod GUIDES
				INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH (NOLOCK)
					ON DO.Guide_Serie = guides.ItemSerie 
					AND DO.Guide_Number = guides.ItemNumber
				LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)
					ON DOP.Guide_Serie = DO.Guide_Serie 
					AND DOP.Guide_Number = DO.Guide_Number 
					AND DOP.Guide_Number is null 
				LEFT JOIN [DeliveryBackOffice].[dbo].[DeliverySettlementDetail] DSD WITH (NOLOCK)
					ON DSD.Guide_Serie = DO.Guide_Serie 
					AND DSD.Guide_Number = DO.Guide_Number 
					AND DSD.RowStatus = 1		
			WHERE   
				ISNULL(DSD.Settlement_Collect_OnDelivery,0)>0
			
			--Guardar número de depósito únicamente no número de autorización
			--if (@DocumentType =0)
			BEGIN
				UPDATE DO
					SET Deposit_Number = @DocumentNumber 				
				FROM DeliveryBackOffice.dbo.DeliveryOrder AS DO WITH (NOLOCK)
					INNER JOIN #listGuides_cod AS GUIDES
						ON DO.Guide_Serie=GUIDES.ItemSerie
						AND DO.Guide_Number=GUIDES.ItemNumber					
			END			  
		END 			
	END TRY

	BEGIN CATCH
		SELECT 
			'Transaccion no completada' AS 'msg', 
			ERROR_MESSAGE() AS 'Description'
		ROLLBACK TRANSACTION
	END CATCH;

	IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT TRANSACTION;
		
		DECLARE @jsonDetail NVARCHAR(MAX)
		DECLARE @jsonHeader NVARCHAR(MAX)

		if (@ID_M>0) 
		BEGIN
			SET @jsonDetail = (
			SELECT STUFF((
			SELECT 
				CONCAT(',{"Guide_Serie":"' , DOP.Guide_Serie , '",' ,'"Guide_Number":' , DOP.Guide_Number , '}')
			FROM DeliveryBackOffice.dbo.DeliveryOrderPaidHeader DOPH WITH (NOLOCK)
				INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaid DOP WITH (NOLOCK)
				ON DOP.IdDeliveryOrderPaidHeader = DOPH.IdDeliveryOrderPaid 
			WHERE DOPH.IdDeliveryOrderPaid= @ID_M
			FOR XML PATH(''), TYPE
			).value('.', 'varchar(max)'),1,1,''
			) 
			) ;

			set @jsonHeader = 
			(
				SELECT STUFF
				(
					(
						SELECT 
							CONCAT
							(
								',{"Date":"' 
								, CASE WHEN DOPH.Manifest_Date IS NULL THEN '' ELSE CONVERT(VARCHAR,DOPH.Manifest_Date,126) END 
								, '",' 
								,'"Serie":"' 
								,DOPH.Manifest_Serie 
								,'",' 
								,'"Id_Manifest":' 
								, convert(varchar,DOPH.Manifest_Number) 
								, '}'
							)
						FROM DeliveryBackOffice.dbo.DeliveryOrderPaidHeader DOPH WITH (NOLOCK)
						WHERE DOPH.IdDeliveryOrderPaid= @ID_M
						FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
				) 
			) ;

			SELECT replace( '['+ @jsonHeader + '"services":[' + @jsonDetail + ']}]','}"services',',"services') FormatJson ;
		END
		ELSE 
		BEGIN
			SET @jsonHeader = 
			(
				SELECT STUFF
				(
					(
						SELECT 
							CONCAT(',{"msg":"' , 'No hay guias aptas para pago' , '}')
						FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)')
					,1
					,1
					,''
				)
			)
			
		END
	END	

END