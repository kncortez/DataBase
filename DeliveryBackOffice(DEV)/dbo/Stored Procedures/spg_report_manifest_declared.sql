-- =============================================
-- Author:		<Bidcar Herrera>
-- Create date: <21/10/2020>
-- Description:	<Reporte por manifiesto declarado>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <14/06/2024>
-- Description:	<Filtro de pais origen>
-- =============================================
CREATE PROCEDURE [dbo].[spg_report_manifest_declared]
	-- Add the parameters for the stored procedure here
	@PreparationDate DATE = '2020-06-24',
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

IF OBJECT_ID('tempdb..#HeaderDeliveryOrder') IS NOT NULL
BEGIN
 DROP TABLE #HeaderDeliveryOrder			
END

IF OBJECT_ID('tempdb..#Pieces_Arrived') IS NOT NULL
BEGIN
 DROP TABLE #Pieces_Arrived			
END


--DECLARE	@PreparationDate DATE = '2020-06-24'
select do.Preparation_Date,
	do.Manifest_Serie,
	do.Manifest_Number,
	do.Guide_Serie,
	do.Guide_Number,
	isnull(do.Sender_FirstName,'') +' '+ isnull(do.Sender_LastName,'') as Sender,
	do.Pieces_Dry as Pieces_Dry_Declared,
	do.Pieces_Cold as Pieces_Cold_Declared--,	
into #HeaderDeliveryOrder
from DeliveryBackOffice.dbo.DeliveryOrder do
where CONVERT(VARCHAR, Preparation_Date, 23) = CONVERT(VARCHAR, @PreparationDate, 23)
AND do.SenderCountryId = @IdCountry


select det.Guide_Serie,det.Guide_Number,
do.Manifest_Serie,
do.Manifest_Number,
sum(case when Temperature_Celsius is null then 1 else 0 end) Pieces_Dry_Arrived,
sum(case when Temperature_Celsius is null then 0 else 1 end) Pieces_Cold_Arrived
into #Pieces_Arrived
from #HeaderDeliveryOrder do
inner join DeliveryOrderDetail det on do.Guide_Serie = det.Guide_Serie
and do.Guide_Number = det.Guide_Number 
where det.StatusOrderId = 11
group by det.Guide_Serie,det.Guide_Number,do.Manifest_Serie,
do.Manifest_Number

CREATE NONCLUSTERED INDEX tempOrders ON #HeaderDeliveryOrder (Guide_Serie, Guide_Number);
CREATE NONCLUSTERED INDEX tempPieces ON #Pieces_Arrived (Manifest_Serie, Manifest_Number);

select CONVERT(varchar, head.Preparation_Date, 103) Preparation_Date,
	head.Manifest_Serie + 
	CAST(head.Manifest_Number as varchar) Manifest,
	head.Sender,
    sum(head.Pieces_Dry_Declared) Pieces_Dry_Declared,
	sum(head.Pieces_Cold_Declared) Pieces_Cold_Declared,
	coalesce(sum(arrv.Pieces_Dry_Arrived),0) Pieces_Dry_Arrived,
	coalesce(sum(arrv.Pieces_Cold_Arrived),0) Pieces_Cold_Arrived
from #HeaderDeliveryOrder head
left join #Pieces_Arrived arrv on 
    head.Guide_Serie = arrv.Guide_Serie
and head.Guide_Number = arrv.Guide_Number
and head.Manifest_Serie = arrv.Manifest_Serie 
and head.Manifest_Number= arrv.Manifest_Number
group by head.Manifest_Serie,head.Manifest_Number,CONVERT(varchar, Preparation_Date, 103),head.Sender


END