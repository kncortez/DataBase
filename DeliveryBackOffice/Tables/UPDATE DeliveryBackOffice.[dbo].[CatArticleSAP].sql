UPDATE DeliveryBackOffice.[dbo].[CatArticleSAP]
SET Category = 'SERVICIO'
WHERE SAPCode IN ('S04001','S04002','S04003', 'S04004')

UPDATE DeliveryBackOffice.[dbo].[CatArticleSAP]
SET Category = 'BIEN'
WHERE SAPCode IN ('S04005')

UPDATE DeliveryBackOffice.[dbo].[CatArticleSAP]
SET CardPercent = 3.50
WHERE SAPCode = 'S04004'

UPDATE DeliveryBackOffice.[dbo].[CatArticleSAP]
SET CardAmount = 2.00
WHERE SAPCode IN ('S04001','S04002','S04003', 'S04005')