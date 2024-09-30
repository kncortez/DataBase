INSERT INTO KindOfVPClient
(
    KindOfVPName,
    KindOfVPStatus,
    TokenCreated,
    DateCreated,
    TokenUpdate,
    DateUpdated,
    IdCountry
)
SELECT KindOfVPName,
       KindOfVPStatus,
       TokenCreated,
       GETDATE(),
       NULL,
       NULL,
       'HN'
FROM KindOfVPClient


INSERT INTO KindOfVPBusiness
(
    KindOfVPNameBussiness,
    Shorthand,
    StatusKindOfVPBusiness,
    TokenCreated,
    DateCreated,
    TokenUpdate,
    DateUpdated,
    IdCountry
)
SELECT KindOfVPNameBussiness,
       Shorthand,
       StatusKindOfVPBusiness,
       TokenCreated,
       GETDATE(),
       NULL,
       NULL,
       'HN'
FROM KindOfVPBusiness