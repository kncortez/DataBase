USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_validate_guides_pickup]    Script Date: 2/02/2022 10:07:24 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-02-15>
-- Description:	<Verifica si existen guias
--				 si estan en estado 15 (generado) o 1(solicitado)
--               Si no estan asignadas a otra recolección (IdPickup) >
-- =============================================
ALTER PROCEDURE [dbo].[spws_get_validate_guides_pickup]
	-- Add the parameters for the stored procedure here
	@InGuides  nvarchar(max)  = 'FD138515,FD138513,FD13852,FD138514,FD138545,FD135539',
	@IdPickup   bigint = 120,
	@Token NVARCHAR(50)
AS
BEGIN
	
	SET NOCOUNT ON;

	
	BEGIN TRY  

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
				IF OBJECT_ID('tempdb.dbo.#ErrorGuides', 'U') IS NOT NULL DROP TABLE #ErrorGuides;

				select SUBSTRING(Item, 1,2) ItemSerie,
				SUBSTRING(Item,3, iif(CHARINDEX('-',Item)=0, (len(item)) , (CHARINDEX('-',Item)- 3))) ItemNumber , 
				SUBSTRING(Item,CHARINDEX('-',Item),len(Item)) ItemPiece, 
				CHARINDEX('-',Item) charinde,  
				len(Item) len
						into #listGuides
						from DeliveryBackOffice.dbo.SplitUnlimited(@InGuides,',')

				-- select * from #listGuides

				--Se inserta log de cambio de recolección a un servicio
				INSERT INTO ServicePickupLog (GuideSerie, GuideNumber, OldIdHeaderRecolection, NewIdHeaderRecolection, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
					SELECT DISTINCT
						g.ItemSerie
					   ,g.ItemNumber
					   ,COALESCE(dopd.IdHeaderRecolection,-1)
					   ,@IdPickup
					   ,1
					   ,@Token
					   ,GETDATE()
					   ,NULL
					   ,NULL
					FROM #listGuides g
					JOIN DeliveryOrderPaymentDetail dopd
						ON dopd.GuideSerie = g.ItemSerie
							AND dopd.GuideNumber = g.ItemNumber
					JOIN DeliveryOrder do
						ON do.Guide_Serie = g.ItemSerie
							AND do.Guide_Number = g.ItemNumber
					WHERE COALESCE(dopd.IdHeaderRecolection,0) <> @IdPickup
					AND do.StatusOrderId IN (16, 15, 1)

				--Se asignan los servicios a la nueva recolección
				UPDATE dopd
				SET dopd.IdHeaderRecolection = @IdPickup
				FROM DeliveryOrderPaymentDetail dopd
				JOIN #listGuides g
					ON g.ItemSerie = dopd.GuideSerie
					AND g.ItemNumber = dopd.GuideNumber
				JOIN DeliveryOrder do
					ON do.Guide_Serie = g.ItemSerie
					AND do.Guide_Number = g.ItemNumber
				WHERE COALESCE(dopd.IdHeaderRecolection,0) <> @IdPickup
				AND do.StatusOrderId IN (16, 15, 1)

				select distinct lst.ItemSerie , lst.ItemNumber , isnull( dr.Guide_Number,0) exist, 

				iif(ISNULL(pyt.IdHeaderRecolection,0) = @IdPickup , 1, iif(ISNULL(pyt.IdHeaderRecolection,0) =0,1 ,0)) pik, 
				IIF(dr.StatusOrderId IN (16, 15, 1),1,0) status, st.OrderDescription
				--, pyt.IdHeaderRecolection
				Into #ErrorGuides
				from #listGuides lst  
				left join dbo.DeliveryOrder dr on dr.Guide_Serie = lst.ItemSerie and dr.Guide_Number = lst.ItemNumber
				left join dbo.DeliveryOrderPaymentDetail pyt on pyt.GuideSerie = dr.Guide_Serie and pyt.GuideNumber = dr.Guide_Number
				left join dbo.StatusOrder st on st.StatusOrderId = dr.StatusOrderId

				--select * from #ErrorGuides

				select concat(er.ItemSerie , er.ItemNumber) Guide, 
				iif(er.exist =0, 'Servicio no existe',  concat('Servicio ', er.OrderDescription) ) Mensaje
				from #ErrorGuides er where er.exist =0 or er.status =0 --  or er.pik =0  Se elimina esta validacione por la reasignación

	END TRY  
	BEGIN CATCH  
		SELECT   Cast(ERROR_NUMBER() as nvarchar) AS ErrorNumber  
				,Cast(ERROR_SEVERITY() as nvarchar) AS ErrorSeverity  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage;
		
	END CATCH;   

END