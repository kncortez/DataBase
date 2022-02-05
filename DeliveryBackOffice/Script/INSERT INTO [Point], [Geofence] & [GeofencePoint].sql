
INSERT INTO Point
(PointDescription,PointLatitude,PointLongitude,RowStatus,TokenCreated,DateCreated)
VALUES
('Inferior izquierda Guatemala',13.589935,-92.623744,1,'SYS-ARUIZ',GETDATE()),
('Inferior derecha Guatemala',13.479813,-88.252170,1,'SYS-ARUIZ',GETDATE()),
('Superior izquierda Guatemala',18.006084, -92.154269,1,'SYS-ARUIZ',GETDATE()),
('Superior derecha Guatemala',17.945424, -88.057472,1,'SYS-ARUIZ',GETDATE())

INSERT INTO Geofence 
(CountryId,GeofenceDescription,RowStatus,TokenCreated,DateCreated)
VALUES ('GT','Guatemala',1,'SYS-ARUIZ',GETDATE())

INSERT INTO GeofencePoint 
(IdGeofence,IdPoint,GeofencePointOrder,RowStatus,TokenCreated,DateCreated)
VALUES 
(1,3,1,1,'SYS-ARUIZ',GETDATE()),
(1,4,2,1,'SYS-ARUIZ',GETDATE()),
(1,2,3,1,'SYS-ARUIZ',GETDATE()),
(1,1,4,1,'SYS-ARUIZ',GETDATE()),
(1,3,5,1,'SYS-ARUIZ',GETDATE())
