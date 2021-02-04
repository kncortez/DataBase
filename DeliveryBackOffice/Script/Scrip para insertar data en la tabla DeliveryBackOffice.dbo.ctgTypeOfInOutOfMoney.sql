---Scrip para insertar data en la tabla DeliveryBackOffice.dbo.ctgTypeOfInOutOfMoney

  ---Cupon
 insert into [dbo].[ctgTypeOfInOutOfMoney] (tio_pk_id, tio_pk_name, tio_tokenCreated, tio_dateCreated) 
 values(3, 'pago con cupon', 'SYS-SYSTEM', GETDATE());
 ---Wallet
 insert into [dbo].[ctgTypeOfInOutOfMoney] (tio_pk_id,tio_pk_name, tio_tokenCreated, tio_dateCreated) 
 values(4, 'pago con wallet', 'SYS-SYSTEM', GETDATE());
 --Credito
 insert into [dbo].[ctgTypeOfInOutOfMoney] (tio_pk_id, tio_pk_name, tio_tokenCreated, tio_dateCreated) 
 values(5, 'credito', 'SYS-SYSTEM', GETDATE());
 
 