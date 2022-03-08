USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_courier_dispatched_status]    Script Date: 21/09/2020 08:07:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		 <Cano,Carlos>
-- Create date:  <13/Agosto/2020>
-- Description:	 <Listado de afiliados y su status actual sobre entregas>
-- Modificado:   <López, Marcos>
-- Modified:     <14/Sepiembre/2020>
-- Description:  <Se agregó la columna del total de guías por usuario>
-- Modificado:   <Ixchop,Alberto>
-- Modified:     <25/Enero/2022>
-- Description:  <Se optimizó el sp>
-- =============================================
ALTER PROCEDURE [dbo].[spg_courier_dispatched_status]
	@DispatchedDate DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	SELECT  
		SR.ID AS ID_Courier,
		SR.First_Name + ' ' + SR.Last_Name AS Courier_Name,
		ISNULL(HL.HubAbbreviation,' ') AS HUB,
		COUNT(DISTINCT Guide_Serie+CONVERT(NVARCHAR,(Guide_Number)))AS Cantidad_Guias ,
		COUNT(SR.ID) AS Dispatched,
		COUNT(CASE WHEN DATT.Delivered=1 THEN DATT.Delivered ELSE NULL END) AS Delivered,
		COUNT(DATT.Verified) AS Verified,
		(SUM(CAST(ISNULL(DATT.Verified,0) AS INT))- SUM(CAST(ISNULL(DATT.Accepted,0) AS INT))) AS Failed
		FROM DBO.DeliveryAttempt DATT
		LEFT JOIN  DBO.SenderReceiver SR ON DATT.ID_Courier=SR.ID
		LEFT JOIN DBO.HubLogistics HL ON SR.HubLogisticId=HL.IdHubLogistic
		WHERE
		CONVERT(DATE,DATT.Date_Created)=@DispatchedDate
		GROUP BY SR.ID,HL.HubAbbreviation,SR.First_Name,SR.Last_Name,HL.IdHubLogistic;
END
GO


