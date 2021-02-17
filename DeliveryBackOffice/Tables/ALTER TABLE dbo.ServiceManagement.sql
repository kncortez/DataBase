ALTER TABLE dbo.ServiceManagement ADD ServiceStatusId INT NULL ;

ALTER TABLE ServiceManagement 
   ADD CONSTRAINT fk_ServiceStatus
   FOREIGN KEY (ServiceStatusId) 
   REFERENCES CatServiceStatus(IdServiceStatus);


select * from  dbo.ServiceManagement