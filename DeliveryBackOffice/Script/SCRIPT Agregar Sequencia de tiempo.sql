UPDATE  dbo.CatPaymentTime
set TimeSequence = 10
where TimePlaAbrev = 'AHR'

UPDATE  dbo.CatPaymentTime
set TimeSequence = 20
where TimePlaAbrev = 'RECL'

UPDATE  dbo.CatPaymentTime
set TimeSequence = 30
where TimePlaAbrev = 'DEST'

UPDATE  dbo.CatPaymentTime
set TimeSequence = 40
where TimePlaAbrev = 'POST'

select * from dbo.CatPaymentTime