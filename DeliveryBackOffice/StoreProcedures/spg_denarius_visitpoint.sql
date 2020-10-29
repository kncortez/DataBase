USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_denarius_visitpoint]    Script Date: 29/10/2020 10:23:42 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Cano, Carlos>
-- Create date: <2020-10-29>
-- Description:	<Devuelve información de todos los puntos de visita de Denarius para asociarlos al punto de venta de Hermes>
-- =============================================
CREATE PROCEDURE [dbo].[spg_denarius_visitpoint]
	@IdCountry NVARCHAR(2)
AS
BEGIN

	SELECT
		RVP_VisitPointId as Denarius_ID
		,RVP_ClientBranchName as Denarius_Name
		,RVP_BranchAddress as Denarius_Address
		,STN_Name as Denarius_Station
		,ACY_ClientCardCode as Denarius_Customer_ID
		,ACY_ClientName as Denarius_Customer_Name
	FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints rvp WITH(NOLOCK)
	JOIN DenariusDesktop_Dev.dbo.ADM_SYS_Client cli WITH(NOLOCK) ON cli.ACY_ClientCardCode = rvp.RVP_SAPcardCode
	JOIN DenariusDesktop_Dev.dbo.PRM_Station sta WITH(NOLOCK) ON sta.STN_IdStation = rvp.RVP_Station
	WHERE RVP_Country = @IdCountry
	AND (RVP_U_fechabaja IS NULL OR RVP_U_fechabaja = '')
	ORDER BY RVP_ClientBranchName, ACY_ClientName ASC

END
GO


