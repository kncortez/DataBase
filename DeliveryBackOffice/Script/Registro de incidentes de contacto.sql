INSERT INTO [DeliveryBackOffice].[dbo].[ContactIncident] VALUES ('Llamada sin respuesta')
INSERT INTO [DeliveryBackOffice].[dbo].[ContactIncident] VALUES ('Número incorrecto')

SELECT * FROM [DeliveryBackOffice].[dbo].[ContactIncident]

ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD ID_ContactIncident TINYINT NULL

ALTER TABLE [dbo].[DeliveryOrder] ADD CONSTRAINT [FK_DeliveryOrder_ContactIncident] FOREIGN KEY([ID_ContactIncident])
REFERENCES [dbo].[ContactIncident] ([ID])

ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD Contact_Confirmed BIT NULL
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD User_ContactConfirmed NVARCHAR(50) NULL
ALTER TABLE DeliveryBackOffice.dbo.DeliveryOrder ADD Date_ContactConfirmed DATETIME NULL


--ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt DROP CONSTRAINT FK_DeliveryAttempt_ContactIncident
--ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt DROP COLUMN Date_ContactConfirmed 
--ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt DROP COLUMN User_ContactConfirmed
--ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt DROP COLUMN Contact_Confirmed
--ALTER TABLE DeliveryBackOffice.dbo.DeliveryAttempt DROP COLUMN ID_ContactIncident