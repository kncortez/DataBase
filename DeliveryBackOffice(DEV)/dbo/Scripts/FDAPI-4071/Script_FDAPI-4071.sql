-- Script para agregar dos campos en el objeto tipo tabla TblListGuidesWithAnticipatedCOD


-- PASO 1:  Eliminar el procedimiento que usa este objeto
DROP procedure sps_set_finishService

-- PASO 2:  Eliminar el objeto
DROP TYPE [dbo].[TblListGuidesWithAnticipatedCOD];

-- PASO 3:  Crear nuevamente el objeto con los nuevos campos (AmountToPay,CODAmount)
CREATE TYPE [dbo].[TblListGuidesWithAnticipatedCOD] AS TABLE (
    [Guide_Serie]       NVARCHAR (2)		NULL,
    [Guide_Number]      INT					NULL,
    [ExcludeCOD]        BIT					NULL,
    [IsAnticipatedCOD]  BIT					NULL,
    [AmountToPay]       DECIMAL(18,2)		NULL,
    [CODAmount]         DECIMAL(18,2)		NULL
);

-- PASO 4:  Crear la nueva version del  SP sps_set_finishService con los cambios realizados



