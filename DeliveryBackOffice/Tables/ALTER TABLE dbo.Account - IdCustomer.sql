/*
HPW-64
*/

 ALTER TABLE [Account]
 ADD IdCustomer INT;

ALTER TABLE [Account]
ADD FOREIGN KEY([IdCustomer])
REFERENCES [dbo].[Customer] ([IdCustomer])