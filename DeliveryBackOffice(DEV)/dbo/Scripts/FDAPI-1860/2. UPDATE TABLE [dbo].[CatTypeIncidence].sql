--Cambio de nombre de incidencia : Destinatario no presentó documento de identificación
UPDATE DeliveryBackOffice.dbo.CatTypeIncidence
SET NameIncidence = 'No cumple requisito para entrega' --Destinatario no presentó documento de identificación
,DescriptionIncidence = 'No cumple requisito para entrega' --Destinatario no presentó documento de identificación
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated =  GETDATE()
WHERE ServiceType = 'DELIVERY'
AND RowStatus = 1
AND NameIncidence = 'Destinatario no presentó documento de identificación'

SELECT * FROM DeliveryBackOffice.dbo.CatTypeIncidence
WHERE ServiceType = 'DELIVERY'
AND RowStatus = 1
AND 
(NameIncidence = 'Destinatario no presentó documento de identificación'
OR NameIncidence = 'No cumple requisito para entrega'
)

--Inhabilitar incidencias Paquete dañado y Paquete extraviado
UPDATE DeliveryBackOffice.dbo.CatTypeIncidence
SET RowStatus = 0
,TokenUpdated = 'SYS-BHERRERA'
,DateUpdated =  GETDATE()
WHERE ServiceType = 'DELIVERY'
AND RowStatus = 1
AND 
(
 NameIncidence = 'Paquete dañado'
 OR NameIncidence = 'Paquete extraviado'
)

SELECT * FROM DeliveryBackOffice.dbo.CatTypeIncidence
WHERE ServiceType = 'DELIVERY'
AND RowStatus = 0
AND 
(
 NameIncidence = 'Paquete dañado'
 OR NameIncidence = 'Paquete extraviado'
)

--Ingresar tipo de incidencia Paquete con problema
INSERT INTO DeliveryBackOffice.dbo.CatTypeIncidence
(
    NameIncidence,
    DescriptionIncidence,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    ServiceType,
    OrderId,
    Code,
    IncidenceClasificationId,
    IsForcedIncidence,
    ValidatesLocation,
    HasConfirmationProcess,
    NotifiesOrigin
)
VALUES
(   'Paquete con problema',      -- NameIncidence - varchar(200)
    'Paquete con problema',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-BHERRERA',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(25)
    1,      -- OrderId - int
    NULL,      -- Code - int
    NULL,      -- IncidenceClasificationId - int
    1,   -- IsForcedIncidence - bit
    0,   -- ValidatesLocation - bit
    0,   -- HasConfirmationProcess - bit
    0-- NotifiesOrigin - bit
    )

SELECT * FROM DeliveryBackOffice.dbo.CatTypeIncidence
WHERE ServiceType = 'DELIVERY'
AND RowStatus = 1
AND NameIncidence = 'Paquete con problema'