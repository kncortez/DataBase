--SCRIPT PARA ACTUALIZAR LOS ARTICULOS DE HN CON LOS TARIFARIOS

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 582 --531
WHERE IdRateData = 69146 
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 582 --531
WHERE IdRateData = 69151
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 593 --532
WHERE IdRateData = 69147 
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 593 --532
WHERE IdRateData = 69152
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 594 --533
WHERE IdRateData = 69148 
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 594 --533
WHERE IdRateData = 69153
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 595 --534
WHERE IdRateData = 69149 
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 595 --534
WHERE IdRateData = 69154
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 596 --535
WHERE IdRateData = 69150 
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)

UPDATE DeliveryBackOffice.dbo.RateData
SET ArticleId = 596 --535
WHERE IdRateData = 69155
AND TypeSegmentId = 1 AND RowStatus = 'true'
AND TypeServiceId IN (5,6)