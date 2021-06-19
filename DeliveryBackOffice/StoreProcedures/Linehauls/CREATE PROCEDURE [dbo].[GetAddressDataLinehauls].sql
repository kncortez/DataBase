USE [DeliveryBackOffice]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Marco, Jiménez>
-- Create date: <2021-06-15>
-- Description:	<Retorna las direcciones de una guía para Linehauls>
-- =============================================
ALTER PROCEDURE [dbo].[GetAddressDataLinehauls]
@Guide_Number as NVARCHAR(MAX)
AS
BEGIN


	SELECT
	CONCAT(ord.Sender_Address,',',ord.Sender_Department,',',ord.Sender_Town) as SenderAddress,
	CONCAT(ord.Receiver_Address,',',ord.Receiver_Department,',',ord.Receiver_Town) as ReceiverAddress
	FROM DeliveryBackOffice.dbo.DeliveryOrder ord
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPiece pc
	ON ord.Guide_Number = pc.GuideNumber
		AND ord.Guide_Serie = pc.GuideSerie
WHERE CONCAT(pc.GuideSerie, CAST(pc.GuideNumber AS VARCHAR), '-', CAST(pc.NoPiece AS VARCHAR)) = @Guide_Number


END
