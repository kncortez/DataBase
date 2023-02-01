-- Script FDAPI-1310
CREATE TABLE CatMembershipDescription(
	IdCatMembershipDescription INT IDENTITY(1,1) NOT NULL,

	Title NVARCHAR(100) NOT NULL,
	Description NVARCHAR(500) NOT NULL,
	Position INT NOT NULL,
	Type NVARCHAR(50) NOT NULL,

	CatMembershipId INT NOT NULL,

	RowStatus BIT NOT NULL,
	DateCreated DateTime NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DateTime NULL,
	TokenUpdated NVARCHAR(50) NULL

	PRIMARY KEY(IdCatMembershipDescription),
	CONSTRAINT FK_CatMembership_CatMembershipDescription FOREIGN KEY (CatMembershipId) REFERENCES CatMembership(IdCatMembership),
);

INSERT INTO [dbo].[CatMembershipDescription]	([Title],
												[Description],
												[Position],
												[Type],
												[CatMembershipId], 
												[RowStatus],
												[DateCreated],
												[TokenCreated])
VALUES											('Club Forza',
												'Es una membresía para emprendedores y Mi Pymes que te da beneficios y accesos exclusivos a promociones y descuentos, recolecciones sin costo y con frecuencia programada de visita.',
												1,
												'TELEMERCADEO',
												1,
												1,
												SYSDATETIME(),
												'SYS-JOCHOA');

INSERT INTO [dbo].[CatMembershipDescription]	([Title],
												[Description],
												[Position],
												[Type],
												[CatMembershipId], 
												[RowStatus],
												[DateCreated],
												[TokenCreated])
VALUES											('¿Quieres más Descuentos?',
												'Al ser miembro del Club Forza podrás adquirir suscripciones mensuales que te brindan paquetes de envíos cada vez mas económicos.',
												2,
												'TELEMERCADEO',
												1,
												1,
												SYSDATETIME(),
												'SYS-JOCHOA');

CREATE TABLE CatSubscriptionDescription(
	IdCatSubscriptionDescription INT IDENTITY(1,1) NOT NULL,

	Title NVARCHAR(100) NOT NULL,
	Description NVARCHAR(500) NOT NULL,
	Position INT NOT NULL,
	Type NVARCHAR(50) NOT NULL,

	CatSubscriptionId INT NOT NULL,

	RowStatus BIT NOT NULL,
	DateCreated DateTime NOT NULL,
	TokenCreated NVARCHAR(50) NOT NULL,
	DateUpdated DateTime NULL,
	TokenUpdated NVARCHAR(50) NULL

	PRIMARY KEY(IdCatSubscriptionDescription),
	CONSTRAINT FK_CatSubscription_CatSubscriptionDescription FOREIGN KEY (CatSubscriptionId) REFERENCES CatSubscription(IdCatSubscription),
);