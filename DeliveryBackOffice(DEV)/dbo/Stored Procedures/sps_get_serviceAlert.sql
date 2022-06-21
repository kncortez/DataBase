CREATE PROCEDURE sps_get_serviceAlert
     @token varchar(50),
	 @IdCourier bigint,
	 @DateRoute date 
AS
BEGIN
	--SELECT doa.GuideSerie, doa.GuideNumber, doa.ServiceType,doa.AlertDescription 
	--FROM DeliveryOrderAlert doa
	--INNER JOIN DeliveryAttempt dat ON doa.GuideNumber = dat.Guide_Number
	--INNER JOIN RouteAssigment rat ON dat.ID_Courier  = rat.IdCurrierMan
	--WHERE rat.IdCurrierMan = 436 AND rat.DateOfRoute = '2021-03-02'
	--AND doa.RowStatus = 1 AND doa.AlertTypeId = 1
		DECLARE @Output VARCHAR(MAX);	
	SET @Output = 
				'[ { ' +  
				'"Results": [ ' + 
				(SELECT STUFF((SELECT ' { "Guide": "' +CONCAT(doa.GuideSerie, CAST(doa.GuideNumber AS VARCHAR))+ '", ' + 
										 --'"ServiceType": "' +(doa.ServiceType)+ '", ' + 
										 '"Description": "' +(doa.AlertDescription)+ '" }, '
									 FROM DeliveryOrderAlert doa
										INNER JOIN DeliveryAttempt dat ON doa.GuideNumber = dat.Guide_Number
										INNER JOIN RouteAssigment rat ON dat.ID_Courier  = rat.IdCurrierMan
										WHERE rat.IdCurrierMan = @IdCourier AND rat.DateOfRoute = @DateRoute
										AND doa.RowStatus = 1 AND doa.AlertTypeId = 1
									 FOR XML PATH ('')), 1, 1, '')) +
				'] } ]'; 
				
		SET @Output = SUBSTRING(@Output, 1, (len(@Output) - 7)) + SUBSTRING(@Output, (len(@Output) - 5), len(@Output));
		SELECT @Output FormatJson;


END




  