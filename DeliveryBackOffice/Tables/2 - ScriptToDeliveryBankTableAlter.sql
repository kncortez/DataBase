USE [DeliveryBackOffice]

BEGIN TRAN

--AGREGAR COLUMNAS
ALTER TABLE [dbo].[DeliveryBank] ADD [ACHCode] [int] NULL, [PayingBank] [int] NULL
ALTER TABLE [dbo].[DeliveryBank] ADD  CONSTRAINT [DF_DeliveryBank_PayingBank]  DEFAULT ((31)) FOR [PayingBank]

--AGREGAR LLAVE FORANEA PARA TABLA RECURSIVA
BEGIN TRAN
ALTER TABLE [dbo].[DeliveryBank]  WITH CHECK ADD  CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank] FOREIGN KEY([PayingBank]) 
REFERENCES [dbo].[DeliveryBank] ([Id_bank])
ALTER TABLE [dbo].[DeliveryBank] CHECK CONSTRAINT [FK_DeliveryBank_IdBank_PayingBank]

--COMMIT



