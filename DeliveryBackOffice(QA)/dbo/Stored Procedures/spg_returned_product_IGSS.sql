-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <30/06/2020>
-- Description:	<Reporte de producto retornado>
-- =============================================
CREATE PROCEDURE [dbo].[spg_returned_product_IGSS]
	-- Add the parameters for the stored procedure here
	@_dateReport nvarchar(50) = '30/06/2020',
	@VP_ID INT,
	@Status_ID NVARCHAR(MAX)
AS
BEGIN

BEGIN TRY

select 
  DOR.Guide_Serie + CAST(DOR.Guide_Number AS VARCHAR) Guide 
 ,DOR.Ticket_Number Ticket
 ,DOR.Manifest_Serie + CAST(DOR.Manifest_Number AS VARCHAR) Manifest 
 ,isnull(DOR.Receiver_FirstName,'') + CASE WHEN LEN(isnull(DOR.Receiver_LastName,'')) = 0 THEN ' ' ELSE '' END + isnull(DOR.Receiver_LastName,'') ReceiverName 
 ,DOR.Receiver_Address Address, DOR.Receiver_Phone Phone
 ,Observations as ReasonForFailure
 --,VP.DescriptionOfClient as VPName
 ,ISNULL(DOR.Receiver_SocialSecurity_ID, ISNULL(DOR.Receiver_Alternant_SocialSecurity_ID,'ND')) as SocialSecurityID
 ,CONVERT(varchar, DOR.Shipping_Date, 103) as ShippingDate
 ,DOR.Consolidated_Number as ConsolidatedNumber
 from DeliveryBackOffice.dbo.DeliveryOrderDetail DOD
 join DeliveryBackOffice.dbo.DeliveryOrder DOR ON DOR.Guide_Serie  = DOD.Guide_Serie AND DOR.Guide_Number = DOD.Guide_Number
 join DeliveryBackOffice.dbo.ServiceRequest SVR ON SVR.Manifest_Serie  = DOR.Manifest_Serie and SVR.Manifest_Number = DOR.Manifest_Number /*and SVR.CustomerID = 1*/
 --join DeliveryBackOffice.dbo.VisitPointClient VP ON VP.CustomerID = SVR.CustomerID
 where DOD.StatusOrderId in (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@Status_ID,','))
 and CAST(DOD.DateCreated as date) = CONVERT(DATETIME, @_dateReport, 103)-- CAST(GETDATE()-1 as date)
 and DOR.Sender_ID IN (SELECT Item FROM DenariusDesktop_Dev.dbo.SplitUnlimited(@VP_ID,','))
 --order by DOD.DateCreatedInSystem asc
 order by DOR.Guide_Number asc 

END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			
		END CATCH;

END
