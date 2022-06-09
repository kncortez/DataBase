


CREATE PROCEDURE [dbo].[spwsGetWizardAccount]
  @IdAccount int = null,
  @IdWizardAccount int = null,
  @status int = null
 
AS 

BEGIN

  DECLARE @jsonResult NVARCHAR(MAX) 
    SET @jsonResult =  
  ( 
 
SELECT STUFF((
SELECT
      ',{"IdAccount":"' +  isnull(CAST(dwc.AccIdAccount AS VARCHAR), 'N/A') + '",'+
	   '"WizardId":"' +  isnull(CAST(dwc.IdWiz AS VARCHAR), 'N/A') + '",'+
	  '"WizardStatus":"' +  isnull(CAST(dwc.StatusAccountWiz AS VARCHAR), 'N/A') + '",'+
	  '"WizardName":"' +  isnull(CAST(upper(cw.NameWiz) AS VARCHAR), 'N/A') + '",'+
	  '"WizardDescription":"' +   isnull(CAST( cw.DescriptionWiz AS VARCHAR(MAX)), 'N/A') + '"}'
		 from DeliveryWizardAccount dwc
		inner join CatWizard cw on  (dwc.IdWiz = cw.IdWiz )
		inner join Account ac on (ac.AccIdAccount = dwc.AccIdAccount)
		where ac.AccIdAccount = @IdAccount  and dwc.StatusAccountWiz = 1
 FOR XML PATH(''), TYPE
	 ).value('.', 'varchar(max)'),1,1,''
				  )
			) 
 
  select  '['+ @jsonResult + ']' FormatJson


END