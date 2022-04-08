USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-07>
-- Description:	<Obtiene información para Form Monitoreo de Servicios de Recolección>
-- =============================================
CREATE PROCEDURE [dbo].[GetMonitoringPickupServices]
	-- Add the parameters for the stored procedure here
	@CustomerId INT = -1,
	@DateStart DATE = '2022-01-07',
	@DateEnd DATE = '2022-04-07',
	@Phone NVARCHAR(50) = '-1'
AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
SET NOCOUNT ON;

    DECLARE @PhoneNew NVARCHAR(52) =IIF(@Phone = '-1','-1',CONCAT('%',REPLACE(@Phone,'-',''),'%'))

	SELECT DISTINCT
		IdServiceManagement ServiceId
	   ,vpc.DescriptionOfClient VisitPoint
	   ,do.Sender_Department Department
	   ,do.Sender_Town Town
	   ,do.Sender_Address Address
	   ,css.Name Status
	FROM ServiceManagement sm WITH (NOLOCK)
	JOIN SchedulePickup sp WITH (NOLOCK)
		ON sp.SchedulePickupId = sm.IdSchedulePickup
	LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
		ON vpc.CodeOfReference = sp.SenderId
	JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
		ON dopd.IdHeaderRecolection = sp.SchedulePickupId
	JOIN DeliveryOrder do WITH (NOLOCK)
		ON do.Guide_Serie = dopd.GuideSerie
			AND do.Guide_Number = dopd.GuideNumber
	JOIN CatServiceStatus css WITH (NOLOCK)
		ON css.IdServiceStatus = sm.ServiceStatusId
	JOIN Customer cu WITH (NOLOCK)
		ON cu.IdCustomer = do.IdCustomer
	WHERE (do.IdCustomer = @CustomerId
	OR @CustomerId = -1)
	AND (REPLACE(do.Sender_Phone, '-', '') LIKE @PhoneNew
	OR REPLACE(cu.CustomerPhone, '-', '') LIKE @PhoneNew
	OR @PhoneNew = '-1')
	AND CAST(sm.DateCreated AS DATE) BETWEEN @DateStart AND @DateEnd
END
GO
