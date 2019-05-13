use Boston
go
CREATE OR ALTER PROCEDURE generate_housing_model (@trained_model varbinary(max) OUTPUT)  
AS  
BEGIN  
EXEC sp_execute_external_script @language = N'Python',  
@script = N'  
import pickle  
from sklearn.linear_model import LinearRegression
model = LinearRegression()  
trained_model = pickle.dumps(model.fit(housing[[0]], housing[[1]]))  
'  
, @input_data_1 = N'select "RM", "Price" from housing'  
, @input_data_1_name = N'housing'  
, @params = N'@trained_model varbinary(max) OUTPUT'  
, @trained_model = @trained_model OUTPUT;  
END;  
GO 

/*
The pickle module implements a fundamental, but powerful algorithm for serializing 
and de-serializing a Python object structure. 
“Pickling” is the process whereby a Python object hierarchy is converted into a byte stream, 
and “unpickling” is the inverse operation, whereby a byte stream is converted back 
into an object hierarchy. 
*/

create table housing_models
(
	id int identity not null,
	model_name sysname,
	model varbinary(max),
	created datetime default (getdate()),
	iscurrent bit default(1)
)
go

DECLARE @model varbinary(max);
DECLARE @new_model_name varchar(50)
SET @new_model_name = 'Linear Regression'
EXEC generate_housing_model @model OUTPUT;

UPDATE housing_models 
SET iscurrent=0 where iscurrent=1 and model_name = @new_model_name;


INSERT INTO housing_models (model_name, model) values(@new_model_name, @model);
GO
SELECT  [id]
      ,[model_name]
      ,[model]
      ,[created]
      ,[iscurrent]
  FROM [Boston].[dbo].[housing_models] (NOLOCK)
GO


CREATE OR ALTER PROCEDURE predict_housing 
AS
BEGIN
DECLARE @nb_model varbinary(max) = (SELECT model FROM housing_models WHERE iscurrent=1);
EXEC sp_execute_external_script @language = N'Python', 
@script = N'
import pickle
model = pickle.loads(nb_model)
price_pred = model.predict(housing[[1]])
housing["PredictedPrice"] = price_pred
OutputDataSet = housing[[0,1,2,3]] 
print(OutputDataSet)
'
, @input_data_1 = N'select id, "RM", "Price" from housing'
, @input_data_1_name = N'housing'
, @params = N'@nb_model varbinary(max)'
, @nb_model = @nb_model
WITH RESULT SETS ( ("id" int, "RM" float, "Price" float, "PredictedPrice" float));
END;
GO