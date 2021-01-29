USE [DeliveryBackOffice]
GO

CREATE PROCEDURE [dbo].[spwsGetServiceDetail] 
@Token nvarchar(50) = '',
@IdAccount int = 0,
@GuideNumber nvarchar(200) = 'FD89911'
AS
BEGIN
DECLARE @jsonOutput NVARCHAR(MAX)
	     
DECLARE @Guide_Serie nvarchar(2) = SUBSTRING(@GuideNumber, 1, 2)
DECLARE @Guide_Number nvarchar(100) = SUBSTRING(@GuideNumber, 3,LEN(@GuideNumber))
print '@Guide_Serie'
print @Guide_Serie
print '@Guide_Number'
print @Guide_Number
SET @jsonOutput = 
  (

SELECT ''+ STUFF((
SELECT  distinct
			',{"Price":' + CONVERT(varchar,PriceShippment) + ''+						
			',"FromAddressName":"' + CONVERT(varchar,Sender_FirstName + ' ' + Sender_LastName ) + '"'+									
			',"FromAddressEmail":"' + CONVERT(varchar,'') + '"'+									
			',"FromAddress":"'   + CONVERT(varchar,Sender_Address) + '"'+									
			',"ToAddressName":"' + CONVERT(varchar,COALESCE(Receiver_FirstName,'')) + ' ' + COALESCE(Receiver_LastName,'') + '"'+									
			',"ToAddressContact":"' + CONVERT(varchar,COALESCE(Receiver_FirstName,'')) + ' ' + COALESCE(Receiver_LastName,'')  + '"'+									
			',"ToAddressEmail":"' + CONVERT(varchar,Receiver_Email ) + '"'+									
			',"Phone":"' + CONVERT(varchar,Receiver_Phone ) + '"'+									
			',"ToAddress":"' + CONVERT(varchar,Receiver_Address ) + '"'+									
			',"CountPieces":' + CONVERT(varchar,Pieces_Cold + Pieces_Dry ) + ''+									
			',"TypeService":"' + CONVERT(varchar,COALESCE(TypeService,'') ) + '"'+												
			',"Base":' + CONVERT(varchar,COALESCE(PriceShippment,0) / 1.12) + ''+						
			',"IVA":' + CONVERT(varchar,COALESCE(PriceShippment,0) - COALESCE(PriceShippment,0) / 1.12) + ''
			
			+ '}'
			from DeliveryBackOffice.dbo.DeliveryOrder
			where Guide_Serie =  @Guide_Serie
			and Guide_Number = @Guide_Number			
		FOR XML PATH(''), TYPE
   ).value('.', 'varchar(max)'),1,1,''
              ) + ''

  )

  select 
  --'[' + 
  @jsonOutput 
  --+ ']' 
  FormatJson

END
