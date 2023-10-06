DECLARE @Intento AS INT 
SELECT @Intento = IdCatIncidenceClasification FROM DeliveryBackOffice.dbo.CatIncidenceClasification
WHERE IncidenceTypeName = 'Intento de entrega fallida'
 
 --VERIFICAR QUE SEAN 6
 update DeliveryBackOffice.dbo.CatTypeIncidence
 SET IncidenceClasificationId = @Intento
 WHERE RowStatus = 1
 AND ServiceType = 'DELIVERY'
 AND NameIncidence IN (
'Datos de dirección de entrega incorrectos'
,'No hay nadie en destino'
,'Destinatario solicita otra fecha de entrega'
,'No cumple requisito para entrega'
,'Tiempo de espera excedido'
,'Cliente solicita entrega en un Express Center'
 )

DECLARE @Rechazo AS INT 
SELECT @Rechazo = IdCatIncidenceClasification FROM DeliveryBackOffice.dbo.CatIncidenceClasification
WHERE IncidenceTypeName = 'Rechazo a la entrega'

--VERIFICAR QUE SEAN 2
update DeliveryBackOffice.dbo.CatTypeIncidence
 SET IncidenceClasificationId = @Rechazo
 WHERE RowStatus = 1
 AND ServiceType = 'DELIVERY'
 AND NameIncidence IN (
'Destinatario rechaza paquete'
,'Remitente solicita devolución'
 )

DECLARE @IncidenciaOperativa AS INT 
SELECT @IncidenciaOperativa = IdCatIncidenceClasification FROM DeliveryBackOffice.dbo.CatIncidenceClasification
WHERE IncidenceTypeName = 'Incidencias operativas'

--VERIFICAR QUE SEAN 3
update DeliveryBackOffice.dbo.CatTypeIncidence
 SET IncidenceClasificationId = @IncidenciaOperativa
 WHERE RowStatus = 1
 AND ServiceType = 'DELIVERY'
 AND NameIncidence IN (
'Envío fuera de ruta'
,'Paquete con problema'
,'No dio tiempo a realizar la entrega'
 )

SELECT IncidenceClasificationId,* from DeliveryBackOffice.dbo.CatTypeIncidence
 WHERE RowStatus = 1
 AND ServiceType = 'DELIVERY'