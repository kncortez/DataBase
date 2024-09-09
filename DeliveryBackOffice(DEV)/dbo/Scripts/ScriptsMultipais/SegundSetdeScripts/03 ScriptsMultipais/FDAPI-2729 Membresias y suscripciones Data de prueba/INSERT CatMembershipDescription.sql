--pendiente
DECLARE @CatMembershipId INT = (SELECT IdCatMembership FROM CatMembership WHERE MembershipName = 'Club Forza' AND IdCountry = 'HN')

INSERT INTO CatMembershipDescription (Title,Description, Position, Type,CatMembershipId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Que es?',
	   'La membresía del Club Forza es un exclusivo programa de beneficios diseñado para fidelizar a nuestros clientes que realizan envíos frecuentes. Reconocemos y premiamos la preferencia con acumulación de puntos y beneficios en comercios afiliados. Únete al Club Forza y disfruta de los beneficios que Forza te puede brindar.',
	   1,'TELEMERCADEO',@CatMembershipId,1,GETDATE(),'SYS-JOCHOA'),
	  ('¿Cómo Funciona?',
	   'Al unirte al Club Forza con tu membresia por L63.87 al Club Forza, obtienes acceso instántaneo a una serie de beneficios exclusivos. Simplemente realiza tus envíos como de costumbre y automáticamente recibirás acumulación de puntos para envíos gratis. Además, disfrutarás de beneficios adicionales como promociones en comercios afiliados. ¡Únete hoy mismo y comienza a aprovechar todas las ventajas que ofrece el Club Forza!',
	   2,'TELEMERCADEO',@CatMembershipId,1,GETDATE(),'SYS-EVASQUEZ')