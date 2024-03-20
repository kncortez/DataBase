DECLARE @ERROR_SQL int;

BEGIN TRAN VALORES

-- VARIABLES PARA CONFIGURAR CLIENTE
 
DECLARE @CUSTOMERID INT;
SET @CUSTOMERID = (SELECT TOP 1 IdCustomer FROM Customer WHERE [Name] like '%DHL%' AND IdCustomerType = 1 and RowSatus = 1);
SET @ERROR_SQL=@@ERROR

IF (@ERROR_SQL <>0 ) GOTO TratarError
-- VARIABLES PARA ESTADOS DE GUIAS

DECLARE @CheckStatusRecolectado INT;
SET @CheckStatusRecolectado = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Recolectado' AND RowStatus = 1);

DECLARE @CheckStatusRuta INT;
SET @CheckStatusRuta = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Recolectado' AND RowStatus = 1);

DECLARE @CheckStatusEntregado INT;
SET @CheckStatusEntregado = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Entregado' AND RowStatus = 1);

DECLARE @CheckStatusEnInventario INT;
SET @CheckStatusEnInventario = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'En Inventario' AND RowStatus = 1);

DECLARE @CheckStatusArribo INT;
SET @CheckStatusArribo = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Arribó a las instalaciones' AND RowStatus = 1);

DECLARE @CheckStatusDevuelto INT;
SET @CheckStatusDevuelto = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Devuelto' AND RowStatus = 1);

DECLARE @CheckStatusRutaDevuelto INT;
SET @CheckStatusRutaDevuelto = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'En ruta para devolución' AND RowStatus = 1);

DECLARE @CheckStatusRecibidoExpress INT;
SET @CheckStatusRecibidoExpress = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Recibido En Express Center' AND RowStatus = 1);

DECLARE @CheckStatusEntregadoExpress INT;
SET @CheckStatusEntregadoExpress = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Entregado En Express Center' AND RowStatus = 1);

DECLARE @CheckStatusDevueltoExpress INT;
SET @CheckStatusDevueltoExpress = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Devuelto en Express Center' AND RowStatus = 1);

DECLARE @CheckStatusInventarioDevolucion INT;
SET @CheckStatusInventarioDevolucion = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'En Inventario de devolución' AND RowStatus = 1);

DECLARE @CheckStatusIncidenciaRuta INT;
SET @CheckStatusIncidenciaRuta = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Incidencia en ruta' AND RowStatus = 1);

DECLARE @CheckStatusIncidenciaValida INT;
SET @CheckStatusIncidenciaValida = (SELECT TOP 1 StatusOrderID FROM StatusOrder WHERE OrderDescription = 'Incidencia Validada' AND RowStatus = 1);

-- VARIABLES PARA INCIDENCIAS DE GUIAS DE GUIAS

DECLARE @CheckIncidenciaExcesoTiempo INT;
SET @CheckIncidenciaExcesoTiempo = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'Tiempo de espera excedido' AND RowStatus = 1);

DECLARE @CheckIncidenciaRechazaPaquete INT;
SET @CheckIncidenciaRechazaPaquete = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'Destinatario rechaza paquete' AND RowStatus = 1);

DECLARE @CheckIncidenciaDireccionIncorrecta INT;
SET @CheckIncidenciaDireccionIncorrecta = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'Datos de dirección de entrega incorrectos' AND RowStatus = 1);

DECLARE @CheckIncidenciaNoHayNadie INT;
SET @CheckIncidenciaNoHayNadie = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'No hay nadie en destino' AND RowStatus = 1);

DECLARE @CheckIncidenciaCambioFecha INT;
SET @CheckIncidenciaCambioFecha = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'Destinatario solicita otra fecha de entrega' AND RowStatus = 1);

DECLARE @CheckIncidenciaFueraRuta INT;
SET @CheckIncidenciaFueraRuta = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'Envío fuera de ruta' AND RowStatus = 1);

DECLARE @CheckIncidenciaNoDioTiempo INT;
SET @CheckIncidenciaNoDioTiempo = (SELECT TOP 1 IdIncidenceType FROM CatTypeIncidence WHERE NameIncidence = 'No dio tiempo a realizar la entrega' AND RowStatus = 1);

COMMIT TRAN VARIABLES

-- INGRESO DE LAS DIFERENTES FORMAS DE CONEXIÓN PARA WEBHHOOK
BEGIN TRAN CONEXION

INSERT INTO WebhookCatTypeConnection(IdCatTypeConnection,CatTypeConnectionName,RowStatus,DateCreated,TokenCreated)
                              VALUES (1,'API',1,GETDATE(),'SYS-CAZURDIA')

INSERT INTO WebhookCatTypeConnection(IdCatTypeConnection,CatTypeConnectionName,RowStatus,DateCreated,TokenCreated)
                              VALUES (2,'SFTP',1,GETDATE(),'SYS-CAZURDIA')

-- CLIENTS DE WEBHOOK PREVIOS A IMPLEMENTAR A DHL SON TIPO 1 (USO DE API - WEBHOOK)

DECLARE @TYPECONECTIONAPI INT;
SET @TYPECONECTIONAPI = (SELECT TOP 1 IdCatTypeConnection FROM WebhookCatTypeConnection WHERE [CatTypeConnectionName] = 'API' and RowStatus = 1);

DECLARE @TYPECONECTIONSFTP INT;
SET @TYPECONECTIONSFTP = (SELECT TOP 1 IdCatTypeConnection FROM WebhookCatTypeConnection WHERE [CatTypeConnectionName] = 'SFTP' and RowStatus = 1);

