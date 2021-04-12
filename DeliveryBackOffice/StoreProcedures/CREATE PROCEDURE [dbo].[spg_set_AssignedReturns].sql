USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_set_Assigned]    Script Date: 12/04/2021 12:48:30 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2021-04-12>
-- Description:	<Devuelve información para mostrar listado de guías seleccionadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_AssignedReturns]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@ListGuides AS VARCHAR(MAX) = '',
		@Route AS VARCHAR(100) = '',
		@Courier AS VARCHAR(100) = '',
		@DateAssigned AS VARCHAR(50) = ''--dd/MM/yyyy
				
AS
BEGIN



select SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
into #listGuides
from DenariusDesktop_Dev.dbo.SplitUnlimited(@ListGuides,',')

UPDATE
    Table_A
SET
    Table_A.Courier_Route = @Route,
	Table_A.Courier_Name = @Courier,
	Table_A.Dispatched_Date = CONVERT(DATETIME, getdate(), 103) + ' '  + convert(varchar, getdate(), 114) ,
	Table_A.Dispatched_Token = @Token,
	Table_A.StatusOrderId = 14 --Fuera para entrega
FROM
    DeliveryBackOffice.dbo.DeliveryOrder AS Table_A
    INNER JOIN #listGuides AS Table_B
        ON Table_A.Guide_Serie = Table_B.ItemSerie 
		and Table_A.Guide_Number = Table_B.ItemNumber	

-- INSERTAR CHECKPOINT INICIAL EN TABLA HISTÓRICA
INSERT [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] (
[Guide_Serie], 
[Guide_Number], 
[StatusOrderId], 
[UserCreated], 
[DateCreated], 
[DateCreatedInSystem]
)
SELECT 
	Table_A.Guide_Serie,
	Table_A.Guide_Number,
	14,
	@Token,
	CONVERT(DATETIME, getdate(), 103) + ' '  + convert(varchar, getdate(), 114),
	GETDATE()
FROM
    DeliveryBackOffice.dbo.DeliveryOrder Table_A
    INNER JOIN #listGuides AS Table_B
        ON Table_A.Guide_Serie  = Table_B.ItemSerie
		and Table_A.Guide_Number = Table_B.ItemNumber	

---Update a la tabla de piezas del status de todas las piezas de la guia.

update DeliveryOrderPiece set StatusOrderId = 14
FROM
    DeliveryBackOffice.dbo.DeliveryOrderPiece Dop
    INNER JOIN #listGuides AS Table_B
        ON Dop.GuideSerie  = Table_B.ItemSerie
		and Dop.GuideNumber = Table_B.ItemNumber	

IF @@ROWCOUNT > 0
	SELECT 1 AS Result

END

