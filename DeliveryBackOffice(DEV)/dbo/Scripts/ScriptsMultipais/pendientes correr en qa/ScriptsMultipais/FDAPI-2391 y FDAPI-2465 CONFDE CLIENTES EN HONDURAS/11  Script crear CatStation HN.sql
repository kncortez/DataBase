
--CREAMOS ESTACION PARA HONDURAS

SELECT TOP 100 * FROM DeliveryBackOffice.dbo.CatStation WITH(NOLOCK)
ORDER BY IdStation DESC

SELECT * FROM DeliveryBackOffice.dbo.CatStation
WHERE StationType = 2
AND CountryId = 'HN'
AND RowStatus = 1

SELECT * FROM DeliveryBackOffice.dbo.CatStatusType WITH(NOLOCK)

INSERT INTO CatStation VALUES ('FD EXC HN 1', 'HN',2,NULL,677882,1,'SYS-WOROZCO',GETDATE(),NULL,NULL)

