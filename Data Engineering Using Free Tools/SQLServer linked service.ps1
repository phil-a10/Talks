# Get the SQL Server connection string
$sqlConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=False;User ID=$sqlServerAdminUser;Password=$sqlServerAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Need to create a linked service in ADF
# This is just a way of connecting to a data source

# Create a linked service JSON file for SQL Database
$sqlProperties = @{
    type = "AzureSqlDatabase"
    typeProperties = @{
        connectionString = "$sqlConnectionString"
    }
}|ConvertTo-Json | Out-File -FilePath "linkedServiceSql.json"

# Create a Data Factory linked service to the SQL Database
az datafactory linked-service create --resource-group $resourceGroup --factory-name "adfdataengfree" --name "sql database adf demo" --properties "linkedServiceSql.json"

# Get the SQL Server connection string
$sqlConnectionString = "Server=tcp:$sqlServerName.database.windows.net,1433;Initial Catalog=$sqlDatabaseName;Persist Security Info=False;User ID=$sqlServerAdminUser;Password=$sqlServerAdminPassword;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

# Need to create a linked service in ADF
# This is just a way of connecting to a data source

# Create a linked service JSON file for SQL Database
$sqlProperties = @{
    type = "AzureSqlDatabase"
    typeProperties = @{
        connectionString = "$sqlConnectionString"
    }
}|ConvertTo-Json | Out-File -FilePath "linkedServiceSql.json"

# Create a Data Factory linked service to the SQL Database
az datafactory linked-service create --resource-group $resourceGroup --factory-name "adfdataengfree" --name "sql database adf demo" --properties "linkedServiceSql.json"
