<#
    Declare SQL statements using .NET library; only returns data for SELECT statements,
	but still processes UPDATE and DELETE queries.

	Best practices dictate parameterized queries should only be executed as
	Stored Procedures.

	If making one query, use Invoke-SQL.

	If making multiple, sequential SQL statements, use SQL-Connection to open sustained connection
	to pass to Query-SQL function.
	NOTE: Remember to close the connection when done querying.

    Author: MC
    Date: 3/13/19

    Returns: PSObject array of records
#>


<#
    Opens SQL connection and executes query.
#>
function Invoke-SQL() {
    param(
        ## Environment-specific parameters
        [string] $Server = @(throw "Server must be specified."),
        [string] $Database = @(throw "Database must be specified."),
        [string] $Query = $(throw "Query must be specified.")
    )

    ## Connection parameters
    $connectionString = "Data Source=$Server; " +
                        "Integrated Security = SSPI; " +
                        "Initial Catalog=$Database"

    try {
        $connection = New-Object System.Data.SqlClient.SQLConnection($connectionString)
        $command = New-Object System.Data.SqlClient.SqlCommand($Query, $connection)
        $connection.Open()

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
        $dataSet = New-Object System.Data.DataSet
        $adapter.Fill($dataSet) | Out-Null

        $connection.Close()
        Return $dataSet.Tables
    }
    catch {
        throw "ERROR: Query execution failed."
    }
}


<#
    Opens SQL connection.
#>
function SQL-Connection() {
    param(
        [string] $Server = @(throw "Server must be specified."),
        [string] $Database = @(throw "Database must be specified."),
        [string] $Security = 'SSPI'
    )

    $connectionResources = "Data Source=$Server; " + "Integrated Security = $Security; " + "Initial Catalog=$database";

    $connection = New-Object System.Data.SqlClient.SQLConnection($connectionResources);
    return $connection
}


<#
    Executes SQL Query on open connection.
#>
function Query-SQL() {
    param(
        [PSObject] $Connection = @(throw "Connection must be established."),
        [String] $Query = $(throw "Query must be specified.")
    )

    $command = New-Object System.Data.SqlClient.SqlCommand($Query, $Connection);

    $adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command;
    $dataSet = New-Object System.Data.DataSet;
    $adapter.Fill($dataSet) | Out-Null;

    return $dataSet.Tables;
}


<#
    Get info for specific table
#>
function Describe-Table() {
    param(
        [string] $Table = @(throw 'Table must be specified.'),
        [PSObject] $Connection = @(throw 'Connection must be specified.')
    )

    $query = "exec sp_columns '{0}'" -f $Table;
    $resp = Query-SQL -Connection $Connection -Query $query;
    return $resp;
}


<#
    Close connections when no longer needed.
#>
function Close-SQL() {
    param(
        [System.Data.SqlClient.SqlConnection] $Connection = @(throw "Connection must be specified.")
    )

    $Connection.close()
}