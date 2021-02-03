use DeliveryBackOffice
go
IF OBJECT_ID('sps_DeliveryOrderPiece') IS not NULL
BEGIN
 Drop procedure [dbo].[sps_DeliveryOrderPiece] 
END
go
CREATE PROCEDURE [dbo].[sps_DeliveryOrderPiece] 
   @GuideSerie			varchar(2) = 'FD'  
  ,@GuideNumber			int = 138014
  ,@PiecePhysicalWeight	decimal(12,2) = 0
  ,@PieceHeight			decimal(12,2) = 0 
  ,@PieceWidth			decimal(12,2) = 0
  ,@PieceLength			decimal(12,2) = 0
  ,@PieceWeight			decimal(12,2) = 0
  ,@DateCreated			datetime
  ,@fragile				bit = 0 
  ,@Detail				varchar(2500) = ''
  ,@Currency			varchar(15) = ''
  ,@Amount				decimal(12,2) = 0
AS 
BEGIN
	insert into DeliveryBackOffice.[dbo].[DeliveryOrderPiece] 
	(GuideSerie
	,GuideNumber
	,PiecePhysicalWeight
	,PieceHeight
	,PieceWidth
	,PieceLength
	,PieceWeight
	,DateCreated
	,fragile
	,Detail
	,Currency
	,Amount)
	values (
	@GuideSerie			
	,@GuideNumber			
	,@PiecePhysicalWeight	
	,@PieceHeight			
	,@PieceWidth			
	,@PieceLength			
	,@PieceWeight			
	,@DateCreated			
	,@fragile
	,@Detail
	,@Currency
	,@Amount
	)


	select  @@Identity
END 