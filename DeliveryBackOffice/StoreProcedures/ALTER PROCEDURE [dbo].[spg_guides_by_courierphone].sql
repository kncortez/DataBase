USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_guides_by_courierphone]    Script Date: 14/01/2021 7:35:55 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-08-07>
-- Description:	<Devuelve el nombre del destinatario y todas las piezas asignadas al courierman>
-- =============================================
ALTER PROCEDURE [dbo].[spg_guides_by_courierphone]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@PhoneNumber NVARCHAR(50)
AS
BEGIN
  


	SELECT
		do.Receiver_FirstName + ' ' + do.Receiver_LastName as Receiver,
		do.Receiver_Alternant_FullName as Alternant,
		CASE WHEN do.IsCollect = 1 THEN CONVERT(decimal(14,2), do.Collect_OnDelivery) ELSE 0 END as CollectDelivery,
		CONVERT(decimal(14,2), do.PriceShippment) as PriceShippment,
		subq.Guide_Serie + CAST(subq.Guide_Number AS VARCHAR) as Guide,
		subq.Pieces_Dry,
		subq.Pieces_Cold
	FROM
	(  
		SELECT
			da.Guide_Serie 
			,da.Guide_Number
			,SUM(CAST(da.[Dry] AS INT)) AS Pieces_Dry
			,SUM(CAST(da.[Cold]AS INT)) AS Pieces_Cold
		FROM DeliveryBackOffice.dbo.DeliveryAttempt da
			JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = da.ID_Courier
		WHERE sr.Phone like '%' + @PhoneNumber + '%'
			AND da.Guide_Serie = @GuideSerie
			AND da.Guide_Number = @GuideNumber
			AND CONVERT(VARCHAR, da.Date_Created, 23) = CONVERT(VARCHAR, GETDATE(), 23) --QUITADO TEMPORALMENTE BIDCAR HERRERA
			GROUP BY da.Guide_Serie, da.Guide_Number, da.ID_Courier
	) AS subq
	JOIN DeliveryBackOffice.dbo.DeliveryOrder do ON do.Guide_Serie = subq.Guide_Serie 
	AND subq.Guide_Number = do.Guide_Number

END
GO


