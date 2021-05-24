
insert into dbo.CatPaymentTime
([TimePlaName], [TimePlaDescription],[TimePlaAbrev],[TimePlaStatus],[TokenCreated],[DateCreated])
values('Post-Venta','Pago con crédito','POST',1,'SYS-CAQUINO',GETDATE())

select * from dbo.CatPaymentTime