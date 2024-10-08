
UPDATE CatProductSubCategory
SET ProductSubCategoryParentId = 3
WHERE IdCatProductSubCategory IN (4,5);

UPDATE CatProductSubCategory
SET ProductSubCategoryParentId = 1
WHERE IdCatProductSubCategory IN (9,10);

UPDATE CatProductSubCategory
SET ProductSubCategoryParentId = 2
WHERE IdCatProductSubCategory IN (11);

UPDATE CatProductSubCategory
SET ProductSubCategoryParentId = 6
WHERE IdCatProductSubCategory IN (12);


UPDATE CatProductSubCategory
SET Icon = 'fas fa-microscope'
WHERE IdCatProductSubCategory =1

UPDATE CatProductSubCategory
SET Icon = 'fas fa-book'
WHERE IdCatProductSubCategory =2

UPDATE CatProductSubCategory
SET Icon = 'fas fa-tshirt'
WHERE IdCatProductSubCategory =3

UPDATE CatProductSubCategory
SET Icon = 'fas fa-couch'
WHERE IdCatProductSubCategory =6

UPDATE CatProductSubCategory
SET Icon = 'fas fa-book'
WHERE IdCatProductSubCategory =7

UPDATE CatProductSubCategory
SET Icon = 'fas fa-tshirt'
WHERE IdCatProductSubCategory =8