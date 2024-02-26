select * from DeliveryBackOffice.dbo.ContentDetail
where ContentDetailTitle in ('Servicio C.O.D.','Servicio Estándar')

UPDATE DeliveryBackOffice.dbo.ContentDetail
SET ContentDetailDescription = 'Servicio de entrega y cobro de mercadería en el destino. (Comisión del 3.8% sobre el valor de la mercancía) Deposito inmediato. '
WHERE ContentDetailTitle = 'Servicio C.O.D.'

UPDATE DeliveryBackOffice.dbo.ContentDetail
SET ContentDetailDescription = 'Servicio regular de paquetería y encomiendas, con cobertura a nivel nacional de 24 a h48 horas. Puedes cancelar en origen o en destino (+Q4.00).'
WHERE ContentDetailTitle = 'Servicio Estándar'

select * from DeliveryBackOffice.dbo.ContentDetail
where ContentDetailTitle in ('Servicio C.O.D.','Servicio Estándar')
