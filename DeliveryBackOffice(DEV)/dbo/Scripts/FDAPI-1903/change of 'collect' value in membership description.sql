SELECT * FROM DeliveryBackOffice.dbo.CatMembershipAttribute
WHERE MembershipAttributeDescription LIKE '%collect + Q 3.00%'

UPDATE DeliveryBackOffice.dbo.CatMembershipAttribute
SET MembershipAttributeDescription =  'El envío lo puede pagar el remitente o puedes solicitar el servicio cobrar al destinatario (collect + Q 4.00).'
,MembershipAttributeDescriptionLong = 'El envío lo puede pagar el remitente o puedes solicitar el servicio cobrar al destinatario (collect + Q 4.00).'
WHERE MembershipAttributeDescription LIKE '%collect + Q 3.00%'

SELECT * FROM DeliveryBackOffice.dbo.CatMembershipAttribute
WHERE MembershipAttributeDescription LIKE '%collect + Q 4.00%'


