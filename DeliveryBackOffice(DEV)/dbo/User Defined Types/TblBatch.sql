/* =================================================
   SP:        [dbo].[TblBatch]
   Propósito: <Tipo de dato tabla para manejo de información de lotes de facturación electrónica>
   Autor:     <Walter Orozco>
   Historia:  <FDAPI-3044>
   Fecha:     2024-08-14
============================================
=== CHANGELOG ================================
-- 2024-09-11 | Historia/épica: FDAPI-3052 | Autor: Walter Orozco |
-- 2024-09-06 | Historia/épica: FDAPI-3044 | Autor: Walter Orozco |
=========================================== */

CREATE TYPE [dbo].[TblBatch] AS TABLE (
	[Id_Lote]                           INT             NULL,
    [RTN]                               NVARCHAR(50)    NULL,
    [NoDeclaracion]                     NVARCHAR(50)    NULL,
    [CAI]                               NVARCHAR(100)   NULL,
    [LimitDateEmision]                  DATETIME        NULL,
    [Establishment]                     INT             NULL,
    [Emision_Point]                     INT             NULL,
    [TypeDocument]                      INT             NULL,
    [RecepcionDate]                     DATETIME        NULL,
    [Administration_Code]               INT             NULL,
    [Status]                            BIT             NULL,
    [Enable]                            BIT             NULL,
    [InitialRange]                      BIGINT          NULL,
    [FinalRange]                        BIGINT          NULL,
    [Last_Process]                      BIGINT          NULL,
    [AmountGranted]                     BIGINT          NULL,
    [AmountRequested]                   BIGINT          NULL,
    [Emailification]                    NVARCHAR(50)    NULL,
    [DaysLeftifycation]                 INT             NULL,
    [PercentInvoiceLeftifycation]       INT             NULL,
    [RowStatus]                         BIT             NULL);