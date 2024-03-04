UPDATE DeliveryBackOffice.dbo.CatMembershipDescription
SET Description = 'Es un club de beneficios para impulsar a emprendedores y clientes que realizan envíos frecuentes, premiando su preferencia a través de descuentos, beneficios y acceso a paquetes de Guías prepago con tarifa única a todo el pais.'
WHERE Title = '¿Qué es?' AND RowStatus = 1

UPDATE DeliveryBackOffice.dbo.CatMembershipDescription
SET Description = 'Adquiere tu membresia por Q 1.00 al Club Forza y podras obtener acumula puntos para envíos gratis y otros beneficios en comercios afiliados.'
WHERE Title = '¿Cómo Funciona?' AND RowStatus = 1

UPDATE DeliveryBackOffice.dbo.CatMembershipDescription
SET Description = 'Acumulación de puntos para envíos gratis.;Beneficios en comercios Afiliados;Recolecciones SIN COSTO.;Envío de devoluciones SIN COSTO.;Pagos de reclamo en 24 horas.'
WHERE Title = '¿Qué otros Beneficios obtienes?' AND RowStatus = 1

UPDATE DeliveryBackOffice.dbo.CatMembershipDescription
SET Description = 'Puedes comprar el plan amigo que te brinda 10% de descuento en tus envíos ó puedes comprar paquetes de guías prepagadas que más te convenga según el volumen de envíos que realices para obtener precio con tárifa unica a todo el pais.'
WHERE Title = 'Disfruta de más beneficios' AND RowStatus = 1
 
 -- Quitar atributos existentes 
UPDATE DeliveryBackOffice.dbo.CatMembershipAttribute
SET RowStatus = 0
WHERE RowStatus = 1
 INSERT INTO DeliveryBackOffice.dbo.CatMembershipAttribute
(
    CatMembershipId,
    CatAttributeId,
    MembershipAttributeValue,
    MembershipAttributeDescription,
    MembershipAttributePosition,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    MembershipAttributeDescriptionLong
)
VALUES
(   1,         -- CatMembershipId - int
    1,         -- CatAttributeId - int
    N'1',       -- MembershipAttributeValue - nvarchar(50)
    'Acumulación de puntos para envíos gratis.',      -- MembershipAttributeDescription - nvarchar(300)
    1,         -- MembershipAttributePosition - int
    1,   -- RowStatus - bit
    N'SYS-BHERRERA',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime   
	NULL,
	NULL,
    'Acumulación de puntos para envíos gratis.'       -- MembershipAttributeDescriptionLong - nvarchar(500)
    )


INSERT INTO DeliveryBackOffice.dbo.CatMembershipAttribute
(
    CatMembershipId,
    CatAttributeId,
    MembershipAttributeValue,
    MembershipAttributeDescription,
    MembershipAttributePosition,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    MembershipAttributeDescriptionLong
)
VALUES
(   1,         -- CatMembershipId - int
    1,         -- CatAttributeId - int
    N'1',       -- MembershipAttributeValue - nvarchar(50)
    'Beneficios en comercios Afiliados',      -- MembershipAttributeDescription - nvarchar(300)
    2,         -- MembershipAttributePosition - int
    1,   -- RowStatus - bit
    N'SYS-BHERRERA',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime    
	NULL,
	NULL,
    'Beneficios en comercios Afiliados'       -- MembershipAttributeDescriptionLong - nvarchar(500)
    )

INSERT INTO DeliveryBackOffice.dbo.CatMembershipAttribute
(
    CatMembershipId,
    CatAttributeId,
    MembershipAttributeValue,
    MembershipAttributeDescription,
    MembershipAttributePosition,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    MembershipAttributeDescriptionLong
)
VALUES
(   1,         -- CatMembershipId - int
    1,         -- CatAttributeId - int
    N'1',       -- MembershipAttributeValue - nvarchar(50)
    'Recolecciones SIN COSTO.',      -- MembershipAttributeDescription - nvarchar(300)
    3,         -- MembershipAttributePosition - int
    1,   -- RowStatus - bit
    N'SYS-BHERRERA',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime    
    NULL,
	NULL,
	'Recolecciones SIN COSTO.'       -- MembershipAttributeDescriptionLong - nvarchar(500)
    )

INSERT INTO DeliveryBackOffice.dbo.CatMembershipAttribute
(
    CatMembershipId,
    CatAttributeId,
    MembershipAttributeValue,
    MembershipAttributeDescription,
    MembershipAttributePosition,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    MembershipAttributeDescriptionLong
)
VALUES
(   1,         -- CatMembershipId - int
    1,         -- CatAttributeId - int
    N'1',       -- MembershipAttributeValue - nvarchar(50)
    'Envío de devoluciones SIN COSTO.',      -- MembershipAttributeDescription - nvarchar(300)
    4,         -- MembershipAttributePosition - int
    1,   -- RowStatus - bit
    N'SYS-BHERRERA',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime 
	NULL,
	NULL,
    'Envío de devoluciones SIN COSTO.'       -- MembershipAttributeDescriptionLong - nvarchar(500)
    )

INSERT INTO DeliveryBackOffice.dbo.CatMembershipAttribute
(
    CatMembershipId,
    CatAttributeId,
    MembershipAttributeValue,
    MembershipAttributeDescription,
    MembershipAttributePosition,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    MembershipAttributeDescriptionLong
)
VALUES
(   1,         -- CatMembershipId - int
    1,         -- CatAttributeId - int
    N'1',       -- MembershipAttributeValue - nvarchar(50)
    'Pagos de reclamo en 24 horas.',      -- MembershipAttributeDescription - nvarchar(300)
    5,         -- MembershipAttributePosition - int
    1,   -- RowStatus - bit
    N'SYS-BHERRERA',       -- TokenCreated - nvarchar(50)
    GETDATE(), -- DateCreated - datetime    
	NULL,
	NULL,
    'Pagos de reclamo en 24 horas.'       -- MembershipAttributeDescriptionLong - nvarchar(500)
    )



ALTER TABLE dbo.Membership ADD
	ActivationDate datetime NULL
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de activación del producto'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Membership', N'COLUMN', N'ActivationDate'

ALTER TABLE dbo.Subscription ADD
	ActivationDate datetime NULL
GO
DECLARE @v sql_variant 
SET @v = N'Fecha de activación del producto'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Subscription', N'COLUMN', N'ActivationDate'