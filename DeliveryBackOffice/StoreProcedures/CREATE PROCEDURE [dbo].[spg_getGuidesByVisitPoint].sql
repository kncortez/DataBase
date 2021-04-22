USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_getGuidesByVisitPoint]    Script Date: 20/04/2021 09:39:12 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Abner, Juarez>
-- Create date: <2020-04-13>
-- Description:	<Consulta las guías por un punto de visita>
-- =============================================
CREATE PROCEDURE [dbo].[spg_getGuidesByVisitPoint]
		@idCodeOfReference as int
AS
BEGIN
	select CONCAT(dro.Guide_Serie,' '+ dro.Guide_Number) as Guide, 
			dro.TypeService,
			CONCAT(dro.Receiver_Department,', ',dro.Receiver_Town,', ',dro.Receiver_Address, ', ',dro.Receiver_Zone) as ReceiverAddress
	from DeliveryBackOffice.dbo.DeliveryOrder as dro
	left join DeliveryBackOffice.dbo.VisitPointClient as vpc on vpc.CodeOfReference = dro.Sender_ID
	where vpc.CodeOfReference = @idCodeOfReference and (dro.StatusOrderId = 15 or dro.StatusOrderId = 1) order by Guide_Number desc
END