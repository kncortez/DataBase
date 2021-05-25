DECLARE @IdTownship int
DECLARE @IdProvince int
DECLARE @HeaderCode varchar(10)

declare @IdCountry varchar(2) = 'GT'
declare @Hub varchar(3) = 'BAR'
DECLARE @Token varchar(50) = 'SYS-CAQUINO'

select @IdTownship = IdTownship
	,@IdProvince = IdProvince
	,@HeaderCode = HeaderCode
from dbo.Township
where HeaderCode ='2211'


insert into dbo.Settlement
(Settlement,SettlementSatus, IdTownship,IdProvince,IdCountry,TokenCreated,DateCreated)
VALUES ('Comapa, Comapa, Jutiapa',1,@IdTownship,@IdProvince,@IdCountry,@Token,Getdate())

DECLARE @IdCom int = SCOPE_IDENTITY()  


insert into dbo.Settlement
(Settlement,SettlementSatus, IdTownship,IdProvince,IdCountry,TokenCreated,DateCreated)
VALUES ('San cristobal Comapa, Jutiapa',1,@IdTownship,@IdProvince,@IdCountry,@Token,Getdate())

DECLARE @IdSnc int = SCOPE_IDENTITY()  

insert into dbo.Settlement
(Settlement,SettlementSatus, IdTownship,IdProvince,IdCountry,TokenCreated,DateCreated)
VALUES ('San Jose, Comapa, Jutiapa',1,@IdTownship,@IdProvince,@IdCountry,@Token,Getdate())

DECLARE @IdSnj int = SCOPE_IDENTITY()  

insert into dbo.Settlement
(Settlement,SettlementSatus, IdTownship,IdProvince,IdCountry,TokenCreated,DateCreated)
VALUES ('Guachipilin, Comapa, Jutiapa',1,@IdTownship,@IdProvince,@IdCountry,@Token,Getdate())

DECLARE @IdGch int = SCOPE_IDENTITY()  

insert into dbo.Settlement
(Settlement,SettlementSatus, IdTownship,IdProvince,IdCountry,TokenCreated,DateCreated)
VALUES ('Estanzuella, Comapa Jutiapa',1,@IdTownship,@IdProvince,@IdCountry,@Token,Getdate())

DECLARE @IdStn int = SCOPE_IDENTITY()  



DECLARE @File varchar(50) ='Coberturas v.2'
declare @Version varchar(50) = '1.0.2'

declare @Route varchar(50) =' '
declare @SDD bit =0
declare @NDD bit =1
declare @TDA bit =0


insert into DumpServiceCoverage
(DumpFileName,DumpVersion,HeaderCode,IdSettlement,Hub,RouteCode,SDD,NDD,TDA,RowStatus,TokenCreated,DateCreated)
values(@File,@Version,@HeaderCode,@IdCom,@Hub, @Route,@SDD,@NDD,@TDA,1,@Token,getdate())
	,(@File,@Version,@HeaderCode,@IdSnc,@Hub, @Route,@SDD,@NDD,@TDA,1,@Token,getdate())
	,(@File,@Version,@HeaderCode,@IdSnj,@Hub, @Route,@SDD,@NDD,@TDA,1,@Token,getdate())
	,(@File,@Version,@HeaderCode,@IdGch,@Hub, @Route,@SDD,@NDD,@TDA,1,@Token,getdate())
	,(@File,@Version,@HeaderCode,@IdStn,@Hub, @Route,@SDD,@NDD,@TDA,1,@Token,getdate())





select * from dbo.DumpServiceCoverage
where HeaderCode = @HeaderCode


