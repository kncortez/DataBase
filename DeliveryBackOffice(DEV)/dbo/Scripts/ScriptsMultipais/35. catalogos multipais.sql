INSERT INTO CatTypeOfBusiness
(
    TypeOfBusinessName,
    TypeOfBusinessDescription,
    CountryID,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
select TypeOfBusinessName,
       TypeOfBusinessDescription,
       'HN',
       RowStatus,
       'SYS-BPEDROZA',
       GETDATE(),
       NULL,
       NULL
from CatTypeOfBusiness

INSERT INTO CatSaleAdvisor
(
    SaleAdvisorCode,
    SaleAdvisorDescription,
    EmployeID,
    SAPSellerID,
    CountryID,
    SaleAdvisorStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated
)
select SaleAdvisorCode,
       SaleAdvisorDescription,
       EmployeID,
       SAPSellerID,
       'HN',
       SaleAdvisorStatus,
       'SYS-BPEDROZA',
       GETDATE(),
       TokenUpdated,
       DateUpdated
from CatSaleAdvisor

INSERT INTO CatBusinessSegment
(
    BusinessSegmentName,
    BusinessSegmentDescription,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    IdCountry
)
SELECT BusinessSegmentName,
       BusinessSegmentDescription,
       RowStatus,
       'SYS-BPEDROZA',
       GETDATE(),
       NULL,
       NULL,
       'HN'
FROM CatBusinessSegment