/* =================================================
   SP:        [dbo].[TblTicketList]
   Propósito: Define el tipo en que se devuelve una consulta masiva de guías para procesamiento ZPL.
   Autor:     Erick Guerra
   Historia:  FDAPI-5660
   Fecha:     2026-02-27
============================================
=== CHANGELOG ================================
2026-03-06	|	Épica: FDAPI-5556	|	Autor: Erick	|
=========================================== */

CREATE TYPE dbo.TblTicketList AS TABLE
(
	[IdCustomer]            INT NOT NULL,
    [TicketNumber] NVARCHAR(150) NOT NULL
);
GO