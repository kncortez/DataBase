--1
 ALTER TABLE dbo.DeliveryOrder ADD OrderStatus nvarchar(25) NULL;
--2
DECLARE @v sql_variant 
SET @v = N'Solicitado | Enviado | Para Entrega | Arrivando | Entregado'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'DeliveryOrder', N'COLUMN', N'OrderStatus'

--3
UPDATE DeliveryOrder SET OrderStatus = 'Arrivando';

--4
 ALTER TABLE dbo.DeliveryOrder ALTER COLUMN OrderStatus nvarchar(25) NOT NULL;
