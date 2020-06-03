USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_set_Assigned]    Script Date: 3/06/2020 17:00:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para mostrar listado de guías seleccionadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_set_Assigned]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@ListGuides AS VARCHAR(MAX) = '',
		@Route AS VARCHAR(100),
		@Courier AS VARCHAR(100),
		@DateAssigned AS VARCHAR(50)
				
AS
--exec [dbo].[spg_get_RoutePreparation] @Department = 'Guatemala'
--exec dbo.spg_get_getGuideList @ListGuides='FD999,FD1015'
BEGIN

select Item
into #listGuides
from DenariusDesktop_Dev.dbo.SplitUnlimited(@ListGuides,',')

UPDATE
    Table_A
SET
    Table_A.Courier_Route = @Route,
	Table_A.Courier_Name = @Courier,
	Table_A.Dispatched_Date = @DateAssigned,
	Table_A.Dispatched_Token = 'SYS-BHERRERA',
	Table_A.StatusOrderId = 3 --Fuera para entrega
FROM
    DeliveryBackOffice.dbo.DeliveryOrder AS Table_A
    INNER JOIN #listGuides AS Table_B
        ON Table_A.Guide_Serie +  CAST(Table_A.Guide_Number AS VARCHAR) 
		COLLATE SQL_Latin1_General_CP1_CI_AS = Table_B.Item	
END
GO


