/***************************************************************************************************
* TICKET:       FDAPI-5985
* DESCRIPCION:  Actualización de códigos de país nulos en Person (GT)
* AUTOR:        SYS-EGUERRA
* FECHA:        2026-03-31
* PAIS:         Guatemala (GT)
* BASE DE DATOS: DeliveryBackOffice
*
* TABLAS AFECTADAS:
*   - Person
***************************************************************************************************/

USE DeliveryBackOffice;
UPDATE Person
	SET [PerCountryOrigin] = 'GT'
	WHERE [PerCountryOrigin] IS NULL;
