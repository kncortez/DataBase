UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Dirección y teléfono incorrecto', DescriptionIncidence = 'Dirección y teléfono incorrecto', ServiceType = 'PICKUP', OrderId = 1
WHERE	IdIncidenceType = 1 

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Información incompleta', DescriptionIncidence = 'Información incompleta', ServiceType = 'PICKUP', OrderId = 2
WHERE	IdIncidenceType = 2

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Fuera de horario', DescriptionIncidence = 'Fuera de horario', ServiceType = 'PICKUP', OrderId = 3
WHERE	IdIncidenceType = 3

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Exceso de capacidad del vehículo', DescriptionIncidence = 'Exceso de capacidad del vehículo', ServiceType = 'PICKUP', OrderId = 4
WHERE	IdIncidenceType = 4 

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Paquetería no conforme', DescriptionIncidence = 'Paquetería no conforme', ServiceType = 'PICKUP', OrderId = 5
WHERE	IdIncidenceType = 5

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Retiro por tiempo de estadía', DescriptionIncidence = 'Retiro por tiempo de estadía', ServiceType = 'PICKUP', OrderId = 6
WHERE	IdIncidenceType = 6

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Otro', DescriptionIncidence = 'Otro', ServiceType = 'PICKUP', OrderId = 7
WHERE	IdIncidenceType = 7 
---------------------------------------------------------------------- RETURN -----------------------------------------------------------------------------------------------------------
UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Dirección y teléfono incorrecto', DescriptionIncidence = 'Dirección y teléfono incorrecto', ServiceType = 'RETURN', OrderId = 1
WHERE	IdIncidenceType = 8 

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Información incompleta', DescriptionIncidence = 'Información incompleta', ServiceType = 'RETURN', OrderId = 2
WHERE	IdIncidenceType = 9

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Fuera de horario', DescriptionIncidence = 'Fuera de horario', ServiceType = 'RETURN', OrderId = 3
WHERE	IdIncidenceType = 10

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Exceso de capacidad del vehículo', DescriptionIncidence = 'Exceso de capacidad del vehículo', ServiceType = 'RETURN', OrderId = 4
WHERE	IdIncidenceType = 11 

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Paquetería no conforme', DescriptionIncidence = 'Paquetería no conforme', ServiceType = 'RETURN', OrderId = 5
WHERE	IdIncidenceType = 12

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Retiro por tiempo de estadía', DescriptionIncidence = 'Retiro por tiempo de estadía', ServiceType = 'RETURN', OrderId = 6
WHERE	IdIncidenceType = 13

UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'Otro', DescriptionIncidence = 'Otro', ServiceType = 'RETURN', OrderId = 7
WHERE	IdIncidenceType = 14 
 
 ----------------------------------------------------- Delivery ------------------------------------------------------------------------------------
 
UPDATE dbo.CatTypeIncidence 
SET NameIncidence = 'No hay nadie en destino', DescriptionIncidence = 'No hay nadie en destino', ServiceType = 'DELIVERY', OrderId = 1
WHERE	IdIncidenceType = 15 


INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Dirección y teléfono incorrecto',      -- NameIncidence - varchar(200)
    'Dirección y teléfono incorrecto',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    2,      -- OrderId - int
    NULL       -- Code - int
    ) 


	
INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Información incompleta',      -- NameIncidence - varchar(200)
    'Información incompleta',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    3,      -- OrderId - int
    NULL       -- Code - int
    ) 


		
INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Cliente no dejó documento (IGSS)',      -- NameIncidence - varchar(200)
    'Cliente no dejó documento (IGSS)',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    4,      -- OrderId - int
    NULL       -- Code - int
    ) 

INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Cliente no tiene dinero',      -- NameIncidence - varchar(200)
    'Cliente no tiene dinero',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    5,      -- OrderId - int
    NULL       -- Code - int
    ) 

	INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Cliente no realizó pedido',      -- NameIncidence - varchar(200)
    'Cliente no realizó pedido',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    6,      -- OrderId - int
    NULL       -- Code - int
    ) 

	INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Cliente solicita otra fecha de entrega',      -- NameIncidence - varchar(200)
    'Cliente solicita otra fecha de entrega',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    7,      -- OrderId - int
    NULL       -- Code - int
    ) 


		INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Pedido duplicado',      -- NameIncidence - varchar(200)
    'Pedido duplicado',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    Null,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    8,      -- OrderId - int
    NULL       -- Code - int
    ) 

		INSERT INTO	dbo.CatTypeIncidence
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
    Code
)
VALUES
(   'Otro',      -- NameIncidence - varchar(200)
    'Otro',      -- DescriptionIncidence - varchar(200)
    1,      -- RowStatus - bit
    'SYS-HGOMEZ',        -- TokenCreated - varchar(50)
    GETDATE(), -- DateCreated - datetime
    NULL,      -- TokenUpdated - varchar(50)
    NULL,      -- DateUpdated - datetime
    'DELIVERY',      -- ServiceType - nvarchar(10)
    9,      -- OrderId - int
    NULL       -- Code - int
    ) 




SELECT * FROM dbo.CatTypeIncidence