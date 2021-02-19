-----------------/////////////////////// Tabla para el Path de la incidencia  ///////////////////////////////////
CREATE TABLE DeliveryBackOffice.dbo.ProofIncidence
(IdProofIncidence int IDENTITY (1,1) PRIMARY KEY NOT NULL,
IncidenceId int null,
PathIncidence varchar (100) null,
RowStatus bit not NULL,
TokenCreated varchar(50)  NOT NULL,
DateCreated datetime  NOT NULL,
TokenUpdated varchar(50)   NULL,
DateUpdated datetime   NULL,
CONSTRAINT FKProofIncidence FOREIGN KEY (IncidenceId) REFERENCES IncidenceServices(IdIncidence))
GO