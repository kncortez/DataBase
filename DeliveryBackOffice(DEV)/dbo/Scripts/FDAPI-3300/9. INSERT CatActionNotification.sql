--1
INSERT INTO dbo.CatActionNotification ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Rastreo de guías','Abrir pantalla de "Detalle del rastreo" precargando rastreo de la guía','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')
--2
INSERT INTO dbo.CatActionNotification ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Recolección confirmada','Abrir pantalla de "Recolecciones" aplicando el filtro de "Creado"','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')
--3
INSERT INTO dbo.CatActionNotification ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Recolección realizada','Abrir pantalla de "Recolecciones" aplicando el filtro de "Recolectado"','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')
--4
INSERT INTO dbo.CatActionNotification ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Acreditación de beneficios','Pantalla mis beneficios','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')
--5
INSERT INTO dbo.CatActionNotification ([Name], [Description], [UserCreated], [DateCreated], [TokenCreated])
 VALUES('Confirmación de pago de C.O.D.','Abrir pantalla de "Mis COD" aplicando el filtro de "Pagados"','SYS-ARECINOS', GETDATE(), 'SYS-ARECINOS')