--- AQUI YA SE PUEDE PONER QUE TypeConectionId no debe ser Nulo y es llave foranea de WebookCAtTypeConnection.
IF (@ERROR_SQL <>0 ) GOTO TratarError
-- INGRESO DE DHL Y SUS CREDENCIALES, ES TIPO 2 (SFTP)

INSERT INTO WebhookEndpoint(WebhookTypeId,CustomerId,WebhookEndpointURI,RowStatus,DateCreated,TokenCreated,typeConnectionId,Hostname,UserName,Password,Port)
VALUES(1,@CUSTOMERID,'http://developer.marvel.com/',1,GETDATE(),'SYS-CAZURDIA',@TYPECONECTIONSFTP,'c2Z0cDMtdGVzdC5kaGwuY29t','q8v3d809','eCNjQ0tuYWNmMV9SWFExSA==',4222, '/in/build/')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError

COMMIT TRAN CONEXION

-- INGRESO DE LOS ESTADOS QUE SI NOTIFICARA DHL AL WEBHOOK 
BEGIN TRAN NOTIFICACIONES

INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusRecolectado,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusRuta,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusEntregado,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusEnInventario,1,'SYS-CAZURDIA', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusArribo,1,'SYS-CAZURDIA', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusDevuelto,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusRutaDevuelto,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusRecibidoExpress,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusEntregadoExpress,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusDevueltoExpress,1,'ELOPEZ', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusInventarioDevolucion,1,'SYS-CAZURDIA', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusIncidenciaRuta,1,'SYS-CAZURDIA', GETDATE())
GO
INSERT INTO WebhookRestrinctionByUser (CustomerId,WebhookTypeId,StatusOrderId,RowStatus,TokenCreated,DateCreated)
VALUES(@CUSTOMERID,1,@CheckStatusIncidenciaValida,1,'SYS-CAZURDIA', GETDATE())

COMMIT TRAN NOTIFICACIONES
---- INGRESO DE LOS REMARKS DE DHL 
BEGIN TRAN ESTATUS_DHL

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'WC ', 'WC= With courier. El material es recolectado por FORZA',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'AR AGENT DEL ', 'AR= Arrive Facility. El material llega a una de las bodegas de FORZA',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'BAD ', 'BA= Bad Address. El envió no se pudo entregar por mala dirección, no existe la empresa o contacto, o cualquier otro motivo del cliente.',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'DEL', 'DEL= Delivery. Destino solicita fecha de entrega',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'FAILED DEL', 'El envió no se logra entregar por algún atraso o responsabilidad de FORZA, no del cliente',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'OH AT AGENT ', 'OH= On Hold. Por alguna razón interna de FORZA. envío/pieza físico está en espera dentro de las instalaciones/instalaciones de FORZA. La idea es dar visibilidad que el envió no se movió en el día.',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'RTO TO DHL ZONA 13', 'RTO TO DHL = Return To DHL. Envíos que no se pueden entregar después de dos intentos y son retornados a DHL con la previa autorización',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, 'WC FORZA EN RUTA', 'WC= With courier. El material sale a ruta por FORZA (por pieza)',1,GETDATE(),'SYS-CAZURDIA');

INSERT INTO StatusOrderExternal (CustomerId,Remark,Description,RowStatus,DateCreated,TokenCreated)
VALUES(@CUSTOMERID, '', 'El NAME no soporta caracteres especiales (tíldes, signos, etc.). Después de este checkpoint no se permiten nuevos estados.',1,GETDATE(),'SYS-CAZURDIA');

COMMIT TRAN ESTATUS_DHL

----- INGRESO DE LOS ESTATUS DE POD, EXPRESS

BEGIN TRAN ESTATUS_DHL_FORZA

INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusRecolectado,1,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusRecibidoExpress,1,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusArribo,2,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusEnInventario,6,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusInventarioDevolucion,6,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusDevuelto,7,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusDevueltoExpress,7,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusRuta,8,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusRutaDevuelto,8,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusEntregado,9,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO StatusOrderRelation (StatusOrderId,StatusOrderExternalId,RowStatus,DateCreated,TokenCreated)
VALUES(@CheckStatusEntregadoExpress,9,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError

COMMIT TRAN ESTATUS_DHL_FORZA
------ INGRESO DE LOS INCIDENTES POD, EXPRESS
BEGIN TRAN INCIDENCIAS_DHL_FORZA

INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(3,@CheckIncidenciaDireccionIncorrecta ,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(3,@CheckIncidenciaNoHayNadie,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(4,@CheckIncidenciaCambioFecha,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(3,@CheckIncidenciaExcesoTiempo,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(3,@CheckIncidenciaRechazaPaquete,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(5,@CheckIncidenciaFueraRuta,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
INSERT INTO IncidentTypeRelation (StatusOrderExternalId,IncidenceTypeId,RowStatus,DateCreated,TokenCreated)
VALUES(5,@CheckIncidenciaNoDioTiempo,1,GETDATE(),'SYS-CAZURDIA')
SET @ERROR_SQL=@@ERROR
IF (@ERROR_SQL <>0 ) GOTO TratarError
COMMIT TRAN INCIDENCIAS_DHL_FORZA

TratarError:

If @@Error<>0 THEN
BEGIN
	PRINT  CONCAT('EXISTE UN ERROR: ', @@ERROR)
	ROLLBACK TRAN VARIABLES
END