UPDATE DeliveryBackOffice.dbo.StatusOrder
SET CatStatusProcessId = (SELECT IdStatusProcess FROM CatStatusProcess WHERE NameStatusProcess = 'Recibido')
WHERE OrderDescription IN ('Recolectado','Recibido En Express Center')