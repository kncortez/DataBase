
-- Paquete dañado                 El paquete esta dañado y es rechazado por el cliente
-- Paquete no encontrado          El paquete no se encontró en la unidad y no pudo ser entregado al cliente
-- Paquete rechazado por retraso  El paquete fue rechazado por el cliente de Forza porque fue rechazado por su cliente, por un retraso responsabilidad de la empresa.
-- Paquete incorrecto             El paquete tiene la guía correcta pero fue rechazado por el cliente por no ser el paquete esperado. 

-- Cliente no vive en la dirección   									Cliente no vive en la dirección
-- Dirección errónea													Dirección errónea
-- No hay nadie en casa             									No hay nadie en casa
-- Cliente no dejó documento a la persona que recibe el paquete     	Cliente no dejó documento a la persona que recibe el paquete
-- Servicio fuera de ruta	                                            Servicio fuera de ruta

----------------------------------------------------------------------  Start Service Return ----------------------------------------------------------------------------------------

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Cliente no vive en la dirección', 'Cliente no vive en la dirección', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'RETURN',1)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Dirección errónea', 'Dirección errónea', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'RETURN',2)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('No hay nadie en casa', 'No hay nadie en casa', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'RETURN',3)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Cliente no dejó documento a la persona que recibe el paquete', 'Cliente no dejó documento a la persona que recibe el paquete', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'RETURN',4)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Servicio fuera de ruta', 'Servicio fuera de ruta', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'RETURN',5)
------------------------------------------------------------------------  End Service Return ----------------------------------------------------------------------------------------

------------------------------------------------------------------------  Start Incidence by piece ----------------------------------------------------------------------------------
Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Paquete dañado', 'El paquete esta dañado y es rechazado por el cliente', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'PIECE',1)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Paquete no encontrado', 'El paquete no se encontró en la unidad y no pudo ser entregado al cliente', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'PIECE',2)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Paquete rechazado por retraso', 'El paquete fue rechazado por el cliente de Forza porque fue rechazado por su cliente, por un retraso responsabilidad de la empresa', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'PIECE',3)

Insert into DeliveryBackOffice.dbo.CatTypeIncidence (NameIncidence, DescriptionIncidence, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated, ServiceType, OrderId)
values ('Paquete incorrecto', 'El paquete tiene la guía correcta pero fue rechazado por el cliente por no ser el paquete esperado', 1, 'SYS-HGOMEZ', GETDATE(), null, null, 'PIECE',4)

----------------------------------------------------------------------  End Incidence by piece ----------------------------------------------------------------------------------

select * from CatTypeIncidence