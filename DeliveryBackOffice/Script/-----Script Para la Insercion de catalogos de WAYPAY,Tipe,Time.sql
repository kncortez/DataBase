-------Script Para la Insercion de catalogos de WAYPAY
----Efectivo
--insert into [dbo].[CatWayToPay] (WayPayName, WayPayDescription, WayPayAbrev, WayPayStatus, TokenCreated, DateCreated)
-- values('Efectivo', 'El pago es en efectivo', 'EFECT', 1,  'SYS-SYSTEM', GETDATE());
-- ---Tarjeta
-- insert into [dbo].[CatWayToPay] (WayPayName, WayPayDescription, WayPayAbrev, WayPayStatus, TokenCreated, DateCreated)
-- values('Tarjeta', 'EL pago es con tarjeta de credito o debito', 'TARJT', 1,  'SYS-SYSTEM', GETDATE());
-- ---Cupon
-- insert into [dbo].[CatWayToPay] (WayPayName, WayPayDescription, WayPayAbrev, WayPayStatus, TokenCreated, DateCreated)
-- values('Cupon', 'El pago es con un cupon promocional', 'CUPN', 1,  'SYS-SYSTEM', GETDATE());
-- ---Wallet
-- insert into [dbo].[CatWayToPay] (WayPayName, WayPayDescription, WayPayAbrev, WayPayStatus, TokenCreated, DateCreated)
-- values('Wallet', 'El pago es con billetera electronica', 'WALLT', 1,  'SYS-SYSTEM', GETDATE());
-- --Credito
-- insert into [dbo].[CatWayToPay] (WayPayName, WayPayDescription, WayPayAbrev, WayPayStatus, TokenCreated, DateCreated)
-- values('Credito', 'El servico sera al credito', 'CREDIT', 1,  'SYS-SYSTEM', GETDATE());
--
--- ya no ejecutar el scrip de CatWayToPay
--- de aqui para abajo si
 -----Script Para la Insercion de catalogos de PAYTYPE
--Contado
insert into [dbo].[CatPaymentType] (PayTypeName, PayTypeDescriptions, PayTypeAbrev, PayTypeStatus, TokenCreated, DateCreated)
 values('Contado', 'El tipo de pago es al contado', 'CONT', 1,  'SYS-SYSTEM', GETDATE());
 ---Collect-
insert into [dbo].[CatPaymentType] (PayTypeName, PayTypeDescriptions, PayTypeAbrev, PayTypeStatus, TokenCreated, DateCreated)
 values('Collect', 'El tipo de pago es en destino', 'COLLT', 1,  'SYS-SYSTEM', GETDATE());
 ---Prepago
 insert into [dbo].[CatPaymentType] (PayTypeName, PayTypeDescriptions, PayTypeAbrev, PayTypeStatus, TokenCreated, DateCreated)
 values('Prepago', 'El tipo de pago es la billetera electronica', 'PREPG', 1,  'SYS-SYSTEM', GETDATE());
 ---Credit
insert into [dbo].[CatPaymentType] (PayTypeName, PayTypeDescriptions, PayTypeAbrev, PayTypeStatus, TokenCreated, DateCreated)
 values('Credit', 'El tipo de pago es al credito', 'CREDT', 1,  'SYS-SYSTEM', GETDATE());
 select * from dbo.[CatPaymentType]
 -----Tiempo/Lugar
  ---Credit
insert into [dbo].CatPaymentTime (TimePlaName, TimePlaDescription, TimePlaAbrev, TimePlaStatus, TokenCreated, DateCreated)
 values('Ahora', 'El pago sera efectuado en el lugar de la solicitud', 'AHR', 1,  'SYS-SYSTEM', GETDATE());
   ---Credit
insert into [dbo].CatPaymentTime (TimePlaName, TimePlaDescription, TimePlaAbrev, TimePlaStatus, TokenCreated, DateCreated)
 values('Destino', 'El pago del servicio sera efectuado en el destino', 'DEST', 1,  'SYS-SYSTEM', GETDATE());
 select *  from dbo.CatPaymentTime