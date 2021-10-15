-- Inserta los nuevos catalogos en la tabla que tiene configurado los catalogos por modulo

INSERT INTO DeliveryBackOffice.dbo.CatalogbyModule
(
NameCatalog,
ModuleID,
SystemID,
RowStatus,
TokenCreated,
DateCreated
)
VALUES
(
'BatchTypeCOD',
22,
2,
1,
'SYS-MESPINOZA',
GETDATE()
),
(
'BatchFrequencyCOD',
22,
2,
1,
'SYS-MESPINOZA',
GETDATE()
)

SELECT * FROM DeliveryBackOffice.dbo.CatalogbyModule WHERE ModuleID=22
