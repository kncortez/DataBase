/*
1 = Checkpoints que denotan el inicio de un servicio = 'CheckPoints Iniciales'
2 = Checkpoints de transición = 'CheckPoints de Proceso'
3 = Checkpoints finales = 'CheckPoints Finales'
4 = Checkpoints que denotan aluna incidencia en el servicio = CheckPoints de Incidencia
*/

UPDATE dbo.StatusOrder 
SET CatCheckpointTypeId = 1
WHERE StatusOrderId IN (15,21);

UPDATE dbo.StatusOrder 
SET CatCheckpointTypeId = 3
WHERE StatusOrderId IN (5, 7, 14, 22, 23, 25, 30);

UPDATE dbo.StatusOrder 
SET CatCheckpointTypeId = 4
WHERE StatusOrderId IN (9, 12, 27);

SELECT 
*
FROM
[DeliveryBackOffice].[dbo].[StatusOrder]
