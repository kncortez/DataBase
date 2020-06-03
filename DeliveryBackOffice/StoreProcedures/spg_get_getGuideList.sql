USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_get_getGuideList]    Script Date: 3/06/2020 16:57:49 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para mostrar listado de guías seleccionadas>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_getGuideList]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@ListGuides AS VARCHAR(MAX) = ''		
AS
--exec [dbo].[spg_get_RoutePreparation] @Department = 'Guatemala'
--exec dbo.spg_get_getGuideList @ListGuides='FD999,FD1015'
BEGIN

select Item  
into #listGuides
from DenariusDesktop_Dev.dbo.SplitUnlimited(@ListGuides,',')

		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,
			serv.Receiver_FirstName + ' '+ serv.Receiver_LastName Name,
			serv.Receiver_Address Address,
			serv.Receiver_Zone Zone,
			serv.Receiver_Town Town,
			serv.Receiver_Department Department			  
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN #listGuides lst ON
		  lst.Item =  Guide_Serie +  CAST(Guide_Number AS VARCHAR) COLLATE SQL_Latin1_General_CP1_CI_AS
		
END
GO


