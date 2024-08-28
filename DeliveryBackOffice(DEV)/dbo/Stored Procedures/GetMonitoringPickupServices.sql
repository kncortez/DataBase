-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-04-07>
-- Description:	<Obtiene información para Form Monitoreo de Servicios de Recolección>
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-08-27>
-- Description:	<Se cambia la dirección y la fecha de servicio por el de recolección>
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
	   ,sp.SenderName Customer  
	   ,vpc.DescriptionOfClient VisitPoint
	   ,vpc.Department Department
	   ,vpc.Town Town
	   ,sp.AddressPickup Address
	   ,css.Name Status
	   ,IIF(sp.IsScheduled IS NULL OR sp.IsScheduled = 0, 'A demanda', 'Programada') TypeService
	   ,FORMAT(sp.StartDate,'dd/MM/yyyy HH:mm:ss') DateCreated
	   ,FORMAT(sp.EndDate,'dd/MM/yyyy HH:mm:ss') EndDate
	FROM ServiceManagement sm
	JOIN SchedulePickup sp
		ON sp.SchedulePickupId = sm.IdSchedulePickup
	JOIN VisitPointClient vpc
		ON vpc.CodeOfReference = sp.SenderId
	JOIN CatServiceStatus css
		ON css.IdServiceStatus = sm.ServiceStatusId
	JOIN Customer cu
		ON cu.IdCustomer = vpc.CustomerID
	LEFT JOIN CatSystem cs
		ON cs.SysIdSystem = sp.IdSourcePlataform
	WHERE (cu.IdCustomer = @CustomerId
	OR @CustomerId = -1)
	AND (REPLACE(sp.SenderPhone, '-', '') LIKE @PhoneNew
	OR REPLACE(vpc.Phone, '-', '') LIKE @PhoneNew
	OR REPLACE(cu.CustomerPhone, '-', '') LIKE @PhoneNew
	OR @PhoneNew = '-1')
	AND CAST(sp.StartDate AS DATE) >= @DateStart
    AND CAST(sp.EndDate AS DATE) <= @DateEnd
END