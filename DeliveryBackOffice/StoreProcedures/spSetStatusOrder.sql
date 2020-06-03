USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spSetStatusOrder]    Script Date: 3/06/2020 17:01:27 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Cambiar el estado de liquidación>
-- =============================================
CREATE PROCEDURE [dbo].[spSetStatusOrder]
		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@Manifest AS VARCHAR(50) = 'FM253',		
		@Guide AS VARCHAR(50) = 'FM253',
		@Statusid AS INT = 1
AS
BEGIN

update DeliveryBackOffice.dbo.DeliveryOrder
set StatusOrderId = @Statusid
WHERE Manifest_Serie +  CAST(Manifest_Number AS VARCHAR) = @Manifest 
and Guide_Serie + CAST(Guide_Number AS VARCHAR) = @Guide

--insert into DeliveryBackOffice.dbo.StatusOrderDetail
--([Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated])	
--select 
--[Guide_Serie], [Guide_Number], [StatusOrderId], [UserCreated], [DateCreated]
-- from 

select 1 'Result', 'Correcto' 'ResultDescription'

END
GO


