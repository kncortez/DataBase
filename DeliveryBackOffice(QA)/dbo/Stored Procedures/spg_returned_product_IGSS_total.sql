-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <30/06/2020>
-- Description:	<Totales Reporte de producto retornado>
-- =============================================
CREATE PROCEDURE [dbo].[spg_returned_product_IGSS_total]
	-- Add the parameters for the stored procedure here
	@_dateReport nvarchar(50) = '30/06/2020',
	@VP_ID INT,
	@Status_ID NVARCHAR(MAX)
AS
BEGIN
BEGIN TRY

 select count (DOR.Guide_Number) CountGuides
 ,CONVERT(varchar,@_dateReport--GETDATE()-1
 ,103) DateReport
 from DeliveryBackOffice.dbo.DeliveryOrderDetail DOD
 join DeliveryBackOffice.dbo.DeliveryOrder DOR ON DOR.Guide_Serie  = DOD.Guide_Serie AND DOR.Guide_Number = DOD.Guide_Number
 join DeliveryBackOffice.dbo.ServiceRequest SVR ON SVR.Manifest_Serie  = DOR.Manifest_Serie and SVR.Manifest_Number = DOR.Manifest_Number /*and SVR.CustomerID = 1*/
 where DOD.StatusOrderId in (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Status_ID,','))
 and CAST(DOD.DateCreated as date) = CONVERT(DATETIME, @_dateReport, 103)--CAST(GETDATE()-1 as date)
 and DOR.Sender_ID IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@VP_ID,','))

END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			
		END CATCH;
END
