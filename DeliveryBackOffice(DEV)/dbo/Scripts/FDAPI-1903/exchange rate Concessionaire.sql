DECLARE @IdRate INT = 0
SELECT * FROM DeliveryBackOffice.dbo.Customer
WHERE IdCustomer = 84

SELECT @IdRate= A1.RbcIdRate FROM DeliveryBackOffice.dbo.RatebyCustomer A1
WHERE RbcIdCustomer = 84

select * from DeliveryBackOffice.dbo.RateHeader
where RheId = @IdRate

select * from DeliveryBackOffice.dbo.RateCOD
where RateId = @IdRate

update DeliveryBackOffice.dbo.RateHeader
set CollectRate = 4 --3
where RheId = @IdRate

update DeliveryBackOffice.dbo.RateCOD
set CODRate = 3.8 --3.5 A 2
where RateId = @IdRate

select * from DeliveryBackOffice.dbo.RateHeader
where RheId = @IdRate

select * from DeliveryBackOffice.dbo.RateCOD
where RateId = @IdRate

